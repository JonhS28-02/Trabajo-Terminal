import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../data/moca_result.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_widgets.dart';

class LenguajeGame extends StatefulWidget {
  const LenguajeGame({super.key});

  @override
  State<LenguajeGame> createState() => _LenguajeGameState();
}

class _LenguajeGameState extends State<LenguajeGame> {
  int _subTask = 0;

  // ── Repetición de oraciones ──
  static const _oraciones = [
    'El gato se escondió bajo el sofá cuando los perros entraron en la sala.',
    'Espero que él le entregue el mensaje una vez que ella se lo pida.',
  ];
  final _oraCtrls = List.generate(2, (_) => TextEditingController());
  final _oraChecked = [false, false];
  final _oraCorrect = [false, false];
  bool _oraShowSentence0 = true;
  bool _oraShowSentence1 = true;
  Timer? _hideTimer0;
  Timer? _hideTimer1;

  // ── Voice input ──
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  int _listeningFor = -1;

  // ── Fluidez verbal ──
  int _timerSec = 60;
  Timer? _fluidezTimer;
  bool _timerRunning = false;
  final _fluidezCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _hideTimer0 = Timer(const Duration(seconds: 6), () {
      if (mounted) setState(() => _oraShowSentence0 = false);
    });
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (_) {
        if (mounted) setState(() => _listeningFor = -1);
      },
    );
    if (mounted) setState(() {});
  }

  static const _accentMap = {
    'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u', 'ñ': 'n',
  };

  String _stripAccents(String s) {
    final buf = StringBuffer();
    for (final c in s.runes) {
      final ch = String.fromCharCode(c);
      buf.write(_accentMap[ch] ?? ch);
    }
    return buf.toString();
  }

  String _normalize(String s) =>
      _stripAccents(s.trim().toLowerCase().replaceAll(RegExp(r'[^\w\s]'), ''))
          .replaceAll(RegExp(r'\s+'), ' ');

  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    final prev = List<int>.generate(b.length + 1, (i) => i);
    final curr = List<int>.filled(b.length + 1, 0);
    for (int i = 1; i <= a.length; i++) {
      curr[0] = i;
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        curr[j] = [curr[j - 1] + 1, prev[j] + 1, prev[j - 1] + cost]
            .reduce((a, b) => a < b ? a : b);
      }
      prev.setAll(0, curr);
    }
    return curr[b.length];
  }

  bool _isCloseEnough(String input, String target) {
    final a = _normalize(input);
    final b = _normalize(target);
    if (a == b) return true;
    final wordsA = a.split(' ');
    final wordsB = b.split(' ');
    if (wordsA.length != wordsB.length) {
      if ((wordsA.length - wordsB.length).abs() > 2) return false;
    }
    final dist = _levenshtein(a, b);
    final maxLen = b.length;
    return dist <= (maxLen * 0.15).ceil();
  }

  void _checkOracion(int i) {
    setState(() {
      _oraChecked[i] = true;
      _oraCorrect[i] = _isCloseEnough(_oraCtrls[i].text, _oraciones[i]);
    });
    if (i == 0) {
      _hideTimer1 = Timer(const Duration(seconds: 6), () {
        if (mounted) setState(() => _oraShowSentence1 = false);
      });
    }
    if (_oraChecked[0] && _oraChecked[1]) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _subTask = 1);
      });
    }
  }

  void _toggleListening(int i) async {
    if (_listeningFor == i) {
      await _speech.stop();
      setState(() => _listeningFor = -1);
      return;
    }
    if (!_speechAvailable) return;
    setState(() => _listeningFor = i);
    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _oraCtrls[i].text = result.recognizedWords;
          if (result.finalResult) _listeningFor = -1;
        });
      },
      listenOptions: stt.SpeechListenOptions(
        localeId: 'es_MX',
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 4),
      ),
    );
  }

  void _startFluidez() {
    setState(() => _timerRunning = true);
    _fluidezTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _timerSec--;
        if (_timerSec <= 0) {
          _fluidezTimer?.cancel();
          _timerRunning = false;
        }
      });
    });
  }

  int get _wordCount {
    final text = _fluidezCtrl.text.trim().toLowerCase();
    if (text.isEmpty) return 0;
    final words = text.split(RegExp(r'[\s,;.]+'))
        .where((w) => w.isNotEmpty && w.startsWith('f'))
        .toSet();
    return words.length;
  }

  void _finish() {
    _fluidezTimer?.cancel();
    _hideTimer0?.cancel();
    _hideTimer1?.cancel();
    _speech.stop();
    final rep = (_oraCorrect[0] ? 1 : 0) + (_oraCorrect[1] ? 1 : 0);
    final flu = _wordCount >= 11 ? 1 : 0;
    Navigator.of(context).pop(AreaResult(
      idArea: 5,
      puntajeObtenido: rep + flu,
      puntajeMaximo: 3,
      detalles: {
        'oracion_1': _oraCorrect[0],
        'oracion_2': _oraCorrect[1],
        'fluidez_palabras': _wordCount,
        'fluidez_punto': flu,
      },
    ));
  }

  @override
  void dispose() {
    _fluidezTimer?.cancel();
    _hideTimer0?.cancel();
    _hideTimer1?.cancel();
    _speech.stop();
    _oraCtrls[0].dispose();
    _oraCtrls[1].dispose();
    _fluidezCtrl.dispose();
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
            Text('Lenguaje', style: AppText.title.copyWith(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              _subTask == 0
                  ? 'Sub-tarea 1/2: Repetición de oraciones (2 pts)'
                  : 'Sub-tarea 2/2: Fluidez verbal (1 pt)',
              style: AppText.subtitle.copyWith(color: AppColors.hint),
            ),
            const SizedBox(height: 24),
            if (_subTask == 0) _buildOraciones(),
            if (_subTask == 1) _buildFluidez(),
          ],
        ),
      ),
    );
  }

  Widget _buildOraciones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'Lee la oración, memorízala y escríbela o dila por voz cuando desaparezca.',
            style: AppText.subtitle
                .copyWith(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 20),
        _oracionWidget(0, _oraShowSentence0),
        const SizedBox(height: 16),
        if (_oraChecked[0]) _oracionWidget(1, _oraShowSentence1),
      ],
    );
  }

  Widget _oracionWidget(int i, bool showing) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Oración ${i + 1}',
              style: AppText.label.copyWith(color: AppColors.purple, fontSize: 11)),
          const SizedBox(height: 8),
          if (showing)
            Text(_oraciones[i],
                style: AppText.subtitle.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ))
          else if (!_oraChecked[i]) ...[
            Text('Escribe o dicta la oración de memoria:',
                style: AppText.subtitle
                    .copyWith(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: AppField(
                    hint: 'Escribe la oración...',
                    controller: _oraCtrls[i],
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _checkOracion(i),
                  ),
                ),
                if (_speechAvailable) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _toggleListening(i),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: _listeningFor == i ? null : AppColors.gradient,
                        color: _listeningFor == i ? Colors.redAccent : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _listeningFor == i ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (_listeningFor == i)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('Escuchando...',
                    style: AppText.subtitle.copyWith(
                        color: Colors.orange, fontSize: 12)),
              ),
            const SizedBox(height: 8),
            PrimaryButton(
              label: 'VERIFICAR',
              height: 40,
              onPressed: () => _checkOracion(i),
            ),
          ] else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: _oraCorrect[i]
                    ? Colors.green.withAlpha(30)
                    : Colors.redAccent.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _oraCorrect[i] ? 'Correcto' : 'Incorrecto',
                textAlign: TextAlign.center,
                style: AppText.label.copyWith(
                  color: _oraCorrect[i] ? Colors.green : Colors.redAccent,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFluidez() {
    final min = _timerSec ~/ 60;
    final sec = _timerSec % 60;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'Escribe todas las palabras que puedas que empiecen con la letra F.\n'
            'Sepáralas con comas o espacios. Se requieren ≥11 para obtener el punto.',
            style: AppText.subtitle
                .copyWith(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 24),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.field,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: [
              Text(
                '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}',
                style: AppText.title.copyWith(fontSize: 48),
              ),
              const SizedBox(height: 8),
              if (!_timerRunning && _timerSec == 60)
                PrimaryButton(
                    label: 'INICIAR CRONÓMETRO', onPressed: _startFluidez)
              else if (_timerSec <= 0)
                Text('Tiempo terminado',
                    style: AppText.label.copyWith(color: Colors.orange)),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        AppField(
          hint: 'fresa, fútbol, familia...',
          controller: _fluidezCtrl,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text('Palabras con F: $_wordCount',
              style: AppText.label.copyWith(color: AppColors.purple, fontSize: 16)),
        ),
        const SizedBox(height: 24),
        PrimaryButton(label: 'FINALIZAR SECCIÓN', onPressed: _finish),
      ],
    );
  }
}
