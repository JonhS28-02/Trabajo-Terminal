from __future__ import annotations

from sqlalchemy import Column, Date, ForeignKey, Integer, String, Text, TIMESTAMP, func

from ..database import Base


class NotaClinica(Base):
    __tablename__ = "nota_clinica"

    id_nota = Column(Integer, primary_key=True)
    id_paciente = Column(Integer, ForeignKey("paciente.id_paciente", ondelete="CASCADE"), nullable=False)
    id_especialista = Column(Integer, ForeignKey("especialista.id_especialista"), nullable=False)
    id_moca = Column(Integer, ForeignKey("moca.id_moca", ondelete="SET NULL"))
    impresion_diagnostica = Column(String(20))
    nota = Column(Text, nullable=False)
    plan = Column(Text)
    fecha_seguimiento = Column(Date)
    created_at = Column(TIMESTAMP, nullable=False, server_default=func.now())
