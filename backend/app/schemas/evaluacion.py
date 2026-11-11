from __future__ import annotations

from datetime import datetime
from typing import Optional

from pydantic import BaseModel, field_validator


class GenerarCodigoRequest(BaseModel):
    id_paciente: int


class GenerarCodigoResponse(BaseModel):
    codigo: str
    expires_at: datetime


class ValidarCodigoRequest(BaseModel):
    codigo: str

    @field_validator("codigo")
    @classmethod
    def valid_code(cls, v: str) -> str:
        v = v.strip()
        if not v.isdigit() or len(v) != 6:
            raise ValueError("El código debe ser de 6 dígitos")
        return v


class MocaResponse(BaseModel):
    id_moca: int
    id_paciente: int
    id_especialista: Optional[int] = None
    fecha: datetime
    completada: bool
    puntaje_total: Optional[int] = None
    clasificacion: Optional[str] = None

    model_config = {"from_attributes": True}


class SesionStatusResponse(BaseModel):
    id_moca: int
    id_paciente: int
    id_especialista: Optional[int] = None
    nombre_paciente: str
    fecha: datetime
    completada: bool
