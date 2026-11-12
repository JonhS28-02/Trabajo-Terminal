from datetime import datetime, timedelta, timezone
from random import randint

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..models.especialista import Especialista
from ..models.paciente import Paciente
from ..models.usuario import Consentimiento, Credencial, Usuario
from ..schemas.auth import (
    CedulaValidationResponse,
    LoginRequest,
    ProfileResponse,
    ProfileUpdateRequest,
    RegisterPatientRequest,
    RegisterSpecialistRequest,
    TokenResponse,
)
from ..security.jwt import create_access_token, get_current_user
from ..security.password import hash_password, verify_password
from ..services.cedula import validate_cedula


def _generate_codigo_paciente(db: Session) -> str:
    for _ in range(20):
        code = str(randint(10000000, 99999999))
        if not db.query(Paciente).filter(Paciente.codigo_paciente == code).first():
            return code
    raise HTTPException(status_code=500, detail="No se pudo generar código de paciente")

router = APIRouter(prefix="/api/auth", tags=["Autenticación"])

MAX_ATTEMPTS = 5
LOCKOUT_MINUTES = 15


@router.post("/login", response_model=TokenResponse)
def login(body: LoginRequest, db: Session = Depends(get_db)):
    cred = db.query(Credencial).filter(Credencial.usuario == body.email.lower()).first()

    generic_error = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Correo o contraseña incorrectos",
    )

    if cred is None:
        raise generic_error

    if cred.bloqueado_hasta and cred.bloqueado_hasta > datetime.now(timezone.utc):
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Cuenta bloqueada temporalmente. Intente en 15 minutos.",
        )

    if not verify_password(body.password, cred.contrasena_hash):
        cred.intentos_fallidos += 1
        if cred.intentos_fallidos >= MAX_ATTEMPTS:
            cred.bloqueado_hasta = datetime.now(timezone.utc) + timedelta(minutes=LOCKOUT_MINUTES)
        db.commit()
        raise generic_error

    cred.intentos_fallidos = 0
    cred.bloqueado_hasta = None
    db.commit()

    user = db.query(Usuario).filter(Usuario.id_usuario == cred.id_usuario).first()
    role = _get_role(db, user.id_usuario)

    codigo = None
    if role == "paciente":
        pac = db.query(Paciente).filter(Paciente.id_usuario == user.id_usuario).first()
        if pac:
            codigo = pac.codigo_paciente

    token = create_access_token({"sub": str(user.id_usuario), "role": role, "email": cred.usuario})
    return TokenResponse(
        access_token=token,
        role=role,
        user_id=user.id_usuario,
        nombre=user.nombre,
        codigo_paciente=codigo,
    )


