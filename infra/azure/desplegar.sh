#!/usr/bin/env bash
# Crea y actualiza la infraestructura de Brain Test en Azure (sección 3.15 del reporte técnico):
# App Service (contenedor FastAPI) + Azure Database for PostgreSQL + Blob Storage.
#
# Uso: infra/azure/desplegar.sh <paso>
#   grupo | postgres | storage | registro | imagen | webapp | modelo | estado
# Cada paso se puede repetir sin duplicar recursos. Requiere `az login` previo.
set -euo pipefail

RAIZ="$(cd "$(dirname "$0")/../.." && pwd)"
SECRETOS="$RAIZ/infra/azure/.secretos.env"

REGION="${REGION:-mexicocentral}"
GRUPO="${GRUPO:-rg-braintest}"
PLAN="${PLAN:-plan-braintest}"
PLAN_SKU="${PLAN_SKU:-B1}"
PG_SKU="${PG_SKU:-Standard_B1ms}"
PG_VERSION="${PG_VERSION:-17}"
BD="braintest"
PG_USUARIO="braintest_admin"

# Sufijo único y estable para los nombres que son globales en Azure; se genera una sola vez.
touch "$SECRETOS" && chmod 600 "$SECRETOS"
# shellcheck disable=SC1090
source "$SECRETOS"
guardar() { grep -q "^$1=" "$SECRETOS" || echo "$1='$2'" >> "$SECRETOS"; }
if [ -z "${SUFIJO:-}" ]; then SUFIJO="$(openssl rand -hex 3)"; guardar SUFIJO "$SUFIJO"; fi
if [ -z "${PG_CLAVE:-}" ]; then PG_CLAVE="$(openssl rand -base64 30 | tr -dc 'A-Za-z0-9' | cut -c1-28)"; guardar PG_CLAVE "$PG_CLAVE"; fi
if [ -z "${SECRET_KEY:-}" ]; then SECRET_KEY="$(openssl rand -hex 48)"; guardar SECRET_KEY "$SECRET_KEY"; fi

PG_SERVIDOR="pg-braintest-$SUFIJO"
CUENTA="stbraintest$SUFIJO"
REGISTRO="acrbraintest$SUFIJO"
WEBAPP="api-braintest-$SUFIJO"
IMAGEN="braintest-api"

paso_grupo() {
  az group create --name "$GRUPO" --location "$REGION" --output none
  echo "Grupo de recursos $GRUPO en $REGION"
}

paso_postgres() {
  if ! az postgres flexible-server show -g "$GRUPO" -n "$PG_SERVIDOR" --output none 2>/dev/null; then
    az postgres flexible-server create -g "$GRUPO" -n "$PG_SERVIDOR" --location "$REGION" \
      --tier Burstable --sku-name "$PG_SKU" --storage-size 32 --version "$PG_VERSION" \
      --admin-user "$PG_USUARIO" --admin-password "$PG_CLAVE" \
      --public-access 0.0.0.0 --backup-retention 7 --yes --output none
  fi
  az postgres flexible-server db create -g "$GRUPO" -s "$PG_SERVIDOR" -d "$BD" --output none
  echo "PostgreSQL $PG_SERVIDOR.postgres.database.azure.com, base $BD (solo acepta TLS)"
}

cadena_storage() {
  az storage account show-connection-string -g "$GRUPO" -n "$CUENTA" --query connectionString -o tsv
}

paso_storage() {
  az storage account create -g "$GRUPO" -n "$CUENTA" --location "$REGION" --sku Standard_LRS \
    --kind StorageV2 --min-tls-version TLS1_2 --allow-blob-public-access false --output none
  local cadena; cadena="$(cadena_storage)"
  az storage container create --name modelos --connection-string "$cadena" --output none
  az storage container create --name reportes --connection-string "$cadena" --output none
  echo "Cuenta de almacenamiento $CUENTA con contenedores privados: modelos, reportes"
}

