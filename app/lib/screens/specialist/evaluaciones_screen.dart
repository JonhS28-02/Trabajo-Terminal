import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/entrance.dart';

class EvaluacionesScreen extends StatefulWidget {
  const EvaluacionesScreen({super.key, required this.patient});
  final Map<String, dynamic> patient;

  @override
  State<EvaluacionesScreen> createState() => _EvaluacionesScreenState();
}

class _EvaluacionesScreenState extends State<EvaluacionesScreen> {
  List<Map<String, dynamic>> _mocas = [];
  bool _loading = true;
  int? _selectedIndex;

  static const _areaNames = [
    'Visuoespacial',
    'Identificación',
    'Memoria',
    'Atención',
    'Lenguaje',
    'Abstracción',
    'Recuerdo',
    'Orientación',
  ];

  static const _areaMax = [5, 3, 0, 6, 3, 2, 5, 6];

  static const _areaColors = [
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFFEC4899),
    Color(0xFF3B82F6),
    Color(0xFF6366F1),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final token = await SessionService.getToken();
      if (token == null) return;
      final idPaciente = widget.patient['id_paciente'] as int;
      final list = await ApiService.historialMoca(idPaciente, token);
      if (!mounted) return;
      setState(() {
        _mocas = list.cast<Map<String, dynamic>>();
        _loading = false;
        if (_mocas.isNotEmpty) _selectedIndex = _mocas.length - 1;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        showDemoMessage(context, 'Error al cargar evaluaciones');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = widget.patient['nombre'] as String? ?? '';
    final apellido = widget.patient['apellido_paterno'] as String? ?? '';
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.purple))
          : SingleChildScrollView(
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + 16,
                left: AppSizes.gutter,
                right: AppSizes.gutter,
                bottom: 32 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: staggered([
                  const CircleBackButton(),
                  const SizedBox(height: 16),
                  Text('Evaluaciones MoCA', style: AppText.title.copyWith(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text(
                    '$nombre $apellido',
                    style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  if (_mocas.isEmpty)
                    _buildEmpty()
                  else ...[
                    if (_mocas.length > 1) ...[
                      _buildEvolutionChart(),
                      const SizedBox(height: 24),
                    ],
                    _buildSessionSelector(),
                    const SizedBox(height: 16),
                    if (_selectedIndex != null) ...[
                      _buildSummaryCard(_mocas[_selectedIndex!]),
                      const SizedBox(height: 20),
                      _buildRadarChart(_mocas[_selectedIndex!]),
                      const SizedBox(height: 20),
                      _buildAreaBreakdown(_mocas[_selectedIndex!]),
                    ],
                  ],
                ]),
              ),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.assessment_outlined, size: 80, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 20),
          Text('Sin evaluaciones', style: AppText.title.copyWith(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            'Este paciente aún no ha completado ninguna evaluación MoCA.',
            textAlign: TextAlign.center,
            style: AppText.subtitle.copyWith(color: AppColors.hint),
          ),
        ],
      ),
    );
  }

  Widget _buildEvolutionChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Evolución del puntaje total', style: AppText.label.copyWith(fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            '${_mocas.length} evaluaciones realizadas',
            style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 11),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: CustomPaint(
              size: const Size(double.infinity, 180),
              painter: _EvolutionPainter(
                mocas: _mocas,
                selectedIndex: _selectedIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionSelector() {
    return SizedBox(
      height: 84,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _mocas.length,
        itemBuilder: (context, i) {
          final m = _mocas[i];
          final fecha = DateTime.tryParse(m['fecha'] as String? ?? '');
          final pts = m['puntaje_total'] as int? ?? 0;
          final selected = _selectedIndex == i;
          final clasificacion = m['clasificacion'] as String? ?? '';
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = i),
            child: Container(
              width: 110,
              margin: EdgeInsets.only(right: i < _mocas.length - 1 ? 10 : 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected ? AppColors.purpleDark.withValues(alpha: 0.6) : AppColors.field,
                borderRadius: BorderRadius.circular(12),
                border: selected ? Border.all(color: AppColors.purple, width: 1.5) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '#${i + 1}',
                    style: AppText.label.copyWith(
                      fontSize: 11,
                      color: selected ? AppColors.purple : AppColors.hint,
                    ),
                  ),
                  Text(
                    '$pts/30',
                    style: AppText.label.copyWith(
                      fontSize: 16,
                      color: _colorForClasificacion(clasificacion),
                    ),
                  ),
                  if (fecha != null)
                    Text(
                      '${fecha.day}/${fecha.month}/${fecha.year}',
                      style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 9),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> moca) {
    final pts = moca['puntaje_total'] as int? ?? 0;
    final clasificacion = moca['clasificacion'] as String? ?? 'N/A';
    final fecha = DateTime.tryParse(moca['fecha'] as String? ?? '');
    final color = _colorForClasificacion(clasificacion);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: pts / 30,
                    strokeWidth: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$pts', style: AppText.title.copyWith(fontSize: 24, color: color)),
                    Text('/30', style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    clasificacion,
                    style: AppText.label.copyWith(color: color, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 8),
                if (fecha != null)
                  Text(
                    '${fecha.day}/${fecha.month}/${fecha.year} — ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}',
                    style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 11),
                  ),
                const SizedBox(height: 4),
                Text(
                  pts >= 26
                      ? 'Dentro del rango normal'
                      : pts >= 18
                          ? 'Deterioro cognitivo leve'
                          : 'Posible demencia',
                  style: AppText.subtitle.copyWith(
                    color: color.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarChart(Map<String, dynamic> moca) {
    final resultados = (moca['resultados'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Perfil cognitivo', style: AppText.label.copyWith(fontSize: 13)),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: CustomPaint(
              size: const Size(double.infinity, 260),
              painter: _RadarPainter(resultados: resultados, areaMax: _areaMax),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaBreakdown(Map<String, dynamic> moca) {
    final resultados = (moca['resultados'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Desglose por área', style: AppText.label.copyWith(fontSize: 13)),
        const SizedBox(height: 12),
        for (int i = 0; i < _areaNames.length; i++)
          _buildAreaBar(i, resultados),
      ],
    );
  }

  Widget _buildAreaBar(int areaIndex, List<Map<String, dynamic>> resultados) {
    final idArea = areaIndex + 1;
    final resultado = resultados.where((r) => r['id_area'] == idArea).firstOrNull;
    final obtenido = resultado?['puntaje_obtenido'] as int? ?? 0;
    final maximo = _areaMax[areaIndex];
    final color = _areaColors[areaIndex];

    if (maximo == 0) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_areaNames[areaIndex], style: AppText.label.copyWith(fontSize: 12)),
                  Text('Sin puntuación (registro)', style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final fraction = maximo > 0 ? obtenido / maximo : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(_areaNames[areaIndex], style: AppText.label.copyWith(fontSize: 12)),
              ),
              Text(
                '$obtenido/$maximo',
                style: AppText.label.copyWith(
                  fontSize: 14,
                  color: fraction >= 0.7 ? Colors.green : fraction >= 0.4 ? Colors.orange : Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForClasificacion(String c) {
    final lower = c.toLowerCase();
    if (lower.contains('normal')) return Colors.green;
    if (lower.contains('leve') || lower.contains('dcl')) return Colors.orange;
    return Colors.redAccent;
  }
}

class _EvolutionPainter extends CustomPainter {
  _EvolutionPainter({required this.mocas, this.selectedIndex});
  final List<Map<String, dynamic>> mocas;
  final int? selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (mocas.isEmpty) return;

    final leftPad = 30.0;
    final rightPad = 10.0;
    final topPad = 10.0;
    final bottomPad = 24.0;
    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;

    final normalPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    final normalY = topPad + chartH * (1 - 26 / 30);
    canvas.drawRect(Rect.fromLTRB(leftPad, topPad, leftPad + chartW, normalY), normalPaint);

    final dclPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    final dclY = topPad + chartH * (1 - 18 / 30);
    canvas.drawRect(Rect.fromLTRB(leftPad, normalY, leftPad + chartW, dclY), dclPaint);

    final demPaint = Paint()
      ..color = Colors.redAccent.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTRB(leftPad, dclY, leftPad + chartW, topPad + chartH), demPaint);

    for (final threshold in [26, 18]) {
      final y = topPad + chartH * (1 - threshold / 30);
      final dashPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..strokeWidth = 1;
      for (double x = leftPad; x < leftPad + chartW; x += 8) {
        canvas.drawLine(Offset(x, y), Offset(math.min(x + 4, leftPad + chartW), y), dashPaint);
      }
      final tp = TextPainter(
        text: TextSpan(
          text: '$threshold',
          style: const TextStyle(color: Colors.white38, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 4, y - tp.height / 2));
    }

    final points = <Offset>[];
    for (int i = 0; i < mocas.length; i++) {
      final pts = mocas[i]['puntaje_total'] as int? ?? 0;
      final x = mocas.length == 1
          ? leftPad + chartW / 2
          : leftPad + (chartW * i / (mocas.length - 1));
      final y = topPad + chartH * (1 - pts / 30);
      points.add(Offset(x, y));
    }

    if (points.length > 1) {
      final linePaint = Paint()
        ..color = AppColors.purple
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final path = Path()..moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);

      final fillPath = Path()..addPath(path, Offset.zero);
      fillPath.lineTo(points.last.dx, topPad + chartH);
      fillPath.lineTo(points.first.dx, topPad + chartH);
      fillPath.close();
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.purple.withValues(alpha: 0.3), AppColors.purple.withValues(alpha: 0.0)],
        ).createShader(Rect.fromLTWH(0, topPad, size.width, chartH));
      canvas.drawPath(fillPath, fillPaint);
    }

    for (int i = 0; i < points.length; i++) {
      final isSelected = selectedIndex == i;
      final dotPaint = Paint()
        ..color = isSelected ? Colors.white : AppColors.purple
        ..style = PaintingStyle.fill;
      canvas.drawCircle(points[i], isSelected ? 6 : 4, dotPaint);
      if (isSelected) {
        final ringPaint = Paint()
          ..color = AppColors.purple
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(points[i], 6, ringPaint);
      }

      final pts = mocas[i]['puntaje_total'] as int? ?? 0;
      final tp = TextPainter(
        text: TextSpan(
          text: '$pts',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSelected ? 11 : 9,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(points[i].dx - tp.width / 2, points[i].dy - tp.height - 8));
    }
  }

  @override
  bool shouldRepaint(covariant _EvolutionPainter old) =>
      old.selectedIndex != selectedIndex || old.mocas.length != mocas.length;
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({required this.resultados, required this.areaMax});
  final List<Map<String, dynamic>> resultados;
  final List<int> areaMax;

  static const _labels = ['VE', 'ID', 'ME', 'AT', 'LE', 'AB', 'RE', 'OR'];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(cx, cy) - 30;
    final n = 8;
    final angleStep = 2 * math.pi / n;
    final startAngle = -math.pi / 2;

    for (final level in [0.25, 0.5, 0.75, 1.0]) {
      final r = radius * level;
      final path = Path();
      for (int i = 0; i <= n; i++) {
        final angle = startAngle + angleStep * (i % n);
        final x = cx + r * math.cos(angle);
        final y = cy + r * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.06)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }

    for (int i = 0; i < n; i++) {
      final angle = startAngle + angleStep * i;
      final ex = cx + radius * math.cos(angle);
      final ey = cy + radius * math.sin(angle);
      canvas.drawLine(
        Offset(cx, cy),
        Offset(ex, ey),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.06)
          ..strokeWidth = 0.5,
      );

      final labelR = radius + 18;
      final lx = cx + labelR * math.cos(angle);
      final ly = cy + labelR * math.sin(angle);
      final tp = TextPainter(
        text: TextSpan(
          text: _labels[i],
          style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
    }

    final dataPath = Path();
    for (int i = 0; i <= n; i++) {
      final idx = i % n;
      final idArea = idx + 1;
      final max = areaMax[idx];
      double frac = 0;
      if (max > 0) {
        final r = resultados.where((r) => r['id_area'] == idArea).firstOrNull;
        final obt = r?['puntaje_obtenido'] as int? ?? 0;
        frac = obt / max;
      }
      final angle = startAngle + angleStep * idx;
      final x = cx + radius * frac * math.cos(angle);
      final y = cy + radius * frac * math.sin(angle);
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();

    canvas.drawPath(
      dataPath,
      Paint()
        ..color = AppColors.purple.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = AppColors.purple
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    for (int i = 0; i < n; i++) {
      final max = areaMax[i];
      double frac = 0;
      if (max > 0) {
        final r = resultados.where((r) => r['id_area'] == (i + 1)).firstOrNull;
        final obt = r?['puntaje_obtenido'] as int? ?? 0;
        frac = obt / max;
      }
      final angle = startAngle + angleStep * i;
      final x = cx + radius * frac * math.cos(angle);
      final y = cy + radius * frac * math.sin(angle);
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()..color = AppColors.purple,
      );
      canvas.drawCircle(
        Offset(x, y),
        2,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) => true;
}
