
CREATE TABLE public.actividad_asignada (
    id_actividad_asignada integer NOT NULL,
    id_actividad integer NOT NULL,
    id_paciente integer NOT NULL,
    id_especialista integer,
    id_moca integer,
    fecha_asignacion date DEFAULT CURRENT_DATE NOT NULL
);

CREATE SEQUENCE public.actividad_asignada_id_actividad_asignada_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.actividad_asignada_id_actividad_asignada_seq OWNED BY public.actividad_asignada.id_actividad_asignada;

CREATE TABLE public.actividad_realizada (
    id_actividad_realizada integer NOT NULL,
    id_actividad_asignada integer NOT NULL,
    fecha_realizacion timestamp without time zone DEFAULT now() NOT NULL,
    duracion_segundos integer,
    aciertos smallint,
    intentos smallint,
    retroalimentacion text
);

CREATE SEQUENCE public.actividad_realizada_id_actividad_realizada_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.actividad_realizada_id_actividad_realizada_seq OWNED BY public.actividad_realizada.id_actividad_realizada;

CREATE TABLE public.antecedente_familiar (
    id_antecedente_familiar integer NOT NULL,
    id_parentesco integer NOT NULL,
    id_enfermedad integer NOT NULL,
    id_paciente integer NOT NULL
);

CREATE SEQUENCE public.antecedente_familiar_id_antecedente_familiar_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.antecedente_familiar_id_antecedente_familiar_seq OWNED BY public.antecedente_familiar.id_antecedente_familiar;

CREATE TABLE public.cat_actividad (
    id_actividad integer NOT NULL,
    nombre_actividad character varying(150) NOT NULL,
    descripcion text,
    id_area integer NOT NULL
);

CREATE SEQUENCE public.cat_actividad_id_actividad_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.cat_actividad_id_actividad_seq OWNED BY public.cat_actividad.id_actividad;

CREATE TABLE public.cat_area (
    id_area integer NOT NULL,
    nombre_area character varying(80) NOT NULL
);

CREATE SEQUENCE public.cat_area_id_area_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.cat_area_id_area_seq OWNED BY public.cat_area.id_area;

CREATE TABLE public.cat_enfermedad (
    id_enfermedad integer NOT NULL,
    nombre_enfermedad character varying(120) NOT NULL,
    categoria character varying(60) DEFAULT 'General'::character varying NOT NULL,
    indicador_modelo character varying(40)
);

CREATE SEQUENCE public.cat_enfermedad_id_enfermedad_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.cat_enfermedad_id_enfermedad_seq OWNED BY public.cat_enfermedad.id_enfermedad;

CREATE TABLE public.cat_escolaridad (
    id_escolaridad integer NOT NULL,
    escolaridad character varying(60) NOT NULL,
    anios smallint
);

CREATE SEQUENCE public.cat_escolaridad_id_escolaridad_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.cat_escolaridad_id_escolaridad_seq OWNED BY public.cat_escolaridad.id_escolaridad;

CREATE TABLE public.cat_genero (
    id_genero integer NOT NULL,
    nombre_genero character varying(30) NOT NULL
);

CREATE SEQUENCE public.cat_genero_id_genero_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.cat_genero_id_genero_seq OWNED BY public.cat_genero.id_genero;

CREATE TABLE public.cat_ocupacion (
    id_ocupacion integer NOT NULL,
    ocupacion character varying(80) NOT NULL
);

CREATE SEQUENCE public.cat_ocupacion_id_ocupacion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.cat_ocupacion_id_ocupacion_seq OWNED BY public.cat_ocupacion.id_ocupacion;

CREATE TABLE public.cat_parentesco (
    id_parentesco integer NOT NULL,
    nombre_parentesco character varying(60) NOT NULL
);

CREATE SEQUENCE public.cat_parentesco_id_parentesco_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.cat_parentesco_id_parentesco_seq OWNED BY public.cat_parentesco.id_parentesco;

CREATE TABLE public.cat_sustancia (
    id_sustancia integer NOT NULL,
    nombre_sustancia character varying(80) NOT NULL
);

CREATE SEQUENCE public.cat_sustancia_id_sustancia_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.cat_sustancia_id_sustancia_seq OWNED BY public.cat_sustancia.id_sustancia;

CREATE TABLE public.codigo_supervision (
    id_codigo integer NOT NULL,
    id_paciente integer NOT NULL,
    id_especialista integer NOT NULL,
    codigo_hash character varying(255) NOT NULL,
    fecha_generacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_expiracion timestamp without time zone NOT NULL,
    usado boolean DEFAULT false NOT NULL,
    id_moca integer
);

CREATE SEQUENCE public.codigo_supervision_id_codigo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.codigo_supervision_id_codigo_seq OWNED BY public.codigo_supervision.id_codigo;

CREATE TABLE public.condicion_evaluacion (
    id_condicion_evaluacion integer NOT NULL,
    condicion character varying(100) NOT NULL
);

CREATE SEQUENCE public.condicion_evaluacion_id_condicion_evaluacion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.condicion_evaluacion_id_condicion_evaluacion_seq OWNED BY public.condicion_evaluacion.id_condicion_evaluacion;

