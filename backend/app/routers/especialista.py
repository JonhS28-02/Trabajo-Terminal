from __future__ import annotations

from datetime import date

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..models.catalogos import (
    CatEnfermedad,
    CatEscolaridad,
    CatOcupacion,
    CatParentesco,
    ConsumoAlcohol,
    ConsumoTabaco,
)
from ..models.especialista import Especialista, PacienteEspecialista
from ..models.paciente import (
    AntecedenteFamiliar,
    EnfermedadPaciente,
    ExpedienteClinico,
    Paciente,
)
from ..models.usuario import Usuario
from ..schemas.especialista import (
    AntecedenteFamiliarOut,
    CatalogoItem,
    EnfermedadItem,
    EscolaridadItem,
    ExpedienteRequest,
    ExpedienteResponse,
    PacienteResumen,
    VincularPacienteRequest,
    VincularResponse,
)
from ..security.jwt import get_current_user_role

router = APIRouter(prefix="/api/especialista", tags=["Especialista"])


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


@router.post("/vincular", response_model=VincularResponse, status_code=status.HTTP_201_CREATED)
def vincular_paciente(
    body: VincularPacienteRequest,
    esp: Especialista = Depends(_require_specialist),
    db: Session = Depends(get_db),
):
    paciente = db.query(Paciente).filter(Paciente.codigo_paciente == body.codigo_paciente).first()
    if not paciente:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Paciente no encontrado")

    existing = (
        db.query(PacienteEspecialista)
        .filter(
            PacienteEspecialista.id_paciente == paciente.id_paciente,
            PacienteEspecialista.id_especialista == esp.id_especialista,
            PacienteEspecialista.fecha_desvinculacion.is_(None),
        )
        .first()
    )
    if existing:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Este paciente ya está vinculado")

    link = PacienteEspecialista(
        id_paciente=paciente.id_paciente,
        id_especialista=esp.id_especialista,
        fecha_vinculacion=date.today(),
    )
    db.add(link)
    db.commit()

    resumen = _build_paciente_resumen(db, paciente, link.fecha_vinculacion)
    return VincularResponse(detail="Paciente vinculado exitosamente", paciente=resumen)


@router.get("/pacientes", response_model=list[PacienteResumen])
def listar_pacientes(
    esp: Especialista = Depends(_require_specialist),
    db: Session = Depends(get_db),
):
    links = (
        db.query(PacienteEspecialista)
        .filter(
            PacienteEspecialista.id_especialista == esp.id_especialista,
            PacienteEspecialista.fecha_desvinculacion.is_(None),
        )
        .all()
    )
    result = []
    for link in links:
        pac = db.query(Paciente).filter(Paciente.id_paciente == link.id_paciente).first()
        if pac:
            result.append(_build_paciente_resumen(db, pac, link.fecha_vinculacion))
    return result


@router.post(
    "/pacientes/{id_paciente}/expediente",
    response_model=ExpedienteResponse,
    status_code=status.HTTP_201_CREATED,
)
def crear_expediente(
    id_paciente: int,
    body: ExpedienteRequest,
    esp: Especialista = Depends(_require_specialist),
    db: Session = Depends(get_db),
):
    _verify_link(db, esp.id_especialista, id_paciente)

    existing = db.query(ExpedienteClinico).filter(ExpedienteClinico.id_paciente == id_paciente).first()
    if existing:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Ya existe un expediente para este paciente")

    expediente = ExpedienteClinico(
        id_paciente=id_paciente,
        id_escolaridad=body.id_escolaridad,
        id_ocupacion=body.id_ocupacion,
        id_consumo_alcohol=body.id_consumo_alcohol,
        id_consumo_tabaco=body.id_consumo_tabaco,
    )
    db.add(expediente)
    db.flush()

    for enf_id in body.enfermedades:
        db.add(EnfermedadPaciente(id_paciente=id_paciente, id_enfermedad=enf_id))

    for ant in body.antecedentes_familiares:
        db.add(AntecedenteFamiliar(
            id_parentesco=ant.id_parentesco,
            id_enfermedad=ant.id_enfermedad,
            id_paciente=id_paciente,
        ))

    db.commit()
    db.refresh(expediente)
    return _build_expediente_response(db, expediente, id_paciente)


