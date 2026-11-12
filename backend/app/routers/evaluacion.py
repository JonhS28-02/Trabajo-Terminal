from __future__ import annotations

import secrets
from datetime import datetime, timedelta, timezone
from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from passlib.hash import bcrypt
from sqlalchemy.orm import Session

from ..database import get_db
from ..models.especialista import Especialista, PacienteEspecialista
from ..models.evaluacion import CodigoSupervision, Moca, ResultadoArea
from ..models.paciente import ExpedienteClinico, Paciente
from ..models.usuario import Usuario
from ..schemas.evaluacion import (
    FinalizarMocaRequest,
    GenerarCodigoRequest,
    GenerarCodigoResponse,
    GuardarResultadosRequest,
    MocaCompleteResponse,
    MocaResponse,
    ResultadoAreaResponse,
    SesionStatusResponse,
    ValidarCodigoRequest,
)
from ..security.jwt import get_current_user_role

router = APIRouter(prefix="/api/evaluacion", tags=["Evaluación MoCA"])

CODE_EXPIRY_MINUTES = 30


def _require_specialist(
    user_role: tuple[Usuario, str] = Depends(get_current_user_role),
    db: Session = Depends(get_db),
) -> Especialista:
    user, role = user_role
    if role != "especialista":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Solo especialistas")
    esp = db.query(Especialista).filter(Especialista.id_usuario == user.id_usuario).first()
    if not esp:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Especialista no encontrado")
    return esp


def _require_patient(
    user_role: tuple[Usuario, str] = Depends(get_current_user_role),
    db: Session = Depends(get_db),
) -> Paciente:
    user, role = user_role
    if role != "paciente":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Solo pacientes")
    pac = db.query(Paciente).filter(Paciente.id_usuario == user.id_usuario).first()
    if not pac:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Paciente no encontrado")
    return pac


def _verify_link(db: Session, id_especialista: int, id_paciente: int) -> None:
    link = (
        db.query(PacienteEspecialista)
        .filter(
            PacienteEspecialista.id_paciente == id_paciente,
            PacienteEspecialista.id_especialista == id_especialista,
            PacienteEspecialista.fecha_desvinculacion.is_(None),
        )
        .first()
    )
    if not link:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="No tiene vínculo activo con este paciente",
        )


@router.post("/codigo", response_model=GenerarCodigoResponse, status_code=status.HTTP_201_CREATED)
def generar_codigo(
    body: GenerarCodigoRequest,
    esp: Especialista = Depends(_require_specialist),
    db: Session = Depends(get_db),
):
    _verify_link(db, esp.id_especialista, body.id_paciente)

    expediente = (
        db.query(ExpedienteClinico)
        .filter(ExpedienteClinico.id_paciente == body.id_paciente)
        .first()
    )
    if not expediente:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El paciente no tiene expediente clínico",
        )

    db.query(CodigoSupervision).filter(
        CodigoSupervision.id_paciente == body.id_paciente,
        CodigoSupervision.id_especialista == esp.id_especialista,
        CodigoSupervision.usado == False,  # noqa: E712
    ).update({"usado": True})

    codigo_plano = str(secrets.randbelow(900000) + 100000)
    codigo_hash = bcrypt.hash(codigo_plano)
    expires_at = datetime.now(timezone.utc) + timedelta(minutes=CODE_EXPIRY_MINUTES)

    nuevo = CodigoSupervision(
        id_paciente=body.id_paciente,
        id_especialista=esp.id_especialista,
        codigo_hash=codigo_hash,
        fecha_expiracion=expires_at,
    )
    db.add(nuevo)
    db.commit()

    return GenerarCodigoResponse(codigo=codigo_plano, expires_at=expires_at)


@router.post("/validar-codigo", response_model=MocaResponse, status_code=status.HTTP_201_CREATED)
def validar_codigo(
    body: ValidarCodigoRequest,
    pac: Paciente = Depends(_require_patient),
    db: Session = Depends(get_db),
):
    now = datetime.now(timezone.utc)
    codigos = (
        db.query(CodigoSupervision)
        .filter(
            CodigoSupervision.id_paciente == pac.id_paciente,
            CodigoSupervision.usado == False,  # noqa: E712
            CodigoSupervision.fecha_expiracion > now,
        )
        .all()
    )

    matched = None
    for c in codigos:
        if bcrypt.verify(body.codigo, c.codigo_hash):
            matched = c
            break

    if not matched:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Código inválido o expirado",
        )

    moca = Moca(
        id_paciente=pac.id_paciente,
        id_especialista=matched.id_especialista,
    )
    db.add(moca)
    db.flush()

    matched.usado = True
    matched.id_moca = moca.id_moca
    db.commit()
    db.refresh(moca)

    return MocaResponse.model_validate(moca)


