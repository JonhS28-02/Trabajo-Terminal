import 'dart:math';

final _rng = Random();

// ═══════════════════════════════════════════════════════════
// 2 — Identificación: animal triplets
// ═══════════════════════════════════════════════════════════

class AnimalVariant {
  final List<String> animals;
  final List<List<String>> accepted;
  const AnimalVariant(this.animals, this.accepted);
}

const _animalVariants = <AnimalVariant>[
  AnimalVariant(['León', 'Rinoceronte', 'Camello'], [['león', 'leon'], ['rinoceronte', 'rino'], ['camello', 'dromedario']]),
  AnimalVariant(['Elefante', 'Jirafa', 'Cebra'], [['elefante'], ['jirafa'], ['cebra']]),
  AnimalVariant(['Tigre', 'Hipopótamo', 'Águila'], [['tigre'], ['hipopotamo', 'hipopótamo'], ['aguila', 'águila']]),
  AnimalVariant(['Gorila', 'Cocodrilo', 'Canguro'], [['gorila'], ['cocodrilo'], ['canguro']]),
  AnimalVariant(['Oso', 'Delfín', 'Búho'], [['oso'], ['delfin', 'delfín'], ['buho', 'búho']]),
  AnimalVariant(['Lobo', 'Tortuga', 'Pavo real'], [['lobo'], ['tortuga'], ['pavo real', 'pavo']]),
  AnimalVariant(['Zorro', 'Pantera', 'Foca'], [['zorro'], ['pantera'], ['foca']]),
  AnimalVariant(['Caballo', 'Serpiente', 'Pingüino'], [['caballo'], ['serpiente', 'víbora', 'vibora'], ['pinguino', 'pingüino']]),
  AnimalVariant(['Venado', 'Ballena', 'Tucán'], [['venado', 'ciervo'], ['ballena'], ['tucan', 'tucán']]),
  AnimalVariant(['Mono', 'Flamenco', 'Koala'], [['mono', 'chango'], ['flamenco'], ['koala']]),
  AnimalVariant(['Puma', 'Avestruz', 'Morsa'], [['puma'], ['avestruz'], ['morsa']]),
  AnimalVariant(['Jaguar', 'Iguana', 'Lince'], [['jaguar'], ['iguana'], ['lince']]),
  AnimalVariant(['Búfalo', 'Gaviota', 'Armadillo'], [['bufalo', 'búfalo'], ['gaviota'], ['armadillo']]),
  AnimalVariant(['Bisonte', 'Pelícano', 'Nutria'], [['bisonte'], ['pelicano', 'pelícano'], ['nutria']]),
  AnimalVariant(['Alce', 'Halcón', 'Mapache'], [['alce'], ['halcon', 'halcón'], ['mapache']]),
  AnimalVariant(['Panda', 'Cóndor', 'Castor'], [['panda'], ['condor', 'cóndor'], ['castor']]),
  AnimalVariant(['Jabalí', 'Lechuza', 'Hurón'], [['jabali', 'jabalí'], ['lechuza'], ['huron', 'hurón']]),
  AnimalVariant(['Tapir', 'Cigüeña', 'Comadreja'], [['tapir'], ['cigueña', 'cigüeña'], ['comadreja']]),
  AnimalVariant(['Capibara', 'Garza', 'Tejón'], [['capibara', 'carpincho'], ['garza'], ['tejon', 'tejón']]),
  AnimalVariant(['Llama', 'Cuervo', 'Suricata'], [['llama'], ['cuervo'], ['suricata', 'suricato']]),
];

// ═══════════════════════════════════════════════════════════
// 3/7 — Memoria / Recuerdo: word sets
// ═══════════════════════════════════════════════════════════

