import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

/// Animated live simulation that auto-completes the game so the patient
/// can watch how it works before doing it for real.
class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key, required this.idArea, required this.nombre});

  final int idArea;
  final String nombre;

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen>
    with TickerProviderStateMixin {
  bool _finished = false;

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
            const SizedBox(height: 12),
            // Banner
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.orange.withAlpha(40),
                  Colors.orange.withAlpha(15),
                ]),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withAlpha(60)),
              ),
              child: Row(children: [
                const Icon(Icons.play_circle_outline,
                    color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'EJEMPLO — ${widget.nombre}',
                    style: AppText.label.copyWith(
                      color: Colors.orange,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 6),
            Text(
              'Observa cómo se completa la prueba automáticamente.',
              style: AppText.subtitle
                  .copyWith(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 16),
            _buildSim(),
            const SizedBox(height: 20),
            if (_finished)
              PrimaryButton(
                label: 'ENTENDIDO, CONTINUAR',
                onPressed: () => Navigator.of(context).pop(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSim() {
    switch (widget.idArea) {
      case 1:
        return _TrailSim(onDone: () => setState(() => _finished = true));
      case 2:
        return _IdentSim(onDone: () => setState(() => _finished = true));
      case 3:
        return _MemoriaSim(onDone: () => setState(() => _finished = true));
      case 4:
        return _AtencionSim(onDone: () => setState(() => _finished = true));
      case 5:
        return _LenguajeSim(onDone: () => setState(() => _finished = true));
      case 6:
        return _AbstraccionSim(
            onDone: () => setState(() => _finished = true));
      case 7:
        return _RecuerdoSim(onDone: () => setState(() => _finished = true));
      case 8:
        return _OrientacionSim(
            onDone: () => setState(() => _finished = true));
      default:
        return const SizedBox();
    }
  }
}

// ══════════════════════════════════════════════════════════
// Shared helpers
// ══════════════════════════════════════════════════════════

const _simBg = AppColors.field;

Widget _simBox({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _simBg,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.orange.withAlpha(40)),
    ),
    child: child,
  );
}

Widget _simLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          textAlign: TextAlign.center,
          style: AppText.subtitle
              .copyWith(color: Colors.orange, fontSize: 12)),
    );

// ══════════════════════════════════════════════════════════
// 1 — Trail Making: nodes light up one by one in correct order
// ══════════════════════════════════════════════════════════

class _TrailSim extends StatefulWidget {
  const _TrailSim({required this.onDone});
  final VoidCallback onDone;
  @override
  State<_TrailSim> createState() => _TrailSimState();
}

class _TrailSimState extends State<_TrailSim> {
  final _seq = const ['1', 'A', '2', 'B', '3', 'C', '4', 'D', '5'];
  final _pos = const <String, Offset>{
    '1': Offset(30, 160),
    'A': Offset(120, 40),
    '2': Offset(220, 100),
    'B': Offset(80, 100),
    '3': Offset(180, 180),
    'C': Offset(260, 50),
    '4': Offset(50, 240),
    'D': Offset(200, 260),
    '5': Offset(280, 160),
  };
  int _idx = 0;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (!mounted) return;
      if (_idx < _seq.length) {
        setState(() => _idx++);
      } else {
        _t?.cancel();
        widget.onDone();
      }
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _simBox(
      child: Column(children: [
        _simLabel('Trail Making — conectando nodos…'),
        SizedBox(
          height: 300,
          child: Stack(
            children: [
              CustomPaint(
                size: const Size(double.infinity, 300),
                painter: _SimTrailPainter(
                    seq: _seq, pos: _pos, upTo: _idx),
              ),
              for (final e in _pos.entries)
                Positioned(
                  left: e.value.dx - 16,
                  top: e.value.dy - 16,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _seq.indexOf(e.key) < _idx
                          ? AppColors.purple
                          : AppColors.field,
                      border:
                          Border.all(color: AppColors.purple, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(e.key,
                        style: AppText.label.copyWith(fontSize: 12)),
                  ),
                ),
            ],
          ),
        ),
        Text(
          _idx >= _seq.length
              ? 'Secuencia completada correctamente ✓'
              : 'Seleccionando: ${_seq[min(_idx, _seq.length - 1)]}',
          style: AppText.subtitle.copyWith(
            color: _idx >= _seq.length ? Colors.green : Colors.white70,
            fontSize: 12,
          ),
        ),
      ]),
    );
  }
}