CREATE TABLE public.consentimiento (
    id_consentimiento integer NOT NULL,
    id_usuario integer NOT NULL,
    tipo character varying(30) NOT NULL,
    version character varying(20) NOT NULL,
    fecha_aceptacion timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_consentimiento_tipo CHECK (((tipo)::text = ANY ((ARRAY['privacidad'::character varying, 'terminos_uso'::character varying, 'datos_clinicos'::character varying])::text[])))
);

CREATE SEQUENCE public.consentimiento_id_consentimiento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.consentimiento_id_consentimiento_seq OWNED BY public.consentimiento.id_consentimiento;

CREATE TABLE public.consumo_alcohol (
    id_consumo_alcohol integer NOT NULL,
    nivel_de_consumo_mensual character varying(60) NOT NULL
);

CREATE SEQUENCE public.consumo_alcohol_id_consumo_alcohol_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.consumo_alcohol_id_consumo_alcohol_seq OWNED BY public.consumo_alcohol.id_consumo_alcohol;

CREATE TABLE public.consumo_tabaco (
    id_consumo_tabaco integer NOT NULL,
    nivel_de_consumo_mensual character varying(60) NOT NULL
);

CREATE SEQUENCE public.consumo_tabaco_id_consumo_tabaco_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.consumo_tabaco_id_consumo_tabaco_seq OWNED BY public.consumo_tabaco.id_consumo_tabaco;

CREATE TABLE public.credencial (
    id_credencial integer NOT NULL,
    usuario character varying(120) NOT NULL,
    contrasena_hash character varying(255) NOT NULL,
    id_usuario integer NOT NULL,
    intentos_fallidos smallint DEFAULT 0 NOT NULL,
    bloqueado_hasta timestamp without time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    codigo_recuperacion character varying(6),
    codigo_recuperacion_expira timestamp without time zone
);

CREATE SEQUENCE public.credencial_id_credencial_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.credencial_id_credencial_seq OWNED BY public.credencial.id_credencial;

CREATE TABLE public.diagnostico_clinico (
    id_diagnostico integer NOT NULL,
    id_paciente integer NOT NULL,
    id_especialista integer NOT NULL,
    id_moca integer,
    fecha date DEFAULT CURRENT_DATE NOT NULL,
    clase character varying(20) NOT NULL,
    observaciones text,
    CONSTRAINT ck_diagnostico_clase CHECK (((clase)::text = ANY ((ARRAY['normal'::character varying, 'dcl'::character varying, 'alzheimer'::character varying, 'vascular'::character varying])::text[])))
);

CREATE SEQUENCE public.diagnostico_clinico_id_diagnostico_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.diagnostico_clinico_id_diagnostico_seq OWNED BY public.diagnostico_clinico.id_diagnostico;

CREATE TABLE public.enfermedad_paciente (
    id_paciente integer NOT NULL,
    id_enfermedad integer NOT NULL
);

CREATE TABLE public.especialista (
    id_especialista integer NOT NULL,
    cedula character varying(20) NOT NULL,
    especialidad character varying(120) NOT NULL,
    id_genero integer NOT NULL,
    id_usuario integer NOT NULL
);

CREATE SEQUENCE public.especialista_id_especialista_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.especialista_id_especialista_seq OWNED BY public.especialista.id_especialista;

CREATE TABLE public.excepcion_evaluacion (
    id_excepcion integer NOT NULL,
    id_paciente integer NOT NULL,
    id_especialista integer NOT NULL,
    id_moca integer,
    fecha_autorizacion timestamp without time zone DEFAULT now() NOT NULL,
    motivo text NOT NULL
);

CREATE SEQUENCE public.excepcion_evaluacion_id_excepcion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.excepcion_evaluacion_id_excepcion_seq OWNED BY public.excepcion_evaluacion.id_excepcion;

CREATE TABLE public.expediente_clinico (
    id_expediente integer NOT NULL,
    id_paciente integer NOT NULL,
    id_escolaridad integer,
    id_ocupacion integer,
    id_consumo_alcohol integer,
    id_consumo_tabaco integer,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);

CREATE SEQUENCE public.expediente_clinico_id_expediente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.expediente_clinico_id_expediente_seq OWNED BY public.expediente_clinico.id_expediente;

