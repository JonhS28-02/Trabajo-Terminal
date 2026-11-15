"""Puente entre la base de datos de la app y modelo_integrado_v01 (detección de 4 clases + progresión de DCL)."""
from __future__ import annotations

import sys
import tempfile
from datetime import date
from functools import lru_cache
from pathlib import Path
from typing import Any, Dict, List, Optional

ML_DIR = Path(__file__).resolve().parent.parent / "ml"
if str(ML_DIR) not in sys.path:
    sys.path.insert(0, str(ML_DIR))

import modelo_integrado_v01 as M  # noqa: E402

from ..config import settings  # noqa: E402

CLASES = list(M.CLASES)

AREA_A_DOMINIO = {
    1: "D_visuoejecutiva",
    2: "D_denominacion",
    4: "D_atencion",
    5: "D_lenguaje",
    6: "D_abstraccion",
    7: "D_recuerdo_diferido",
    8: "D_orientacion",
}
DOMINIO_MAX = {
    "D_visuoejecutiva": 5,
    "D_denominacion": 3,
    "D_atencion": 6,
    "D_lenguaje": 3,
    "D_abstraccion": 2,
    "D_recuerdo_diferido": 5,
    "D_orientacion": 6,
}
ETIQUETAS = {
    "D_visuoejecutiva": "Visuoespacial / ejecutiva",
    "D_denominacion": "Identificación",
    "D_atencion": "Atención",
    "D_lenguaje": "Lenguaje",
    "D_abstraccion": "Abstracción",
    "D_recuerdo_diferido": "Recuerdo diferido",
    "D_orientacion": "Orientación",
    "EDAD": "Edad",
    "SEXO": "Sexo",
    "ESC_ANIOS": "Escolaridad",
    "HIPERTENSION": "Hipertensión",
    "DIABETES": "Diabetes",
    "COLESTEROL_LIPIDOS": "Colesterol o lípidos altos",
    "ACV_TIA": "EVC o isquemia transitoria",
    "TABACO": "Tabaquismo (alguna vez)",
    "ALCOHOL_ABUSO": "Abuso de alcohol",
    "DROGAS": "Abuso de drogas",
    "CAT_PSIQ": "Antecedente psiquiátrico",
    "CAT_NEURO": "Convulsiones o traumatismo craneal",
    "CAT_CARDIO": "Antecedente cardiovascular",
    "CAT_ENDO": "Antecedente endocrino-metabólico",
}
ANTECEDENTES = [
    "HIPERTENSION", "DIABETES", "COLESTEROL_LIPIDOS", "ACV_TIA", "TABACO", "ALCOHOL_ABUSO",
    "DROGAS", "CAT_PSIQ", "CAT_NEURO", "CAT_CARDIO", "CAT_ENDO",
]
# cat_enfermedad.indicador_modelo -> banderas del modelo, con las definiciones de NACC (notebook 04).
INDICADOR_A_VARIABLES = {
    "DIABETES": ("DIABETES", "CAT_ENDO"),
    "HIPERTENSION": ("HIPERTENSION",),
    "HIPERLIPIDEMIA": ("COLESTEROL_LIPIDOS", "CAT_ENDO"),
    "DEPRESION": ("CAT_PSIQ",),
    "PSIQUIATRICA": ("CAT_PSIQ",),
    "TCE": ("CAT_NEURO",),
    "EPILEPSIA": ("CAT_NEURO",),
    "CARDIOVASCULAR": ("CAT_CARDIO",),
    "ACV_TIA": ("ACV_TIA",),
    "ALCOHOL_ABUSO": ("ALCOHOL_ABUSO",),
    "DROGAS": ("DROGAS",),
}

# Prueba final en NACC (notebook 14, Paso 3) y de progresión (notebook 15, Paso 11).
DESEMPENO = {
    "base": {
        "recall": {"Normal": 0.752, "DCL": 0.355, "Alzheimer": 0.749, "Vascular": 0.446},
        "precision": {"Normal": 0.896, "DCL": 0.413, "Alzheimer": 0.789, "Vascular": 0.068},
    },
    "expediente": {
        "recall": {"Normal": 0.770, "DCL": 0.435, "Alzheimer": 0.750, "Vascular": 0.482},
        "precision": {"Vascular": 0.099},
    },
    "progresion": {"sensibilidad": 0.576, "especificidad": 0.790, "precision": 0.280},
}


