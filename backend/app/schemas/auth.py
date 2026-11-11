from __future__ import annotations

import re
from datetime import date
from typing import Optional

from pydantic import BaseModel, EmailStr, field_validator


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    role: str
    user_id: int
    nombre: str
    codigo_paciente: Optional[str] = None


class RegisterPatientRequest(BaseModel):
    nombre: str
    apellido_paterno: str
    apellido_materno: Optional[str] = None
    fecha_nacimiento: date
    email: EmailStr
    password: str
    id_genero: int
    acepta_privacidad: bool
    acepta_terminos: bool

    @field_validator("nombre", "apellido_paterno")
    @classmethod
    def not_empty(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError("Este campo es obligatorio")
        if len(v) > 80:
            raise ValueError("Máximo 80 caracteres")
        return v

    @field_validator("nombre", "apellido_paterno", "apellido_materno")
    @classmethod
    def safe_text(cls, v: Optional[str]) -> Optional[str]:
        if v is None:
            return v
        if re.search(r"[<>;'\"\\\x00]", v):
            raise ValueError("Caracteres no permitidos")
        return v.strip()

    @field_validator("password")
    @classmethod
    def strong_password(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError("La contraseña debe tener al menos 8 caracteres")
        if len(v) > 128:
            raise ValueError("Máximo 128 caracteres")
        if not re.search(r"[A-Z]", v):
            raise ValueError("Debe contener al menos una mayúscula")
        if not re.search(r"[a-z]", v):
            raise ValueError("Debe contener al menos una minúscula")
        if not re.search(r"\d", v):
            raise ValueError("Debe contener al menos un número")
        return v

    @field_validator("fecha_nacimiento")
    @classmethod
    def valid_birthdate(cls, v: date) -> date:
        from datetime import date as d
        today = d.today()
        age = today.year - v.year - ((today.month, today.day) < (v.month, v.day))
        if age < 18:
            raise ValueError("Debe ser mayor de 18 años")
        if age > 120:
            raise ValueError("Fecha de nacimiento inválida")
        return v

    @field_validator("acepta_privacidad", "acepta_terminos")
    @classmethod
    def must_accept(cls, v: bool) -> bool:
        if not v:
            raise ValueError("Debe aceptar para continuar")
        return v


class RegisterSpecialistRequest(RegisterPatientRequest):
    cedula: str

    @field_validator("cedula")
    @classmethod
    def valid_cedula(cls, v: str) -> str:
        v = v.strip()
        if not re.match(r"^\d{6,8}$", v):
            raise ValueError("Cédula profesional debe tener entre 6 y 8 dígitos")
        return v


class CedulaValidationResponse(BaseModel):
    valid: bool
    nombre: Optional[str] = None
    especialidad: Optional[str] = None
    institucion: Optional[str] = None
    message: Optional[str] = None
