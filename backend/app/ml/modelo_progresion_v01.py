"""Modelo de progresión de DCL a Alzheimer del TT (regresión logística, D-169 y D-170), versión v01.
Dada una visita de un paciente con DCL, devuelve la probabilidad de que la visita siguiente sea clasificada como Alzheimer. No ajusta nada. Uso:
    import modelo_progresion_v01 as M
    m = M.cargar('ruta/a/models')
    P = M.predecir(registros, m)     # columnas: D_visuoejecutiva, D_denominacion, D_atencion, D_lenguaje, D_abstraccion, D_recuerdo_diferido, D_orientacion, EDAD, SEXO ('F' o 'M'), ESC_ANIOS (opcional)
Prototipo de investigación: no es una herramienta de diagnóstico y no tiene validación en población mexicana."""
import hashlib, json
from pathlib import Path
import numpy as np
import pandas as pd
import joblib

VERSION = 'v01'


def _huella(ruta):
    h = hashlib.sha256()
    with open(ruta, 'rb') as f:
        for b in iter(lambda: f.read(1 << 20), b''):
            h.update(b)
    return h.hexdigest()


def cargar(carpeta_models):
    """Carga la ficha y el modelo, y comprueba que el archivo del modelo no haya cambiado (huella SHA-256)."""
    carpeta = Path(carpeta_models)
    ficha = json.loads((carpeta / 'modelo_progresion_ficha_v01.json').read_text(encoding='utf-8'))
    a = ficha['archivos']['modelo']
    assert _huella(carpeta / a['archivo']) == a['sha256'], 'El archivo del modelo no es el que se guardó en el notebook 15'
    return {'ficha': ficha, 'modelo': joblib.load(carpeta / a['archivo'])}


def preparar(registros, m, sexo_faltante=None):
    """Matriz de entrada. SEXO F = 1 y M = 0; ESC_ANIOS faltante = mediana del entrenamiento (D-120). Cualquier otra variable faltante, o un SEXO distinto de F y M, es un error;
    sexo_faltante='M' reproduce lo que se hizo con las pocas visitas del desarrollo sin sexo."""
    f = m['ficha']
    R = pd.DataFrame(registros).copy()
    faltan = [c for c in f['variables'] if c not in R.columns and c != 'ESC_ANIOS']
    if faltan:
        raise ValueError(f'Faltan columnas: {faltan}')
    if 'ESC_ANIOS' not in R.columns:
        R['ESC_ANIOS'] = np.nan
    R['ESC_ANIOS'] = pd.to_numeric(R['ESC_ANIOS'], errors='coerce').fillna(f['mediana_esc'])
    sx = R['SEXO'].astype('object')
    if sexo_faltante is not None:
        sx = sx.where(sx.notna(), sexo_faltante)
    if not sx.isin(['F', 'M']).all():
        raise ValueError('SEXO debe ser "F" o "M" en todos los registros')
    X = pd.DataFrame(index=R.index)
    for c in f['variables']:
        X[c] = (sx == 'F').astype(float) if c == 'SEXO' else pd.to_numeric(R[c], errors='coerce')
    if X.isna().any().any():
        raise ValueError(f'Hay valores faltantes o no numéricos en: {list(X.columns[X.isna().any()])}')
    return X


def predecir(registros, m, sexo_faltante=None):
    """Devuelve probabilidad de que la visita siguiente sea Alzheimer y alerta (True si la probabilidad supera el umbral de la ficha)."""
    X = preparar(registros, m, sexo_faltante)
    p = m['modelo'].predict_proba(X)[:, 1]
    u = m['ficha']['umbral']['valor']
    return pd.DataFrame({'probabilidad': p, 'alerta': p > u, 'umbral': u}, index=X.index)