CREATE TABLE public.moca (
    id_moca integer NOT NULL,
    id_paciente integer NOT NULL,
    id_especialista integer,
    fecha timestamp without time zone DEFAULT now() NOT NULL,
    puntaje_total smallint,
    clasificacion character varying(60),
    id_condicion_evaluacion integer,
    id_validez integer,
    completada boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE public.moca_id_moca_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.moca_id_moca_seq OWNED BY public.moca.id_moca;

CREATE TABLE public.nota_clinica (
    id_nota integer NOT NULL,
    id_paciente integer NOT NULL,
    id_especialista integer NOT NULL,
    id_moca integer,
    impresion_diagnostica character varying(20),
    nota text NOT NULL,
    plan text,
    fecha_seguimiento date,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);

CREATE SEQUENCE public.nota_clinica_id_nota_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.nota_clinica_id_nota_seq OWNED BY public.nota_clinica.id_nota;

CREATE TABLE public.notificacion (
    id_notificacion integer NOT NULL,
    id_especialista integer NOT NULL,
    id_paciente integer NOT NULL,
    id_moca integer NOT NULL,
    tipo character varying(40) NOT NULL,
    caida_puntos smallint,
    dominios_afectados text,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    leida boolean DEFAULT false NOT NULL,
    fecha_lectura timestamp without time zone
);

CREATE SEQUENCE public.notificacion_id_notificacion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.notificacion_id_notificacion_seq OWNED BY public.notificacion.id_notificacion;

CREATE TABLE public.paciente (
    id_paciente integer NOT NULL,
    id_genero integer NOT NULL,
    id_usuario integer NOT NULL,
    codigo_paciente character varying(10) NOT NULL
);

CREATE TABLE public.paciente_especialista (
    id_paciente_especialista integer NOT NULL,
    id_paciente integer NOT NULL,
    id_especialista integer NOT NULL,
    fecha_vinculacion date DEFAULT CURRENT_DATE NOT NULL,
    fecha_desvinculacion date
);

CREATE SEQUENCE public.paciente_especialista_id_paciente_especialista_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.paciente_especialista_id_paciente_especialista_seq OWNED BY public.paciente_especialista.id_paciente_especialista;

CREATE SEQUENCE public.paciente_id_paciente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.paciente_id_paciente_seq OWNED BY public.paciente.id_paciente;

CREATE TABLE public.prediccion (
    id_prediccion integer NOT NULL,
    id_moca integer NOT NULL,
    version_modelo character varying(40) NOT NULL,
    variante character varying(20) NOT NULL,
    p_normal double precision NOT NULL,
    p_dcl double precision NOT NULL,
    p_alzheimer double precision NOT NULL,
    p_vascular double precision NOT NULL,
    clase_predicha character varying(20) NOT NULL,
    origen_clase character varying(20) NOT NULL,
    prob_progresion double precision,
    alerta_progresion boolean,
    umbral_progresion double precision,
    fecha_calculo timestamp without time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.prediccion_dominio (
    id_prediccion_dominio integer NOT NULL,
    id_prediccion integer NOT NULL,
    id_area integer NOT NULL,
    posicion smallint NOT NULL,
    contribucion double precision NOT NULL,
    CONSTRAINT ck_pred_dominio_pos CHECK (((posicion >= 1) AND (posicion <= 8)))
);

CREATE SEQUENCE public.prediccion_dominio_id_prediccion_dominio_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.prediccion_dominio_id_prediccion_dominio_seq OWNED BY public.prediccion_dominio.id_prediccion_dominio;

CREATE SEQUENCE public.prediccion_id_prediccion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.prediccion_id_prediccion_seq OWNED BY public.prediccion.id_prediccion;

CREATE TABLE public.reporte_pdf (
    id_reporte integer NOT NULL,
    id_paciente integer NOT NULL,
    id_especialista integer,
    id_moca integer,
    ruta_archivo character varying(500) NOT NULL,
    fecha_generacion timestamp without time zone DEFAULT now() NOT NULL,
    conservar_hasta date NOT NULL
);

CREATE SEQUENCE public.reporte_pdf_id_reporte_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.reporte_pdf_id_reporte_seq OWNED BY public.reporte_pdf.id_reporte;

CREATE TABLE public.resultado_area (
    id_resultado_area integer NOT NULL,
    id_moca integer NOT NULL,
    id_area integer NOT NULL,
    puntaje_obtenido smallint NOT NULL,
    puntaje_maximo smallint NOT NULL,
    detalles jsonb
);

CREATE SEQUENCE public.resultado_area_id_resultado_area_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.resultado_area_id_resultado_area_seq OWNED BY public.resultado_area.id_resultado_area;

CREATE TABLE public.seguimiento (
    id_seguimiento integer NOT NULL,
    id_paciente integer NOT NULL,
    id_especialista integer NOT NULL,
    id_area integer NOT NULL,
    fecha_inicio date DEFAULT CURRENT_DATE NOT NULL,
    meta text
);

CREATE SEQUENCE public.seguimiento_id_seguimiento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.seguimiento_id_seguimiento_seq OWNED BY public.seguimiento.id_seguimiento;

CREATE TABLE public.seguimiento_periodico (
    id_seguimiento_periodico integer NOT NULL,
    id_seguimiento integer NOT NULL,
    fecha_registro timestamp without time zone DEFAULT now() NOT NULL,
    notas text
);

CREATE SEQUENCE public.seguimiento_periodico_id_seguimiento_periodico_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.seguimiento_periodico_id_seguimiento_periodico_seq OWNED BY public.seguimiento_periodico.id_seguimiento_periodico;

CREATE TABLE public.sustancia_paciente (
    id_sustancia_paciente integer NOT NULL,
    id_paciente integer NOT NULL,
    id_sustancia integer NOT NULL,
    frecuencia character varying(40),
    tiempo_consumo character varying(40)
);

CREATE SEQUENCE public.sustancia_paciente_id_sustancia_paciente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.sustancia_paciente_id_sustancia_paciente_seq OWNED BY public.sustancia_paciente.id_sustancia_paciente;

CREATE TABLE public.usuario (
    id_usuario integer NOT NULL,
    nombre character varying(80) NOT NULL,
    apellido_paterno character varying(80) NOT NULL,
    apellido_materno character varying(80),
    fecha_nacimiento date NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);

CREATE SEQUENCE public.usuario_id_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.usuario_id_usuario_seq OWNED BY public.usuario.id_usuario;

CREATE TABLE public.validez_prueba (
    id_validez integer NOT NULL,
    opcion_valida character varying(60) NOT NULL
);

CREATE SEQUENCE public.validez_prueba_id_validez_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.validez_prueba_id_validez_seq OWNED BY public.validez_prueba.id_validez;

ALTER TABLE ONLY public.actividad_asignada ALTER COLUMN id_actividad_asignada SET DEFAULT nextval('public.actividad_asignada_id_actividad_asignada_seq'::regclass);

ALTER TABLE ONLY public.actividad_realizada ALTER COLUMN id_actividad_realizada SET DEFAULT nextval('public.actividad_realizada_id_actividad_realizada_seq'::regclass);

ALTER TABLE ONLY public.antecedente_familiar ALTER COLUMN id_antecedente_familiar SET DEFAULT nextval('public.antecedente_familiar_id_antecedente_familiar_seq'::regclass);

ALTER TABLE ONLY public.cat_actividad ALTER COLUMN id_actividad SET DEFAULT nextval('public.cat_actividad_id_actividad_seq'::regclass);

ALTER TABLE ONLY public.cat_area ALTER COLUMN id_area SET DEFAULT nextval('public.cat_area_id_area_seq'::regclass);

ALTER TABLE ONLY public.cat_enfermedad ALTER COLUMN id_enfermedad SET DEFAULT nextval('public.cat_enfermedad_id_enfermedad_seq'::regclass);

ALTER TABLE ONLY public.cat_escolaridad ALTER COLUMN id_escolaridad SET DEFAULT nextval('public.cat_escolaridad_id_escolaridad_seq'::regclass);

ALTER TABLE ONLY public.cat_genero ALTER COLUMN id_genero SET DEFAULT nextval('public.cat_genero_id_genero_seq'::regclass);

ALTER TABLE ONLY public.cat_ocupacion ALTER COLUMN id_ocupacion SET DEFAULT nextval('public.cat_ocupacion_id_ocupacion_seq'::regclass);

ALTER TABLE ONLY public.cat_parentesco ALTER COLUMN id_parentesco SET DEFAULT nextval('public.cat_parentesco_id_parentesco_seq'::regclass);

ALTER TABLE ONLY public.cat_sustancia ALTER COLUMN id_sustancia SET DEFAULT nextval('public.cat_sustancia_id_sustancia_seq'::regclass);

ALTER TABLE ONLY public.codigo_supervision ALTER COLUMN id_codigo SET DEFAULT nextval('public.codigo_supervision_id_codigo_seq'::regclass);

ALTER TABLE ONLY public.condicion_evaluacion ALTER COLUMN id_condicion_evaluacion SET DEFAULT nextval('public.condicion_evaluacion_id_condicion_evaluacion_seq'::regclass);

ALTER TABLE ONLY public.consentimiento ALTER COLUMN id_consentimiento SET DEFAULT nextval('public.consentimiento_id_consentimiento_seq'::regclass);

ALTER TABLE ONLY public.consumo_alcohol ALTER COLUMN id_consumo_alcohol SET DEFAULT nextval('public.consumo_alcohol_id_consumo_alcohol_seq'::regclass);

ALTER TABLE ONLY public.consumo_tabaco ALTER COLUMN id_consumo_tabaco SET DEFAULT nextval('public.consumo_tabaco_id_consumo_tabaco_seq'::regclass);

ALTER TABLE ONLY public.credencial ALTER COLUMN id_credencial SET DEFAULT nextval('public.credencial_id_credencial_seq'::regclass);

ALTER TABLE ONLY public.diagnostico_clinico ALTER COLUMN id_diagnostico SET DEFAULT nextval('public.diagnostico_clinico_id_diagnostico_seq'::regclass);

ALTER TABLE ONLY public.especialista ALTER COLUMN id_especialista SET DEFAULT nextval('public.especialista_id_especialista_seq'::regclass);

ALTER TABLE ONLY public.excepcion_evaluacion ALTER COLUMN id_excepcion SET DEFAULT nextval('public.excepcion_evaluacion_id_excepcion_seq'::regclass);

ALTER TABLE ONLY public.expediente_clinico ALTER COLUMN id_expediente SET DEFAULT nextval('public.expediente_clinico_id_expediente_seq'::regclass);

ALTER TABLE ONLY public.moca ALTER COLUMN id_moca SET DEFAULT nextval('public.moca_id_moca_seq'::regclass);

ALTER TABLE ONLY public.nota_clinica ALTER COLUMN id_nota SET DEFAULT nextval('public.nota_clinica_id_nota_seq'::regclass);

ALTER TABLE ONLY public.notificacion ALTER COLUMN id_notificacion SET DEFAULT nextval('public.notificacion_id_notificacion_seq'::regclass);

ALTER TABLE ONLY public.paciente ALTER COLUMN id_paciente SET DEFAULT nextval('public.paciente_id_paciente_seq'::regclass);

ALTER TABLE ONLY public.paciente_especialista ALTER COLUMN id_paciente_especialista SET DEFAULT nextval('public.paciente_especialista_id_paciente_especialista_seq'::regclass);

ALTER TABLE ONLY public.prediccion ALTER COLUMN id_prediccion SET DEFAULT nextval('public.prediccion_id_prediccion_seq'::regclass);

ALTER TABLE ONLY public.prediccion_dominio ALTER COLUMN id_prediccion_dominio SET DEFAULT nextval('public.prediccion_dominio_id_prediccion_dominio_seq'::regclass);

ALTER TABLE ONLY public.reporte_pdf ALTER COLUMN id_reporte SET DEFAULT nextval('public.reporte_pdf_id_reporte_seq'::regclass);

ALTER TABLE ONLY public.resultado_area ALTER COLUMN id_resultado_area SET DEFAULT nextval('public.resultado_area_id_resultado_area_seq'::regclass);

ALTER TABLE ONLY public.seguimiento ALTER COLUMN id_seguimiento SET DEFAULT nextval('public.seguimiento_id_seguimiento_seq'::regclass);

ALTER TABLE ONLY public.seguimiento_periodico ALTER COLUMN id_seguimiento_periodico SET DEFAULT nextval('public.seguimiento_periodico_id_seguimiento_periodico_seq'::regclass);

ALTER TABLE ONLY public.sustancia_paciente ALTER COLUMN id_sustancia_paciente SET DEFAULT nextval('public.sustancia_paciente_id_sustancia_paciente_seq'::regclass);

ALTER TABLE ONLY public.usuario ALTER COLUMN id_usuario SET DEFAULT nextval('public.usuario_id_usuario_seq'::regclass);

ALTER TABLE ONLY public.validez_prueba ALTER COLUMN id_validez SET DEFAULT nextval('public.validez_prueba_id_validez_seq'::regclass);

ALTER TABLE ONLY public.actividad_asignada
    ADD CONSTRAINT actividad_asignada_pkey PRIMARY KEY (id_actividad_asignada);

ALTER TABLE ONLY public.actividad_realizada
    ADD CONSTRAINT actividad_realizada_pkey PRIMARY KEY (id_actividad_realizada);

ALTER TABLE ONLY public.antecedente_familiar
    ADD CONSTRAINT antecedente_familiar_pkey PRIMARY KEY (id_antecedente_familiar);

ALTER TABLE ONLY public.cat_actividad
    ADD CONSTRAINT cat_actividad_pkey PRIMARY KEY (id_actividad);

ALTER TABLE ONLY public.cat_area
    ADD CONSTRAINT cat_area_nombre_area_key UNIQUE (nombre_area);

ALTER TABLE ONLY public.cat_area
    ADD CONSTRAINT cat_area_pkey PRIMARY KEY (id_area);

ALTER TABLE ONLY public.cat_enfermedad
    ADD CONSTRAINT cat_enfermedad_nombre_enfermedad_key UNIQUE (nombre_enfermedad);

ALTER TABLE ONLY public.cat_enfermedad
    ADD CONSTRAINT cat_enfermedad_pkey PRIMARY KEY (id_enfermedad);

ALTER TABLE ONLY public.cat_escolaridad
    ADD CONSTRAINT cat_escolaridad_escolaridad_key UNIQUE (escolaridad);

ALTER TABLE ONLY public.cat_escolaridad
    ADD CONSTRAINT cat_escolaridad_pkey PRIMARY KEY (id_escolaridad);

ALTER TABLE ONLY public.cat_genero
    ADD CONSTRAINT cat_genero_nombre_genero_key UNIQUE (nombre_genero);

ALTER TABLE ONLY public.cat_genero
    ADD CONSTRAINT cat_genero_pkey PRIMARY KEY (id_genero);

ALTER TABLE ONLY public.cat_ocupacion
    ADD CONSTRAINT cat_ocupacion_ocupacion_key UNIQUE (ocupacion);

ALTER TABLE ONLY public.cat_ocupacion
    ADD CONSTRAINT cat_ocupacion_pkey PRIMARY KEY (id_ocupacion);

ALTER TABLE ONLY public.cat_parentesco
    ADD CONSTRAINT cat_parentesco_nombre_parentesco_key UNIQUE (nombre_parentesco);

ALTER TABLE ONLY public.cat_parentesco
    ADD CONSTRAINT cat_parentesco_pkey PRIMARY KEY (id_parentesco);

ALTER TABLE ONLY public.cat_sustancia
    ADD CONSTRAINT cat_sustancia_nombre_sustancia_key UNIQUE (nombre_sustancia);

ALTER TABLE ONLY public.cat_sustancia
    ADD CONSTRAINT cat_sustancia_pkey PRIMARY KEY (id_sustancia);

ALTER TABLE ONLY public.codigo_supervision
    ADD CONSTRAINT codigo_supervision_pkey PRIMARY KEY (id_codigo);

ALTER TABLE ONLY public.condicion_evaluacion
    ADD CONSTRAINT condicion_evaluacion_condicion_key UNIQUE (condicion);

ALTER TABLE ONLY public.condicion_evaluacion
    ADD CONSTRAINT condicion_evaluacion_pkey PRIMARY KEY (id_condicion_evaluacion);

ALTER TABLE ONLY public.consentimiento
    ADD CONSTRAINT consentimiento_pkey PRIMARY KEY (id_consentimiento);

ALTER TABLE ONLY public.consumo_alcohol
    ADD CONSTRAINT consumo_alcohol_nivel_de_consumo_mensual_key UNIQUE (nivel_de_consumo_mensual);

ALTER TABLE ONLY public.consumo_alcohol
    ADD CONSTRAINT consumo_alcohol_pkey PRIMARY KEY (id_consumo_alcohol);

ALTER TABLE ONLY public.consumo_tabaco
    ADD CONSTRAINT consumo_tabaco_nivel_de_consumo_mensual_key UNIQUE (nivel_de_consumo_mensual);

ALTER TABLE ONLY public.consumo_tabaco
    ADD CONSTRAINT consumo_tabaco_pkey PRIMARY KEY (id_consumo_tabaco);

ALTER TABLE ONLY public.credencial
    ADD CONSTRAINT credencial_pkey PRIMARY KEY (id_credencial);

ALTER TABLE ONLY public.credencial
    ADD CONSTRAINT credencial_usuario_key UNIQUE (usuario);

ALTER TABLE ONLY public.diagnostico_clinico
    ADD CONSTRAINT diagnostico_clinico_pkey PRIMARY KEY (id_diagnostico);

ALTER TABLE ONLY public.enfermedad_paciente
    ADD CONSTRAINT enfermedad_paciente_pkey PRIMARY KEY (id_paciente, id_enfermedad);

ALTER TABLE ONLY public.especialista
    ADD CONSTRAINT especialista_cedula_key UNIQUE (cedula);

ALTER TABLE ONLY public.especialista
    ADD CONSTRAINT especialista_id_usuario_key UNIQUE (id_usuario);

ALTER TABLE ONLY public.especialista
    ADD CONSTRAINT especialista_pkey PRIMARY KEY (id_especialista);

ALTER TABLE ONLY public.excepcion_evaluacion
    ADD CONSTRAINT excepcion_evaluacion_pkey PRIMARY KEY (id_excepcion);

ALTER TABLE ONLY public.expediente_clinico
    ADD CONSTRAINT expediente_clinico_pkey PRIMARY KEY (id_expediente);

ALTER TABLE ONLY public.moca
    ADD CONSTRAINT moca_pkey PRIMARY KEY (id_moca);

ALTER TABLE ONLY public.nota_clinica
    ADD CONSTRAINT nota_clinica_pkey PRIMARY KEY (id_nota);

ALTER TABLE ONLY public.notificacion
    ADD CONSTRAINT notificacion_pkey PRIMARY KEY (id_notificacion);

ALTER TABLE ONLY public.paciente_especialista
    ADD CONSTRAINT paciente_especialista_pkey PRIMARY KEY (id_paciente_especialista);

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_id_usuario_key UNIQUE (id_usuario);

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_pkey PRIMARY KEY (id_paciente);

ALTER TABLE ONLY public.prediccion_dominio
    ADD CONSTRAINT prediccion_dominio_pkey PRIMARY KEY (id_prediccion_dominio);

ALTER TABLE ONLY public.prediccion
    ADD CONSTRAINT prediccion_pkey PRIMARY KEY (id_prediccion);

ALTER TABLE ONLY public.reporte_pdf
    ADD CONSTRAINT reporte_pdf_pkey PRIMARY KEY (id_reporte);

ALTER TABLE ONLY public.resultado_area
    ADD CONSTRAINT resultado_area_id_moca_id_area_key UNIQUE (id_moca, id_area);

ALTER TABLE ONLY public.resultado_area
    ADD CONSTRAINT resultado_area_pkey PRIMARY KEY (id_resultado_area);

ALTER TABLE ONLY public.seguimiento_periodico
    ADD CONSTRAINT seguimiento_periodico_pkey PRIMARY KEY (id_seguimiento_periodico);

ALTER TABLE ONLY public.seguimiento
    ADD CONSTRAINT seguimiento_pkey PRIMARY KEY (id_seguimiento);

ALTER TABLE ONLY public.sustancia_paciente
    ADD CONSTRAINT sustancia_paciente_pkey PRIMARY KEY (id_sustancia_paciente);

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT uq_paciente_codigo UNIQUE (codigo_paciente);

ALTER TABLE ONLY public.prediccion_dominio
    ADD CONSTRAINT uq_pred_dominio_pos UNIQUE (id_prediccion, posicion);

ALTER TABLE ONLY public.prediccion
    ADD CONSTRAINT uq_prediccion_moca_modelo UNIQUE (id_moca, version_modelo);

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);

ALTER TABLE ONLY public.validez_prueba
    ADD CONSTRAINT validez_prueba_opcion_valida_key UNIQUE (opcion_valida);

ALTER TABLE ONLY public.validez_prueba
    ADD CONSTRAINT validez_prueba_pkey PRIMARY KEY (id_validez);

ALTER TABLE ONLY public.actividad_asignada
    ADD CONSTRAINT actividad_asignada_id_actividad_fkey FOREIGN KEY (id_actividad) REFERENCES public.cat_actividad(id_actividad);

ALTER TABLE ONLY public.actividad_asignada
    ADD CONSTRAINT actividad_asignada_id_especialista_fkey FOREIGN KEY (id_especialista) REFERENCES public.especialista(id_especialista);

ALTER TABLE ONLY public.actividad_asignada
    ADD CONSTRAINT actividad_asignada_id_moca_fkey FOREIGN KEY (id_moca) REFERENCES public.moca(id_moca);

ALTER TABLE ONLY public.actividad_asignada
    ADD CONSTRAINT actividad_asignada_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES public.paciente(id_paciente);

ALTER TABLE ONLY public.actividad_realizada
    ADD CONSTRAINT actividad_realizada_id_actividad_asignada_fkey FOREIGN KEY (id_actividad_asignada) REFERENCES public.actividad_asignada(id_actividad_asignada) ON DELETE CASCADE;

ALTER TABLE ONLY public.antecedente_familiar
    ADD CONSTRAINT antecedente_familiar_id_enfermedad_fkey FOREIGN KEY (id_enfermedad) REFERENCES public.cat_enfermedad(id_enfermedad);

ALTER TABLE ONLY public.antecedente_familiar
    ADD CONSTRAINT antecedente_familiar_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES public.paciente(id_paciente) ON DELETE CASCADE;

ALTER TABLE ONLY public.antecedente_familiar
    ADD CONSTRAINT antecedente_familiar_id_parentesco_fkey FOREIGN KEY (id_parentesco) REFERENCES public.cat_parentesco(id_parentesco);

ALTER TABLE ONLY public.cat_actividad
    ADD CONSTRAINT cat_actividad_id_area_fkey FOREIGN KEY (id_area) REFERENCES public.cat_area(id_area);

ALTER TABLE ONLY public.codigo_supervision
    ADD CONSTRAINT codigo_supervision_id_especialista_fkey FOREIGN KEY (id_especialista) REFERENCES public.especialista(id_especialista);

ALTER TABLE ONLY public.codigo_supervision
    ADD CONSTRAINT codigo_supervision_id_moca_fkey FOREIGN KEY (id_moca) REFERENCES public.moca(id_moca);

ALTER TABLE ONLY public.codigo_supervision
    ADD CONSTRAINT codigo_supervision_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES public.paciente(id_paciente);

ALTER TABLE ONLY public.consentimiento
    ADD CONSTRAINT consentimiento_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario) ON DELETE CASCADE;

