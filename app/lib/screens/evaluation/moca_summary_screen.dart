import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/moca_result.dart';
import '../../data/moca_sections.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class MocaSummaryScreen extends StatefulWidget {
  const MocaSummaryScreen({
    super.key,
    required this.results,
    required this.idMoca,
    required this.token,
    this.role = 'especialista',
  });

  final List<AreaResult> results;
  final int idMoca;
  final String token;
  final String role;

  @override
  State<MocaSummaryScreen> createState() => _MocaSummaryScreenState();
}

class _MocaSummaryScreenState extends State<MocaSummaryScreen>
    with SingleTickerProviderStateMixin {
  bool _saving = false;
  late final AnimationController _animCtrl;
  late final Animation<double> _anim;

  bool get _isPatient => widget.role == 'paciente';

  int get _total => widget.results.fold(0, (s, r) => s + r.puntajeObtenido);
  int get _max => widget.results.fold(0, (s, r) => s + r.puntajeMaximo);

  String get _clasificacion {
    if (_total >= 26) return 'Normal';
    if (_total >= 18) return 'Deterioro Cognitivo Leve';
    return 'Demencia';
  }

  Color get _clasificacionColor {
    if (_total >= 26) return Colors.green;
    if (_total >= 18) return Colors.orange;
    return Colors.redAccent;
  }

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _anim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _finalizar() async {
    setState(() => _saving = true);
    try {
      await ApiService.guardarResultados(
        widget.idMoca,
        widget.results.map((r) => r.toJson()).toList(),
        widget.token,
      );
      await ApiService.finalizarMoca(
        widget.idMoca,
        _total,
        _clasificacion,
        widget.token,
      );
      if (!mounted) return;
      showDemoMessage(context, 'Evaluación finalizada exitosamente');
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on ApiException catch (e) {
      if (mounted) showDemoMessage(context, e.message);
    } catch (_) {
      if (mounted) showDemoMessage(context, 'Error de conexión');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: pad.top + 16,
          left: AppSizes.gutter,
          right: AppSizes.gutter,
          bottom: 28 + pad.bottom,
        ),
        child: _isPatient ? _buildPatientView() : _buildSpecialistView(),
      ),
    );
  }

  Widget _buildPatientView() {
    return Column(
      children: [
        const SizedBox(height: 60),
        AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => Transform.scale(
            scale: 0.5 + 0.5 * _anim.value,
            child: Opacity(
              opacity: _anim.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green.withAlpha(40),
                      AppColors.purple.withAlpha(40),
                    ],
                  ),
                  border: Border.all(color: Colors.green.withAlpha(80), width: 3),
                ),
                child: const Icon(Icons.check_rounded, color: Colors.green, size: 60),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text('Evaluación completada',
            style: AppText.title.copyWith(fontSize: 22)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(Icons.psychology_outlined, color: AppColors.purple, size: 40),
              const SizedBox(height: 16),
              Text(
                'Gracias por completar la evaluación',
                textAlign: TextAlign.center,
                style: AppText.label.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                'El especialista analizará tus resultados y te brindará '
                'las indicaciones correspondientes.',
                textAlign: TextAlign.center,
                style: AppText.subtitle.copyWith(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        PrimaryButton(
          label: 'FINALIZAR',
          loading: _saving,
          onPressed: _finalizar,
        ),
      ],
    );
  }

  Widget _buildSpecialistView() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text('Resultados MoCA',
            style: AppText.title.copyWith(fontSize: 22)),
        const SizedBox(height: 4),
        Text('Evaluación completada',
            style: AppText.subtitle.copyWith(color: AppColors.hint)),
        const SizedBox(height: 28),

        AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => _ScoreRing(
            score: _total,
            maxScore: _max,
            progress: _anim.value,
            color: _clasificacionColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              _clasificacionColor.withAlpha(50),
              _clasificacionColor.withAlpha(20),
            ]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _clasificacionColor.withAlpha(80)),
          ),
          child: Text(
            _clasificacion,
            style: AppText.label.copyWith(
              color: _clasificacionColor,
              fontSize: 15,
            ),
          ),
        ),

        const SizedBox(height: 32),

        Align(
          alignment: Alignment.centerLeft,
          child: Text('Desglose por área',
              style: AppText.label.copyWith(fontSize: 14)),
        ),
        const SizedBox(height: 12),

        for (int i = 0; i < widget.results.length; i++) ...[
          _AreaCard(result: widget.results[i], index: i),
          if (i < widget.results.length - 1) const SizedBox(height: 10),
        ],

        const SizedBox(height: 16),
        _ScaleLegend(color: _clasificacionColor),
        const SizedBox(height: 32),

        PrimaryButton(
          label: 'FINALIZAR EVALUACIÓN',
          loading: _saving,
          onPressed: _finalizar,
        ),
      ],
    );
  }
}