@router.get("/sesion/{id_moca}", response_model=SesionStatusResponse)
def obtener_sesion(
    id_moca: int,
    user_role: tuple[Usuario, str] = Depends(get_current_user_role),
    db: Session = Depends(get_db),
):
    user, role = user_role
    moca = db.query(Moca).filter(Moca.id_moca == id_moca).first()
    if not moca:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Sesión no encontrada")

    if role == "especialista":
        esp = db.query(Especialista).filter(Especialista.id_usuario == user.id_usuario).first()
        if not esp or esp.id_especialista != moca.id_especialista:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Sin acceso")
    elif role == "paciente":
        pac = db.query(Paciente).filter(Paciente.id_usuario == user.id_usuario).first()
        if not pac or pac.id_paciente != moca.id_paciente:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Sin acceso")
    else:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Rol no válido")

    paciente = db.query(Paciente).filter(Paciente.id_paciente == moca.id_paciente).first()
    usuario = db.query(Usuario).filter(Usuario.id_usuario == paciente.id_usuario).first()

    return SesionStatusResponse(
        id_moca=moca.id_moca,
        id_paciente=moca.id_paciente,
        id_especialista=moca.id_especialista,
        nombre_paciente=f"{usuario.nombre} {usuario.apellido_paterno}",
        fecha=moca.fecha,
        completada=moca.completada,
    )


def _get_moca_for_patient(db: Session, id_moca: int, pac: Paciente) -> Moca:
    moca = db.query(Moca).filter(Moca.id_moca == id_moca).first()
    if not moca:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Sesión no encontrada")
    if moca.id_paciente != pac.id_paciente:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Sin acceso a esta sesión")
    return moca


@router.post(
    "/sesion/{id_moca}/resultados",
    response_model=List[ResultadoAreaResponse],
    status_code=status.HTTP_201_CREATED,
)
def guardar_resultados(
    id_moca: int,
    body: GuardarResultadosRequest,
    pac: Paciente = Depends(_require_patient),
    db: Session = Depends(get_db),
):
    moca = _get_moca_for_patient(db, id_moca, pac)
    if moca.completada:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La sesión ya fue completada",
        )

    seen_areas: set[int] = set()
    for r in body.resultados:
        if r.id_area in seen_areas:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Área {r.id_area} duplicada",
            )
        seen_areas.add(r.id_area)
        if r.puntaje_obtenido > r.puntaje_maximo:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Puntaje obtenido ({r.puntaje_obtenido}) mayor que máximo ({r.puntaje_maximo}) en área {r.id_area}",
            )

    saved = []
    for r in body.resultados:
        existing = (
            db.query(ResultadoArea)
            .filter(ResultadoArea.id_moca == id_moca, ResultadoArea.id_area == r.id_area)
            .first()
        )
        if existing:
            existing.puntaje_obtenido = r.puntaje_obtenido
            existing.puntaje_maximo = r.puntaje_maximo
            existing.detalles = r.detalles
            saved.append(existing)
        else:
            nuevo = ResultadoArea(
                id_moca=id_moca,
                id_area=r.id_area,
                puntaje_obtenido=r.puntaje_obtenido,
                puntaje_maximo=r.puntaje_maximo,
                detalles=r.detalles,
            )
            db.add(nuevo)
            saved.append(nuevo)

    db.commit()
    for s in saved:
        db.refresh(s)

    return saved


@router.post("/sesion/{id_moca}/finalizar", response_model=MocaCompleteResponse)
def finalizar_moca(
    id_moca: int,
    body: FinalizarMocaRequest,
    pac: Paciente = Depends(_require_patient),
    db: Session = Depends(get_db),
):
    moca = _get_moca_for_patient(db, id_moca, pac)
    if moca.completada:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La sesión ya fue completada",
        )

    moca.puntaje_total = body.puntaje_total
    moca.clasificacion = body.clasificacion
    moca.completada = True
    db.commit()
    db.refresh(moca)

    resultados = (
        db.query(ResultadoArea)
        .filter(ResultadoArea.id_moca == id_moca)
        .order_by(ResultadoArea.id_area)
        .all()
    )

    return MocaCompleteResponse(
        id_moca=moca.id_moca,
        puntaje_total=moca.puntaje_total,
        clasificacion=moca.clasificacion,
        completada=moca.completada,
        resultados=[ResultadoAreaResponse.model_validate(r) for r in resultados],
    )


@router.get(
    "/sesion/{id_moca}/resultados",
    response_model=List[ResultadoAreaResponse],
)
def obtener_resultados(
    id_moca: int,
    user_role: tuple = Depends(get_current_user_role),
    db: Session = Depends(get_db),
):
    user, role = user_role
    moca = db.query(Moca).filter(Moca.id_moca == id_moca).first()
    if not moca:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Sesión no encontrada")

    if role == "especialista":
        esp = db.query(Especialista).filter(Especialista.id_usuario == user.id_usuario).first()
        if not esp or esp.id_especialista != moca.id_especialista:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Sin acceso")
    elif role == "paciente":
        pac = db.query(Paciente).filter(Paciente.id_usuario == user.id_usuario).first()
        if not pac or pac.id_paciente != moca.id_paciente:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Sin acceso")
    else:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Rol no válido")

    resultados = (
        db.query(ResultadoArea)
        .filter(ResultadoArea.id_moca == id_moca)
        .order_by(ResultadoArea.id_area)
        .all()
    )
    return resultados
