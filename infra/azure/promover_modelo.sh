#!/usr/bin/env bash
# Pone en servicio una versión del modelo ya publicada en el registro (o regresa a una anterior).
# Uso: infra/azure/promover_modelo.sh v02
set -euo pipefail

RAIZ="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck disable=SC1091
source "$RAIZ/infra/azure/.secretos.env"
GRUPO="${GRUPO:-rg-braintest}"
WEBAPP="api-braintest-$SUFIJO"
VERSION="${1:?indique la versión, por ejemplo v02}"

az webapp config appsettings set -g "$GRUPO" -n "$WEBAPP" --settings MODEL_VERSION="$VERSION" --output none
az webapp restart -g "$GRUPO" -n "$WEBAPP"
echo "Esperando a que el servicio reinicie..."
sleep 45
curl -s -m 90 "https://$WEBAPP.azurewebsites.net/api/modelo/info"
echo