@router.get("/pacientes/{id_paciente}/expediente", response_model=ExpedienteResponse)
def obtener_expediente(
    id_paciente: int,
    esp: Especialista = Depends(_require_specialist),
    db: Session = Depends(get_db),
):
    _verify_link(db, esp.id_especialista, id_paciente)

    expediente = db.query(ExpedienteClinico).filter(ExpedienteClinico.id_paciente == id_paciente).first()
    if not expediente:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Expediente no encontrado")
    return _build_expediente_response(db, expediente, id_paciente)


@router.put("/pacientes/{id_paciente}/expediente", response_model=ExpedienteResponse)
def actualizar_expediente(
    id_paciente: int,
    body: ExpedienteRequest,
    esp: Especialista = Depends(_require_specialist),
    db: Session = Depends(get_db),
):
    _verify_link(db, esp.id_especialista, id_paciente)

    expediente = db.query(ExpedienteClinico).filter(ExpedienteClinico.id_paciente == id_paciente).first()
    if not expediente:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Expediente no encontrado")

    expediente.id_escolaridad = body.id_escolaridad
    expediente.id_ocupacion = body.id_ocupacion
    expediente.id_consumo_alcohol = body.id_consumo_alcohol
    expediente.id_consumo_tabaco = body.id_consumo_tabaco

    db.query(EnfermedadPaciente).filter(EnfermedadPaciente.id_paciente == id_paciente).delete()
    for enf_id in body.enfermedades:
        db.add(EnfermedadPaciente(id_paciente=id_paciente, id_enfermedad=enf_id))

    db.query(AntecedenteFamiliar).filter(AntecedenteFamiliar.id_paciente == id_paciente).delete()
    for ant in body.antecedentes_familiares:
        db.add(AntecedenteFamiliar(
            id_parentesco=ant.id_parentesco,
            id_enfermedad=ant.id_enfermedad,
            id_paciente=id_paciente,
        ))

    db.commit()
    db.refresh(expediente)
    return _build_expediente_response(db, expediente, id_paciente)


# ── Catálogos (público para el form del frontend) ──

catalogos_router = APIRouter(prefix="/api/catalogos", tags=["Catálogos"])


@catalogos_router.get("/escolaridad", response_model=list[EscolaridadItem])
def listar_escolaridad(db: Session = Depends(get_db)):
    rows = db.query(CatEscolaridad).order_by(CatEscolaridad.anios).all()
    return [EscolaridadItem(id=r.id_escolaridad, nombre=r.escolaridad, anios=r.anios) for r in rows]


@catalogos_router.get("/ocupacion", response_model=list[CatalogoItem])
def listar_ocupacion(db: Session = Depends(get_db)):
    rows = db.query(CatOcupacion).order_by(CatOcupacion.id_ocupacion).all()
    return [CatalogoItem(id=r.id_ocupacion, nombre=r.ocupacion) for r in rows]


@catalogos_router.get("/enfermedades", response_model=list[EnfermedadItem])
def listar_enfermedades(db: Session = Depends(get_db)):
    rows = db.query(CatEnfermedad).order_by(CatEnfermedad.categoria, CatEnfermedad.nombre_enfermedad).all()
    return [
        EnfermedadItem(
            id=r.id_enfermedad,
            nombre=r.nombre_enfermedad,
            categoria=r.categoria,
            indicador_modelo=r.indicador_modelo,
        )
        for r in rows
    ]


@catalogos_router.get("/parentesco", response_model=list[CatalogoItem])
def listar_parentesco(db: Session = Depends(get_db)):
    rows = db.query(CatParentesco).order_by(CatParentesco.id_parentesco).all()
    return [CatalogoItem(id=r.id_parentesco, nombre=r.nombre_parentesco) for r in rows]


@catalogos_router.get("/consumo-alcohol", response_model=list[CatalogoItem])
def listar_consumo_alcohol(db: Session = Depends(get_db)):
    rows = db.query(ConsumoAlcohol).order_by(ConsumoAlcohol.id_consumo_alcohol).all()
    return [CatalogoItem(id=r.id_consumo_alcohol, nombre=r.nivel_de_consumo_mensual) for r in rows]


@catalogos_router.get("/consumo-tabaco", response_model=list[CatalogoItem])
def listar_consumo_tabaco(db: Session = Depends(get_db)):
    rows = db.query(ConsumoTabaco).order_by(ConsumoTabaco.id_consumo_tabaco).all()
    return [CatalogoItem(id=r.id_consumo_tabaco, nombre=r.nivel_de_consumo_mensual) for r in rows]