ALTER TABLE ONLY public.credencial
    ADD CONSTRAINT credencial_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario) ON DELETE CASCADE;

ALTER TABLE ONLY public.diagnostico_clinico
    ADD CONSTRAINT diagnostico_clinico_id_especialista_fkey FOREIGN KEY (id_especialista) REFERENCES public.especialista(id_especialista);

ALTER TABLE ONLY public.diagnostico_clinico
    ADD CONSTRAINT diagnostico_clinico_id_moca_fkey FOREIGN KEY (id_moca) REFERENCES public.moca(id_moca);

ALTER TABLE ONLY public.diagnostico_clinico
    ADD CONSTRAINT diagnostico_clinico_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES public.paciente(id_paciente);

ALTER TABLE ONLY public.enfermedad_paciente
    ADD CONSTRAINT enfermedad_paciente_id_enfermedad_fkey FOREIGN KEY (id_enfermedad) REFERENCES public.cat_enfermedad(id_enfermedad);

ALTER TABLE ONLY public.enfermedad_paciente
    ADD CONSTRAINT enfermedad_paciente_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES public.paciente(id_paciente) ON DELETE CASCADE;

ALTER TABLE ONLY public.especialista
    ADD CONSTRAINT especialista_id_genero_fkey FOREIGN KEY (id_genero) REFERENCES public.cat_genero(id_genero);

