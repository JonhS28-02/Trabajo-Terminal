# TT 2026-B141 · Prototipo de Sistema de Detección y Apoyo para la Prevención de Enfermedades Neurodegenerativas

Trabajo Terminal de la Escuela Superior de Cómputo (ESCOM-IPN).

- **Director:** Dra. Rocío Palacios Solano
- **Equipo:** Jonathan Ulises Rivera García · Isaac Pardo Gómez · Iván Marcelino Meza Bravo

---

## 1. ¿De qué trata el proyecto?

Sistema de apoyo para la detección temprana de deterioro cognitivo a partir de la prueba **MoCA** (Montreal Cognitive Assessment) y de un expediente clínico básico del paciente. Un modelo de aprendizaje automático clasifica el estado cognitivo en tres clases:

| Clase | Descripción |
|---|---|
| DCL | Deterioro cognitivo leve |
| Alzheimer | Demencia tipo Alzheimer |
| Vascular | Deterioro de origen vascular |

> El sistema es una herramienta de **apoyo**; no sustituye el diagnóstico de un profesional de la salud.

**Componentes del sistema**

- Backend: FastAPI + PostgreSQL (Azure)
- App móvil (Android / iOS · Flutter)
- Modelos de ML: Regresión Logística, SVM, Random Forest (scikit-learn)

---

## 2. Datos

Los datos crudos y los CSV procesados están en una carpeta de Google Drive:

