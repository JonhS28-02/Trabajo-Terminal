import 'package:flutter/material.dart';

import '../../../data/moca_result.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_widgets.dart';

class OrientacionGame extends StatefulWidget {
  const OrientacionGame({super.key});

  @override
  State<OrientacionGame> createState() => _OrientacionGameState();
}

class _OrientacionGameState extends State<OrientacionGame> {
  final _diaCtrl = TextEditingController();
  final _mesCtrl = TextEditingController();
  final _anioCtrl = TextEditingController();
  final _diaSemCtrl = TextEditingController();
  final _ciudadCtrl = TextEditingController();
  final _instCtrl = TextEditingController();

  static const _meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  void _finish() {
    final now = DateTime.now();
    int score = 0;
    final det = <String, dynamic>{};

    final diaOk = int.tryParse(_diaCtrl.text.trim()) == now.day;
    if (diaOk) score++;
    det['dia'] = diaOk;

    final mesT = _mesCtrl.text.trim().toLowerCase();
    final mesOk =
        mesT == _meses[now.month - 1] || int.tryParse(mesT) == now.month;
    if (mesOk) score++;
    det['mes'] = mesOk;

    final anioOk = int.tryParse(_anioCtrl.text.trim()) == now.year;
    if (anioOk) score++;
    det['anio'] = anioOk;

    final dsT = _diaSemCtrl.text.trim().toLowerCase();
    final weekday = now.weekday; // 1=lun .. 7=dom
    final expectedDays = <String>[];
    switch (weekday) {
      case 1: expectedDays.addAll(['lunes']); break;
      case 2: expectedDays.addAll(['martes']); break;
      case 3: expectedDays.addAll(['miércoles', 'miercoles']); break;
      case 4: expectedDays.addAll(['jueves']); break;
      case 5: expectedDays.addAll(['viernes']); break;
      case 6: expectedDays.addAll(['sábado', 'sabado']); break;
      case 7: expectedDays.addAll(['domingo']); break;
    }
    final diaSemOk = expectedDays.contains(dsT);
    if (diaSemOk) score++;
    det['dia_semana'] = diaSemOk;

    final ciudadOk = _ciudadCtrl.text.trim().isNotEmpty;
    if (ciudadOk) score++;
    det['ciudad'] = _ciudadCtrl.text.trim();

    final instOk = _instCtrl.text.trim().isNotEmpty;
    if (instOk) score++;
    det['institucion'] = _instCtrl.text.trim();

    Navigator.of(context).pop(AreaResult(
      idArea: 8,
      puntajeObtenido: score,
      puntajeMaximo: 6,
      detalles: det,
    ));
  }

  @override
  void dispose() {
    _diaCtrl.dispose();
    _mesCtrl.dispose();
    _anioCtrl.dispose();
    _diaSemCtrl.dispose();
    _ciudadCtrl.dispose();
    _instCtrl.dispose();
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
            Text('Orientación', style: AppText.title.copyWith(fontSize: 20)),
            const SizedBox(height: 4),
            Text('Responde las siguientes preguntas de orientación.',
                style: AppText.subtitle
                    .copyWith(color: AppColors.hint, fontSize: 13)),
            const SizedBox(height: 24),
            _field('¿Qué día del mes es hoy?', _diaCtrl,
                TextInputType.number),
            _field('¿En qué mes estamos?', _mesCtrl, TextInputType.text),
            _field('¿En qué año estamos?', _anioCtrl, TextInputType.number),
            _field('¿Qué día de la semana es?', _diaSemCtrl,
                TextInputType.text),
            _field(
                '¿En qué ciudad estamos?', _ciudadCtrl, TextInputType.text),
            _field('¿En qué institución estamos?', _instCtrl,
                TextInputType.text),
            const SizedBox(height: 24),
            PrimaryButton(label: 'FINALIZAR SECCIÓN', onPressed: _finish),
          ],
        ),
      ),
    );
  }

  Widget _field(
      String label, TextEditingController ctrl, TextInputType type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: LabeledField(
        label: label,
        field:
            AppField(hint: '', keyboardType: type, controller: ctrl),
      ),
    );
  }
}
