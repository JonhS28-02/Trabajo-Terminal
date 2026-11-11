import 'package:flutter/material.dart';

import '../../data/moca_sections.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class MocaInstructionsScreen extends StatefulWidget {
  const MocaInstructionsScreen({
    super.key,
    required this.sections,
    required this.patientName,
  });

  final List<MocaSection> sections;
  final String patientName;

  @override
  State<MocaInstructionsScreen> createState() => _MocaInstructionsScreenState();
}

class _MocaInstructionsScreenState extends State<MocaInstructionsScreen> {
  int _current = 0;

  MocaSection get _section => widget.sections[_current];
  bool get _isLast => _current == widget.sections.length - 1;

  void _next() {
    if (_isLast) {
      showDemoMessage(context, 'Las secciones de evaluación están en desarrollo');
      Navigator.of(context).pop();
      return;
    }
    setState(() => _current++);
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
            const SizedBox(height: 28),

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

            const SizedBox(height: 36),
            PrimaryButton(
              label: _isLast ? 'FINALIZAR' : 'SIGUIENTE',
              onPressed: _next,
            ),
          ],
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
