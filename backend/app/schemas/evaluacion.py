from __future__ import annotations

from datetime import datetime
from typing import Any, Dict, List, Optional

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


class ResultadoAreaCreate(BaseModel):
    id_area: int
    puntaje_obtenido: int
    puntaje_maximo: int
    detalles: Optional[Dict[str, Any]] = None

    @field_validator("id_area")
    @classmethod
    def valid_area(cls, v: int) -> int:
        if v < 1 or v > 8:
            raise ValueError("id_area debe estar entre 1 y 8")
        return v


class ResultadoAreaResponse(BaseModel):
    id_resultado_area: int
    id_moca: int
    id_area: int
    puntaje_obtenido: int
    puntaje_maximo: int
    detalles: Optional[Dict[str, Any]] = None

    model_config = {"from_attributes": True}


class GuardarResultadosRequest(BaseModel):
    resultados: List[ResultadoAreaCreate]


class FinalizarMocaRequest(BaseModel):
    puntaje_total: int
    clasificacion: str


class MocaCompleteResponse(BaseModel):
    id_moca: int
    puntaje_total: Optional[int] = None
    clasificacion: Optional[str] = None
    completada: bool
    resultados: List[ResultadoAreaResponse] = []

    model_config = {"from_attributes": True}
