from __future__ import annotations

from sqlalchemy.orm import Session

from .database import SessionLocal
from .models.catalogos import (
    CatEscolaridad,
    CatEnfermedad,
    CatGenero,
    CatOcupacion,
    CatParentesco,
    ConsumoAlcohol,
    ConsumoTabaco,
)

GENEROS = [
    (1, "Masculino"),
    (2, "Femenino"),
    (3, "No binario"),
    (4, "Prefiero no decir"),
]

ESCOLARIDADES = [
    ("Sin escolaridad", 0),
    ("Primaria incompleta", 3),
    ("Primaria completa", 6),
    ("Secundaria incompleta", 8),
    ("Secundaria completa", 9),
    ("Preparatoria incompleta", 11),
    ("Preparatoria completa", 12),
    ("Licenciatura incompleta", 15),
    ("Licenciatura completa", 16),
    ("Posgrado", 20),
]

OCUPACIONES = [
    "Empleado",
    "Desempleado",
    "Jubilado/Pensionado",
    "Hogar",
    "Estudiante",
    "Trabajador independiente",
    "Otro",
]

ENFERMEDADES = [
    ("Diabetes mellitus tipo 1", "Metabólica", "DIABETES"),
    ("Diabetes mellitus tipo 2", "Metabólica", "DIABETES"),
    ("Hipertensión arterial", "Cardiovascular", "HIPERTENSION"),
    ("Hipercolesterolemia", "Metabólica", "HIPERLIPIDEMIA"),
    ("Dislipidemia", "Metabólica", "HIPERLIPIDEMIA"),
    ("Depresión", "Neuropsiquiátrica", "DEPRESION"),
    ("Trastorno depresivo mayor", "Neuropsiquiátrica", "DEPRESION"),
    ("Traumatismo craneoencefálico", "Neurológica", "TCE"),
    ("Infarto agudo de miocardio", "Cardiovascular", "CARDIOVASCULAR"),
    ("Insuficiencia cardíaca", "Cardiovascular", "CARDIOVASCULAR"),
    ("Arritmia cardíaca", "Cardiovascular", "CARDIOVASCULAR"),
    ("Enfermedad renal crónica", "Renal", "RENAL"),
    ("Insuficiencia renal", "Renal", "RENAL"),
    ("Hepatitis", "Hepática", "HEPATICA"),
    ("Cirrosis hepática", "Hepática", "HEPATICA"),
    ("Esteatosis hepática", "Hepática", "HEPATICA"),
    ("Hipotiroidismo", "Endocrina", "TIROIDEA"),
    ("Hipertiroidismo", "Endocrina", "TIROIDEA"),
    ("Deficiencia de vitamina B12", "Nutricional", "VITB12"),
    ("Insomnio", "Sueño", "SUENO"),
    ("Apnea del sueño", "Sueño", "SUENO"),
    ("Evento vascular cerebral (EVC) o isquemia transitoria", "Neurológica", "ACV_TIA"),
    ("Epilepsia o crisis convulsivas", "Neurológica", "EPILEPSIA"),
    ("Trastorno de ansiedad", "Neuropsiquiátrica", "PSIQUIATRICA"),
    ("Trastorno bipolar", "Neuropsiquiátrica", "PSIQUIATRICA"),
    ("Esquizofrenia", "Neuropsiquiátrica", "PSIQUIATRICA"),
    ("Trastorno obsesivo-compulsivo", "Neuropsiquiátrica", "PSIQUIATRICA"),
    ("Otro trastorno psiquiátrico", "Neuropsiquiátrica", "PSIQUIATRICA"),
    ("Angina de pecho o enfermedad coronaria", "Cardiovascular", "CARDIOVASCULAR"),
    ("Enfermedad valvular cardíaca", "Cardiovascular", "CARDIOVASCULAR"),
    ("Abuso de alcohol o alcoholismo", "Sustancias", "ALCOHOL_ABUSO"),
    ("Abuso de drogas u otras sustancias", "Sustancias", "DROGAS"),
]

PARENTESCOS = [
    "Padre",
    "Madre",
    "Hermano/a",
    "Abuelo/a paterno",
    "Abuelo/a materno",
    "Tío/a",
    "Otro",
]

CONSUMO_ALCOHOL = [
    "Nunca",
    "Ocasional (1-3 veces/mes)",
    "Moderado (1-2 veces/semana)",
    "Frecuente (3+ veces/semana)",
]

CONSUMO_TABACO = [
    "Nunca",
    "Exfumador",
    "Ocasional (1-5 cigarros/semana)",
    "Regular (1-10 cigarros/día)",
    "Frecuente (más de 10 cigarros/día)",
]


def _seed_if_empty(db: Session, model, rows_fn) -> None:
    if db.query(model).first() is not None:
        return
    for obj in rows_fn():
        db.add(obj)


def seed(db: Session | None = None) -> None:
    own_session = db is None
    if own_session:
        db = SessionLocal()

    try:
        _seed_if_empty(db, CatGenero, lambda: [
            CatGenero(id_genero=gid, nombre_genero=name)
            for gid, name in GENEROS
        ])
        _seed_if_empty(db, CatEscolaridad, lambda: [
            CatEscolaridad(escolaridad=name, anios=yrs)
            for name, yrs in ESCOLARIDADES
        ])
        _seed_if_empty(db, CatOcupacion, lambda: [
            CatOcupacion(ocupacion=name) for name in OCUPACIONES
        ])
        existentes = {n for (n,) in db.query(CatEnfermedad.nombre_enfermedad).all()}
        for name, cat, ind in ENFERMEDADES:
            if name not in existentes:
                db.add(CatEnfermedad(nombre_enfermedad=name, categoria=cat, indicador_modelo=ind))
        _seed_if_empty(db, CatParentesco, lambda: [
            CatParentesco(nombre_parentesco=name) for name in PARENTESCOS
        ])
        _seed_if_empty(db, ConsumoAlcohol, lambda: [
            ConsumoAlcohol(nivel_de_consumo_mensual=name)
            for name in CONSUMO_ALCOHOL
        ])
        _seed_if_empty(db, ConsumoTabaco, lambda: [
            ConsumoTabaco(nivel_de_consumo_mensual=name)
            for name in CONSUMO_TABACO
        ])
        db.commit()
    except Exception:
        db.rollback()
        raise
    finally:
        if own_session:
            db.close()


if __name__ == "__main__":
    seed()
    print("Catálogos sembrados correctamente.")
