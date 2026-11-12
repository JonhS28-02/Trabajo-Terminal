import 'dart:math';

import 'package:flutter/material.dart';

import '../../../data/moca_result.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_widgets.dart';

class VisuoespacialGame extends StatefulWidget {
  const VisuoespacialGame({super.key});

  @override
  State<VisuoespacialGame> createState() => _VisuoespacialGameState();
}

class _VisuoespacialGameState extends State<VisuoespacialGame> {
  int _subTask = 0;
  int _trailScore = 0;
  int _cuboScore = 0;
  int _relojContorno = 0;
  int _relojNumeros = 0;
  int _relojManecillas = 0;

  // ── Trail Making ──
  final _seq = const ['1', 'A', '2', 'B', '3', 'C', '4', 'D', '5'];
  final List<String> _trailTapped = [];

  final _nodes = const <String, Offset>{
    '1': Offset(30, 180),  'A': Offset(120, 50),
    '2': Offset(220, 120), 'B': Offset(80, 120),
    '3': Offset(180, 200), 'C': Offset(260, 60),
    '4': Offset(50, 260),  'D': Offset(200, 280),
    '5': Offset(280, 180),
  };

  // ── Cube ──
  final List<List<Offset>> _cubeStrokes = [];
  List<Offset> _cubeCur = [];

  // ── Clock ──
  int _clockPhase = 0;
  final List<List<Offset>> _clockStrokes = [];
  List<Offset> _clockCur = [];
  final List<Offset?> _clockNums = List.filled(12, null);
  int _nextNum = 1;
  Offset? _hourEnd;
  Offset? _minuteEnd;
  bool _placingHour = true;

  static const _cs = 280.0;

  void _onTrailTap(String label) {
    if (_trailTapped.contains(label)) return;
    setState(() => _trailTapped.add(label));
  }

  void _submitTrail() {
    bool correct = _trailTapped.length == _seq.length;
    if (correct) {
      for (int i = 0; i < _seq.length; i++) {
        if (_trailTapped[i] != _seq[i]) { correct = false; break; }
      }
    }
    setState(() => _trailScore = correct ? 1 : 0);
    _advance();
  }

  void _advance() {
    if (_subTask < 2) {
      setState(() => _subTask++);
    } else {
      _finish();
    }
  }

  void _finish() {
    Navigator.of(context).pop(AreaResult(
      idArea: 1,
      puntajeObtenido:
          _trailScore + _cuboScore + _relojContorno + _relojNumeros + _relojManecillas,
      puntajeMaximo: 5,
      detalles: {
        'trail_making': _trailScore,
        'cubo': _cuboScore,
        'reloj_contorno': _relojContorno,
        'reloj_numeros': _relojNumeros,
        'reloj_manecillas': _relojManecillas,
      },
    ));
  }

