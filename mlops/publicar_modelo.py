"""Sube una versión del modelo al registro en Blob Storage. Uso: python mlops/publicar_modelo.py --version v02 --carpeta DIR

Requiere AZURE_STORAGE_CONNECTION_STRING. Las versiones son inmutables: no se sobrescribe una que ya existe.
Para ponerla en servicio se cambia MODEL_VERSION en App Service (infra/azure/promover_modelo.sh)."""
import argparse
import os
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(RAIZ / "backend" / "app" / "ml"))

import modelo_integrado_v01 as M  # noqa: E402
from azure.storage.blob import ContainerClient  # noqa: E402


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--version", required=True)
    ap.add_argument("--carpeta", default=str(RAIZ / "backend" / "app" / "ml" / "models"))
    ap.add_argument("--contenedor", default="modelos")
    a = ap.parse_args()

    carpeta = Path(a.carpeta)
    M.cargar(carpeta)  # falla si alguna huella SHA-256 no coincide con la ficha

    cadena = os.environ.get("AZURE_STORAGE_CONNECTION_STRING")
    if not cadena:
        print("Falta AZURE_STORAGE_CONNECTION_STRING")
        return 1
    contenedor = ContainerClient.from_connection_string(cadena, a.contenedor)
    if next(iter(contenedor.list_blobs(name_starts_with=a.version + "/")), None) is not None:
        print(f"La versión {a.version} ya existe en el registro; use otro número de versión")
        return 1
    for archivo in sorted(carpeta.iterdir()):
        if archivo.suffix in (".joblib", ".json"):
            with archivo.open("rb") as f:
                contenedor.upload_blob(f"{a.version}/{archivo.name}", f)
            print("subido", f"{a.version}/{archivo.name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
