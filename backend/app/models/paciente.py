from sqlalchemy import Column, Integer, String, ForeignKey, TIMESTAMP
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from ..database import Base


class Paciente(Base):
    __tablename__ = "paciente"
    id_paciente = Column(Integer, primary_key=True)
    codigo_paciente = Column(String(10), nullable=False, unique=True)
    id_genero = Column(Integer, ForeignKey("cat_genero.id_genero"), nullable=False)
    id_usuario = Column(Integer, ForeignKey("usuario.id_usuario", ondelete="CASCADE"), nullable=False, unique=True)

    usuario_rel = relationship("Usuario", back_populates="paciente")


class ExpedienteClinico(Base):
    __tablename__ = "expediente_clinico"
    id_expediente = Column(Integer, primary_key=True)
    id_paciente = Column(Integer, ForeignKey("paciente.id_paciente", ondelete="CASCADE"), nullable=False)
    id_escolaridad = Column(Integer, ForeignKey("cat_escolaridad.id_escolaridad"))
    id_ocupacion = Column(Integer, ForeignKey("cat_ocupacion.id_ocupacion"))
    id_consumo_alcohol = Column(Integer, ForeignKey("consumo_alcohol.id_consumo_alcohol"))
    id_consumo_tabaco = Column(Integer, ForeignKey("consumo_tabaco.id_consumo_tabaco"))
    created_at = Column(TIMESTAMP, nullable=False, server_default=func.now())
    updated_at = Column(TIMESTAMP, nullable=False, server_default=func.now(), onupdate=func.now())


class EnfermedadPaciente(Base):
    __tablename__ = "enfermedad_paciente"
    id_paciente = Column(Integer, ForeignKey("paciente.id_paciente", ondelete="CASCADE"), primary_key=True)
    id_enfermedad = Column(Integer, ForeignKey("cat_enfermedad.id_enfermedad"), primary_key=True)


class AntecedenteFamiliar(Base):
    __tablename__ = "antecedente_familiar"
    id_antecedente_familiar = Column(Integer, primary_key=True)
    id_parentesco = Column(Integer, ForeignKey("cat_parentesco.id_parentesco"), nullable=False)
    id_enfermedad = Column(Integer, ForeignKey("cat_enfermedad.id_enfermedad"), nullable=False)
    id_paciente = Column(Integer, ForeignKey("paciente.id_paciente", ondelete="CASCADE"), nullable=False)
