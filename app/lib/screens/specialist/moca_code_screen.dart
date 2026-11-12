import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/moca_sections.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import 'moca_instructions_screen.dart';

class MocaCodeScreen extends StatefulWidget {
  const MocaCodeScreen({super.key, required this.patient});

  final Map<String, dynamic> patient;

  @override
  State<MocaCodeScreen> createState() => _MocaCodeScreenState();
}

class _MocaCodeScreenState extends State<MocaCodeScreen> {
  bool _loading = false;
  String? _codigo;
  DateTime? _expiresAt;
  Timer? _timer;
  int _secondsLeft = 0;

  Future<void> _generar() async {
    setState(() => _loading = true);
    try {
      final token = await SessionService.getToken();
      if (token == null) return;
      final idPaciente = widget.patient['id_paciente'] as int;
      final data = await ApiService.generarCodigoSupervision(idPaciente, token);
      if (!mounted) return;
      setState(() {
        _codigo = data['codigo'] as String;
        _expiresAt = DateTime.parse(data['expires_at'] as String);
        _startTimer();
      });
    } on ApiException catch (e) {
      if (mounted) showDemoMessage(context, e.message);
    } catch (_) {
      if (mounted) showDemoMessage(context, 'Error de conexión');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _updateSecondsLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateSecondsLeft();
      if (_secondsLeft <= 0) {
        _timer?.cancel();
        if (mounted) {
          setState(() {
            _codigo = null;
            _expiresAt = null;
          });
          showDemoMessage(context, 'El código ha expirado');
        }
      }
    });
  }

  void _updateSecondsLeft() {
    if (_expiresAt == null) return;
    final diff = _expiresAt!.difference(DateTime.now().toUtc()).inSeconds;
    if (mounted) setState(() => _secondsLeft = diff > 0 ? diff : 0);
  }

  Future<void> _verInstrucciones() async {
    final token = await SessionService.getToken();
    if (token == null || !mounted) return;
    Navigator.of(context).push(
      fadeRoute(MocaInstructionsScreen(
        sections: mocaSections,
        patientName: _patientName,
        idMoca: 0,
        token: token,
      )),
    );
  }

  String get _patientName {
    final nombre = widget.patient['nombre'] as String? ?? '';
    final apellido = widget.patient['apellido_paterno'] as String? ?? '';
    return '$nombre $apellido';
  }

  @override
  void dispose() {
    _timer?.cancel();
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
            const SizedBox(height: 24),
            Text('Evaluación MoCA',
                style: AppText.title.copyWith(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              _patientName,
              style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 14),
            ),
            const SizedBox(height: 32),

            if (_codigo == null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.field,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.verified_user, color: AppColors.purple, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Código de supervisión',
                      style: AppText.label.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Genere un código temporal para que el paciente '
                      'pueda iniciar la evaluación en su dispositivo.',
                      textAlign: TextAlign.center,
                      style: AppText.subtitle.copyWith(color: AppColors.hint),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'GENERAR CÓDIGO',
                loading: _loading,
                onPressed: _generar,
              ),
            ] else ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 32),
                  decoration: BoxDecoration(
                    color: AppColors.field,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.purple, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Código de supervisión',
                        style: AppText.subtitle.copyWith(color: AppColors.hint),
                      ),
                      const SizedBox(height: 16),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _codigo!.split('').join('  '),
                          maxLines: 1,
                          style: AppText.title.copyWith(
                            fontSize: 36,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _TimerBadge(secondsLeft: _secondsLeft),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Proporcione este código al paciente\nde forma verbal.',
                  textAlign: TextAlign.center,
                  style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 13),
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'GENERAR NUEVO CÓDIGO',
                loading: _loading,
                onPressed: _generar,
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'VER INSTRUCCIONES',
                loading: false,
                onPressed: _verInstrucciones,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimerBadge extends StatelessWidget {
  const _TimerBadge({required this.secondsLeft});
  final int secondsLeft;

  @override
  Widget build(BuildContext context) {
    final min = secondsLeft ~/ 60;
    final sec = secondsLeft % 60;
    final text = '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
    final isLow = secondsLeft < 120;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isLow
            ? Colors.orange.withAlpha(40)
            : AppColors.purpleDark.withAlpha(80),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 16,
            color: isLow ? Colors.orange : AppColors.purple,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppText.label.copyWith(
              fontSize: 13,
              color: isLow ? Colors.orange : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