ALTER TABLE ONLY public.especialista
    ADD CONSTRAINT especialista_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario) ON DELETE CASCADE;

ALTER TABLE ONLY public.excepcion_evaluacion
    ADD CONSTRAINT excepcion_evaluacion_id_especialista_fkey FOREIGN KEY (id_especialista) REFERENCES public.especialista(id_especialista);

ALTER TABLE ONLY public.excepcion_evaluacion
    ADD CONSTRAINT excepcion_evaluacion_id_moca_fkey FOREIGN KEY (id_moca) REFERENCES public.moca(id_moca);

ALTER TABLE ONLY public.excepcion_evaluacion
    ADD CONSTRAINT excepcion_evaluacion_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES public.paciente(id_paciente);

ALTER TABLE ONLY public.expediente_clinico
    ADD CONSTRAINT expediente_clinico_id_consumo_alcohol_fkey FOREIGN KEY (id_consumo_alcohol) REFERENCES public.consumo_alcohol(id_consumo_alcohol);

ALTER TABLE ONLY public.expediente_clinico
    ADD CONSTRAINT expediente_clinico_id_consumo_tabaco_fkey FOREIGN KEY (id_consumo_tabaco) REFERENCES public.consumo_tabaco(id_consumo_tabaco);

ALTER TABLE ONLY public.expediente_clinico
    ADD CONSTRAINT expediente_clinico_id_escolaridad_fkey FOREIGN KEY (id_escolaridad) REFERENCES public.cat_escolaridad(id_escolaridad);

