"""Comprueba que el modelo reproduce las predicciones de referencia. Uso: python mlops/validar_modelo.py [--carpeta DIR] [--actualizar]"""
import argparse
import json
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(RAIZ / "backend" / "app" / "ml"))

import modelo_integrado_v01 as M  # noqa: E402

TOLERANCIA = 1e-6


def predecir(carpeta: Path, casos: list) -> list:
    modelos = M.cargar(carpeta)
    salida = []
    for caso in casos:
        variante = "expediente" if "HIPERTENSION" in caso["entrada"] else "base"
        fila = M.predecir([caso["entrada"]], modelos, variante=variante, clase_conocida=["DCL"]).iloc[0]
        salida.append({
            "probabilidades": {c: float(fila[c]) for c in M.CLASES},
            "clase_predicha": str(fila["clase_predicha"]),
            "prob_progresion": float(fila["prob_progresion"]),
        })
    return salida


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--carpeta", default=str(RAIZ / "backend" / "app" / "ml" / "models"))
    ap.add_argument("--referencia", default=str(Path(__file__).with_name("referencia_v01.json")))
    ap.add_argument("--actualizar", action="store_true", help="reescribe las salidas esperadas con el modelo actual")
    a = ap.parse_args()

    ref = json.loads(Path(a.referencia).read_text(encoding="utf-8"))
    obtenido = predecir(Path(a.carpeta), ref["casos"])

    if a.actualizar:
        for caso, o in zip(ref["casos"], obtenido):
            caso["esperado"] = o
        Path(a.referencia).write_text(json.dumps(ref, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
        print(f"Referencia actualizada con {len(obtenido)} casos")
        return 0

    fallos = 0
    for i, (caso, o) in enumerate(zip(ref["casos"], obtenido)):
        e = caso["esperado"]
        dif = max(
            [abs(o["probabilidades"][c] - e["probabilidades"][c]) for c in M.CLASES]
            + [abs(o["prob_progresion"] - e["prob_progresion"])]
        )
        ok = dif <= TOLERANCIA and o["clase_predicha"] == e["clase_predicha"]
        fallos += not ok
        print(f"caso {i + 1}: {'ok' if ok else 'FALLA'} (diferencia máxima {dif:.2e}, clase {o['clase_predicha']})")
    print("Modelo válido" if not fallos else f"{fallos} casos no coinciden con la referencia")
    return 1 if fallos else 0


if __name__ == "__main__":
    sys.exit(main())