@router.post("/register/patient", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
def register_patient(body: RegisterPatientRequest, db: Session = Depends(get_db)):
    _check_email_unique(db, body.email)

    user = Usuario(
        nombre=body.nombre,
        apellido_paterno=body.apellido_paterno,
        apellido_materno=body.apellido_materno,
        fecha_nacimiento=body.fecha_nacimiento,
    )
    db.add(user)
    db.flush()

    cred = Credencial(
        usuario=body.email.lower(),
        contrasena_hash=hash_password(body.password),
        id_usuario=user.id_usuario,
    )
    db.add(cred)

    codigo = _generate_codigo_paciente(db)
    paciente = Paciente(
        id_genero=body.id_genero,
        id_usuario=user.id_usuario,
        codigo_paciente=codigo,
    )
    db.add(paciente)

    db.add(Consentimiento(id_usuario=user.id_usuario, tipo="privacidad", version="1.0"))
    db.add(Consentimiento(id_usuario=user.id_usuario, tipo="terminos_uso", version="1.0"))

    db.commit()

    token = create_access_token({"sub": str(user.id_usuario), "role": "paciente", "email": cred.usuario})
    return TokenResponse(
        access_token=token,
        role="paciente",
        user_id=user.id_usuario,
        nombre=user.nombre,
        codigo_paciente=codigo,
    )


@router.post("/register/specialist", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def register_specialist(body: RegisterSpecialistRequest, db: Session = Depends(get_db)):
    _check_email_unique(db, body.email)

    existing = db.query(Especialista).filter(Especialista.cedula == body.cedula).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Esta cédula profesional ya está registrada en el sistema.",
        )

    cedula_result = await validate_cedula(body.cedula)
    if not cedula_result.valid:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=cedula_result.message or "Cédula profesional inválida.",
        )

    user = Usuario(
        nombre=body.nombre,
        apellido_paterno=body.apellido_paterno,
        apellido_materno=body.apellido_materno,
        fecha_nacimiento=body.fecha_nacimiento,
    )
    db.add(user)
    db.flush()

    cred = Credencial(
        usuario=body.email.lower(),
        contrasena_hash=hash_password(body.password),
        id_usuario=user.id_usuario,
    )
    db.add(cred)

    especialista = Especialista(
        cedula=body.cedula,
        especialidad=cedula_result.especialidad or "General",
        id_genero=body.id_genero,
        id_usuario=user.id_usuario,
    )
    db.add(especialista)

    db.add(Consentimiento(id_usuario=user.id_usuario, tipo="privacidad", version="1.0"))
    db.add(Consentimiento(id_usuario=user.id_usuario, tipo="terminos_uso", version="1.0"))

    db.commit()

    token = create_access_token({"sub": str(user.id_usuario), "role": "especialista", "email": cred.usuario})
    return TokenResponse(
        access_token=token,
        role="especialista",
        user_id=user.id_usuario,
        nombre=user.nombre,
    )


@router.post("/validate-cedula", response_model=CedulaValidationResponse)
async def check_cedula(cedula: str):
    return await validate_cedula(cedula.strip())


@router.post("/logout")
def logout():
    return {"detail": "Sesión cerrada correctamente"}


@router.get("/profile", response_model=ProfileResponse)
def get_profile(user: Usuario = Depends(get_current_user), db: Session = Depends(get_db)):
    cred = db.query(Credencial).filter(Credencial.id_usuario == user.id_usuario).first()
    role = _get_role(db, user.id_usuario)

    result = {
        "nombre": user.nombre,
        "apellido_paterno": user.apellido_paterno,
        "apellido_materno": user.apellido_materno,
        "email": cred.usuario if cred else "",
        "fecha_nacimiento": user.fecha_nacimiento,
        "role": role,
    }

    if role == "especialista":
        esp = db.query(Especialista).filter(Especialista.id_usuario == user.id_usuario).first()
        if esp:
            result["cedula"] = esp.cedula
            result["especialidad"] = esp.especialidad
    elif role == "paciente":
        pac = db.query(Paciente).filter(Paciente.id_usuario == user.id_usuario).first()
        if pac:
            result["codigo_paciente"] = pac.codigo_paciente

    return result


@router.put("/profile", response_model=ProfileResponse)
def update_profile(
    body: ProfileUpdateRequest,
    user: Usuario = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if body.nombre is not None:
        user.nombre = body.nombre
    if body.apellido_paterno is not None:
        user.apellido_paterno = body.apellido_paterno
    if body.apellido_materno is not None:
        user.apellido_materno = body.apellido_materno
    db.commit()
    db.refresh(user)
    return get_profile(user=user, db=db)


def _check_email_unique(db: Session, email: str):
    exists = db.query(Credencial).filter(Credencial.usuario == email.lower()).first()
    if exists:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Este correo electrónico ya está registrado.",
        )


def _get_role(db: Session, user_id: int) -> str:
    if db.query(Especialista).filter(Especialista.id_usuario == user_id).first():
        return "especialista"
    if db.query(Paciente).filter(Paciente.id_usuario == user_id).first():
        return "paciente"
    return "unknown"
