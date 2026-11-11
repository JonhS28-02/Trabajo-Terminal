import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;
  bool _touched = false;
  String? _error;
  bool _valid = false;

  void _onChanged(String _) {
    _touched = true;
    _validate();
  }

  void _validate() {
    if (!_touched) return;
    final code = _codeCtrl.text.trim();
    setState(() {
      if (code.isEmpty) {
        _error = 'Ingresa el código del paciente';
        _valid = false;
      } else if (!RegExp(r'^\d{8}$').hasMatch(code)) {
        _error = 'El código debe ser de 8 dígitos';
        _valid = false;
      } else {
        _error = null;
        _valid = true;
      }
    });
  }

  Future<void> _vincular() async {
    _touched = true;
    _validate();
    if (_error != null) return;

    setState(() => _loading = true);
    try {
      final token = await SessionService.getToken();
      if (token == null) return;
      await ApiService.vincularPaciente(_codeCtrl.text.trim(), token);
      if (!mounted) return;
      showDemoMessage(context, 'Paciente vinculado exitosamente');
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) showDemoMessage(context, e.message);
    } catch (_) {
      if (mounted) showDemoMessage(context, 'Error de conexión');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
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
            const SizedBox(height: 32),
            Text('Agregar paciente', style: AppText.title.copyWith(fontSize: 26)),
            const SizedBox(height: 12),
            const RichSubtitle(
              'Ingresa el código de ',
              '8 dígitos',
              fontSize: 13,
            ),
            const SizedBox(height: 8),
            Text(
              'El paciente puede encontrar su código en su perfil o mostrarte su QR.',
              style: AppText.subtitle.copyWith(color: AppColors.hint),
            ),
            const SizedBox(height: 40),
            LabeledField(
              label: 'Código del paciente',
              field: AppField(
                hint: '12345678',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                controller: _codeCtrl,
                onChanged: _onChanged,
                onSubmitted: (_) => _vincular(),
                errorText: _error,
                isValid: _valid,
              ),
            ),
            const SizedBox(height: 60),
            PrimaryButton(
              label: 'VINCULAR PACIENTE',
              loading: _loading,
              onPressed: _vincular,
            ),
          ],
        ),
      ),
    );
  }
}