ALTER TABLE ONLY public.expediente_clinico
    ADD CONSTRAINT expediente_clinico_id_ocupacion_fkey FOREIGN KEY (id_ocupacion) REFERENCES public.cat_ocupacion(id_ocupacion);

ALTER TABLE ONLY public.expediente_clinico
    ADD CONSTRAINT expediente_clinico_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES public.paciente(id_paciente) ON DELETE CASCADE;

ALTER TABLE ONLY public.moca
    ADD CONSTRAINT moca_id_condicion_evaluacion_fkey FOREIGN KEY (id_condicion_evaluacion) REFERENCES public.condicion_evaluacion(id_condicion_evaluacion);

ALTER TABLE ONLY public.moca
    ADD CONSTRAINT moca_id_especialista_fkey FOREIGN KEY (id_especialista) REFERENCES public.especialista(id_especialista);

ALTER TABLE ONLY public.moca
    ADD CONSTRAINT moca_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES public.paciente(id_paciente);

ALTER TABLE ONLY public.moca
    ADD CONSTRAINT moca_id_validez_fkey FOREIGN KEY (id_validez) REFERENCES public.validez_prueba(id_validez);

ALTER TABLE ONLY public.nota_clinica
    ADD CONSTRAINT nota_clinica_id_especialista_fkey FOREIGN KEY (id_especialista) REFERENCES public.especialista(id_especialista);