# ── Helpers ──

def _verify_link(db: Session, id_especialista: int, id_paciente: int) -> None:
    link = (
        db.query(PacienteEspecialista)
        .filter(
            PacienteEspecialista.id_especialista == id_especialista,
            PacienteEspecialista.id_paciente == id_paciente,
            PacienteEspecialista.fecha_desvinculacion.is_(None),
        )
        .first()
    )
    if not link:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="No tienes acceso a este paciente",
        )


def _build_paciente_resumen(db: Session, pac: Paciente, fecha_vinculacion: date) -> PacienteResumen:
    user = db.query(Usuario).filter(Usuario.id_usuario == pac.id_usuario).first()
    from ..models.catalogos import CatGenero
    genero = db.query(CatGenero).filter(CatGenero.id_genero == pac.id_genero).first()
    tiene_exp = db.query(ExpedienteClinico).filter(ExpedienteClinico.id_paciente == pac.id_paciente).first() is not None
    return PacienteResumen(
        id_paciente=pac.id_paciente,
        codigo_paciente=pac.codigo_paciente,
        nombre=user.nombre,
        apellido_paterno=user.apellido_paterno,
        apellido_materno=user.apellido_materno,
        fecha_nacimiento=user.fecha_nacimiento,
        genero=genero.nombre_genero if genero else "Desconocido",
        tiene_expediente=tiene_exp,
        fecha_vinculacion=fecha_vinculacion,
    )


def _build_expediente_response(
    db: Session,
    exp: ExpedienteClinico,
    id_paciente: int,
) -> ExpedienteResponse:
    esc = db.query(CatEscolaridad).filter(CatEscolaridad.id_escolaridad == exp.id_escolaridad).first() if exp.id_escolaridad else None
    ocu = db.query(CatOcupacion).filter(CatOcupacion.id_ocupacion == exp.id_ocupacion).first() if exp.id_ocupacion else None
    alc = db.query(ConsumoAlcohol).filter(ConsumoAlcohol.id_consumo_alcohol == exp.id_consumo_alcohol).first() if exp.id_consumo_alcohol else None
    tab = db.query(ConsumoTabaco).filter(ConsumoTabaco.id_consumo_tabaco == exp.id_consumo_tabaco).first() if exp.id_consumo_tabaco else None

    enf_rows = db.query(EnfermedadPaciente).filter(EnfermedadPaciente.id_paciente == id_paciente).all()
    enfermedades = [r.id_enfermedad for r in enf_rows]

    ant_rows = db.query(AntecedenteFamiliar).filter(AntecedenteFamiliar.id_paciente == id_paciente).all()
    antecedentes = []
    for a in ant_rows:
        par = db.query(CatParentesco).filter(CatParentesco.id_parentesco == a.id_parentesco).first()
        enf = db.query(CatEnfermedad).filter(CatEnfermedad.id_enfermedad == a.id_enfermedad).first()
        antecedentes.append(AntecedenteFamiliarOut(
            id_antecedente_familiar=a.id_antecedente_familiar,
            id_parentesco=a.id_parentesco,
            nombre_parentesco=par.nombre_parentesco if par else "",
            id_enfermedad=a.id_enfermedad,
            nombre_enfermedad=enf.nombre_enfermedad if enf else "",
        ))

    return ExpedienteResponse(
        id_expediente=exp.id_expediente,
        id_paciente=id_paciente,
        id_escolaridad=exp.id_escolaridad,
        escolaridad=esc.escolaridad if esc else None,
        anios_escolaridad=esc.anios if esc else None,
        id_ocupacion=exp.id_ocupacion,
        ocupacion=ocu.ocupacion if ocu else None,
        id_consumo_alcohol=exp.id_consumo_alcohol,
        consumo_alcohol=alc.nivel_de_consumo_mensual if alc else None,
        id_consumo_tabaco=exp.id_consumo_tabaco,
        consumo_tabaco=tab.nivel_de_consumo_mensual if tab else None,
        enfermedades=enfermedades,
        antecedentes_familiares=antecedentes,
        created_at=exp.created_at,
        updated_at=exp.updated_at,
    )
