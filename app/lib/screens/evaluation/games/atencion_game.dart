import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/moca_result.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_widgets.dart';

enum _DigitPhase { showing, hiding, input }

class AtencionGame extends StatefulWidget {
  const AtencionGame({super.key});

  @override
  State<AtencionGame> createState() => _AtencionGameState();
}

class _AtencionGameState extends State<AtencionGame> {
  int _subTask = 0;

  // ── Dígitos adelante: 2-1-8-5-4 ──
  final _adelanteCtrl = TextEditingController();
  int _adelanteScore = -1;
  _DigitPhase _adelantePhase = _DigitPhase.showing;
  Timer? _adelanteTimer;

  // ── Dígitos atrás: 7-4-2 → 2-4-7 ──
  final _atrasCtrl = TextEditingController();
  int _atrasScore = -1;
  _DigitPhase _atrasPhase = _DigitPhase.showing;
  Timer? _atrasTimer;

  // ── Vigilancia ──
  static const _vigLetras = [
    'F','B','A','C','M','N','A','A','J','K',
    'L','B','A','F','A','K','D','E','A','A','J',
  ];
  int _vigIdx = 0;
  bool _vigRunning = false;
  bool _vigDone = false;
  bool _tappedThisLetter = false;
  int _vigErrors = 0;
  Timer? _vigTimer;

  // ── Serial 7 ──
  final _s7Ctrls = List.generate(5, (_) => TextEditingController());
  static const _s7Correct = [93, 86, 79, 72, 65];

  @override
  void initState() {
    super.initState();
    _startAdelanteSequence();
  }

