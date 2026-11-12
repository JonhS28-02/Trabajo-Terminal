import 'package:flutter/material.dart';

class MocaSection {
  final int numero;
  final int idArea;
  final String nombre;
  final String queEvalua;
  final String comoSeRealiza;
  final String? ejemplo;
  final int puntajeMaximo;
  final IconData icono;

  const MocaSection({
    required this.numero,
    required this.idArea,
    required this.nombre,
    required this.queEvalua,
    required this.comoSeRealiza,
    this.ejemplo,
    required this.puntajeMaximo,
    required this.icono,
  });
}

const mocaSections = <MocaSection>[
  MocaSection(
    numero: 1,
    idArea: 1,
    nombre: 'Visuoespacial / Ejecutiva',
    queEvalua:
        'Capacidad de planificación, organización visual y habilidades '
        'visuo-constructivas.',
    comoSeRealiza:
        'Se le pedirá que realice tareas de alternancia (conectar números '
        'y letras en orden), copiar un cubo tridimensional y dibujar un '
        'reloj con una hora específica.',
    ejemplo: 'Conectar en orden: 1 → A → 2 → B → 3 → C → 4 → D → 5 → E.',
    puntajeMaximo: 5,
    icono: Icons.grid_view,
  ),
  MocaSection(
    numero: 2,
    idArea: 2,
    nombre: 'Identificación',
    queEvalua:
        'Capacidad para reconocer e identificar objetos o animales '
        'visualmente.',
    comoSeRealiza:
        'Se mostrarán tres imágenes de animales y el paciente debe '
        'nombrar cada uno correctamente.',
    ejemplo: 'Se muestra la imagen de un león, un rinoceronte y un camello.',
    puntajeMaximo: 3,
    icono: Icons.image_search,
  ),
  MocaSection(
    numero: 3,
    idArea: 3,
    nombre: 'Memoria',
    queEvalua:
        'Capacidad de registro y almacenamiento de información verbal '
        'a corto plazo.',
    comoSeRealiza:
        'Se leerán cinco palabras y el paciente debe repetirlas. Se '
        'realizarán dos ensayos de aprendizaje. No se asignan puntos '
        'en esta fase; las palabras se evaluarán después en la sección '
        'de Recuerdo diferido.',
    ejemplo: 'Palabras: rostro, seda, iglesia, clavel, rojo.',
    puntajeMaximo: 0,
    icono: Icons.psychology,
  ),
  MocaSection(
    numero: 4,
    idArea: 4,
    nombre: 'Atención',
    queEvalua:
        'Atención sostenida, concentración y memoria de trabajo.',
    comoSeRealiza:
        'Incluye tres subpruebas: repetir una secuencia de números hacia '
        'adelante y hacia atrás, una tarea de vigilancia (golpear la mesa '
        'al escuchar la letra A), y resta en serie de 7 desde 100.',
    ejemplo: 'Repetir: 2-1-8-5-4. Restar: 100, 93, 86, 79…',
    puntajeMaximo: 6,
    icono: Icons.center_focus_strong,
  ),
  MocaSection(
    numero: 5,
    idArea: 5,
    nombre: 'Lenguaje',
    queEvalua:
        'Habilidades de lenguaje expresivo, incluyendo repetición y '
        'fluidez verbal.',
    comoSeRealiza:
        'El paciente debe repetir dos oraciones complejas exactamente '
        'como se las dicen, y luego decir el mayor número posible de '
        'palabras que comiencen con la letra F en un minuto.',
    ejemplo:
        'Repetir: "El gato se escondió bajo el sofá cuando los perros '
        'entraron en la sala."',
    puntajeMaximo: 3,
    icono: Icons.record_voice_over,
  ),
  MocaSection(
    numero: 6,
    idArea: 6,
    nombre: 'Abstracción',
    queEvalua:
        'Capacidad de pensamiento abstracto para encontrar similitudes '
        'entre conceptos.',
    comoSeRealiza:
        'Se presentan dos pares de palabras y el paciente debe decir '
        'en qué se parecen o qué tienen en común.',
    ejemplo:
        'Naranja – Plátano → son frutas. '
        'Tren – Bicicleta → son medios de transporte.',
    puntajeMaximo: 2,
    icono: Icons.category,
  ),
  MocaSection(
    numero: 7,
    idArea: 7,
    nombre: 'Recuerdo diferido',
    queEvalua:
        'Memoria a largo plazo y capacidad de recuperación de información '
        'almacenada previamente.',
    comoSeRealiza:
        'El paciente debe recordar las cinco palabras que se leyeron en '
        'la sección de Memoria, sin pistas. Si no recuerda alguna, se '
        'ofrecen pistas de categoría y luego de opción múltiple.',
    ejemplo: 'Recordar las palabras: rostro, seda, iglesia, clavel, rojo.',
    puntajeMaximo: 5,
    icono: Icons.replay,
  ),
  MocaSection(
    numero: 8,
    idArea: 8,
    nombre: 'Orientación',
    queEvalua:
        'Orientación temporal y espacial del paciente.',
    comoSeRealiza:
        'El paciente debe indicar la fecha completa (día, mes, año, día '
        'de la semana) y el lugar donde se encuentra (ciudad e institución).',
    ejemplo:
        'Hoy es martes 11 de noviembre de 2026. Estamos en la Ciudad '
        'de México, en el IPN.',
    puntajeMaximo: 6,
    icono: Icons.calendar_today,
  ),
];