class _SimTrailPainter extends CustomPainter {
  _SimTrailPainter(
      {required this.seq, required this.pos, required this.upTo});
  final List<String> seq;
  final Map<String, Offset> pos;
  final int upTo;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.purple
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < upTo - 1; i++) {
      final a = pos[seq[i]], b = pos[seq[i + 1]];
      if (a != null && b != null) canvas.drawLine(a, b, p);
    }
  }

  @override
  bool shouldRepaint(covariant _SimTrailPainter o) => o.upTo != upTo;
}

// ══════════════════════════════════════════════════════════
// 2 — Identificación: animals + typed answers appear
// ══════════════════════════════════════════════════════════

class _IdentSim extends StatefulWidget {
  const _IdentSim({required this.onDone});
  final VoidCallback onDone;
  @override
  State<_IdentSim> createState() => _IdentSimState();
}

class _IdentSimState extends State<_IdentSim> {
  static const _animals = ['León', 'Rinoceronte', 'Camello'];
  static const _icons = [Icons.pets, Icons.pest_control, Icons.emoji_nature];
  int _step = 0;
  String _typing = '';
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _runType();
  }

  void _runType() {
    if (_step >= _animals.length) {
      widget.onDone();
      return;
    }
    final word = _animals[_step].toLowerCase();
    int ci = 0;
    _t = Timer.periodic(const Duration(milliseconds: 120), (_) {
      if (!mounted) return;
      if (ci < word.length) {
        setState(() => _typing = word.substring(0, ci + 1));
        ci++;
      } else {
        _t?.cancel();
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          setState(() {
            _step++;
            _typing = '';
          });
          _runType();
        });
      }
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _simBox(
      child: Column(children: [
        _simLabel('Identificación de animales'),
        const SizedBox(height: 8),
        for (int i = 0; i < _animals.length; i++) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: i < _step
                  ? Colors.green.withAlpha(20)
                  : Colors.white.withAlpha(5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: i < _step
                    ? Colors.green.withAlpha(60)
                    : Colors.white12,
              ),
            ),
            child: Row(children: [
              Icon(_icons[i], color: AppColors.purple, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Animal ${i + 1}',
                        style: AppText.subtitle.copyWith(
                            color: Colors.white54, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(
                      i < _step
                          ? _animals[i].toLowerCase()
                          : i == _step
                              ? _typing.isEmpty ? '|' : _typing
                              : '…',
                      style: AppText.label.copyWith(
                        fontSize: 14,
                        color: i < _step ? Colors.green : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (i < _step)
                const Icon(Icons.check_circle,
                    color: Colors.green, size: 20),
            ]),
          ),
        ],
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 3 — Memoria: words flash, then "typed" back
// ══════════════════════════════════════════════════════════

class _MemoriaSim extends StatefulWidget {
  const _MemoriaSim({required this.onDone});
  final VoidCallback onDone;
  @override
  State<_MemoriaSim> createState() => _MemoriaSimState();
}

class _MemoriaSimState extends State<_MemoriaSim> {
  static const _words = ['rostro', 'seda', 'iglesia', 'clavel', 'rojo'];
  int _phase = 0; // 0=showing, 1=hidden/typing, 2=done
  int _typed = 0;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _phase = 1);
      _typeWords();
    });
  }

  void _typeWords() {
    _t = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (!mounted) return;
      if (_typed < _words.length) {
        setState(() => _typed++);
      } else {
        _t?.cancel();
        setState(() => _phase = 2);
        widget.onDone();
      }
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _simBox(
      child: Column(children: [
        _simLabel(_phase == 0
            ? 'Memorizando palabras…'
            : _phase == 1
                ? 'Escribiendo de memoria…'
                : 'Registro completado'),
        const SizedBox(height: 12),
        if (_phase == 0)
          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _words
                .map((w) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.purpleDark.withAlpha(80),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child:
                          Text(w, style: AppText.label.copyWith(fontSize: 14)),
                    ))
                .toList(),
          )
        else
          for (int i = 0; i < _words.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                SizedBox(
                  width: 24,
                  child: Text('${i + 1}.',
                      style: AppText.subtitle
                          .copyWith(color: Colors.white38, fontSize: 12)),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: i < _typed
                              ? Colors.green.withAlpha(60)
                              : Colors.white12),
                    ),
                    child: Text(
                      i < _typed ? _words[i] : '…',
                      style: AppText.subtitle.copyWith(
                        color: i < _typed ? Colors.white : Colors.white24,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                if (i < _typed)
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child:
                        Icon(Icons.check, color: Colors.green, size: 16),
                  ),
              ]),
            ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 4 — Atención: digits typed, vigilancia taps, serial 7
// ══════════════════════════════════════════════════════════

class _AtencionSim extends StatefulWidget {
  const _AtencionSim({required this.onDone});
  final VoidCallback onDone;
  @override
  State<_AtencionSim> createState() => _AtencionSimState();
}

class _AtencionSimState extends State<_AtencionSim> {
  int _sub = 0; // 0=adelante, 1=atrás, 2=vigilancia, 3=serial7
  String _typed = '';
  Timer? _t;

  // Vigilancia
  static const _vigLetters = ['F', 'B', 'A', 'C', 'M', 'A', 'K'];
  int _vigIdx = -1;
  bool _vigTapped = false;

  // Serial 7
  int _s7Done = 0;
  static const _s7Answers = ['93', '86', '79', '72', '65'];

  @override
  void initState() {
    super.initState();
    _runSub();
  }

  void _runSub() {
    switch (_sub) {
      case 0:
        _typeSequence('21854', () => _nextSub());
        break;
      case 1:
        _typeSequence('247', () => _nextSub());
        break;
      case 2:
        _runVig();
        break;
      case 3:
        _runSerial();
        break;
    }
  }

  void _nextSub() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _sub++;
        _typed = '';
      });
      if (_sub <= 3) {
        _runSub();
      } else {
        widget.onDone();
      }
    });
  }

  void _typeSequence(String target, VoidCallback then) {
    int ci = 0;
    _t = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted) return;
      if (ci < target.length) {
        setState(() => _typed = target.substring(0, ci + 1));
        ci++;
      } else {
        _t?.cancel();
        then();
      }
    });
  }

  void _runVig() {
    _t = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      if (!mounted) return;
      setState(() {
        _vigIdx++;
        _vigTapped = false;
      });
      if (_vigIdx < _vigLetters.length) {
        if (_vigLetters[_vigIdx] == 'A') {
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) setState(() => _vigTapped = true);
          });
        }
      } else {
        _t?.cancel();
        _nextSub();
      }
    });
  }

  void _runSerial() {
    _t = Timer.periodic(const Duration(milliseconds: 700), (_) {
      if (!mounted) return;
      if (_s7Done < 5) {
        setState(() => _s7Done++);
      } else {
        _t?.cancel();
        _nextSub();
      }
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _simBox(
      child: Column(children: [
        _simLabel(_subLabel),
        const SizedBox(height: 8),
        if (_sub == 0 || _sub == 1) _buildDigits(),
        if (_sub == 2) _buildVig(),
        if (_sub == 3) _buildSerial(),
      ]),
    );
  }

  String get _subLabel {
    switch (_sub) {
      case 0:
        return 'Dígitos hacia adelante: 2-1-8-5-4';
      case 1:
        return 'Dígitos hacia atrás: 7-4-2 → 2-4-7';
      case 2:
        return 'Vigilancia — presionar GOLPE en la letra A';
      case 3:
        return 'Resta en serie: 100 − 7 × 5';
      default:
        return 'Completado';
    }
  }

  Widget _buildDigits() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          _typed.isEmpty ? '|' : _typed,
          style: AppText.title.copyWith(fontSize: 32, letterSpacing: 8),
        ),
      ),
    );
  }

  Widget _buildVig() {
    if (_vigIdx < 0 || _vigIdx >= _vigLetters.length) {
      return const SizedBox(height: 80);
    }
    return Column(children: [
      Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.purpleDark.withAlpha(80),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(_vigLetters[_vigIdx],
            style: AppText.title.copyWith(fontSize: 36)),
      ),
      const SizedBox(height: 12),
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient:
              !_vigTapped ? AppColors.gradient : null,
          color: _vigTapped ? Colors.green.withAlpha(40) : null,
          borderRadius: BorderRadius.circular(12),
          border: _vigTapped
              ? Border.all(color: Colors.green, width: 2)
              : null,
        ),
        child: Text(
          _vigTapped ? 'GOLPE REGISTRADO' : 'GOLPE',
          style: AppText.button.copyWith(fontSize: 14),
        ),
      ),
    ]);
  }

  Widget _buildSerial() {
    return Column(
      children: [
        for (int i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              SizedBox(
                width: 80,
                child: Text('${100 - 7 * i} − 7 =',
                    style: AppText.label.copyWith(fontSize: 13)),
              ),
              const SizedBox(width: 8),
              Text(
                i < _s7Done ? _s7Answers[i] : '…',
                style: AppText.subtitle.copyWith(
                  color: i < _s7Done ? Colors.green : Colors.white24,
                  fontSize: 14,
                ),
              ),
            ]),
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
// 5 — Lenguaje: sentence appears, hides, gets typed, timer counts
// ══════════════════════════════════════════════════════════

class _LenguajeSim extends StatefulWidget {
  const _LenguajeSim({required this.onDone});
  final VoidCallback onDone;
  @override
  State<_LenguajeSim> createState() => _LenguajeSimState();
}

class _LenguajeSimState extends State<_LenguajeSim> {
  int _phase = 0; // 0=show sentence, 1=typing sentence, 2=fluency, 3=done
  String _sentence =
      'El gato se escondió bajo el sofá cuando los perros entraron en la sala.';
  String _typed = '';
  int _fWords = 0;
  static const _fList = [
    'fresa',
    'fútbol',
    'familia',
    'flor',
    'fuego',
    'fácil',
    'forma',
    'fuerza',
    'fiesta',
    'frío',
    'faro',
  ];
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _phase = 1);
      _typeSentence();
    });
  }

  void _typeSentence() {
    int ci = 0;
    final target = _sentence.toLowerCase();
    _t = Timer.periodic(const Duration(milliseconds: 40), (_) {
      if (!mounted) return;
      if (ci < target.length) {
        setState(() => _typed = target.substring(0, ci + 1));
        ci++;
      } else {
        _t?.cancel();
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() => _phase = 2);
            _runFluency();
          }
        });
      }
    });
  }

  void _runFluency() {
    _t = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      if (_fWords < _fList.length) {
        setState(() => _fWords++);
      } else {
        _t?.cancel();
        setState(() => _phase = 3);
        widget.onDone();
      }
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _simBox(
      child: Column(children: [
        _simLabel(_phase <= 1
            ? 'Repetición de oraciones'
            : _phase == 2
                ? 'Fluidez verbal — palabras con F'
                : 'Sección completada'),
        const SizedBox(height: 8),
        if (_phase == 0)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.purpleDark.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(_sentence,
                style: AppText.subtitle.copyWith(
                  color: Colors.white,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                )),
          )
        else if (_phase == 1)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.purple.withAlpha(60)),
            ),
            child: Text(
              _typed.isEmpty ? '|' : _typed,
              style: AppText.subtitle.copyWith(
                color: Colors.white,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (int i = 0; i < _fWords; i++)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.purpleDark.withAlpha(60),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(_fList[i],
                      style: AppText.subtitle.copyWith(
                          color: Colors.white, fontSize: 12)),
                ),
            ],
          ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 6 — Abstracción: pairs + answers typed
// ══════════════════════════════════════════════════════════

class _AbstraccionSim extends StatefulWidget {
  const _AbstraccionSim({required this.onDone});
  final VoidCallback onDone;
  @override
  State<_AbstraccionSim> createState() => _AbstraccionSimState();
}

class _AbstraccionSimState extends State<_AbstraccionSim> {
  static const _pairs = [
    ['Naranja', 'Plátano', 'frutas'],
    ['Tren', 'Bicicleta', 'transporte'],
  ];
  int _done = 0;
  String _typing = '';
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _typePair();
  }

  void _typePair() {
    if (_done >= _pairs.length) {
      widget.onDone();
      return;
    }
    final answer = _pairs[_done][2];
    int ci = 0;
    _t = Timer.periodic(const Duration(milliseconds: 150), (_) {
      if (!mounted) return;
      if (ci < answer.length) {
        setState(() => _typing = answer.substring(0, ci + 1));
        ci++;
      } else {
        _t?.cancel();
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          setState(() {
            _done++;
            _typing = '';
          });
          _typePair();
        });
      }
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _simBox(
      child: Column(children: [
        _simLabel('Abstracción — similitud entre pares'),
        const SizedBox(height: 8),
        for (int i = 0; i < _pairs.length; i++) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: i < _done
                  ? Colors.green.withAlpha(15)
                  : Colors.white.withAlpha(5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: i < _done
                      ? Colors.green.withAlpha(50)
                      : Colors.white12),
            ),
            child: Column(children: [
              Text('${_pairs[i][0]}  —  ${_pairs[i][1]}',
                  style: AppText.label.copyWith(fontSize: 14)),
              const SizedBox(height: 8),
              Text(
                i < _done
                    ? _pairs[i][2]
                    : i == _done
                        ? (_typing.isEmpty ? '|' : _typing)
                        : '…',
                style: AppText.subtitle.copyWith(
                  color:
                      i < _done ? Colors.green : Colors.white70,
                  fontSize: 13,
                ),
              ),
            ]),
          ),
        ],
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 7 — Recuerdo: words typed from memory
// ══════════════════════════════════════════════════════════

class _RecuerdoSim extends StatefulWidget {
  const _RecuerdoSim({required this.onDone});
  final VoidCallback onDone;
  @override
  State<_RecuerdoSim> createState() => _RecuerdoSimState();
}

class _RecuerdoSimState extends State<_RecuerdoSim> {
  static const _words = ['rostro', 'seda', 'iglesia', 'clavel', 'rojo'];
  int _done = 0;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (!mounted) return;
      if (_done < _words.length) {
        setState(() => _done++);
      } else {
        _t?.cancel();
        widget.onDone();
      }
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _simBox(
      child: Column(children: [
        _simLabel('Recuerdo diferido — escribiendo palabras'),
        const SizedBox(height: 8),
        for (int i = 0; i < _words.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              SizedBox(
                width: 24,
                child: Text('${i + 1}.',
                    style: AppText.subtitle
                        .copyWith(color: Colors.white38, fontSize: 12)),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: i < _done
                            ? Colors.green.withAlpha(60)
                            : Colors.white12),
                  ),
                  child: Text(
                    i < _done ? _words[i] : '…',
                    style: AppText.subtitle.copyWith(
                      color:
                          i < _done ? Colors.white : Colors.white24,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              if (i < _done)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child:
                      Icon(Icons.check, color: Colors.green, size: 16),
                ),
            ]),
          ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 8 — Orientación: fields fill in automatically
// ══════════════════════════════════════════════════════════

class _OrientacionSim extends StatefulWidget {
  const _OrientacionSim({required this.onDone});
  final VoidCallback onDone;
  @override
  State<_OrientacionSim> createState() => _OrientacionSimState();
}

class _OrientacionSimState extends State<_OrientacionSim> {
  static const _labels = [
    '¿Día del mes?',
    '¿Mes?',
    '¿Año?',
    '¿Día de la semana?',
    '¿Ciudad?',
    '¿Institución?',
  ];
  late final List<String> _answers;
  int _done = 0;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    const dias = [
      '', 'lunes', 'martes', 'miércoles', 'jueves',
      'viernes', 'sábado', 'domingo',
    ];
    _answers = [
      '${now.day}',
      meses[now.month - 1],
      '${now.year}',
      dias[now.weekday],
      'Ciudad de México',
      'ESCOM - IPN',
    ];
    _t = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (!mounted) return;
      if (_done < _labels.length) {
        setState(() => _done++);
      } else {
        _t?.cancel();
        widget.onDone();
      }
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _simBox(
      child: Column(children: [
        _simLabel('Orientación — respondiendo preguntas'),
        const SizedBox(height: 8),
        for (int i = 0; i < _labels.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(
                flex: 2,
                child: Text(_labels[i],
                    style: AppText.subtitle
                        .copyWith(color: Colors.white54, fontSize: 12)),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: i < _done
                            ? Colors.green.withAlpha(50)
                            : Colors.white12),
                  ),
                  child: Text(
                    i < _done ? _answers[i] : '…',
                    style: AppText.subtitle.copyWith(
                      color: i < _done ? Colors.white : Colors.white24,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ]),
          ),
      ]),
    );
  }
}