paso_modelo() {
  # Publica en el registro la versión incluida en el repositorio (por omisión v01).
  local version="${1:-v01}"
  AZURE_STORAGE_CONNECTION_STRING="$(cadena_storage)" \
    "$RAIZ/backend/venv/bin/python" "$RAIZ/mlops/publicar_modelo.py" --version "$version"
}

paso_registro() {
  az acr create -g "$GRUPO" -n "$REGISTRO" --location "$REGION" --sku Basic --admin-enabled true --output none
  echo "Registro de contenedores $REGISTRO.azurecr.io"
}

paso_imagen() {
  # Construye para linux/amd64 (la arquitectura de App Service) y sube la imagen con la etiqueta del commit.
  local etiqueta; etiqueta="$(git -C "$RAIZ" rev-parse --short HEAD)-$(date +%Y%m%d%H%M)"
  az acr login -n "$REGISTRO"
  docker buildx build --platform linux/amd64 -t "$REGISTRO.azurecr.io/$IMAGEN:$etiqueta" \
    -t "$REGISTRO.azurecr.io/$IMAGEN:latest" --push "$RAIZ/backend"
  echo "$etiqueta" > "$RAIZ/infra/azure/.ultima_imagen"
  echo "Imagen $REGISTRO.azurecr.io/$IMAGEN:$etiqueta"
}

paso_webapp() {
  local etiqueta; etiqueta="$(cat "$RAIZ/infra/azure/.ultima_imagen")"
  local imagen="$REGISTRO.azurecr.io/$IMAGEN:$etiqueta"
  az appservice plan create -g "$GRUPO" -n "$PLAN" --location "$REGION" --is-linux --sku "$PLAN_SKU" --output none
  if ! az webapp show -g "$GRUPO" -n "$WEBAPP" --output none 2>/dev/null; then
    az webapp create -g "$GRUPO" -p "$PLAN" -n "$WEBAPP" --container-image-name "$imagen" \
      --container-registry-user "$REGISTRO" \
      --container-registry-password "$(az acr credential show -n "$REGISTRO" --query 'passwords[0].value' -o tsv)" \
      --output none
  else
    az webapp config container set -g "$GRUPO" -n "$WEBAPP" --container-image-name "$imagen" --output none
  fi
  az webapp config appsettings set -g "$GRUPO" -n "$WEBAPP" --output none --settings \
    WEBSITES_PORT=8000 \
    DATABASE_URL="postgresql://$PG_USUARIO:$PG_CLAVE@$PG_SERVIDOR.postgres.database.azure.com:5432/$BD?sslmode=require" \
    SECRET_KEY="$SECRET_KEY" \
    CORS_ORIGINS="" \
    MODEL_VERSION="${MODEL_VERSION:-v01}" \
    AZURE_STORAGE_CONNECTION_STRING="$(cadena_storage)"
  az webapp update -g "$GRUPO" -n "$WEBAPP" --https-only true --output none
  az webapp config set -g "$GRUPO" -n "$WEBAPP" --always-on true --min-tls-version 1.2 \
    --generic-configurations '{"healthCheckPath": "/api/health"}' --output none
  echo "API en https://$WEBAPP.azurewebsites.net/api"
}

paso_estado() {
  echo "Recursos en $GRUPO:"
  az resource list -g "$GRUPO" --query "[].{nombre:name, tipo:type}" -o table
  echo
  curl -s -m 30 "https://$WEBAPP.azurewebsites.net/api/health" || true
  echo
  curl -s -m 60 "https://$WEBAPP.azurewebsites.net/api/modelo/info" || true
  echo
}

case "${1:-}" in
  grupo) paso_grupo ;;
  postgres) paso_postgres ;;
  storage) paso_storage ;;
  modelo) paso_modelo "${2:-v01}" ;;
  registro) paso_registro ;;
  imagen) paso_imagen ;;
  webapp) paso_webapp ;;
  estado) paso_estado ;;
  *) sed -n '2,8p' "$0"; exit 1 ;;
esac
