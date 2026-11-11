import 'package:flutter/material.dart';

import '../../data/moca_sections.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../specialist/moca_instructions_screen.dart';

class EnterCodeScreen extends StatefulWidget {
  const EnterCodeScreen({super.key});

  @override
  State<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  bool _loading = false;
  String? _error;
  String _code = '';

  Future<void> _validar() async {
    if (_code.length != 6) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await SessionService.getToken();
      if (token == null) return;
      await ApiService.validarCodigoSupervision(_code, token);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        fadeRoute(MocaInstructionsScreen(
          sections: mocaSections,
          patientName: '',
        )),
      );
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Error de conexión');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
            const SizedBox(height: 32),
            Text('Iniciar Evaluación',
                style: AppText.title.copyWith(fontSize: 24)),
            const SizedBox(height: 12),
            Text(
              'Ingresa el código de 6 dígitos que tu especialista '
              'te proporcionó para comenzar la evaluación MoCA.',
              style: AppText.subtitle.copyWith(color: AppColors.hint),
            ),
            const SizedBox(height: 48),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.lock_outline, color: AppColors.purple, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    'Código de supervisión',
                    style: AppText.label.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 24),
                  CodeInput(
                    onCompleted: (code) {
                      _code = code;
                      _validar();
                    },
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 16, color: Colors.redAccent),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _error!,
                            style: AppText.subtitle.copyWith(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'VALIDAR CÓDIGO',
              loading: _loading,
              onPressed: _code.length == 6 ? _validar : null,
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'El código expira en 30 minutos.\n'
                'Solicita uno nuevo si ha expirado.',
                textAlign: TextAlign.center,
                style: AppText.subtitle.copyWith(
                  color: AppColors.hint,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
