import 'package:flutter/material.dart';

import '../../../data/moca_result.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_widgets.dart';

class AbstraccionGame extends StatefulWidget {
  const AbstraccionGame({super.key});

  @override
  State<AbstraccionGame> createState() => _AbstraccionGameState();
}

class _AbstraccionGameState extends State<AbstraccionGame> {
  static const _pares = [
    ['Naranja', 'Plátano'],
    ['Tren', 'Bicicleta'],
  ];

  static const _keywords = <List<String>>[
    ['fruta', 'frutas', 'alimento', 'alimentos', 'comida'],
    ['transporte', 'vehiculo', 'vehículo', 'vehiculos', 'vehículos',
     'medio', 'medios'],
  ];

  final _ctrls = List.generate(2, (_) => TextEditingController());
  final _checked = [false, false];
  final _correct = [false, false];

  void _check(int i) {
    final input = _ctrls[i].text.trim().toLowerCase();
    setState(() {
      _checked[i] = true;
      _correct[i] = _keywords[i].any((k) => input.contains(k));
    });
    if (_checked.every((c) => c)) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _finish();
      });
    }
  }

  void _finish() {
    for (int i = 0; i < 2; i++) {
      if (!_checked[i]) {
        final input = _ctrls[i].text.trim().toLowerCase();
        _checked[i] = true;
        _correct[i] = _keywords[i].any((k) => input.contains(k));
      }
    }
    Navigator.of(context).pop(AreaResult(
      idArea: 6,
      puntajeObtenido: _correct.where((c) => c).length,
      puntajeMaximo: 2,
      detalles: {
        'par_1': _correct[0],
        'par_2': _correct[1],
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
            Text('Abstracción', style: AppText.title.copyWith(fontSize: 20)),
            const SizedBox(height: 4),
            Text('Escribe en qué se parecen los dos elementos.',
                style: AppText.subtitle
                    .copyWith(color: AppColors.hint, fontSize: 13)),
            const SizedBox(height: 24),
            for (int i = 0; i < 2; i++) ...[
              _parCard(i),
              if (i < 1) const SizedBox(height: 16),
            ],
            const SizedBox(height: 32),
            PrimaryButton(label: 'FINALIZAR SECCIÓN', onPressed: _finish),
          ],
        ),
      ),
    );
  }

  Widget _parCard(int i) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text('Par ${i + 1}',
              style: AppText.label
                  .copyWith(color: AppColors.purple, fontSize: 11)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _WordChip(_pares[i][0]),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child:
                    Text('—', style: AppText.subtitle.copyWith(fontSize: 20)),
              ),
              _WordChip(_pares[i][1]),
            ],
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: AppField(
                hint: '¿En qué se parecen?',
                controller: _ctrls[i],
                textInputAction:
                    i < 1 ? TextInputAction.next : TextInputAction.done,
                onSubmitted: (_) => _check(i),
                isValid: _checked[i] && _correct[i],
                errorText:
                    _checked[i] && !_correct[i] ? 'Respuesta incorrecta' : null,
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
                  child:
                      const Icon(Icons.check, color: Colors.white, size: 22),
                ),
              ),
          ]),
        ],
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  const _WordChip(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.purpleDark.withAlpha(80),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: AppText.label.copyWith(fontSize: 15)),
    );
  }
}