@lru_cache(maxsize=1)
def _carpeta_modelos() -> Path:
    """Carpeta local con los archivos del modelo activo: descargada del registro en Blob o la incluida en la imagen."""
    if not settings.AZURE_STORAGE_CONNECTION_STRING:
        return ML_DIR / "models"
    from azure.storage.blob import ContainerClient

    destino = Path(tempfile.gettempdir()) / "modelos" / settings.MODEL_VERSION
    destino.mkdir(parents=True, exist_ok=True)
    contenedor = ContainerClient.from_connection_string(
        settings.AZURE_STORAGE_CONNECTION_STRING, settings.MODELS_CONTAINER
    )
    prefijo = settings.MODEL_VERSION + "/"
    nombres = [b.name for b in contenedor.list_blobs(name_starts_with=prefijo)]
    if not nombres:
        raise RuntimeError(f"El registro no tiene archivos para la versión {settings.MODEL_VERSION}")
    for nombre in nombres:
        (destino / nombre[len(prefijo):]).write_bytes(contenedor.download_blob(nombre).readall())
    return destino


@lru_cache(maxsize=1)
def modelos() -> Dict[str, Any]:
    return M.cargar(_carpeta_modelos())


def info_modelo() -> Dict[str, Any]:
    """Qué modelo está sirviendo esta instancia; cargar() ya verificó las huellas contra la ficha."""
    import sklearn

    mods = modelos()
    final, prog = mods["final"]["ficha"], mods["progresion"]["ficha"]
    return {
        "version": settings.MODEL_VERSION,
        "origen": "blob" if settings.AZURE_STORAGE_CONNECTION_STRING else "imagen",
        "modulo": M.VERSION,
        "sklearn": sklearn.__version__,
        "sklearn_entrenamiento": final["entorno"]["scikit-learn"],
        "sha256": {
            **{v["archivo"]: v["sha256_modelo"] for v in final["variantes"].values()},
            prog["archivos"]["modelo"]["archivo"]: prog["archivos"]["modelo"]["sha256"],
        },
    }


def edad_en(fecha_nacimiento: date, fecha: date) -> float:
    return round((fecha - fecha_nacimiento).days / 365.25, 1)


def antecedentes_desde_expediente(indicadores: List[Optional[str]], fumo_alguna_vez: bool) -> Dict[str, int]:
    banderas = {v: 0 for v in ANTECEDENTES}
    for ind in indicadores:
        for var in INDICADOR_A_VARIABLES.get(ind or "", ()):
            banderas[var] = 1
    banderas["TABACO"] = 1 if fumo_alguna_vez else 0
    return banderas


def _factores(registro: Dict[str, Any], variante: str, clase: str) -> List[Dict[str, Any]]:
    """Aportación de cada variable al puntaje lineal de la clase predicha (coeficiente estandarizado x valor estandarizado)."""
    v = modelos()["final"]["ficha"]["variantes"][variante]
    out = []
    for var in v["variables"]:
        if var == "SEXO":
            x = 1.0 if registro["SEXO"] == "F" else 0.0
        elif var == "ESC_ANIOS":
            x = float(registro["ESC_ANIOS"]) if registro.get("ESC_ANIOS") is not None else v["mediana_ESC_ANIOS"]
        else:
            x = float(registro[var])
        z = (x - v["media"][var]) / v["desviacion_estandar"][var]
        aporte = v["coeficientes_estandarizados"][clase][var] * z
        out.append({"variable": var, "etiqueta": ETIQUETAS[var], "valor": _valor_legible(var, registro), "aporte": round(aporte, 3)})
    out.sort(key=lambda f: abs(f["aporte"]), reverse=True)
    return out[:5]


def _valor_legible(var: str, registro: Dict[str, Any]) -> str:
    if var in DOMINIO_MAX:
        return f"{int(registro[var])}/{DOMINIO_MAX[var]}"
    if var == "EDAD":
        return f"{registro['EDAD']:.0f} años"
    if var == "SEXO":
        return {"F": "Femenino", "M": "Masculino"}.get(registro["SEXO"], "No registrado")
    if var == "ESC_ANIOS":
        return f"{registro['ESC_ANIOS']} años" if registro.get("ESC_ANIOS") is not None else "No registrada"
    return "Sí" if registro[var] else "No"


