from sqlalchemy import Column, Integer, String, Date, ForeignKey, SmallInteger, TIMESTAMP
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from ..database import Base


class Usuario(Base):
    __tablename__ = "usuario"
    id_usuario = Column(Integer, primary_key=True)
    nombre = Column(String(80), nullable=False)
    apellido_paterno = Column(String(80), nullable=False)
    apellido_materno = Column(String(80))
    fecha_nacimiento = Column(Date, nullable=False)
    created_at = Column(TIMESTAMP, nullable=False, server_default=func.now())

    credencial = relationship("Credencial", back_populates="usuario_rel", uselist=False)
    paciente = relationship("Paciente", back_populates="usuario_rel", uselist=False)
    especialista = relationship("Especialista", back_populates="usuario_rel", uselist=False)


class Credencial(Base):
    __tablename__ = "credencial"
    id_credencial = Column(Integer, primary_key=True)
    usuario = Column(String(120), nullable=False, unique=True)
    contrasena_hash = Column(String(255), nullable=False)
    id_usuario = Column(Integer, ForeignKey("usuario.id_usuario", ondelete="CASCADE"), nullable=False)
    intentos_fallidos = Column(SmallInteger, nullable=False, default=0)
    bloqueado_hasta = Column(TIMESTAMP)
    created_at = Column(TIMESTAMP, nullable=False, server_default=func.now())

    usuario_rel = relationship("Usuario", back_populates="credencial")


class Consentimiento(Base):
    __tablename__ = "consentimiento"
    id_consentimiento = Column(Integer, primary_key=True)
    id_usuario = Column(Integer, ForeignKey("usuario.id_usuario", ondelete="CASCADE"), nullable=False)
    tipo = Column(String(30), nullable=False)
    version = Column(String(20), nullable=False)
    fecha_aceptacion = Column(TIMESTAMP, nullable=False, server_default=func.now())
