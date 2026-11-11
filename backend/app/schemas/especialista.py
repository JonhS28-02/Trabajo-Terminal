from __future__ import annotations

from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel, field_validator


class VincularPacienteRequest(BaseModel):
    codigo_paciente: str

    @field_validator("codigo_paciente")
    @classmethod
    def valid_code(cls, v: str) -> str:
        v = v.strip()
        if not v.isdigit() or len(v) != 8:
            raise ValueError("El código del paciente debe ser de 8 dígitos")
        return v


class PacienteResumen(BaseModel):
    id_paciente: int
    codigo_paciente: str
    nombre: str
    apellido_paterno: str
    apellido_materno: Optional[str] = None
    fecha_nacimiento: date
    genero: str
    tiene_expediente: bool
    fecha_vinculacion: date

    model_config = {"from_attributes": True}


class VincularResponse(BaseModel):
    detail: str
    paciente: PacienteResumen


class CatalogoItem(BaseModel):
    id: int
    nombre: str
    model_config = {"from_attributes": True}


class EscolaridadItem(BaseModel):
    id: int
    nombre: str
    anios: Optional[int] = None
    model_config = {"from_attributes": True}


class EnfermedadItem(BaseModel):
    id: int
    nombre: str
    categoria: str
    indicador_modelo: Optional[str] = None
    model_config = {"from_attributes": True}


class AntecedenteFamiliarIn(BaseModel):
    id_parentesco: int
    id_enfermedad: int


class ExpedienteRequest(BaseModel):
    id_escolaridad: int
    id_ocupacion: int
    id_consumo_alcohol: int
    id_consumo_tabaco: int
    enfermedades: list[int] = []
    antecedentes_familiares: list[AntecedenteFamiliarIn] = []


class AntecedenteFamiliarOut(BaseModel):
    id_antecedente_familiar: int
    id_parentesco: int
    nombre_parentesco: str
    id_enfermedad: int
    nombre_enfermedad: str
    model_config = {"from_attributes": True}


class ExpedienteResponse(BaseModel):
    id_expediente: int
    id_paciente: int
    id_escolaridad: Optional[int] = None
    escolaridad: Optional[str] = None
    anios_escolaridad: Optional[int] = None
    id_ocupacion: Optional[int] = None
    ocupacion: Optional[str] = None
    id_consumo_alcohol: Optional[int] = None
    consumo_alcohol: Optional[str] = None
    id_consumo_tabaco: Optional[int] = None
    consumo_tabaco: Optional[str] = None
    enfermedades: list[int] = []
    antecedentes_familiares: list[AntecedenteFamiliarOut] = []
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    model_config = {"from_attributes": True}
