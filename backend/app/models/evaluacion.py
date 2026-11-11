from __future__ import annotations

from sqlalchemy import (
    Boolean,
    Column,
    ForeignKey,
    Integer,
    SmallInteger,
    String,
    TIMESTAMP,
    UniqueConstraint,
    func,
)
from sqlalchemy.dialects.postgresql import JSONB

from ..database import Base


class Moca(Base):
    __tablename__ = "moca"

    id_moca = Column(Integer, primary_key=True)
    id_paciente = Column(Integer, ForeignKey("paciente.id_paciente"), nullable=False)
    id_especialista = Column(Integer, ForeignKey("especialista.id_especialista"))
    fecha = Column(TIMESTAMP, nullable=False, server_default=func.now())
    puntaje_total = Column(SmallInteger)
    clasificacion = Column(String(60))
    id_condicion_evaluacion = Column(
        Integer, ForeignKey("condicion_evaluacion.id_condicion_evaluacion")
    )
    id_validez = Column(Integer, ForeignKey("validez_prueba.id_validez"))
    completada = Column(Boolean, nullable=False, server_default="false")


class ResultadoArea(Base):
    __tablename__ = "resultado_area"

    id_resultado_area = Column(Integer, primary_key=True)
    id_moca = Column(
        Integer, ForeignKey("moca.id_moca", ondelete="CASCADE"), nullable=False
    )
    id_area = Column(Integer, ForeignKey("cat_area.id_area"), nullable=False)
    puntaje_obtenido = Column(SmallInteger, nullable=False)
    puntaje_maximo = Column(SmallInteger, nullable=False)
    detalles = Column(JSONB)

    __table_args__ = (UniqueConstraint("id_moca", "id_area"),)


class CodigoSupervision(Base):
    __tablename__ = "codigo_supervision"

    id_codigo = Column(Integer, primary_key=True)
    id_paciente = Column(Integer, ForeignKey("paciente.id_paciente"), nullable=False)
    id_especialista = Column(
        Integer, ForeignKey("especialista.id_especialista"), nullable=False
    )
    codigo_hash = Column(String(255), nullable=False)
    fecha_generacion = Column(TIMESTAMP, nullable=False, server_default=func.now())
    fecha_expiracion = Column(TIMESTAMP, nullable=False)
    usado = Column(Boolean, nullable=False, server_default="false")
    id_moca = Column(Integer, ForeignKey("moca.id_moca"))