ALTER TABLE ONLY public.nota_clinica
    ADD CONSTRAINT nota_clinica_id_moca_fkey FOREIGN KEY (id_moca) REFERENCES public.moca(id_moca) ON DELETE SET NULL;

ALTER TABLE ONLY public.nota_clinica
    ADD CONSTRAINT nota_clinica_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES public.paciente(id_paciente) ON DELETE CASCADE;

ALTER TABLE ONLY public.notificacion
    ADD CONSTRAINT notificacion_id_especialista_fkey FOREIGN KEY (id_especialista) REFERENCES public.especialista(id_especialista);

ALTER TABLE ONLY public.notificacion
    ADD CONSTRAINT notificacion_id_moca_fkey FOREIGN KEY (id_moca) REFERENCES public.moca(id_moca);

ALTER TABLE ONLY public.notificacion
    ADD CONSTRAINT notificacion_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES public.paciente(id_paciente);

ALTER TABLE ONLY public.paciente_especialista
    ADD CONSTRAINT paciente_especialista_id_especialista_fkey FOREIGN KEY (id_especialista) REFERENCES public.especialista(id_especialista) ON DELETE CASCADE;

ALTER TABLE ONLY public.paciente_especialista
    ADD CONSTRAINT paciente_especialista_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES public.paciente(id_paciente) ON DELETE CASCADE;

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_id_genero_fkey FOREIGN KEY (id_genero) REFERENCES public.cat_genero(id_genero);

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario) ON DELETE CASCADE;