👉 **[Carpeta de datos en Google Drive](https://drive.google.com/drive/folders/1dpmsF4dxffhKQyq4YzDebAZDoMvsYfOm?usp=sharing)**

> ⚠️ **Acceso restringido.** ADNI, PPMI y NACC se distribuyen bajo acuerdos de uso que, en general, no permiten redistribuir los datos. La carpeta es solo para el equipo y la directora. Si necesitas acceso, pídelo a alguien del equipo con tu correo. Para trabajar por tu cuenta, solicita los datos directamente a cada fuente (enlaces en la sección 7).

### 2.1 Fuentes

| Dataset | Qué es | Para qué lo usamos |
|---|---|---|
| **ADNI** | Alzheimer's Disease Neuroimaging Initiative (LONI IDA) | Base principal: MoCA por ítem, diagnóstico Normal / DCL / Demencia y variables de expediente |
| **NACC** | National Alzheimer's Coordinating Center (UDS) | Base para la clase **vascular** y Alzheimer (diagnóstico etiológico), MoCA por ítem |
| **PPMI** | Parkinson's Progression Markers Initiative | Complemento: ejemplos Normal vs DCL y prueba externa. Población con Parkinson, casi sin Alzheimer ni vascular |

### 2.2 Contenido de la carpeta

> Ajusta los nombres para que coincidan con lo que subiste.

```
Drive/
├── ADNI/
│   ├── Tables_12Oct2026.zip              # 15 tablas All_Subjects_* + DATADIC (MOCA, DXSUM, PTDEMOG, CDR, MMSE, ...)
│   ├── download.zip                      # paquete ADNIMERGE2 (R) + documentación
│   └── moca_dominios_dx.csv              # MoCA por dominio + diagnóstico, una fila por visita
├── NACC/
│   ├── investigator_nacc74.csv           # archivo completo (~1 GB)
│   └── Diccionarios (RDD UDS v4, Neuropatología, Genético).pdf
├── PPMI/
│   ├── ppmi_unificado.csv                # una fila por visita (MoCA + etiqueta + expediente)
│   └── tablas originales (MoCA, Cognitive Categorization, Demographics, ...) + Data/Code Dictionary
└── README
```

### 2.3 Cómo se arma cada tabla de trabajo

**MoCA por dominio.** Se calculan 7 dominios a partir de los ítems:
visuoespacial/ejecutiva, denominación, atención, lenguaje, abstracción, recuerdo diferido y orientación. El dominio de memoria/registro no puntúa. Se suma +1 por escolaridad ≤ 12 años, igual que la regla del MoCA.

**Etiquetas**

| Dataset | Variable | Valores usados |
|---|---|---|
| ADNI | `DIAGNOSIS` (DXSUM) | 1 = Normal, 2 = DCL, 3 = Demencia |
| NACC | `NACCUDSD` y `NACCETPR` | 1 / 2 / 3 / 4 (normal, deterioro, DCL, demencia); `NACCETPR = 8` indica etiología vascular |
| PPMI | `COGSTATE` (Cognitive Categorization) | 1 = Normal, 2 = DCL, 3 = Demencia |

**Expediente.** Edad, escolaridad, sexo y, cuando existe en la fuente: enfermedades cardiovasculares, diabetes, neurológicas, psiquiátricas, colesterol, historia familiar y consumo de sustancias. No todas las variables existen en todas las fuentes:

| Variable | ADNI | NACC | PPMI |
|---|---|---|---|
| Edad, sexo, escolaridad | Sí | Sí | Sí |
| Cardiovascular / metabólico / neurológico / psiquiátrico | Sí (según época) | Sí | Solo por categoría |
| Colesterol | Laboratorios | Solo sí/no | **No** |
| Historia familiar | Sí | Sí | Solo de Parkinson |
| Tabaco / alcohol / drogas | Sí/no | Sí | **No** |

---

## 3. Estado actual

- [x] Descarga de ADNI, NACC y PPMI
- [x] Revisión de variables y tabla MoCA por dominio (ADNI)
- [x] Tabla unificada de PPMI
- [ ] Preparación de datos en Google Colab (limpieza, armonización entre datasets, tabla final)
- [ ] Partición por paciente (evitar fuga de información entre entrenamiento y prueba)
- [ ] Entrenamiento y evaluación de modelos
- [ ] Integración con la app

---

## 4. Cómo trabajar con los datos (Colab)

1. Abre la carpeta de Drive y confirma que tienes acceso.
2. En Colab, monta Drive:
   ```python
   from google.colab import drive
   drive.mount('/content/drive')
   ```
3. Apunta a la ruta de la carpeta y carga solo las columnas necesarias. Esto importa sobre todo con NACC, que pesa ~1 GB:
   ```python
   import pandas as pd
   nacc = pd.read_csv(RUTA_NACC, usecols=COLUMNAS, low_memory=False)
   ```

**Cuidados al preparar los datos**

- Códigos de dato faltante: ADNI usa `-4`; NACC usa `-4`, `88` y `95`–`99`. Hay que convertirlos a `NaN` antes de calcular.
- Varias visitas por paciente: la partición entrenamiento/prueba se hace **por paciente** (por ejemplo, `GroupKFold`).
- Cambios de versión de formularios (ADNI2/GO vs ADNI3/4, versiones de UDS de NACC): hay que armonizar variables.
- PPMI es una población con Parkinson: no mezclar sin revisar el sesgo.

---

## 5. Estructura del repositorio

> Completa según tu repo.

```
├── backend/        # FastAPI
├── app/            # App móvil
├── notebooks/      # Colab: preparación de datos y modelos
├── docs/           # Reporte técnico, diagramas, diccionario de datos
└── README.md
```

---

## 6. Limitaciones

- ADNI no tiene clase vascular. NACC es la fuente principal para esa clase.
- PPMI casi no tiene Alzheimer ni vascular, y su población es distinta a la de la app.
- Algunas variables del expediente (consumo de sustancias, colesterol) no están en las tres fuentes o vienen en otro formato que los catálogos del TT.
- El modelo no está validado clínicamente.

---

## 7. Referencias y acceso a los datos originales

- ADNI: https://adni.loni.usc.edu
- NACC: https://naccdata.org
- PPMI: https://www.ppmi-info.org
- MoCA: https://mocacognition.com

Al usar estos datos se debe reconocer a las fuentes según sus políticas de publicación y agradecimientos.

---

## 8. Licencia y uso

Proyecto académico. El código se publica bajo la licencia que el equipo defina (pendiente). Los datos de ADNI, NACC y PPMI **no** se incluyen en este repositorio y se usan bajo los acuerdos de uso de cada fuente.