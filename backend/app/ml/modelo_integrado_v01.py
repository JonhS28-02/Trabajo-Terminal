"""Modelo integrado del TT (v01): detección de la clase de la visita y apoyo a la vigilancia del DCL, en una sola llamada.
Usa sin cambios modelo_final_v01 (regresión logística de cuatro clases, D-157 y D-158) y modelo_progresion_v01 (probabilidad de que la visita siguiente sea Alzheimer, D-169 y D-170). Uso:
    import modelo_integrado_v01 as M
    modelos = M.cargar('ruta/a/models')
    R = M.predecir(registros, modelos)                                  # la progresión se calcula en las visitas que el modelo clasifica como DCL
    R = M.predecir(registros, modelos, clase_conocida=diagnostico)      # o en las visitas cuyo diagnóstico ya se conoce como DCL
Columnas de entrada: D_visuoejecutiva, D_denominacion, D_atencion, D_lenguaje, D_abstraccion, D_recuerdo_diferido, D_orientacion, EDAD, SEXO ('F' o 'M') y ESC_ANIOS (opcional).
Prototipo de investigación: no es una herramienta de diagnóstico, no está validado en población mexicana y sus probabilidades no son riesgos clínicos."""
import numpy as np
import pandas as pd
import modelo_final_v01 as F
import modelo_progresion_v01 as P

VERSION = 'v01'
CLASES = F.CLASES
AVISOS = ['La progresión se desarrolló con visitas cuyo diagnóstico ya era DCL. Si se aplica a visitas que el modelo de detección clasifica como DCL, la estimación es menos confiable, porque esa clasificación se equivoca con frecuencia (en la prueba final del notebook 14, recall de DCL de 0.355 en NACC).',
          'La probabilidad de progresión es la de que la visita siguiente (a plazo variable, no fijo) sea clasificada como Alzheimer; no es un riesgo a un plazo definido.',
          'Sin validación externa ni en población mexicana. Solo sirve para priorizar el seguimiento, no para diagnosticar.']


def cargar(carpeta_models):
    """Carga los dos modelos comprobando la huella SHA-256 de sus archivos."""
    return {'final': F.cargar(carpeta_models), 'progresion': P.cargar(carpeta_models)}


def predecir(registros, modelos, variante='base', sexo_faltante=None, clase_conocida=None, solo_dcl=True):
    """Devuelve, por registro: probabilidad de cada clase (Normal, DCL, Alzheimer, Vascular) y clase_predicha; origen_clase ('predicha' o 'conocida'), aplica_progresion,
    prob_progresion (vacía si no aplica), alerta_progresion (True si la probabilidad supera el umbral de la ficha) y umbral_progresion.
    clase_conocida: diagnóstico ya conocido de cada registro (Normal, DCL, Alzheimer o Vascular); si se da, la progresión se aplica a los que son DCL en lugar de a los clasificados como DCL.
    solo_dcl=False calcula la progresión en todos los registros (no recomendado: el modelo solo se desarrolló con DCL)."""
    registros = pd.DataFrame(registros)
    D = F.predecir(registros, variante, modelos['final'], sexo_faltante)
    Q = P.predecir(registros, modelos['progresion'], sexo_faltante)
    if clase_conocida is None:
        clase, origen = D['clase_predicha'], 'predicha'
    else:
        valores = np.asarray(clase_conocida, dtype=object)
        if valores.shape != (len(registros),):
            raise ValueError('clase_conocida debe tener un valor por registro')
        clase = pd.Series(valores, index=registros.index)
        malas = sorted(set(clase.dropna()) - set(CLASES))
        if malas or clase.isna().any():
            raise ValueError(f'clase_conocida solo admite {CLASES} y no admite faltantes (valores no válidos: {malas})')
        origen = 'conocida'
    aplica = (clase == 'DCL') if solo_dcl else pd.Series(True, index=registros.index)
    out = D.copy()
    out['origen_clase'] = origen
    out['aplica_progresion'] = aplica.astype(bool)
    out['prob_progresion'] = Q['probabilidad'].where(out['aplica_progresion'])
    out['alerta_progresion'] = pd.Series(Q['alerta'], dtype='boolean').where(out['aplica_progresion'])
    out['umbral_progresion'] = Q['umbral']
    return out