const _memoriaVariants = <List<String>>[
  ['rostro', 'seda', 'iglesia', 'clavel', 'rojo'],
  ['brazo', 'lana', 'teatro', 'tulipán', 'verde'],
  ['pierna', 'algodón', 'museo', 'rosa', 'azul'],
  ['mano', 'cuero', 'escuela', 'violeta', 'negro'],
  ['dedo', 'nylon', 'hospital', 'margarita', 'blanco'],
  ['hombro', 'satin', 'catedral', 'girasol', 'gris'],
  ['codo', 'lino', 'palacio', 'orquídea', 'dorado'],
  ['rodilla', 'seda', 'castillo', 'lirio', 'morado'],
  ['tobillo', 'franela', 'mercado', 'dalia', 'naranja'],
  ['cuello', 'terciopelo', 'templo', 'jazmín', 'café'],
  ['pecho', 'mezclilla', 'estadio', 'azucena', 'plateado'],
  ['espalda', 'encaje', 'capilla', 'gardenia', 'turquesa'],
  ['cintura', 'gamuza', 'biblioteca', 'loto', 'beige'],
  ['frente', 'tela', 'parque', 'amapola', 'coral'],
  ['mejilla', 'raso', 'plaza', 'hortensia', 'vino'],
  ['mentón', 'pana', 'puente', 'magnolia', 'índigo'],
  ['muñeca', 'felpa', 'torre', 'clavel', 'carmín'],
  ['cadera', 'poliéster', 'faro', 'petunia', 'ocre'],
  ['oreja', 'cachemir', 'fuente', 'lavanda', 'rubí'],
  ['nariz', 'organza', 'molino', 'camelia', 'ámbar'],
];

// ═══════════════════════════════════════════════════════════
// 4 — Atención: digit sequences + vigilance letters
// ═══════════════════════════════════════════════════════════

class AtencionVariant {
  final String adelante;
  final String atras;
  final String atrasRespuesta;
  final List<String> vigLetras;
  const AtencionVariant(this.adelante, this.atras, this.atrasRespuesta, this.vigLetras);
}

const _atencionVariants = <AtencionVariant>[
  AtencionVariant('21854', '742', '247', ['F','B','A','C','M','N','A','A','J','K','L','B','A','F','A','K','D','E','A','A','J']),
  AtencionVariant('57396', '531', '135', ['L','A','M','B','A','D','F','A','K','A','N','B','A','C','J','A','E','A','F','M','A']),
  AtencionVariant('83217', '649', '946', ['C','A','K','F','A','B','A','M','L','A','N','D','A','J','A','E','F','B','A','K','A']),
  AtencionVariant('46923', '815', '518', ['M','B','A','K','A','F','C','A','N','A','L','D','A','E','J','B','A','A','F','K','A']),
  AtencionVariant('71538', '263', '362', ['A','F','B','A','M','K','A','N','A','C','L','A','D','J','A','E','B','A','F','A','K']),
  AtencionVariant('39472', '586', '685', ['B','A','F','C','A','M','A','K','N','A','L','A','D','E','J','A','B','F','A','A','K']),
  AtencionVariant('62815', '374', '473', ['K','A','B','F','A','M','C','A','A','N','L','D','A','J','E','A','B','A','F','K','A']),
  AtencionVariant('15736', '928', '829', ['F','A','B','M','A','C','K','A','A','N','L','A','D','E','A','J','B','A','F','A','K']),
  AtencionVariant('48291', '657', '756', ['A','B','F','A','C','M','A','K','N','A','A','L','D','A','E','J','B','F','A','K','A']),
  AtencionVariant('92643', '418', '814', ['M','A','B','F','A','C','A','K','A','N','L','D','A','E','A','J','B','A','F','A','K']),
  AtencionVariant('35178', '296', '692', ['B','F','A','C','A','M','K','A','N','A','L','A','D','E','A','J','A','B','F','A','K']),
  AtencionVariant('67914', '352', '253', ['A','B','A','F','C','M','A','K','N','A','L','D','A','A','E','J','B','F','A','K','A']),
  AtencionVariant('28453', '791', '197', ['F','B','A','C','A','M','N','A','K','A','L','B','A','D','E','A','J','F','A','A','K']),
  AtencionVariant('51876', '463', '364', ['A','F','B','A','C','M','K','A','A','N','L','D','A','E','A','J','B','A','F','K','A']),
  AtencionVariant('94321', '587', '785', ['B','A','F','A','C','M','A','K','N','A','A','L','D','E','A','J','A','B','F','A','K']),
  AtencionVariant('17568', '942', '249', ['M','B','A','F','A','C','K','A','A','N','L','A','D','E','J','A','B','F','A','A','K']),
  AtencionVariant('83649', '275', '572', ['A','B','F','C','A','M','A','K','N','A','L','A','D','A','E','J','B','F','A','K','A']),
  AtencionVariant('42197', '836', '638', ['F','A','B','C','M','A','K','A','N','A','L','D','A','E','A','J','B','A','F','A','K']),
  AtencionVariant('76523', '149', '941', ['B','A','F','A','C','A','M','K','N','A','L','D','A','E','J','A','B','A','F','A','K']),
  AtencionVariant('31847', '562', '265', ['A','F','B','C','A','M','K','A','N','A','A','L','D','E','A','J','B','F','A','K','A']),
];