  void _startAdelanteSequence() {
    _adelanteTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _adelantePhase = _DigitPhase.hiding);
      _adelanteTimer = Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() => _adelantePhase = _DigitPhase.input);
      });
    });
  }

  void _startAtrasSequence() {
    setState(() => _atrasPhase = _DigitPhase.showing);
    _atrasTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _atrasPhase = _DigitPhase.hiding);
      _atrasTimer = Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() => _atrasPhase = _DigitPhase.input);
      });
    });
  }

  void _checkAdelante() {
    final input = _adelanteCtrl.text.replaceAll(RegExp(r'\s+'), '');
    setState(() => _adelanteScore = input == '21854' ? 1 : 0);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _nextSub();
    });
  }

  void _checkAtras() {
    final input = _atrasCtrl.text.replaceAll(RegExp(r'\s+'), '');
    setState(() => _atrasScore = input == '247' ? 1 : 0);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _nextSub();
    });
  }

  // ── Vigilancia ──
  void _startVig() {
    setState(() => _vigRunning = true);
    _scheduleNext();
  }

  void _scheduleNext() {
    _vigTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final letter = _vigLetras[_vigIdx];
      if (letter == 'A' && !_tappedThisLetter) _vigErrors++;
      if (letter != 'A' && _tappedThisLetter) _vigErrors++;
      setState(() {
        _vigIdx++;
        _tappedThisLetter = false;
        if (_vigIdx >= _vigLetras.length) {
          _vigDone = true;
          _vigRunning = false;
        }
      });
      if (!_vigDone) _scheduleNext();
    });
  }

  void _vigTap() {
    if (_vigDone || !_vigRunning) return;
    setState(() => _tappedThisLetter = true);
  }

  int get _vigScore => _vigErrors <= 1 ? 1 : 0;

  int get _s7Score {
    int ok = 0;
    for (int i = 0; i < 5; i++) {
      if (int.tryParse(_s7Ctrls[i].text.trim()) == _s7Correct[i]) ok++;
    }
    if (ok >= 5) return 3;
    if (ok >= 4) return 2;
    if (ok >= 2) return 1;
    return 0;
  }

  void _nextSub() {
    if (_subTask < 3) {
      setState(() => _subTask++);
      if (_subTask == 1) _startAtrasSequence();
    } else {
      _finish();
    }
  }

  void _finish() {
    _vigTimer?.cancel();
    final adelante = _adelanteScore == 1 ? 1 : 0;
    final atras = _atrasScore == 1 ? 1 : 0;
    Navigator.of(context).pop(AreaResult(
      idArea: 4,
      puntajeObtenido: adelante + atras + _vigScore + _s7Score,
      puntajeMaximo: 6,
      detalles: {
        'digitos_adelante': adelante,
        'digitos_atras': atras,
        'vigilancia': _vigScore,
        'vigilancia_errores': _vigErrors,
        'serial_7': _s7Score,
      },
    ));
  }

  @override
  void dispose() {
    _adelanteCtrl.dispose();
    _atrasCtrl.dispose();
    _adelanteTimer?.cancel();
    _atrasTimer?.cancel();
    _vigTimer?.cancel();
    for (final c in _s7Ctrls) c.dispose();
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
            Text('Atención', style: AppText.title.copyWith(fontSize: 20)),
            const SizedBox(height: 4),
            Text(_subLabel,
                style: AppText.subtitle.copyWith(color: AppColors.hint)),
            const SizedBox(height: 24),
            if (_subTask == 0) _buildAdelante(),
            if (_subTask == 1) _buildAtras(),
            if (_subTask == 2) _buildVigilancia(),
            if (_subTask == 3) _buildSerial7(),
          ],
        ),
      ),
    );
  }

  String get _subLabel => switch (_subTask) {
    0 => 'Sub-tarea 1/4: Dígitos hacia adelante (1 pt)',
    1 => 'Sub-tarea 2/4: Dígitos hacia atrás (1 pt)',
    2 => 'Sub-tarea 3/4: Vigilancia (1 pt)',
    _ => 'Sub-tarea 4/4: Resta en serie (3 pts)',
  };

  Widget _buildAdelante() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Memoriza los siguientes dígitos y escríbelos en el mismo orden.',
            style: AppText.subtitle
                .copyWith(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 16),
        if (_adelantePhase == _DigitPhase.showing) ...[
          _numBox('2   1   8   5   4'),
          const SizedBox(height: 16),
          _countdownHint('Memoriza...'),
        ] else if (_adelantePhase == _DigitPhase.hiding) ...[
          _hiddenBox(),
          const SizedBox(height: 16),
          _countdownHint('Preparando...'),
        ] else ...[
          AppField(
            hint: 'Escribe los dígitos (ej: 21854)',
            keyboardType: TextInputType.number,
            controller: _adelanteCtrl,
            onSubmitted: (_) { if (_adelanteScore == -1) _checkAdelante(); },
          ),
          const SizedBox(height: 12),
          if (_adelanteScore == -1)
            PrimaryButton(label: 'VERIFICAR', onPressed: _checkAdelante)
          else
            _badge(_adelanteScore == 1),
        ],
      ],
    );
  }

  Widget _buildAtras() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'Memoriza los dígitos y escríbelos en orden INVERSO.',
            style: AppText.subtitle
                .copyWith(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 16),
        if (_atrasPhase == _DigitPhase.showing) ...[
          _numBox('7   4   2'),
          const SizedBox(height: 16),
          _countdownHint('Memoriza...'),
        ] else if (_atrasPhase == _DigitPhase.hiding) ...[
          _hiddenBox(),
          const SizedBox(height: 16),
          _countdownHint('Preparando...'),
        ] else ...[
          AppField(
            hint: 'Escribe en orden inverso',
            keyboardType: TextInputType.number,
            controller: _atrasCtrl,
            onSubmitted: (_) { if (_atrasScore == -1) _checkAtras(); },
          ),
          const SizedBox(height: 12),
          if (_atrasScore == -1)
            PrimaryButton(label: 'VERIFICAR', onPressed: _checkAtras)
          else
            _badge(_atrasScore == 1),
        ],
      ],
    );
  }

  Widget _buildVigilancia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'Se mostrarán letras una por una. Toca el botón SOLO '
            'cuando veas la letra A.',
            style: AppText.subtitle
                .copyWith(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 16),
        if (!_vigRunning && !_vigDone) ...[
          PrimaryButton(label: 'COMENZAR', onPressed: _startVig),
        ] else if (!_vigDone) ...[
          Center(
            child: Text('${_vigIdx + 1} / ${_vigLetras.length}',
                style: AppText.subtitle.copyWith(color: AppColors.hint)),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.purpleDark.withAlpha(80),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(_vigLetras[_vigIdx],
                  style: AppText.title.copyWith(fontSize: 42)),
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _vigTap,
            child: Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                gradient: _tappedThisLetter ? null : AppColors.gradient,
                color: _tappedThisLetter
                    ? Colors.green.withAlpha(40)
                    : null,
                borderRadius: BorderRadius.circular(16),
                border: _tappedThisLetter
                    ? Border.all(color: Colors.green, width: 2)
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                _tappedThisLetter ? 'GOLPE REGISTRADO' : 'GOLPE',
                style: AppText.button.copyWith(fontSize: 18),
              ),
            ),
          ),
        ] else ...[
          _badge(_vigScore == 1),
          Text('Errores: $_vigErrors (máximo 1 para punto)',
              style: AppText.subtitle
                  .copyWith(color: AppColors.hint, fontSize: 12)),
          const SizedBox(height: 16),
          PrimaryButton(label: 'CONTINUAR', onPressed: _nextSub),
        ],
      ],
    );
  }

  Widget _buildSerial7() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resta 7 sucesivamente desde 100.',
            style: AppText.subtitle
                .copyWith(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 16),
        for (int i = 0; i < 5; i++) ...[
          Row(children: [
            SizedBox(
              width: 80,
              child: Text('${100 - 7 * i} − 7 =',
                  style: AppText.label.copyWith(fontSize: 14)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppField(
                hint: '',
                keyboardType: TextInputType.number,
                controller: _s7Ctrls[i],
                textInputAction:
                    i < 4 ? TextInputAction.next : TextInputAction.done,
              ),
            ),
          ]),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 16),
        PrimaryButton(label: 'FINALIZAR SECCIÓN', onPressed: _finish),
      ],
    );
  }

  // ── Helpers ──

  Widget _numBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.purpleDark.withAlpha(60),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.purple.withAlpha(80)),
      ),
      child: Text(text,
          textAlign: TextAlign.center,
          style: AppText.title.copyWith(fontSize: 28, letterSpacing: 6)),
    );
  }

  Widget _hiddenBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Text('? ? ? ? ?',
          textAlign: TextAlign.center,
          style: AppText.title.copyWith(
              fontSize: 28, letterSpacing: 6, color: Colors.white24)),
    );
  }

  Widget _countdownHint(String text) {
    return Center(
      child: Text(text,
          style: AppText.subtitle.copyWith(
              color: AppColors.purple, fontSize: 14)),
    );
  }

  Widget _badge(bool ok) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: ok ? Colors.green.withAlpha(30) : Colors.redAccent.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        ok ? 'Correcto' : 'Incorrecto',
        textAlign: TextAlign.center,
        style: AppText.label
            .copyWith(color: ok ? Colors.green : Colors.redAccent, fontSize: 14),
      ),
    );
  }
}
