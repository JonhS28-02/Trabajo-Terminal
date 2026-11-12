import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/moca_result.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_widgets.dart';

class MemoriaRegistroGame extends StatefulWidget {
  const MemoriaRegistroGame({super.key});

  @override
  State<MemoriaRegistroGame> createState() => _MemoriaRegistroGameState();
}

class _MemoriaRegistroGameState extends State<MemoriaRegistroGame> {
  static const _palabras = ['rostro', 'seda', 'iglesia', 'clavel', 'rojo'];

  int _ensayo = 1;
  bool _showingWords = true;
  Timer? _hideTimer;

  final _ctrls1 = List.generate(5, (_) => TextEditingController());
  final _ctrls2 = List.generate(5, (_) => TextEditingController());
  final _checked1 = List.filled(5, false);
  final _checked2 = List.filled(5, false);

  List<TextEditingController> get _ctrls => _ensayo == 1 ? _ctrls1 : _ctrls2;
  List<bool> get _checked => _ensayo == 1 ? _checked1 : _checked2;

  @override
  void initState() {
    super.initState();
    _startWordDisplay();
  }

  void _startWordDisplay() {
    setState(() => _showingWords = true);
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showingWords = false);
    });
  }

  void _nextEnsayo() {
    _checkCurrent();
    if (_ensayo == 1) {
      setState(() {
        _ensayo = 2;
        _showingWords = true;
      });
      _hideTimer?.cancel();
      _hideTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) setState(() => _showingWords = false);
      });
    } else {
      _finish();
    }
  }

  void _checkCurrent() {
    for (int i = 0; i < 5; i++) {
      final input = _ctrls[i].text.trim().toLowerCase();
      _checked[i] = _palabras.contains(input);
    }
  }

  void _finish() {
    _checkCurrent();
    final e1 = <String, bool>{};
    final e2 = <String, bool>{};
    for (int i = 0; i < 5; i++) {
      final w1 = _ctrls1[i].text.trim().toLowerCase();
      e1[w1.isEmpty ? '(vacío ${i + 1})' : w1] = _palabras.contains(w1);
    }
    for (int i = 0; i < 5; i++) {
      final w2 = _ctrls2[i].text.trim().toLowerCase();
      e2[w2.isEmpty ? '(vacío ${i + 1})' : w2] = _palabras.contains(w2);
    }
    Navigator.of(context).pop(AreaResult(
      idArea: 3,
      puntajeObtenido: 0,
      puntajeMaximo: 0,
      detalles: {'ensayo_1': e1, 'ensayo_2': e2},
    ));
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    for (final c in _ctrls1) c.dispose();
    for (final c in _ctrls2) c.dispose();
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
            Text('Memoria (Registro)',
                style: AppText.title.copyWith(fontSize: 20)),
            const SizedBox(height: 4),
            Text('Ensayo $_ensayo de 2 — Sin puntuación',
                style: AppText.subtitle.copyWith(color: AppColors.hint)),
            const SizedBox(height: 24),
            if (_showingWords) ...[
              Text('Memoriza las siguientes palabras:',
                  style: AppText.subtitle.copyWith(
                      color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.purpleDark.withAlpha(60),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.purple.withAlpha(80)),
                ),
                child: Column(
                  children: [
                    Text('PALABRAS',
                        style: AppText.label.copyWith(
                            color: AppColors.purple,
                            fontSize: 12,
                            letterSpacing: 2)),
                    const SizedBox(height: 16),
                    Text(_palabras.join('   •   '),
                        textAlign: TextAlign.center,
                        style: AppText.title.copyWith(fontSize: 20)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text('Las palabras se ocultarán automáticamente...',
                    style: AppText.subtitle
                        .copyWith(color: AppColors.hint, fontSize: 11)),
              ),
            ] else ...[
              Text('Escribe las palabras que recuerdes:',
                  style: AppText.subtitle
                      .copyWith(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 16),
              for (int i = 0; i < 5; i++) ...[
                AppField(
                  hint: 'Palabra ${i + 1}',
                  controller: _ctrls[i],
                  textInputAction:
                      i < 4 ? TextInputAction.next : TextInputAction.done,
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 16),
              PrimaryButton(
                label: _ensayo == 1
                    ? 'SEGUNDO ENSAYO'
                    : 'FINALIZAR SECCIÓN',
                onPressed: _nextEnsayo,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