// ═══════════════════════════════════════════════════════════
// 5 — Lenguaje: sentence pairs + fluency letter
// ═══════════════════════════════════════════════════════════

class LenguajeVariant {
  final List<String> oraciones;
  final String letraFluidez;
  const LenguajeVariant(this.oraciones, this.letraFluidez);
}

const _lenguajeVariants = <LenguajeVariant>[
  LenguajeVariant(['El gato se escondió bajo el sofá cuando los perros entraron en la sala.', 'Espero que él le entregue el mensaje una vez que ella se lo pida.'], 'F'),
  LenguajeVariant(['La lluvia no cesaba y los ríos comenzaron a desbordarse por la tarde.', 'Quiero que tú me avises apenas lleguen los resultados del examen.'], 'M'),
  LenguajeVariant(['Los niños corrían por el parque mientras sus padres descansaban a la sombra.', 'Dile que traiga las llaves antes de que cierre la puerta con seguro.'], 'P'),
  LenguajeVariant(['El tren salió de la estación justo cuando empezaba a nevar en la ciudad.', 'Necesito que ella me confirme si va a asistir a la reunión del viernes.'], 'S'),
  LenguajeVariant(['Mi abuela preparó una sopa caliente porque hacía mucho frío en la casa.', 'Pídele que nos mande los documentos cuando termine de revisarlos todos.'], 'C'),
  LenguajeVariant(['El barco cruzó el lago en medio de una fuerte tormenta de verano.', 'Avísame cuando hayas terminado para que podamos salir juntos al centro.'], 'T'),
  LenguajeVariant(['Las flores del jardín se marchitaron después de tres semanas sin agua.', 'Dígale que no se preocupe porque nosotros nos encargaremos de todo eso.'], 'L'),
  LenguajeVariant(['El maestro explicó la lección dos veces porque nadie la había entendido.', 'Espera a que yo regrese del mercado antes de empezar a preparar la cena.'], 'R'),
  LenguajeVariant(['Los pájaros cantaban en la ventana cada mañana al amanecer temprano.', 'Pregúntale si puede venir mañana porque necesitamos hablar con urgencia.'], 'B'),
  LenguajeVariant(['La tienda cerró sus puertas antes de lo normal por la falta de clientes.', 'Te pido que guardes silencio mientras el doctor revisa al paciente ahora.'], 'G'),
  LenguajeVariant(['El viento arrancó las hojas de los árboles durante la noche de octubre.', 'Dile a tu hermano que me llame en cuanto pueda porque es muy importante.'], 'D'),
  LenguajeVariant(['La música sonaba tan fuerte que los vecinos empezaron a quejarse mucho.', 'Asegúrate de que él firme todos los papeles antes de entregar el sobre.'], 'A'),
  LenguajeVariant(['El perro ladró toda la noche y nadie en la casa pudo dormir tranquilo.', 'Recuérdale que debe traer su credencial para poder entrar al edificio hoy.'], 'E'),
  LenguajeVariant(['La puerta del garaje se atascó justo cuando teníamos que salir de prisa.', 'Quiero que me digas la verdad sobre lo que pasó ayer en la oficina grande.'], 'V'),
  LenguajeVariant(['El abuelo contó historias de su juventud junto a la chimenea encendida.', 'Hazme el favor de llamar al técnico para que arregle la tubería mañana.'], 'N'),
  LenguajeVariant(['Las olas del mar golpeaban las rocas con fuerza durante la madrugada.', 'Pídele a María que recoja a los niños si no puedo llegar antes de las seis.'], 'J'),
  LenguajeVariant(['El camión se detuvo en la carretera porque se le ponchó una llanta atrás.', 'Avísale que no vamos a poder ir a la fiesta porque surgió algo inesperado.'], 'H'),
  LenguajeVariant(['La biblioteca estaba llena de estudiantes preparándose para los exámenes.', 'Necesito que alguien me ayude a mover estas cajas pesadas al segundo piso.'], 'O'),
  LenguajeVariant(['El sol se ocultó detrás de las montañas pintando el cielo de color naranja.', 'Confirma con el proveedor si el pedido llegará completo la próxima semana.'], 'I'),
  LenguajeVariant(['La escalera del edificio estaba mojada y alguien casi se resbaló al bajar.', 'Explícale al nuevo empleado cómo funciona el sistema de facturación actual.'], 'U'),
];