  // ── Cube scoring ──
  void _submitCube() {
    if (_cubeStrokes.length < 4) {
      setState(() => _cuboScore = 0);
      _advance();
      return;
    }
    final all = _cubeStrokes.expand((s) => s).toList();
    if (all.length < 10) {
      setState(() => _cuboScore = 0);
      _advance();
      return;
    }
    double minX = double.infinity, maxX = -double.infinity;
    double minY = double.infinity, maxY = -double.infinity;
    for (final p in all) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }
    final area = (maxX - minX) * (maxY - minY);
    setState(() => _cuboScore = area > _cs * _cs * 0.08 ? 1 : 0);
    _advance();
  }

  // ── Clock scoring ──
  void _submitContour() {
    final all = _clockStrokes.expand((s) => s).toList();
    if (all.length < 10) {
      setState(() { _relojContorno = 0; _clockPhase = 1; });
      return;
    }
    double cx = 0, cy = 0;
    for (final p in all) { cx += p.dx; cy += p.dy; }
    cx /= all.length;
    cy /= all.length;
    double avgR = 0;
    for (final p in all) avgR += sqrt(pow(p.dx - cx, 2) + pow(p.dy - cy, 2));
    avgR /= all.length;
    double v = 0;
    for (final p in all) {
      final d = sqrt(pow(p.dx - cx, 2) + pow(p.dy - cy, 2));
      v += pow(d - avgR, 2);
    }
    v /= all.length;
    setState(() {
      _relojContorno = (sqrt(v) / avgR < 0.4 && avgR > _cs * 0.15) ? 1 : 0;
      _clockPhase = 1;
    });
  }

  void _submitNumbers() {
    final placed = _clockNums.where((p) => p != null).length;
    if (placed < 10) {
      setState(() { _relojNumeros = 0; _clockPhase = 2; });
      return;
    }
    const center = Offset(_cs / 2, _cs / 2);
    int ok = 0;
    for (int i = 0; i < 12; i++) {
      final pos = _clockNums[i];
      if (pos == null) continue;
      final expected = -pi / 2 + (i + 1) * pi / 6;
      final actual = atan2(pos.dy - center.dy, pos.dx - center.dx);
      double diff = (actual - expected).abs();
      if (diff > pi) diff = 2 * pi - diff;
      if (diff < pi / 4) ok++;
    }
    setState(() {
      _relojNumeros = ok >= 8 ? 1 : 0;
      _clockPhase = 2;
    });
  }

  void _submitHands() {
    if (_hourEnd == null || _minuteEnd == null) {
      setState(() => _relojManecillas = 0);
      _finish();
      return;
    }
    const center = Offset(_cs / 2, _cs / 2);
    final ha = atan2(_hourEnd!.dy - center.dy, _hourEnd!.dx - center.dx);
    final ma = atan2(_minuteEnd!.dy - center.dy, _minuteEnd!.dx - center.dx);

    double expH = -pi / 2 + (11 + 10.0 / 60) * pi / 6;
    while (expH > pi) expH -= 2 * pi;
    const expM = -pi / 2 + 2 * pi / 6;

    double dh = (ha - expH).abs();
    if (dh > pi) dh = 2 * pi - dh;
    double dm = (ma - expM).abs();
    if (dm > pi) dm = 2 * pi - dm;

    setState(() => _relojManecillas = (dh < pi / 4 && dm < pi / 4) ? 1 : 0);
    _finish();
  }

  // ── Build ──
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top + 16,
          left: AppSizes.gutter,
          right: AppSizes.gutter,
          bottom: 28 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleBackButton(),
            const SizedBox(height: 16),
            Text('Visuoespacial / Ejecutiva',
                style: AppText.title.copyWith(fontSize: 20)),
            const SizedBox(height: 4),
            Text(_label, style: AppText.subtitle.copyWith(color: AppColors.hint)),
            const SizedBox(height: 16),
            if (_subTask == 0) _buildTrail(),
            if (_subTask == 1) _buildCube(),
            if (_subTask == 2) _buildClock(),
          ],
        ),
      ),
    );
  }

  String get _label => switch (_subTask) {
    0 => 'Sub-tarea 1/3: Trail Making (1 pt)',
    1 => 'Sub-tarea 2/3: Copia de cubo (1 pt)',
    _ => 'Sub-tarea 3/3: Dibujo de reloj (3 pts)',
  };

  // ════════ TRAIL ════════

  Widget _buildTrail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conecta los nodos en orden alterno número-letra:\n'
          '1 → A → 2 → B → 3 → C → 4 → D → 5',
          style: AppText.subtitle.copyWith(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Container(
          height: 320,
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              CustomPaint(
                size: const Size(double.infinity, 320),
                painter: _TrailLinePainter(
                  seq: _trailTapped,
                  positions: _nodes,
                  upTo: _trailTapped.length,
                ),
              ),
              for (final e in _nodes.entries)
                Positioned(
                  left: e.value.dx - 18,
                  top: e.value.dy - 18,
                  child: GestureDetector(
                    onTap: () => _onTrailTap(e.key),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _trailTapped.contains(e.key)
                            ? AppColors.purple.withAlpha(60)
                            : AppColors.field,
                        border: Border.all(color: AppColors.purple, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(e.key,
                          style: AppText.label.copyWith(fontSize: 14)),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        PrimaryButton(label: 'CONTINUAR', height: 44, onPressed: _submitTrail),
      ],
    );
  }

  // ════════ CUBE ════════

  Widget _buildCube() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Observa el cubo y dibuja una copia en el recuadro.',
            style: AppText.subtitle.copyWith(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 12),
        Center(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text('Referencia',
                    style: AppText.subtitle
                        .copyWith(color: AppColors.hint, fontSize: 11)),
                CustomPaint(
                    size: const Size(120, 120), painter: _CubeRefPainter()),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('Tu dibujo:', style: AppText.label.copyWith(fontSize: 13)),
        const SizedBox(height: 8),
        _drawingCanvas(
          strokes: _cubeStrokes,
          current: _cubeCur,
          onStart: (d) =>
              setState(() => _cubeCur = [d.localPosition]),
          onUpdate: (d) =>
              setState(() => _cubeCur = [..._cubeCur, d.localPosition]),
          onEnd: (_) => setState(() {
            if (_cubeCur.length > 1) _cubeStrokes.add(_cubeCur);
            _cubeCur = [];
          }),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _outlineBtn('BORRAR', () => setState(() {
                    _cubeStrokes.clear();
                    _cubeCur = [];
                  }))),
          const SizedBox(width: 12),
          Expanded(
              child: PrimaryButton(
                  label: 'TERMINÉ', height: 44, onPressed: _submitCube)),
        ]),
      ],
    );
  }

  // ════════ CLOCK ════════

  Widget _buildClock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_clockInstr,
            style: AppText.subtitle.copyWith(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 16),
        if (_clockPhase == 0) _clockContour(),
        if (_clockPhase == 1) _clockNumbers(),
        if (_clockPhase == 2) _clockHands(),
      ],
    );
  }

  String get _clockInstr => switch (_clockPhase) {
    0 => 'Paso 1/3: Dibuja el contorno circular del reloj.',
    1 => 'Paso 2/3: Toca donde va cada número (1 al 12).',
    _ => 'Paso 3/3: Marca las manecillas para las 11:10.\n'
        'Primero la hora (corta), luego los minutos (larga).',
  };

  Widget _clockContour() {
    return Column(children: [
      _drawingCanvas(
        strokes: _clockStrokes,
        current: _clockCur,
        onStart: (d) =>
            setState(() => _clockCur = [d.localPosition]),
        onUpdate: (d) =>
            setState(() => _clockCur = [..._clockCur, d.localPosition]),
        onEnd: (_) => setState(() {
          if (_clockCur.length > 1) _clockStrokes.add(_clockCur);
          _clockCur = [];
        }),
      ),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
            child: _outlineBtn('BORRAR', () => setState(() {
                  _clockStrokes.clear();
                  _clockCur = [];
                }))),
        const SizedBox(width: 12),
        Expanded(
            child: PrimaryButton(
                label: 'CONTINUAR', height: 44, onPressed: _submitContour)),
      ]),
    ]);
  }

  Widget _clockNumbers() {
    return Column(children: [
      Center(
        child: GestureDetector(
          onTapUp: (d) {
            if (_nextNum > 12) return;
            setState(() {
              _clockNums[_nextNum - 1] = d.localPosition;
              _nextNum++;
            });
          },
          child: Container(
            width: _cs,
            height: _cs,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: CustomPaint(
              size: const Size(_cs, _cs),
              painter:
                  _ClockNumPainter(strokes: _clockStrokes, nums: _clockNums),
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Center(
        child: Text(
          _nextNum <= 12
              ? 'Toca donde va el número $_nextNum'
              : 'Todos los números colocados',
          style: AppText.subtitle.copyWith(
            color: _nextNum <= 12 ? AppColors.purple : Colors.green,
            fontSize: 12,
          ),
        ),
      ),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
            child: _outlineBtn('REINICIAR', () => setState(() {
                  for (int i = 0; i < 12; i++) _clockNums[i] = null;
                  _nextNum = 1;
                }))),
        const SizedBox(width: 12),
        Expanded(
            child: PrimaryButton(
                label: 'CONTINUAR', height: 44, onPressed: _submitNumbers)),
      ]),
    ]);
  }

  Widget _clockHands() {
    return Column(children: [
      Center(
        child: GestureDetector(
          onTapUp: (d) => setState(() {
            if (_placingHour) {
              _hourEnd = d.localPosition;
              _placingHour = false;
            } else {
              _minuteEnd = d.localPosition;
            }
          }),
          child: Container(
            width: _cs,
            height: _cs,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: CustomPaint(
              size: const Size(_cs, _cs),
              painter: _ClockHandPainter(
                strokes: _clockStrokes,
                nums: _clockNums,
                hourEnd: _hourEnd,
                minuteEnd: _minuteEnd,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Center(
        child: Text(
          _placingHour
              ? 'Toca donde termina la manecilla de la HORA (corta)'
              : _minuteEnd == null
                  ? 'Toca donde termina la manecilla de MINUTOS (larga)'
                  : 'Manecillas colocadas',
          style: AppText.subtitle.copyWith(
            color: (_hourEnd != null && _minuteEnd != null)
                ? Colors.green
                : AppColors.purple,
            fontSize: 12,
          ),
        ),
      ),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
            child: _outlineBtn('REINICIAR', () => setState(() {
                  _hourEnd = null;
                  _minuteEnd = null;
                  _placingHour = true;
                }))),
        const SizedBox(width: 12),
        Expanded(
            child: PrimaryButton(
                label: 'FINALIZAR', height: 44, onPressed: _submitHands)),
      ]),
    ]);
  }

  // ════════ Shared widgets ════════

  Widget _drawingCanvas({
    required List<List<Offset>> strokes,
    required List<Offset> current,
    required GestureDragStartCallback onStart,
    required GestureDragUpdateCallback onUpdate,
    required GestureDragEndCallback onEnd,
  }) {
    return Center(
      child: GestureDetector(
        onPanStart: onStart,
        onPanUpdate: onUpdate,
        onPanEnd: onEnd,
        child: Container(
          width: _cs,
          height: _cs,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomPaint(
              size: const Size(_cs, _cs),
              painter: _StrokePainter(strokes: strokes, current: current),
            ),
          ),
        ),
      ),
    );
  }

  Widget _outlineBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: AppText.label.copyWith(fontSize: 12, color: Colors.white60)),
      ),
    );
  }
}

