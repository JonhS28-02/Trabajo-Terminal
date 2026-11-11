from sqlalchemy import Column, Integer, SmallInteger, String

from ..database import Base


class CatGenero(Base):
    __tablename__ = "cat_genero"
    id_genero = Column(Integer, primary_key=True)
    nombre_genero = Column(String(30), nullable=False, unique=True)


class CatEscolaridad(Base):
    __tablename__ = "cat_escolaridad"
    id_escolaridad = Column(Integer, primary_key=True)
    escolaridad = Column(String(60), nullable=False, unique=True)
    anios = Column(SmallInteger)


class CatOcupacion(Base):
    __tablename__ = "cat_ocupacion"
    id_ocupacion = Column(Integer, primary_key=True)
    ocupacion = Column(String(80), nullable=False, unique=True)


class CatEnfermedad(Base):
    __tablename__ = "cat_enfermedad"
    id_enfermedad = Column(Integer, primary_key=True)
    nombre_enfermedad = Column(String(120), nullable=False, unique=True)
    categoria = Column(String(60), nullable=False, server_default="General")
    indicador_modelo = Column(String(40))


class CatParentesco(Base):
    __tablename__ = "cat_parentesco"
    id_parentesco = Column(Integer, primary_key=True)
    nombre_parentesco = Column(String(60), nullable=False, unique=True)


class CatSustancia(Base):
    __tablename__ = "cat_sustancia"
    id_sustancia = Column(Integer, primary_key=True)
    nombre_sustancia = Column(String(80), nullable=False, unique=True)


class ConsumoAlcohol(Base):
    __tablename__ = "consumo_alcohol"
    id_consumo_alcohol = Column(Integer, primary_key=True)
    nivel_de_consumo_mensual = Column(String(60), nullable=False, unique=True)


class ConsumoTabaco(Base):
    __tablename__ = "consumo_tabaco"
    id_consumo_tabaco = Column(Integer, primary_key=True)
    nivel_de_consumo_mensual = Column(String(60), nullable=False, unique=True)


class CatArea(Base):
    __tablename__ = "cat_area"
    id_area = Column(Integer, primary_key=True)
    nombre_area = Column(String(80), nullable=False, unique=True)


class CondicionEvaluacion(Base):
    __tablename__ = "condicion_evaluacion"
    id_condicion_evaluacion = Column(Integer, primary_key=True)
    condicion = Column(String(100), nullable=False, unique=True)


class ValidezPrueba(Base):
    __tablename__ = "validez_prueba"
    id_validez = Column(Integer, primary_key=True)
    opcion_valida = Column(String(60), nullable=False, unique=True)