ALTER TABLE ONLY public.prediccion_dominio
    ADD CONSTRAINT prediccion_dominio_id_area_fkey FOREIGN KEY (id_area) REFERENCES public.cat_area(id_area);

ALTER TABLE ONLY public.prediccion_dominio
    ADD CONSTRAINT prediccion_dominio_id_prediccion_fkey FOREIGN KEY (id_prediccion) REFERENCES public.prediccion(id_prediccion) ON DELETE CASCADE;

ALTER TABLE ONLY public.prediccion
    ADD CONSTRAINT prediccion_id_moca_fkey FOREIGN KEY (id_moca) REFERENCES public.moca(id_moca) ON DELETE CASCADE;

ALTER TABLE ONLY public.reporte_pdf
    ADD CONSTRAINT reporte_pdf_id_especialista_fkey FOREIGN KEY (id_especialista) REFERENCES public.especialista(id_especialista);

ALTER TABLE ONLY public.reporte_pdf
    ADD CONSTRAINT reporte_pdf_id_moca_fkey FOREIGN KEY (id_moca) REFERENCES public.moca(id_moca);

ALTER TABLE ONLY public.reporte_pdf
    ADD CONSTRAINT reporte_pdf_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES public.paciente(id_paciente);

ALTER TABLE ONLY public.resultado_area
    ADD CONSTRAINT resultado_area_id_area_fkey FOREIGN KEY (id_area) REFERENCES public.cat_area(id_area);

ALTER TABLE ONLY public.resultado_area
    ADD CONSTRAINT resultado_area_id_moca_fkey FOREIGN KEY (id_moca) REFERENCES public.moca(id_moca) ON DELETE CASCADE;

ALTER TABLE ONLY public.seguimiento
    ADD CONSTRAINT seguimiento_id_area_fkey FOREIGN KEY (id_area) REFERENCES public.cat_area(id_area);

ALTER TABLE ONLY public.seguimiento
    ADD CONSTRAINT seguimiento_id_especialista_fkey FOREIGN KEY (id_especialista) REFERENCES public.especialista(id_especialista);

ALTER TABLE ONLY public.seguimiento
    ADD CONSTRAINT seguimiento_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES public.paciente(id_paciente);

ALTER TABLE ONLY public.seguimiento_periodico
    ADD CONSTRAINT seguimiento_periodico_id_seguimiento_fkey FOREIGN KEY (id_seguimiento) REFERENCES public.seguimiento(id_seguimiento) ON DELETE CASCADE;

ALTER TABLE ONLY public.sustancia_paciente
    ADD CONSTRAINT sustancia_paciente_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES public.paciente(id_paciente) ON DELETE CASCADE;

ALTER TABLE ONLY public.sustancia_paciente
    ADD CONSTRAINT sustancia_paciente_id_sustancia_fkey FOREIGN KEY (id_sustancia) REFERENCES public.cat_sustancia(id_sustancia);