// ══════════════════════════════════════════
//  Painters
// ══════════════════════════════════════════

class _TrailLinePainter extends CustomPainter {
  _TrailLinePainter(
      {required this.seq, required this.positions, required this.upTo});
  final List<String> seq;
  final Map<String, Offset> positions;
  final int upTo;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.purple
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < upTo - 1; i++) {
      final a = positions[seq[i]], b = positions[seq[i + 1]];
      if (a != null && b != null) canvas.drawLine(a, b, p);
    }
  }

  @override
  bool shouldRepaint(covariant _TrailLinePainter o) => o.upTo != upTo;
}

class _CubeRefPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.purple
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const d = 40.0;
    final cx = size.width / 2, cy = size.height / 2;
    final f1 = Offset(cx - d, cy - d), f2 = Offset(cx + d, cy - d);
    final f3 = Offset(cx + d, cy + d), f4 = Offset(cx - d, cy + d);
    canvas.drawLine(f1, f2, p);
    canvas.drawLine(f2, f3, p);
    canvas.drawLine(f3, f4, p);
    canvas.drawLine(f4, f1, p);
    const o = 20.0;
    final b1 = Offset(f1.dx + o, f1.dy - o);
    final b2 = Offset(f2.dx + o, f2.dy - o);
    final b3 = Offset(f3.dx + o, f3.dy - o);
    canvas.drawLine(f1, b1, p);
    canvas.drawLine(f2, b2, p);
    canvas.drawLine(f3, b3, p);
    canvas.drawLine(b1, b2, p);
    canvas.drawLine(b2, b3, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

class _StrokePainter extends CustomPainter {
  _StrokePainter({required this.strokes, required this.current});
  final List<List<Offset>> strokes;
  final List<Offset> current;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final s in strokes) _draw(canvas, s, p);
    if (current.isNotEmpty) _draw(canvas, current, p);
  }

  void _draw(Canvas canvas, List<Offset> pts, Paint p) {
    if (pts.length < 2) return;
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) path.lineTo(pts[i].dx, pts[i].dy);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _StrokePainter o) => true;
}

