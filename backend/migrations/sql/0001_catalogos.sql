
INSERT INTO public.cat_area VALUES (1, 'Visuoespacial/Ejecutiva');
INSERT INTO public.cat_area VALUES (2, 'Identificación');
INSERT INTO public.cat_area VALUES (3, 'Memoria');
INSERT INTO public.cat_area VALUES (4, 'Atención');
INSERT INTO public.cat_area VALUES (5, 'Lenguaje');
INSERT INTO public.cat_area VALUES (6, 'Abstracción');
INSERT INTO public.cat_area VALUES (7, 'Recuerdo diferido');
INSERT INTO public.cat_area VALUES (8, 'Orientación');

INSERT INTO public.cat_enfermedad VALUES (1, 'Diabetes mellitus tipo 1', 'Metabólica', 'DIABETES');
INSERT INTO public.cat_enfermedad VALUES (2, 'Hipertensión arterial', 'Cardiovascular', 'HIPERTENSION');
INSERT INTO public.cat_enfermedad VALUES (3, 'Enfermedad cardiovascular', 'Cardiovascular', 'CARDIOVASCULAR');
INSERT INTO public.cat_enfermedad VALUES (4, 'Traumatismo craneoencefálico', 'Neurológica', 'TCE');
INSERT INTO public.cat_enfermedad VALUES (5, 'Trastorno depresivo mayor', 'Neuropsiquiátrica', 'DEPRESION');
INSERT INTO public.cat_enfermedad VALUES (6, 'Hipercolesterolemia', 'Metabólica', 'HIPERLIPIDEMIA');
INSERT INTO public.cat_enfermedad VALUES (7, 'Enfermedad renal crónica', 'Renal', 'RENAL');
INSERT INTO public.cat_enfermedad VALUES (8, 'Hipotiroidismo', 'Endocrina', 'TIROIDEA');
INSERT INTO public.cat_enfermedad VALUES (9, 'Deficiencia de vitamina B12', 'Nutricional', 'VITB12');
INSERT INTO public.cat_enfermedad VALUES (10, 'Depresión', 'Neuropsiquiátrica', 'DEPRESION');
INSERT INTO public.cat_enfermedad VALUES (11, 'Insomnio', 'Sueño', 'SUENO');
INSERT INTO public.cat_enfermedad VALUES (12, 'Hepatitis', 'Hepática', 'HEPATICA');
INSERT INTO public.cat_enfermedad VALUES (13, 'Diabetes mellitus tipo 2', 'Metabólica', 'DIABETES');
INSERT INTO public.cat_enfermedad VALUES (14, 'Dislipidemia', 'Metabólica', 'HIPERLIPIDEMIA');
INSERT INTO public.cat_enfermedad VALUES (15, 'Infarto agudo de miocardio', 'Cardiovascular', 'CARDIOVASCULAR');
INSERT INTO public.cat_enfermedad VALUES (16, 'Insuficiencia cardíaca', 'Cardiovascular', 'CARDIOVASCULAR');
INSERT INTO public.cat_enfermedad VALUES (17, 'Arritmia cardíaca', 'Cardiovascular', 'CARDIOVASCULAR');
INSERT INTO public.cat_enfermedad VALUES (18, 'Insuficiencia renal', 'Renal', 'RENAL');
INSERT INTO public.cat_enfermedad VALUES (19, 'Cirrosis hepática', 'Hepática', 'HEPATICA');
INSERT INTO public.cat_enfermedad VALUES (20, 'Esteatosis hepática', 'Hepática', 'HEPATICA');
INSERT INTO public.cat_enfermedad VALUES (21, 'Hipertiroidismo', 'Endocrina', 'TIROIDEA');
INSERT INTO public.cat_enfermedad VALUES (22, 'Apnea del sueño', 'Sueño', 'SUENO');
INSERT INTO public.cat_enfermedad VALUES (23, 'Evento vascular cerebral (EVC) o isquemia transitoria', 'Neurológica', 'ACV_TIA');
INSERT INTO public.cat_enfermedad VALUES (24, 'Epilepsia o crisis convulsivas', 'Neurológica', 'EPILEPSIA');
INSERT INTO public.cat_enfermedad VALUES (25, 'Trastorno de ansiedad', 'Neuropsiquiátrica', 'PSIQUIATRICA');
INSERT INTO public.cat_enfermedad VALUES (26, 'Trastorno bipolar', 'Neuropsiquiátrica', 'PSIQUIATRICA');
INSERT INTO public.cat_enfermedad VALUES (27, 'Esquizofrenia', 'Neuropsiquiátrica', 'PSIQUIATRICA');
INSERT INTO public.cat_enfermedad VALUES (28, 'Trastorno obsesivo-compulsivo', 'Neuropsiquiátrica', 'PSIQUIATRICA');
INSERT INTO public.cat_enfermedad VALUES (29, 'Otro trastorno psiquiátrico', 'Neuropsiquiátrica', 'PSIQUIATRICA');
INSERT INTO public.cat_enfermedad VALUES (30, 'Angina de pecho o enfermedad coronaria', 'Cardiovascular', 'CARDIOVASCULAR');
INSERT INTO public.cat_enfermedad VALUES (31, 'Enfermedad valvular cardíaca', 'Cardiovascular', 'CARDIOVASCULAR');
INSERT INTO public.cat_enfermedad VALUES (32, 'Abuso de alcohol o alcoholismo', 'Sustancias', 'ALCOHOL_ABUSO');
INSERT INTO public.cat_enfermedad VALUES (33, 'Abuso de drogas u otras sustancias', 'Sustancias', 'DROGAS');

