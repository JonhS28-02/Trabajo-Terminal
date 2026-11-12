import 'package:flutter/material.dart';

import '../../../data/moca_result.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_widgets.dart';

class IdentificacionGame extends StatefulWidget {
  const IdentificacionGame({super.key});

  @override
  State<IdentificacionGame> createState() => _IdentificacionGameState();
}

class _IdentificacionGameState extends State<IdentificacionGame> {
  static const _animals = ['León', 'Rinoceronte', 'Camello'];
  static const _accepted = <List<String>>[
    ['león', 'leon'],
    ['rinoceronte', 'rino'],
    ['camello', 'dromedario'],
  ];

  final _ctrls = List.generate(3, (_) => TextEditingController());
  final _checked = [false, false, false];
  final _correct = [false, false, false];

  void _check(int i) {
    final input = _ctrls[i].text.trim().toLowerCase();
    setState(() {
      _checked[i] = true;
      _correct[i] = _accepted[i].contains(input);
    });
    if (_checked.every((c) => c)) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _finish();
      });
    }
  }

  void _finish() {
    for (int i = 0; i < 3; i++) {
      if (!_checked[i]) {
        final input = _ctrls[i].text.trim().toLowerCase();
        _checked[i] = true;
        _correct[i] = _accepted[i].contains(input);
      }
    }
    final total = _correct.where((c) => c).length;
    Navigator.of(context).pop(AreaResult(
      idArea: 2,
      puntajeObtenido: total,
      puntajeMaximo: 3,
      detalles: {
        for (int i = 0; i < 3; i++)
          _animals[i].toLowerCase(): _correct[i],
      },
    ));
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

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
            Text('Identificación', style: AppText.title.copyWith(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              'Escribe el nombre de cada animal que se muestra.',
              style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 13),
            ),
            const SizedBox(height: 24),
            for (int i = 0; i < 3; i++) ...[
              _animalCard(i),
              if (i < 2) const SizedBox(height: 16),
            ],
            const SizedBox(height: 32),
            PrimaryButton(label: 'FINALIZAR SECCIÓN', onPressed: _finish),
          ],
        ),
      ),
    );
  }

  Widget _animalCard(int i) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            width: double.infinity,
            child: CustomPaint(painter: _painter(i)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppField(
                  hint: '¿Qué animal es?',
                  controller: _ctrls[i],
                  textInputAction:
                      i < 2 ? TextInputAction.next : TextInputAction.done,
                  onSubmitted: (_) => _check(i),
                  isValid: _checked[i] && _correct[i],
                  errorText: _checked[i] && !_correct[i]
                      ? 'Respuesta incorrecta'
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              if (!_checked[i])
                GestureDetector(
                  onTap: () => _check(i),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.gradient,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 22),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  CustomPainter _painter(int i) => switch (i) {
    0 => _LionPainter(),
    1 => _RhinoPainter(),
    _ => _CamelPainter(),
  };
}

// ── Animal painters (unchanged) ──

class _LionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 2;
    paint.color = const Color(0xFFCC8833);
    canvas.drawCircle(Offset(cx, cy), 40, paint);
    paint.color = const Color(0xFFDDAA44);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 28, paint);
    paint.color = Colors.black;
    canvas.drawCircle(Offset(cx - 10, cy - 6), 3, paint);
    canvas.drawCircle(Offset(cx + 10, cy - 6), 3, paint);
    paint.color = const Color(0xFF663300);
    final nose = Path()
      ..moveTo(cx, cy + 4)..lineTo(cx - 5, cy + 10)
      ..lineTo(cx + 5, cy + 10)..close();
    canvas.drawPath(nose, paint);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    canvas.drawLine(Offset(cx, cy + 10), Offset(cx, cy + 16), paint);
    canvas.drawArc(Rect.fromCenter(center: Offset(cx - 5, cy + 16), width: 10, height: 6), 0, 3.14, false, paint);
    canvas.drawArc(Rect.fromCenter(center: Offset(cx + 5, cy + 16), width: 10, height: 6), 0, 3.14, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

class _RhinoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final paint = Paint()..strokeWidth = 2;
    paint.color = const Color(0xFF888888);
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 10), width: 100, height: 50),
      const Radius.circular(25),
    ), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 50, cy), width: 40, height: 35), paint);
    paint.color = const Color(0xFF666666);
    final horn = Path()..moveTo(cx - 65, cy - 10)..lineTo(cx - 70, cy - 30)..lineTo(cx - 55, cy - 10)..close();
    canvas.drawPath(horn, paint);
    paint.color = Colors.black;
    canvas.drawCircle(Offset(cx - 42, cy - 4), 3, paint);
    paint.color = const Color(0xFF777777);
    for (final x in [cx - 30, cx - 15, cx + 15, cx + 30])
      canvas.drawRect(Rect.fromLTWH(x - 5, cy + 30, 10, 20), paint);
    paint.style = PaintingStyle.stroke;
    paint.color = const Color(0xFF666666);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 40, cy - 16), width: 10, height: 14), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

class _CamelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final paint = Paint()..strokeWidth = 2;
    paint.color = const Color(0xFFCC9955);
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 10), width: 90, height: 40),
      const Radius.circular(20),
    ), paint);
    final hump = Path()..moveTo(cx - 20, cy - 10)..quadraticBezierTo(cx - 5, cy - 35, cx + 10, cy - 10);
    canvas.drawPath(hump, paint);
    final neck = Path()..moveTo(cx - 40, cy)..lineTo(cx - 55, cy - 35)..lineTo(cx - 45, cy - 35)..lineTo(cx - 30, cy)..close();
    canvas.drawPath(neck, paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 55, cy - 40), width: 25, height: 18), paint);
    paint.color = Colors.black;
    canvas.drawCircle(Offset(cx - 60, cy - 42), 2, paint);
    paint.color = const Color(0xFFBB8844);
    for (final x in [cx - 25, cx - 15, cx + 15, cx + 25])
      canvas.drawRect(Rect.fromLTWH(x - 4, cy + 28, 8, 22), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}
