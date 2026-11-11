-- Brain Test - PostgreSQL Schema
-- TT 2026-B141, ESCOM-IPN

-- ============================================================
-- CATALOGOS
-- ============================================================

CREATE TABLE cat_genero (
    id_genero    SERIAL PRIMARY KEY,
    nombre_genero VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE cat_escolaridad (
    id_escolaridad SERIAL PRIMARY KEY,
    escolaridad    VARCHAR(60) NOT NULL UNIQUE,
    anios          SMALLINT
);

CREATE TABLE cat_ocupacion (
    id_ocupacion SERIAL PRIMARY KEY,
    ocupacion    VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE cat_enfermedad (
    id_enfermedad    SERIAL PRIMARY KEY,
    nombre_enfermedad VARCHAR(120) NOT NULL UNIQUE
);

CREATE TABLE cat_parentesco (
    id_parentesco    SERIAL PRIMARY KEY,
    nombre_parentesco VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE cat_sustancia (
    id_sustancia    SERIAL PRIMARY KEY,
    nombre_sustancia VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE consumo_alcohol (
    id_consumo_alcohol SERIAL PRIMARY KEY,
    nivel_de_consumo_mensual VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE consumo_tabaco (
    id_consumo_tabaco SERIAL PRIMARY KEY,
    nivel_de_consumo_mensual VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE cat_area (
    id_area     SERIAL PRIMARY KEY,
    nombre_area VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE condicion_evaluacion (
    id_condicion_evaluacion SERIAL PRIMARY KEY,
    condicion               VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE validez_prueba (
    id_validez    SERIAL PRIMARY KEY,
    opcion_valida VARCHAR(60) NOT NULL UNIQUE
);

-- ============================================================
-- USUARIOS Y AUTENTICACION
-- ============================================================

CREATE TABLE usuario (
    id_usuario       SERIAL PRIMARY KEY,
    nombre           VARCHAR(80)  NOT NULL,
    apellido_paterno VARCHAR(80)  NOT NULL,
    apellido_materno VARCHAR(80),
    fecha_nacimiento DATE         NOT NULL,
    created_at       TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE TABLE credencial (
    id_credencial   SERIAL PRIMARY KEY,
    usuario         VARCHAR(120) NOT NULL UNIQUE,   -- correo electronico
    contrasena_hash VARCHAR(255) NOT NULL,
    id_usuario      INT          NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    intentos_fallidos SMALLINT   NOT NULL DEFAULT 0,
    bloqueado_hasta   TIMESTAMP,
    created_at      TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE TABLE consentimiento (
    id_consentimiento SERIAL PRIMARY KEY,
    id_usuario        INT          NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    tipo              VARCHAR(30)  NOT NULL,
    version           VARCHAR(20)  NOT NULL,
    fecha_aceptacion  TIMESTAMP    NOT NULL DEFAULT NOW(),
    CONSTRAINT ck_consentimiento_tipo CHECK (tipo IN ('privacidad', 'terminos_uso', 'datos_clinicos'))
);

-- ============================================================
-- PACIENTE
-- ============================================================

CREATE TABLE paciente (
    id_paciente SERIAL PRIMARY KEY,
    id_genero   INT NOT NULL REFERENCES cat_genero(id_genero),
    id_usuario  INT NOT NULL UNIQUE REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

-- ============================================================
-- ESPECIALISTA
-- ============================================================

CREATE TABLE especialista (
    id_especialista SERIAL PRIMARY KEY,
    cedula          VARCHAR(20)  NOT NULL UNIQUE,
    especialidad    VARCHAR(120) NOT NULL,
    id_genero       INT          NOT NULL REFERENCES cat_genero(id_genero),
    id_usuario      INT          NOT NULL UNIQUE REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

-- ============================================================
-- RELACION PACIENTE-ESPECIALISTA
-- ============================================================

CREATE TABLE paciente_especialista (
    id_paciente_especialista SERIAL PRIMARY KEY,
    id_paciente              INT  NOT NULL REFERENCES paciente(id_paciente) ON DELETE CASCADE,
    id_especialista          INT  NOT NULL REFERENCES especialista(id_especialista) ON DELETE CASCADE,
    fecha_vinculacion        DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_desvinculacion     DATE
);

-- ============================================================
-- EXPEDIENTE CLINICO DEL PACIENTE
-- ============================================================

CREATE TABLE expediente_clinico (
    id_expediente   SERIAL PRIMARY KEY,
    id_paciente     INT NOT NULL REFERENCES paciente(id_paciente) ON DELETE CASCADE,
    id_escolaridad  INT REFERENCES cat_escolaridad(id_escolaridad),
    id_ocupacion    INT REFERENCES cat_ocupacion(id_ocupacion),
    id_consumo_alcohol INT REFERENCES consumo_alcohol(id_consumo_alcohol),
    id_consumo_tabaco  INT REFERENCES consumo_tabaco(id_consumo_tabaco),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE enfermedad_paciente (
    id_paciente   INT NOT NULL REFERENCES paciente(id_paciente) ON DELETE CASCADE,
    id_enfermedad INT NOT NULL REFERENCES cat_enfermedad(id_enfermedad),
    PRIMARY KEY (id_paciente, id_enfermedad)
);

CREATE TABLE antecedente_familiar (
    id_antecedente_familiar SERIAL PRIMARY KEY,
    id_parentesco           INT NOT NULL REFERENCES cat_parentesco(id_parentesco),
    id_enfermedad           INT NOT NULL REFERENCES cat_enfermedad(id_enfermedad),
    id_paciente             INT NOT NULL REFERENCES paciente(id_paciente) ON DELETE CASCADE
);

CREATE TABLE sustancia_paciente (
    id_sustancia_paciente SERIAL PRIMARY KEY,
    id_paciente           INT NOT NULL REFERENCES paciente(id_paciente) ON DELETE CASCADE,
    id_sustancia          INT NOT NULL REFERENCES cat_sustancia(id_sustancia),
    frecuencia            VARCHAR(40),
    tiempo_consumo        VARCHAR(40)
);

-- ============================================================
-- EVALUACION MOCA
-- ============================================================

CREATE TABLE moca (
    id_moca         SERIAL PRIMARY KEY,
    id_paciente     INT       NOT NULL REFERENCES paciente(id_paciente),
    id_especialista INT       REFERENCES especialista(id_especialista),
    fecha           TIMESTAMP NOT NULL DEFAULT NOW(),
    puntaje_total   SMALLINT,
    clasificacion   VARCHAR(60),
    id_condicion_evaluacion INT REFERENCES condicion_evaluacion(id_condicion_evaluacion),
    id_validez      INT       REFERENCES validez_prueba(id_validez),
    completada      BOOLEAN   NOT NULL DEFAULT FALSE
);

CREATE TABLE resultado_area (
    id_resultado_area SERIAL PRIMARY KEY,
    id_moca           INT      NOT NULL REFERENCES moca(id_moca) ON DELETE CASCADE,
    id_area           INT      NOT NULL REFERENCES cat_area(id_area),
    puntaje_obtenido  SMALLINT NOT NULL,
    puntaje_maximo    SMALLINT NOT NULL,
    detalles          JSONB,
    UNIQUE (id_moca, id_area)
);

-- ============================================================
-- PREDICCION / MOTOR IA
-- ============================================================

CREATE TABLE prediccion (
    id_prediccion      SERIAL PRIMARY KEY,
    id_moca            INT          NOT NULL REFERENCES moca(id_moca) ON DELETE CASCADE,
    version_modelo     VARCHAR(40)  NOT NULL,
    variante           VARCHAR(20)  NOT NULL,
    p_normal           FLOAT        NOT NULL,
    p_dcl              FLOAT        NOT NULL,
    p_alzheimer        FLOAT        NOT NULL,
    p_vascular         FLOAT        NOT NULL,
    clase_predicha     VARCHAR(20)  NOT NULL,
    origen_clase       VARCHAR(20)  NOT NULL,
    prob_progresion    FLOAT,
    alerta_progresion  BOOLEAN,
    umbral_progresion  FLOAT,
    fecha_calculo      TIMESTAMP    NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_prediccion_moca_modelo UNIQUE (id_moca, version_modelo)
);

CREATE TABLE prediccion_dominio (
    id_prediccion_dominio SERIAL PRIMARY KEY,
    id_prediccion         INT      NOT NULL REFERENCES prediccion(id_prediccion) ON DELETE CASCADE,
    id_area               INT      NOT NULL REFERENCES cat_area(id_area),
    posicion              SMALLINT NOT NULL,
    contribucion          FLOAT    NOT NULL,
    CONSTRAINT ck_pred_dominio_pos CHECK (posicion BETWEEN 1 AND 8),
    CONSTRAINT uq_pred_dominio_pos UNIQUE (id_prediccion, posicion)
);

-- ============================================================
-- DIAGNOSTICO CLINICO
-- ============================================================

CREATE TABLE diagnostico_clinico (
    id_diagnostico  SERIAL PRIMARY KEY,
    id_paciente     INT          NOT NULL REFERENCES paciente(id_paciente),
    id_especialista INT          NOT NULL REFERENCES especialista(id_especialista),
    id_moca         INT          REFERENCES moca(id_moca),
    fecha           DATE         NOT NULL DEFAULT CURRENT_DATE,
    clase           VARCHAR(20)  NOT NULL,
    observaciones   TEXT,
    CONSTRAINT ck_diagnostico_clase CHECK (clase IN ('normal', 'dcl', 'alzheimer', 'vascular'))
);

-- ============================================================
-- SEGUIMIENTO LONGITUDINAL
-- ============================================================

CREATE TABLE seguimiento (
    id_seguimiento  SERIAL PRIMARY KEY,
    id_paciente     INT NOT NULL REFERENCES paciente(id_paciente),
    id_especialista INT NOT NULL REFERENCES especialista(id_especialista),
    id_area         INT NOT NULL REFERENCES cat_area(id_area),
    fecha_inicio    DATE NOT NULL DEFAULT CURRENT_DATE,
    meta            TEXT
);

CREATE TABLE seguimiento_periodico (
    id_seguimiento_periodico SERIAL PRIMARY KEY,
    id_seguimiento           INT       NOT NULL REFERENCES seguimiento(id_seguimiento) ON DELETE CASCADE,
    fecha_registro           TIMESTAMP NOT NULL DEFAULT NOW(),
    notas                    TEXT
);

-- ============================================================
-- ESTIMULACION COGNITIVA
-- ============================================================

CREATE TABLE cat_actividad (
    id_actividad     SERIAL PRIMARY KEY,
    nombre_actividad VARCHAR(150) NOT NULL,
    descripcion      TEXT,
    id_area          INT          NOT NULL REFERENCES cat_area(id_area)
);

CREATE TABLE actividad_asignada (
    id_actividad_asignada SERIAL PRIMARY KEY,
    id_actividad          INT  NOT NULL REFERENCES cat_actividad(id_actividad),
    id_paciente           INT  NOT NULL REFERENCES paciente(id_paciente),
    id_especialista       INT  REFERENCES especialista(id_especialista),
    id_moca               INT  REFERENCES moca(id_moca),
    fecha_asignacion      DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE actividad_realizada (
    id_actividad_realizada SERIAL PRIMARY KEY,
    id_actividad_asignada  INT       NOT NULL REFERENCES actividad_asignada(id_actividad_asignada) ON DELETE CASCADE,
    fecha_realizacion      TIMESTAMP NOT NULL DEFAULT NOW(),
    duracion_segundos      INT,
    aciertos               SMALLINT,
    intentos               SMALLINT,
    retroalimentacion      TEXT
);

-- ============================================================
-- NOTIFICACIONES
-- ============================================================

CREATE TABLE notificacion (
    id_notificacion    SERIAL PRIMARY KEY,
    id_especialista    INT          NOT NULL REFERENCES especialista(id_especialista),
    id_paciente        INT          NOT NULL REFERENCES paciente(id_paciente),
    id_moca            INT          NOT NULL REFERENCES moca(id_moca),
    tipo               VARCHAR(40)  NOT NULL,
    caida_puntos       SMALLINT,
    dominios_afectados TEXT,
    fecha_creacion     TIMESTAMP    NOT NULL DEFAULT NOW(),
    leida              BOOLEAN      NOT NULL DEFAULT FALSE,
    fecha_lectura      TIMESTAMP
);

-- ============================================================
-- REPORTES
-- ============================================================

CREATE TABLE reporte_pdf (
    id_reporte       SERIAL PRIMARY KEY,
    id_paciente      INT          NOT NULL REFERENCES paciente(id_paciente),
    id_especialista  INT          REFERENCES especialista(id_especialista),
    id_moca          INT          REFERENCES moca(id_moca),
    ruta_archivo     VARCHAR(500) NOT NULL,
    fecha_generacion TIMESTAMP    NOT NULL DEFAULT NOW(),
    conservar_hasta  DATE         NOT NULL
);

-- ============================================================
-- CODIGO DE SUPERVISION Y EXCEPCIONES
-- ============================================================

CREATE TABLE codigo_supervision (
    id_codigo         SERIAL PRIMARY KEY,
    id_paciente       INT          NOT NULL REFERENCES paciente(id_paciente),
    id_especialista   INT          NOT NULL REFERENCES especialista(id_especialista),
    codigo_hash       VARCHAR(255) NOT NULL,
    fecha_generacion  TIMESTAMP    NOT NULL DEFAULT NOW(),
    fecha_expiracion  TIMESTAMP    NOT NULL,
    usado             BOOLEAN      NOT NULL DEFAULT FALSE,
    id_moca           INT          REFERENCES moca(id_moca)
);

CREATE TABLE excepcion_evaluacion (
    id_excepcion          SERIAL PRIMARY KEY,
    id_paciente           INT       NOT NULL REFERENCES paciente(id_paciente),
    id_especialista       INT       NOT NULL REFERENCES especialista(id_especialista),
    id_moca               INT       REFERENCES moca(id_moca),
    fecha_autorizacion    TIMESTAMP NOT NULL DEFAULT NOW(),
    motivo                TEXT      NOT NULL
);

-- ============================================================
-- DATOS INICIALES DE CATALOGOS
-- ============================================================

INSERT INTO cat_genero (nombre_genero) VALUES
    ('Masculino'), ('Femenino'), ('No binario'), ('Prefiero no decir');

INSERT INTO cat_escolaridad (escolaridad, anios) VALUES
    ('Sin escolaridad', 0),
    ('Primaria incompleta', 3),
    ('Primaria completa', 6),
    ('Secundaria incompleta', 8),
    ('Secundaria completa', 9),
    ('Preparatoria incompleta', 11),
    ('Preparatoria completa', 12),
    ('Licenciatura incompleta', 14),
    ('Licenciatura completa', 16),
    ('Maestría', 18),
    ('Doctorado', 22);

INSERT INTO cat_ocupacion (ocupacion) VALUES
    ('Estudiante'), ('Empleado'), ('Independiente'), ('Jubilado'),
    ('Desempleado'), ('Hogar'), ('Otro');

INSERT INTO cat_area (nombre_area) VALUES
    ('Visuoespacial/Ejecutiva'),
    ('Identificación'),
    ('Memoria'),
    ('Atención'),
    ('Lenguaje'),
    ('Abstracción'),
    ('Recuerdo diferido'),
    ('Orientación');

INSERT INTO consumo_alcohol (nivel_de_consumo_mensual) VALUES
    ('Nunca'), ('Ocasional (1-3 veces)'), ('Moderado (4-8 veces)'),
    ('Frecuente (9-15 veces)'), ('Diario');

INSERT INTO consumo_tabaco (nivel_de_consumo_mensual) VALUES
    ('Nunca'), ('Ocasional (1-5 cigarrillos)'), ('Moderado (6-15 cigarrillos)'),
    ('Frecuente (16-30 cigarrillos)'), ('Diario (más de 30)');

INSERT INTO cat_enfermedad (nombre_enfermedad) VALUES
    ('Diabetes'), ('Hipertensión'), ('Enfermedad cardiovascular'),
    ('Enfermedad neurológica'), ('Enfermedad psiquiátrica'),
    ('Colesterol alto'), ('Alzheimer'), ('Parkinson'),
    ('Demencia vascular'), ('Depresión'), ('Ansiedad'), ('Otra');

INSERT INTO cat_parentesco (nombre_parentesco) VALUES
    ('Padre'), ('Madre'), ('Hermano/a'), ('Abuelo/a'),
    ('Tío/a'), ('Primo/a'), ('Otro');

INSERT INTO cat_sustancia (nombre_sustancia) VALUES
    ('Alcohol'), ('Tabaco'), ('Cannabis'), ('Cocaína'),
    ('Anfetaminas'), ('Benzodiacepinas'), ('Opioides'), ('Otra');

INSERT INTO condicion_evaluacion (condicion) VALUES
    ('Supervisada por profesional'), ('Autoadministrada con código'),
    ('Excepción autorizada');

INSERT INTO validez_prueba (opcion_valida) VALUES
    ('Válida'), ('Inválida - incompleta'), ('Inválida - cancelada'),
    ('Inválida - error técnico');