INSERT INTO public.cat_escolaridad VALUES (1, 'Sin escolaridad', 0);
INSERT INTO public.cat_escolaridad VALUES (2, 'Primaria incompleta', 3);
INSERT INTO public.cat_escolaridad VALUES (3, 'Primaria completa', 6);
INSERT INTO public.cat_escolaridad VALUES (4, 'Secundaria incompleta', 8);
INSERT INTO public.cat_escolaridad VALUES (5, 'Secundaria completa', 9);
INSERT INTO public.cat_escolaridad VALUES (6, 'Preparatoria incompleta', 11);
INSERT INTO public.cat_escolaridad VALUES (7, 'Preparatoria completa', 12);
INSERT INTO public.cat_escolaridad VALUES (8, 'Licenciatura incompleta', 14);
INSERT INTO public.cat_escolaridad VALUES (9, 'Licenciatura completa', 16);
INSERT INTO public.cat_escolaridad VALUES (10, 'Maestría', 18);
INSERT INTO public.cat_escolaridad VALUES (11, 'Doctorado', 22);

INSERT INTO public.cat_genero VALUES (1, 'Masculino');
INSERT INTO public.cat_genero VALUES (2, 'Femenino');
INSERT INTO public.cat_genero VALUES (3, 'No binario');
INSERT INTO public.cat_genero VALUES (4, 'Prefiero no decir');

INSERT INTO public.cat_ocupacion VALUES (1, 'Estudiante');
INSERT INTO public.cat_ocupacion VALUES (2, 'Empleado');
INSERT INTO public.cat_ocupacion VALUES (3, 'Independiente');
INSERT INTO public.cat_ocupacion VALUES (4, 'Jubilado');
INSERT INTO public.cat_ocupacion VALUES (5, 'Desempleado');
INSERT INTO public.cat_ocupacion VALUES (6, 'Hogar');
INSERT INTO public.cat_ocupacion VALUES (7, 'Otro');