def _confianza(clase: str, margen: float, edad: float) -> Dict[str, str]:
    """Nivel visual de confianza a partir del desempeño por clase en la prueba final y de qué tan separada quedó la clase."""
    if clase == "Vascular":
        nivel, motivo = 0, "El modelo acierta pocas veces cuando indica Vascular"
    elif clase == "DCL":
        nivel, motivo = (1 if margen >= 0.15 else 0), "DCL es la clase que el modelo distingue peor"
    elif margen >= 0.25:
        nivel, motivo = 2, "Clase bien separada de las demás"
    elif margen >= 0.10:
        nivel, motivo = 1, "La segunda clase queda relativamente cerca"
    else:
        nivel, motivo = 0, "Resultado cerrado entre dos clases"
    if edad < 50 and nivel > 0:
        nivel -= 1
        motivo += "; edad fuera del rango con que se desarrolló el modelo"
    return {"nivel": ("baja", "media", "alta")[nivel], "motivo": motivo}


def predecir_visita(
    dominios: Dict[str, int],
    edad: float,
    sexo: Optional[str],
    esc_anios: Optional[int],
    antecedentes: Optional[Dict[str, int]],
    clase_conocida: Optional[str],
) -> Dict[str, Any]:
    """Corre el modelo integrado en una visita. Lanza ValueError si los datos no alcanzan."""
    faltan = [ETIQUETAS[d] for d in DOMINIO_MAX if d not in dominios]
    if faltan:
        raise ValueError("Faltan dominios de la MoCA: " + ", ".join(faltan))

    registro: Dict[str, Any] = dict(dominios)
    registro.update({"EDAD": edad, "SEXO": sexo, "ESC_ANIOS": esc_anios})
    variante = "base"
    if antecedentes is not None:
        registro.update(antecedentes)
        variante = "expediente"

    sexo_faltante = None if sexo in ("F", "M") else "M"
    conocida = [clase_conocida] if clase_conocida else None
    mods = modelos()
    fila = M.predecir([registro], mods, variante=variante, sexo_faltante=sexo_faltante, clase_conocida=conocida).iloc[0]

    probs = {c: round(float(fila[c]), 4) for c in CLASES}
    orden = sorted(probs.values(), reverse=True)
    clase = str(fila["clase_predicha"])
    registro_f = dict(registro, SEXO=sexo if sexo in ("F", "M") else "M")

    salida: Dict[str, Any] = {
        "variante": variante,
        "probabilidades": probs,
        "clase_predicha": clase,
        "margen": round(orden[0] - orden[1], 4),
        "confianza": _confianza(clase, orden[0] - orden[1], edad),
        "factores": _factores(registro_f, variante, clase),
        "base": None,
        "progresion": {
            "aplica": bool(fila["aplica_progresion"]),
            "origen_clase": str(fila["origen_clase"]),
            "probabilidad": round(float(fila["prob_progresion"]), 4) if bool(fila["aplica_progresion"]) else None,
            "alerta": bool(fila["alerta_progresion"]) if bool(fila["aplica_progresion"]) else None,
            "umbral": round(float(fila["umbral_progresion"]), 4),
            "tasa_base": round(float(mods["progresion"]["ficha"]["tasa_base_entrenamiento"]), 4),
        },
    }
    if variante == "expediente":
        b = M.predecir([registro], mods, variante="base", sexo_faltante=sexo_faltante).iloc[0]
        salida["base"] = {
            "probabilidades": {c: round(float(b[c]), 4) for c in CLASES},
            "clase_predicha": str(b["clase_predicha"]),
        }
    return salida


def avisos_generales() -> List[str]:
    return [
        "Prototipo de investigación: apoya la decisión clínica, no la sustituye ni emite un diagnóstico.",
        "Entrenado con cohortes de ADNI, NACC y PPMI; no está validado en población mexicana.",
        "Las probabilidades no están calibradas a la frecuencia real de cada diagnóstico y no son un riesgo absoluto.",
        "La clase Vascular casi siempre es un falso positivo (7 a 10 de cada 100 lo eran en la prueba final) y el modelo "
        "detecta menos de la mitad de los casos reales de DCL.",
    ] + list(M.AVISOS[:2])
