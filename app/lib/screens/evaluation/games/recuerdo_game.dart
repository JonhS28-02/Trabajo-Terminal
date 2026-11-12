import 'package:flutter/material.dart';

import '../../../data/moca_result.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_widgets.dart';

class RecuerdoGame extends StatefulWidget {
  const RecuerdoGame({super.key});

  @override
  State<RecuerdoGame> createState() => _RecuerdoGameState();
}

class _RecuerdoGameState extends State<RecuerdoGame> {
  static const _palabras = ['rostro', 'seda', 'iglesia', 'clavel', 'rojo'];
  final _ctrls = List.generate(5, (_) => TextEditingController());
  bool _checked = false;
  final _correct = List.filled(5, false);

  void _finish() {
    final matched = <String>{};
    for (int i = 0; i < 5; i++) {
      final input = _ctrls[i].text.trim().toLowerCase();
      _correct[i] = _palabras.contains(input) && !matched.contains(input);
      if (_correct[i]) matched.add(input);
    }
    setState(() => _checked = true);

    final total = _correct.where((c) => c).length;
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      Navigator.of(context).pop(AreaResult(
        idArea: 7,
        puntajeObtenido: total,
        puntajeMaximo: 5,
        detalles: {
          for (int i = 0; i < 5; i++)
            _ctrls[i].text.trim().toLowerCase().isEmpty
                ? '(vacío ${i + 1})'
                : _ctrls[i].text.trim().toLowerCase(): _correct[i],
        },
      ));
    });
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
            Text('Recuerdo diferido',
                style: AppText.title.copyWith(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
                'Escribe las 5 palabras que memorizaste en la sección '
                'de Memoria, sin pistas.',
                style: AppText.subtitle
                    .copyWith(color: AppColors.hint, fontSize: 13)),
            const SizedBox(height: 24),
            for (int i = 0; i < 5; i++) ...[
              AppField(
                hint: 'Palabra ${i + 1}',
                controller: _ctrls[i],
                textInputAction:
                    i < 4 ? TextInputAction.next : TextInputAction.done,
                isValid: _checked && _correct[i],
                errorText: _checked && !_correct[i]
                    ? 'No coincide'
                    : null,
              ),
              const SizedBox(height: 10),
            ],
            if (_checked)
              Center(
                child: Text(
                    'Total: ${_correct.where((c) => c).length} / 5',
                    style: AppText.label
                        .copyWith(color: AppColors.purple, fontSize: 16)),
              ),
            const SizedBox(height: 24),
            PrimaryButton(
                label: 'FINALIZAR SECCIÓN', onPressed: _finish),
          ],
        ),
      ),
    );
  }
}
