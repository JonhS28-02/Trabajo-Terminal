import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import 'register_screen.dart';

/// Frames "Animacion 8 → 9": una figura morada con la parte superior redonda
/// sube desde abajo, cubre la pantalla y da paso a "Registro".
class RegisterTransitionScreen extends StatefulWidget {
  const RegisterTransitionScreen({super.key});

  @override
  State<RegisterTransitionScreen> createState() =>
      _RegisterTransitionScreenState();
}

class _RegisterTransitionScreenState extends State<RegisterTransitionScreen>
    with SingleTickerProviderStateMixin {
  // Entrada 400 ms + pausa 400 ms + expansión 510 ms + pausa 400 ms.
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1710),
  );
  late final _rise = CurvedAnimation(
    parent: _c,
    curve: const Interval(0, 0.234, curve: Curves.easeOutCubic),
  );
  late final _expand = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.468, 0.766, curve: Curves.easeOutCubic),
  );

  @override
  void initState() {
    super.initState();
    _c.forward().whenComplete(() {
      if (!mounted) return;
      Navigator.of(context)
          .pushReplacement(fadeRoute(const RegisterScreen(), ms: 510));
    });
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
            final w = box.maxWidth;
            final h = box.maxHeight;
            // En Figma: 402 x 492 en y = 660 (de 874), esquinas superiores 360.
            final semiTop = h * 660 / 874;
            final top = h + (semiTop - h) * _rise.value;
            final currentTop = top * (1 - _expand.value);
            final radius = w * (1 - _expand.value);
            return Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: currentTop,
                  height: h - currentTop + h * 0.3 * (1 - _expand.value),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.shapeGradient,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(radius),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: w, height: h),
              ],
            );
          },
        ),
      ),
    );
  }
}