INSERT INTO public.cat_parentesco VALUES (1, 'Padre');
INSERT INTO public.cat_parentesco VALUES (2, 'Madre');
INSERT INTO public.cat_parentesco VALUES (3, 'Hermano/a');
INSERT INTO public.cat_parentesco VALUES (4, 'Abuelo/a');
INSERT INTO public.cat_parentesco VALUES (5, 'Tío/a');
INSERT INTO public.cat_parentesco VALUES (6, 'Primo/a');
INSERT INTO public.cat_parentesco VALUES (7, 'Otro');

INSERT INTO public.cat_sustancia VALUES (1, 'Alcohol');
INSERT INTO public.cat_sustancia VALUES (2, 'Tabaco');
INSERT INTO public.cat_sustancia VALUES (3, 'Cannabis');
INSERT INTO public.cat_sustancia VALUES (4, 'Cocaína');
INSERT INTO public.cat_sustancia VALUES (5, 'Anfetaminas');
INSERT INTO public.cat_sustancia VALUES (6, 'Benzodiacepinas');
INSERT INTO public.cat_sustancia VALUES (7, 'Opioides');
INSERT INTO public.cat_sustancia VALUES (8, 'Otra');

INSERT INTO public.condicion_evaluacion VALUES (1, 'Supervisada por profesional');
INSERT INTO public.condicion_evaluacion VALUES (2, 'Autoadministrada con código');
INSERT INTO public.condicion_evaluacion VALUES (3, 'Excepción autorizada');

INSERT INTO public.consumo_alcohol VALUES (1, 'Nunca');
INSERT INTO public.consumo_alcohol VALUES (2, 'Ocasional (1-3 veces)');
INSERT INTO public.consumo_alcohol VALUES (3, 'Moderado (4-8 veces)');
INSERT INTO public.consumo_alcohol VALUES (4, 'Frecuente (9-15 veces)');
INSERT INTO public.consumo_alcohol VALUES (5, 'Diario');

INSERT INTO public.consumo_tabaco VALUES (1, 'Nunca');
INSERT INTO public.consumo_tabaco VALUES (2, 'Ocasional (1-5 cigarrillos)');
INSERT INTO public.consumo_tabaco VALUES (3, 'Moderado (6-15 cigarrillos)');
INSERT INTO public.consumo_tabaco VALUES (4, 'Frecuente (16-30 cigarrillos)');
INSERT INTO public.consumo_tabaco VALUES (5, 'Diario (más de 30)');

INSERT INTO public.validez_prueba VALUES (1, 'Válida');
INSERT INTO public.validez_prueba VALUES (2, 'Inválida - incompleta');
INSERT INTO public.validez_prueba VALUES (3, 'Inválida - cancelada');
INSERT INTO public.validez_prueba VALUES (4, 'Inválida - error técnico');

SELECT pg_catalog.setval('public.cat_actividad_id_actividad_seq', 1, false);

SELECT pg_catalog.setval('public.cat_area_id_area_seq', 8, true);

SELECT pg_catalog.setval('public.cat_enfermedad_id_enfermedad_seq', 33, true);

SELECT pg_catalog.setval('public.cat_escolaridad_id_escolaridad_seq', 11, true);

SELECT pg_catalog.setval('public.cat_genero_id_genero_seq', 4, true);

SELECT pg_catalog.setval('public.cat_ocupacion_id_ocupacion_seq', 7, true);

SELECT pg_catalog.setval('public.cat_parentesco_id_parentesco_seq', 7, true);

SELECT pg_catalog.setval('public.cat_sustancia_id_sustancia_seq', 8, true);

SELECT pg_catalog.setval('public.condicion_evaluacion_id_condicion_evaluacion_seq', 3, true);

SELECT pg_catalog.setval('public.consumo_alcohol_id_consumo_alcohol_seq', 5, true);

SELECT pg_catalog.setval('public.consumo_tabaco_id_consumo_tabaco_seq', 5, true);

SELECT pg_catalog.setval('public.validez_prueba_id_validez_seq', 4, true);