// ── Animated circular score ring ──

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({
    required this.score,
    required this.maxScore,
    required this.progress,
    required this.color,
  });

  final int score;
  final int maxScore;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fraction = maxScore > 0 ? score / maxScore : 0.0;
    return SizedBox(
      width: 180,
      height: 180,
      child: CustomPaint(
        painter: _RingPainter(
          fraction: fraction * progress,
          color: color,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(score * progress).round()}',
                style: AppText.title.copyWith(fontSize: 48, color: color),
              ),
              Text(
                'de $maxScore',
                style:
                    AppText.subtitle.copyWith(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.fraction, required this.color});
  final double fraction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 10.0;

    final bgPaint = Paint()
      ..color = Colors.white.withAlpha(15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * fraction,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.color != color;
}

// ── Area card with mini circular indicator ──

class _AreaCard extends StatelessWidget {
  const _AreaCard({required this.result, required this.index});
  final AreaResult result;
  final int index;

  @override
  Widget build(BuildContext context) {
    final section = mocaSections.firstWhere(
      (s) => s.idArea == result.idArea,
      orElse: () => mocaSections.first,
    );
    final fraction = result.puntajeMaximo > 0
        ? result.puntajeObtenido / result.puntajeMaximo
        : 0.0;
    final isPerfect = result.puntajeObtenido == result.puntajeMaximo &&
        result.puntajeMaximo > 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(14),
        border: isPerfect
            ? Border.all(color: Colors.green.withAlpha(60))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CustomPaint(
              painter: _RingPainter(
                fraction: fraction,
                color: isPerfect
                    ? Colors.green
                    : fraction >= 0.5
                        ? AppColors.purple
                        : Colors.orange,
              ),
              child: Center(
                child: Icon(section.icono, color: Colors.white, size: 18),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section.nombre,
                    style: AppText.label.copyWith(fontSize: 13)),
                const SizedBox(height: 2),
                if (result.puntajeMaximo == 0)
                  Text('Sin puntaje (registro)',
                      style: AppText.subtitle
                          .copyWith(color: Colors.white38, fontSize: 11))
                else
                  Row(children: [
                    _ScoreDot(
                        fraction: fraction,
                        isPerfect: isPerfect),
                    const SizedBox(width: 6),
                    Text(
                      '${result.puntajeObtenido} / ${result.puntajeMaximo} pts',
                      style: AppText.subtitle.copyWith(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ]),
              ],
            ),
          ),
          if (isPerfect)
            const Icon(Icons.star, color: Colors.amber, size: 20),
        ],
      ),
    );
  }
}

class _ScoreDot extends StatelessWidget {
  const _ScoreDot({required this.fraction, required this.isPerfect});
  final double fraction;
  final bool isPerfect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPerfect
            ? Colors.green
            : fraction >= 0.5
                ? AppColors.purple
                : Colors.orange,
      ),
    );
  }
}

// ── Scale legend ──

class _ScaleLegend extends StatelessWidget {
  const _ScaleLegend({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.purpleDark.withAlpha(50),
          AppColors.purpleDark.withAlpha(20),
        ]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.purple.withAlpha(40)),
      ),
      child: Column(
        children: [
          Text('Escala de clasificación',
              style: AppText.label.copyWith(fontSize: 12)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _legendItem('≥ 26', 'Normal', Colors.green),
              _legendItem('18-25', 'DCL', Colors.orange),
              _legendItem('< 18', 'Demencia', Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String range, String label, Color c) {
    return Column(children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: c.withAlpha(80),
          shape: BoxShape.circle,
          border: Border.all(color: c, width: 2),
        ),
      ),
      const SizedBox(height: 4),
      Text(range, style: AppText.label.copyWith(fontSize: 11, color: c)),
      Text(label,
          style: AppText.subtitle.copyWith(fontSize: 10, color: Colors.white54)),
    ]);
  }
}
