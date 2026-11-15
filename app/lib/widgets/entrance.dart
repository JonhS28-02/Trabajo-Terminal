import 'package:flutter/material.dart';

/// Entrada con desvanecimiento y un leve deslizamiento hacia arriba. Se reproduce una sola vez.
class Entrance extends StatefulWidget {
  const Entrance({super.key, required this.child, this.index = 0});

  final Widget child;

  /// Posición en la pantalla; cada elemento entra un poco después del anterior.
  final int index;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  late final Animation<double> _curve = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    final delay = Duration(milliseconds: 120 + 45 * widget.index.clamp(0, 10));
    Future<void>.delayed(delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: AnimatedBuilder(
        animation: _curve,
        builder: (_, child) =>
            Transform.translate(offset: Offset(0, 16 * (1 - _curve.value)), child: child),
        child: widget.child,
      ),
    );
  }
}

/// Envuelve los elementos de una columna para que entren escalonados. Los espaciadores no se animan.
List<Widget> staggered(List<Widget> children) {
  var i = 0;
  return [
    for (final w in children)
      if ((w is SizedBox && w.child == null) || w is Flexible || w is Spacer || w is Positioned)
        w
      else
        Entrance(index: i++, child: w),
  ];
}
