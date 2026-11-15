"""Aplicación del modelo final del TT (regresión logística, D-157 y D-158) a registros nuevos.
Lee los archivos de models/ (modelos .joblib y ficha .json). No ajusta nada. Uso:
    import modelo_final_v01 as M
    modelos = M.cargar('ruta/a/models')
    P = M.predecir(registros, 'base', modelos)        # variante base: 7 dominios de la MoCA, edad, sexo y escolaridad
    P = M.predecir(registros, 'expediente', modelos)  # variante con los 11 antecedentes (todos obligatorios)
Es un prototipo de investigación: las probabilidades son de la regresión logística con pesos de clase balanceados y no son probabilidades
calibradas a la frecuencia real de cada diagnóstico. No es una herramienta de diagnóstico."""
import hashlib, json
from pathlib import Path
import numpy as np
import pandas as pd
import joblib

VERSION = 'v01'
CLASES = ['Normal', 'DCL', 'Alzheimer', 'Vascular']


def _huella(ruta):
    h = hashlib.sha256()
    with open(ruta, 'rb') as f:
        for bloque in iter(lambda: f.read(1 << 20), b''):
            h.update(bloque)
    return h.hexdigest()


def cargar(carpeta_models):
    """Carga la ficha y los modelos de la carpeta models/ y comprueba que los archivos no hayan cambiado (huella SHA-256)."""
    carpeta = Path(carpeta_models)
    ficha = json.loads((carpeta / 'modelo_final_ficha_v01.json').read_text(encoding='utf-8'))
    modelos = {}
    for nombre, v in ficha['variantes'].items():
        assert _huella(carpeta / v['archivo']) == v['sha256_modelo'], f'El archivo {v["archivo"]} no es el que se guardó en el notebook 14'
        modelos[nombre] = joblib.load(carpeta / v['archivo'])
    return {'ficha': ficha, 'modelos': modelos}


def preparar(registros, variante, modelos, sexo_faltante=None):
    """Matriz de entrada del modelo. Reglas del desarrollo (D-120): SEXO F = 1, M = 0; ESC_ANIOS faltante = mediana del entrenamiento.
    Cualquier otra variable faltante, o un SEXO distinto de F y M, es un error (el modelo no imputa otras variables). sexo_faltante='M' reproduce lo que se hizo
    con las pocas visitas del desarrollo sin sexo registrado."""
    v = modelos['ficha']['variantes'][variante]
    cols = v['variables']
    faltan = [c for c in cols if c not in registros.columns]
    if faltan:
        raise ValueError(f'Faltan columnas para la variante {variante}: {faltan}')
    X = pd.DataFrame(index=registros.index)
    for c in cols:
        if c == 'SEXO':
            s = registros['SEXO'].copy()
            if sexo_faltante is not None:
                s = s.fillna(sexo_faltante)
            if not s.isin(['F', 'M']).all():
                raise ValueError('SEXO debe ser "F" o "M" en todos los registros')
            X[c] = (s == 'F').astype(float)
        elif c == 'ESC_ANIOS':
            X[c] = registros[c].astype(float).fillna(v['mediana_ESC_ANIOS'])
        else:
            X[c] = registros[c].astype(float)
    malas = [c for c in cols if X[c].isna().any()]
    if malas:
        raise ValueError(f'Hay valores faltantes en: {malas}')
    return X[cols]


def predecir(registros, variante, modelos, sexo_faltante=None):
    """Probabilidad de cada clase (columnas Normal, DCL, Alzheimer, Vascular) y la clase con mayor probabilidad."""
    X = preparar(registros, variante, modelos, sexo_faltante)
    m = modelos['modelos'][variante]
    P = pd.DataFrame(m.predict_proba(X), index=registros.index, columns=list(m.named_steps['regresion_logistica'].classes_)).reindex(columns=CLASES)
    P['clase_predicha'] = P[CLASES].idxmax(axis=1)
    return P