// ═══════════════════════════════════════════════════════════
// 6 — Abstracción: word pairs
// ═══════════════════════════════════════════════════════════

class AbstraccionVariant {
  final List<List<String>> pares;
  final List<List<String>> keywords;
  const AbstraccionVariant(this.pares, this.keywords);
}

const _abstraccionVariants = <AbstraccionVariant>[
  AbstraccionVariant([['Naranja', 'Plátano'], ['Tren', 'Bicicleta']], [['fruta', 'frutas', 'alimento', 'alimentos', 'comida'], ['transporte', 'vehiculo', 'vehículo', 'vehiculos', 'vehículos', 'medio', 'medios']]),
  AbstraccionVariant([['Manzana', 'Uva'], ['Avión', 'Barco']], [['fruta', 'frutas', 'alimento'], ['transporte', 'vehiculo', 'vehículo', 'medio', 'medios']]),
  AbstraccionVariant([['Perro', 'Gato'], ['Mesa', 'Silla']], [['animal', 'animales', 'mascota', 'mascotas', 'ser vivo'], ['mueble', 'muebles', 'mobiliario']]),
  AbstraccionVariant([['Reloj', 'Regla'], ['Piano', 'Guitarra']], [['instrumento', 'medición', 'medir', 'medida'], ['instrumento', 'instrumentos', 'musica', 'música', 'musical']]),
  AbstraccionVariant([['Rosa', 'Tulipán'], ['Martillo', 'Sierra']], [['flor', 'flores', 'planta'], ['herramienta', 'herramientas', 'instrumento']]),
  AbstraccionVariant([['Camisa', 'Pantalón'], ['Pintura', 'Escultura']], [['ropa', 'prenda', 'prendas', 'vestimenta'], ['arte', 'obra', 'obras']]),
  AbstraccionVariant([['Poema', 'Novela'], ['Fútbol', 'Tenis']], [['literatura', 'texto', 'escrito', 'lectura', 'libro'], ['deporte', 'deportes', 'juego']]),
  AbstraccionVariant([['Agua', 'Jugo'], ['Zapato', 'Bota']], [['bebida', 'bebidas', 'líquido', 'liquido'], ['calzado', 'zapato', 'zapatos']]),
  AbstraccionVariant([['Televisor', 'Radio'], ['Cuchara', 'Tenedor']], [['electronico', 'electrónico', 'aparato', 'medio', 'comunicación', 'comunicacion'], ['cubierto', 'cubiertos', 'utensilio']]),
  AbstraccionVariant([['Lápiz', 'Pluma'], ['Cama', 'Sofá']], [['escritura', 'escribir', 'instrumento'], ['mueble', 'muebles', 'descanso', 'descansar']]),
  AbstraccionVariant([['Violín', 'Flauta'], ['Sandía', 'Melón']], [['instrumento', 'instrumentos', 'musica', 'música', 'musical'], ['fruta', 'frutas', 'alimento']]),
  AbstraccionVariant([['Sol', 'Luna'], ['Río', 'Lago']], [['astro', 'cuerpo celeste', 'cielo', 'estrella'], ['agua', 'cuerpo de agua', 'hídrico', 'hidrico']]),
  AbstraccionVariant([['Oro', 'Plata'], ['Águila', 'Halcón']], [['metal', 'metales', 'mineral'], ['ave', 'aves', 'pajaro', 'pájaro']]),
  AbstraccionVariant([['Ojo', 'Oído'], ['Enero', 'Marzo']], [['sentido', 'sentidos', 'organo', 'órgano'], ['mes', 'meses', 'tiempo', 'calendario']]),
  AbstraccionVariant([['Democracia', 'Monarquía'], ['Inglés', 'Francés']], [['gobierno', 'sistema', 'política', 'politica'], ['idioma', 'idiomas', 'lengua', 'lenguas']]),
  AbstraccionVariant([['Mango', 'Piña'], ['Autobús', 'Metro']], [['fruta', 'frutas', 'alimento'], ['transporte', 'vehiculo', 'vehículo', 'medio', 'público', 'publico']]),
  AbstraccionVariant([['Hacha', 'Serrucho'], ['Violin', 'Trompeta']], [['herramienta', 'herramientas', 'instrumento'], ['instrumento', 'instrumentos', 'musica', 'música', 'musical']]),
  AbstraccionVariant([['Lechuga', 'Espinaca'], ['Sombrero', 'Gorra']], [['verdura', 'verduras', 'vegetal', 'hortaliza'], ['accesorio', 'prenda', 'cabeza', 'gorro']]),
  AbstraccionVariant([['Pollo', 'Pescado'], ['Algebra', 'Geometría']], [['carne', 'comida', 'alimento', 'proteina', 'proteína'], ['matematica', 'matemática', 'matemáticas', 'materia', 'ciencia']]),
  AbstraccionVariant([['Espejo', 'Ventana'], ['Hormiga', 'Abeja']], [['vidrio', 'cristal', 'transparente', 'objeto'], ['insecto', 'insectos', 'animal', 'bicho']]),
];

