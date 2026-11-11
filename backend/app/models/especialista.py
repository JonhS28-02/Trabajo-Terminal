from sqlalchemy import Column, Integer, String, Date, ForeignKey
from sqlalchemy.orm import relationship

from ..database import Base


class Especialista(Base):
    __tablename__ = "especialista"
    id_especialista = Column(Integer, primary_key=True)
    cedula = Column(String(20), nullable=False, unique=True)
    especialidad = Column(String(120), nullable=False)
    id_genero = Column(Integer, ForeignKey("cat_genero.id_genero"), nullable=False)
    id_usuario = Column(Integer, ForeignKey("usuario.id_usuario", ondelete="CASCADE"), nullable=False, unique=True)

    usuario_rel = relationship("Usuario", back_populates="especialista")


class PacienteEspecialista(Base):
    __tablename__ = "paciente_especialista"
    id_paciente_especialista = Column(Integer, primary_key=True)
    id_paciente = Column(Integer, ForeignKey("paciente.id_paciente", ondelete="CASCADE"), nullable=False)
    id_especialista = Column(Integer, ForeignKey("especialista.id_especialista", ondelete="CASCADE"), nullable=False)
    fecha_vinculacion = Column(Date, nullable=False)
    fecha_desvinculacion = Column(Date)