class _ClockNumPainter extends CustomPainter {
  _ClockNumPainter({required this.strokes, required this.nums});
  final List<List<Offset>> strokes;
  final List<Offset?> nums;

  @override
  void paint(Canvas canvas, Size size) {
    final sp = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final s in strokes) {
      if (s.length < 2) continue;
      final path = Path()..moveTo(s.first.dx, s.first.dy);
      for (int i = 1; i < s.length; i++) path.lineTo(s[i].dx, s[i].dy);
      canvas.drawPath(path, sp);
    }
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < 12; i++) {
      final pos = nums[i];
      if (pos == null) continue;
      tp.text = TextSpan(
        text: '${i + 1}',
        style: const TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      );
      tp.layout();
      tp.paint(
          canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _ClockNumPainter o) => true;
}

class _ClockHandPainter extends CustomPainter {
  _ClockHandPainter(
      {required this.strokes,
      required this.nums,
      this.hourEnd,
      this.minuteEnd});
  final List<List<Offset>> strokes;
  final List<Offset?> nums;
  final Offset? hourEnd;
  final Offset? minuteEnd;

  @override
  void paint(Canvas canvas, Size size) {
    final sp = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final s in strokes) {
      if (s.length < 2) continue;
      final path = Path()..moveTo(s.first.dx, s.first.dy);
      for (int i = 1; i < s.length; i++) path.lineTo(s[i].dx, s[i].dy);
      canvas.drawPath(path, sp);
    }
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < 12; i++) {
      final pos = nums[i];
      if (pos == null) continue;
      tp.text = TextSpan(
        text: '${i + 1}',
        style: const TextStyle(color: Colors.white70, fontSize: 13),
      );
      tp.layout();
      tp.paint(
          canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }
    final center = Offset(size.width / 2, size.height / 2);
    if (hourEnd != null) {
      canvas.drawLine(
          center,
          hourEnd!,
          Paint()
            ..color = Colors.white
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round);
    }
    if (minuteEnd != null) {
      canvas.drawLine(
          center,
          minuteEnd!,
          Paint()
            ..color = Colors.white70
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round);
    }
    if (hourEnd != null || minuteEnd != null) {
      canvas.drawCircle(center, 4, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _ClockHandPainter o) => true;
}
