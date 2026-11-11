import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'auth/login_screen.dart';

/// Frame de la figura en un instante de la animación, en coordenadas del
/// frame de Figma (402 x 874).
class _Shape {
  const _Shape(this.rect, this.radius, this.turns);

  final Rect rect;
  final double radius;
  final double turns;

  static _Shape lerp(_Shape a, _Shape b, double t) => _Shape(
        Rect.lerp(a.rect, b.rect, t)!,
        a.radius + (b.radius - a.radius) * t,
        a.turns + (b.turns - a.turns) * t,
      );
}

/// Animación de entrada (frames "Animacion 7 → 1 → 2 → 3 → 4 → 5"):
/// cuadro → rombo → círculo → "Brain Test ●" → morado completo → login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _frameW = 402.0;
  static const _frameH = 874.0;

  // Estados clave tomados de cada frame.
  static final _hidden = _Shape(Rect.fromCenter(center: const Offset(201, 437), width: 0, height: 0), 0, 0);
  static final _square = _Shape(const Rect.fromLTWH(141, 377, 120, 120), 20, 0);
  static final _diamond = _Shape(Rect.fromCenter(center: const Offset(201, 437), width: 170, height: 170), 20, 1 / 8);
  static final _dot = _Shape(const Rect.fromLTWH(176, 412, 50, 50), 25, 0);
  static final _dotRight = _Shape(const Rect.fromLTWH(317, 412, 50, 50), 25, 0);
  static final _full = _Shape(const Rect.fromLTWH(0, 0, _frameW, _frameH), 0, 0);

  // Duraciones de los "Smart animate" del prototipo (ms) y pausas.
  static const _steps = <(int, Curve)>[
    (300, Curves.linear), // pausa en negro
    (1020, Curves.easeOutBack), // 7 → 1 resorte (damping 15)
    (500, Curves.easeInOut), // 1 → 2
    (1020, Curves.easeOutBack), // 2 → 3 resorte
    (1020, Curves.easeOutBack), // 3 → 4 resorte
    (1000, Curves.linear), // pausa de 1 s en "Brain Test"
    (510, Curves.easeOutCubic), // 4 → 5 resorte rígido
    (200, Curves.linear), // pausa de 0.2 s
  ];

  late final int _totalMs = _steps.fold(0, (sum, s) => sum + s.$1);
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _totalMs),
  );

  /// Devuelve (índice de paso, progreso con curva) para el tiempo actual.
  (int, double) _phase() {
    var t = _c.value * _totalMs;
    for (var i = 0; i < _steps.length; i++) {
      final (ms, curve) = _steps[i];
      if (t <= ms) return (i, curve.transform((t / ms).clamp(0.0, 1.0)));
      t -= ms;
    }
    return (_steps.length - 1, 1);
  }

  @override
  void initState() {
    super.initState();
    // Arranca hasta que el primer frame ya se mostró y la fuente e imagen del
    // login están cargadas; si no, el arranque de la app se "come" las
    // primeras fases de la animación.
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    try {
      await Future.wait([
        GoogleFonts.pendingFonts([GoogleFonts.inter(fontWeight: FontWeight.w700)]),
        precacheImage(const AssetImage('assets/images/login.jpg'), context),
      ]).timeout(const Duration(seconds: 2));
    } catch (_) {
      // Sin red o carga lenta: la animación sigue con la fuente de respaldo.
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    await _c.forward();
    if (!mounted) return;
    Navigator.of(context)
        .pushReplacement(fadeRoute(const LoginScreen(), ms: 510));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, box) => AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final (step, t) = _phase();
            final shape = switch (step) {
              0 => _hidden,
              1 => _Shape.lerp(_hidden, _square, t),
              2 => _Shape.lerp(_square, _diamond, t),
              3 => _Shape.lerp(_diamond, _dot, t),
              4 => _Shape.lerp(_dot, _dotRight, t),
              5 => _dotRight,
              6 => _Shape.lerp(_dotRight, _full, t),
              _ => _full,
            };
            final textOpacity = switch (step) {
              < 4 => 0.0,
              4 => t.clamp(0.0, 1.0),
              5 => 1.0,
              6 => 1 - t,
              _ => 0.0,
            };

            // Escala del frame de Figma a la pantalla real.
            final sx = box.maxWidth / _frameW;
            final sy = box.maxHeight / _frameH;
            final s = sx < sy ? sx : sy;
            Rect toScreen(Rect r) {
              // La figura final ocupa la pantalla completa sin importar la proporción.
              if (step >= 6) {
                final fullScreen = Offset.zero & box.biggest;
                final fromDot = Rect.fromCenter(
                  center: Offset(box.maxWidth / 2 + (r.center.dx - 201) * s,
                      box.maxHeight / 2 + (r.center.dy - 437) * s),
                  width: r.width * s,
                  height: r.height * s,
                );
                return Rect.lerp(fromDot, fullScreen, step == 6 ? t : 1)!;
              }
              return Rect.fromCenter(
                center: Offset(box.maxWidth / 2 + (r.center.dx - 201) * s,
                    box.maxHeight / 2 + (r.center.dy - 437) * s),
                width: r.width * s,
                height: r.height * s,
              );
            }

            final rect = toScreen(step >= 6 ? _dotRight.rect : shape.rect);
            final width = rect.width.clamp(0.0, double.infinity);
            final height = rect.height.clamp(0.0, double.infinity);

            return Stack(
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity: textOpacity,
                      child: Text(
                        'Brain Test',
                        style: GoogleFonts.inter(
                          fontSize: 40 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: rect.left,
                  top: rect.top,
                  width: width,
                  height: height,
                  child: Transform.rotate(
                    angle: shape.turns * 2 * 3.141592653589793,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.shapeGradient,
                        borderRadius: BorderRadius.circular(
                          (shape.radius * s).clamp(0.0, double.infinity),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
