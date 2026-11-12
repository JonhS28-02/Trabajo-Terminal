import 'package:flutter/material.dart';

import '../../data/moca_result.dart';
import '../../data/moca_sections.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../evaluation/example_screen.dart';
import '../evaluation/games/abstraccion_game.dart';
import '../evaluation/games/atencion_game.dart';
import '../evaluation/games/identificacion_game.dart';
import '../evaluation/games/lenguaje_game.dart';
import '../evaluation/games/memoria_registro_game.dart';
import '../evaluation/games/orientacion_game.dart';
import '../evaluation/games/recuerdo_game.dart';
import '../evaluation/games/visuoespacial_game.dart';
import '../evaluation/moca_summary_screen.dart';

enum _Phase { instruction, example, game }

class MocaInstructionsScreen extends StatefulWidget {
  const MocaInstructionsScreen({
    super.key,
    required this.sections,
    required this.patientName,
    required this.idMoca,
    required this.token,
    this.role = 'especialista',
  });

  final List<MocaSection> sections;
  final String patientName;
  final int idMoca;
  final String token;
  final String role;

  @override
  State<MocaInstructionsScreen> createState() => _MocaInstructionsScreenState();
}

class _MocaInstructionsScreenState extends State<MocaInstructionsScreen> {
  int _current = 0;
  _Phase _phase = _Phase.instruction;
  final List<AreaResult> _results = [];

  MocaSection get _section => widget.sections[_current];
  bool get _isLast => _current == widget.sections.length - 1;

  void _next() {
    switch (_phase) {
      case _Phase.instruction:
        setState(() => _phase = _Phase.example);
        break;
      case _Phase.example:
        Navigator.of(context).push(
          slideUpRoute(ExampleScreen(
            idArea: _section.idArea,
            nombre: _section.nombre,
          )),
        ).then((_) {
          if (mounted) setState(() => _phase = _Phase.game);
        });
        break;
      case _Phase.game:
        _launchGame();
        break;
    }
  }

  void _launchGame() {
    Navigator.of(context)
        .push<AreaResult>(slideUpRoute(_gameWidget()))
        .then((result) {
      if (!mounted) return;
      if (result != null) {
        _results.add(result);
      }
      if (_isLast) {
        Navigator.of(context).pushReplacement(
          slideUpRoute(MocaSummaryScreen(
            results: _results,
            idMoca: widget.idMoca,
            token: widget.token,
            role: widget.role,
          )),
        );
      } else {
        setState(() {
          _current++;
          _phase = _Phase.instruction;
        });
      }
    });
  }

  Widget _gameWidget() {
    switch (_section.idArea) {
      case 1: return const VisuoespacialGame();
      case 2: return const IdentificacionGame();
      case 3: return const MemoriaRegistroGame();
      case 4: return const AtencionGame();
      case 5: return const LenguajeGame();
      case 6: return const AbstraccionGame();
      case 7: return const RecuerdoGame();
      case 8: return const OrientacionGame();
      default: return const SizedBox();
    }
  }

  String get _buttonLabel {
    switch (_phase) {
      case _Phase.instruction:
        return 'VER EJEMPLO';
      case _Phase.example:
        return 'IR AL EJEMPLO';
      case _Phase.game:
        return 'INICIAR PRUEBA';
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_current + 1) / widget.sections.length;
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
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Sección ${_current + 1} de ${widget.sections.length}',
                    style: AppText.subtitle.copyWith(color: AppColors.hint),
                  ),
                ),
                Text(
                  '${_section.puntajeMaximo} pts',
                  style: AppText.label.copyWith(
                    color: AppColors.purple,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.field,
                valueColor: const AlwaysStoppedAnimation(AppColors.purple),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.gradient,
                  ),
                  child: Icon(_section.icono, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    _section.nombre,
                    style: AppText.title.copyWith(fontSize: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Phase indicator
            Row(
              children: [
                _PhaseDot(label: 'Instrucciones', active: _phase == _Phase.instruction),
                const SizedBox(width: 8),
                _PhaseDot(label: 'Ejemplo', active: _phase == _Phase.example),
                const SizedBox(width: 8),
                _PhaseDot(label: 'Prueba', active: _phase == _Phase.game),
              ],
            ),
            const SizedBox(height: 20),

            if (_phase == _Phase.instruction) ...[
              _InstructionCard(
                title: '¿Qué evalúa?',
                body: _section.queEvalua,
                icon: Icons.help_outline,
              ),
              const SizedBox(height: 16),
              _InstructionCard(
                title: '¿Cómo se realiza?',
                body: _section.comoSeRealiza,
                icon: Icons.list_alt,
              ),
              if (_section.ejemplo != null) ...[
                const SizedBox(height: 16),
                _InstructionCard(
                  title: 'Ejemplo',
                  body: _section.ejemplo!,
                  icon: Icons.lightbulb_outline,
                  highlight: true,
                ),
              ],
            ] else if (_phase == _Phase.example) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withAlpha(60)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.school, color: Colors.orange, size: 36),
                    const SizedBox(height: 12),
                    Text(
                      'Ejemplo interactivo',
                      style: AppText.label.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Se mostrará una demostración de cómo funciona esta '
                      'sección. El resultado NO cuenta.',
                      textAlign: TextAlign.center,
                      style: AppText.subtitle.copyWith(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.purpleDark.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.purple.withAlpha(60)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.play_circle_fill, color: AppColors.purple, size: 36),
                    const SizedBox(height: 12),
                    Text(
                      'Prueba real',
                      style: AppText.label.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'El resultado de esta prueba SÍ se registra.',
                      textAlign: TextAlign.center,
                      style: AppText.subtitle.copyWith(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 36),
            PrimaryButton(
              label: _buttonLabel,
              onPressed: _next,
            ),
          ],
        ),
      ),
    );
  }
}

class _PhaseDot extends StatelessWidget {
  const _PhaseDot({required this.label, required this.active});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active ? AppColors.purple.withAlpha(40) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? AppColors.purple : Colors.white24,
        ),
      ),
      child: Text(
        label,
        style: AppText.subtitle.copyWith(
          fontSize: 11,
          color: active ? Colors.white : Colors.white38,
        ),
      ),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard({
    required this.title,
    required this.body,
    required this.icon,
    this.highlight = false,
  });

  final String title;
  final String body;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.purpleDark.withAlpha(60)
            : AppColors.field,
        borderRadius: BorderRadius.circular(12),
        border: highlight
            ? Border.all(color: AppColors.purple.withAlpha(80))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.purple, size: 18),
              const SizedBox(width: 8),
              Text(title, style: AppText.label.copyWith(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: AppText.subtitle.copyWith(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
