class AreaResult {
  final int idArea;
  final int puntajeObtenido;
  final int puntajeMaximo;
  final Map<String, dynamic> detalles;

  const AreaResult({
    required this.idArea,
    required this.puntajeObtenido,
    required this.puntajeMaximo,
    this.detalles = const {},
  });

  Map<String, dynamic> toJson() => {
        'id_area': idArea,
        'puntaje_obtenido': puntajeObtenido,
        'puntaje_maximo': puntajeMaximo,
        'detalles': detalles,
      };
}