// ═══════════════════════════════════════════════════════════
// Public API: pick a random variant, ensuring examples ≠ game
// ═══════════════════════════════════════════════════════════

class MocaVariants {
  int _exAnimal = -1;
  int _exMemoria = -1;
  int _exAtencion = -1;
  int _exLenguaje = -1;
  int _exAbstraccion = -1;

  int _gameAnimal = -1;
  int _gameMemoria = -1;
  int _gameAtencion = -1;
  int _gameLenguaje = -1;
  int _gameAbstraccion = -1;

  MocaVariants() {
    _exAnimal = _rng.nextInt(_animalVariants.length);
    _exMemoria = _rng.nextInt(_memoriaVariants.length);
    _exAtencion = _rng.nextInt(_atencionVariants.length);
    _exLenguaje = _rng.nextInt(_lenguajeVariants.length);
    _exAbstraccion = _rng.nextInt(_abstraccionVariants.length);

    _gameAnimal = _pickDifferent(_animalVariants.length, _exAnimal);
    _gameMemoria = _pickDifferent(_memoriaVariants.length, _exMemoria);
    _gameAtencion = _pickDifferent(_atencionVariants.length, _exAtencion);
    _gameLenguaje = _pickDifferent(_lenguajeVariants.length, _exLenguaje);
    _gameAbstraccion = _pickDifferent(_abstraccionVariants.length, _exAbstraccion);
  }

  int _pickDifferent(int length, int exclude) {
    int idx;
    do {
      idx = _rng.nextInt(length);
    } while (idx == exclude);
    return idx;
  }

  // Example data (for ExampleScreen simulations)
  AnimalVariant get exampleAnimals => _animalVariants[_exAnimal];
  List<String> get exampleMemoria => _memoriaVariants[_exMemoria];
  AtencionVariant get exampleAtencion => _atencionVariants[_exAtencion];
  LenguajeVariant get exampleLenguaje => _lenguajeVariants[_exLenguaje];
  AbstraccionVariant get exampleAbstraccion => _abstraccionVariants[_exAbstraccion];

  // Game data (for actual evaluation)
  AnimalVariant get gameAnimals => _animalVariants[_gameAnimal];
  List<String> get gameMemoria => _memoriaVariants[_gameMemoria];
  AtencionVariant get gameAtencion => _atencionVariants[_gameAtencion];
  LenguajeVariant get gameLenguaje => _lenguajeVariants[_gameLenguaje];
  AbstraccionVariant get gameAbstraccion => _abstraccionVariants[_gameAbstraccion];
}
