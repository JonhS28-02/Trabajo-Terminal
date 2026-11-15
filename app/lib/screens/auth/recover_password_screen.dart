import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import 'recover_email_screen.dart';

class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({
    super.key,
    required this.email,
    required this.code,
  });

  final String email;
  final String code;

  @override
  State<RecoverPasswordScreen> createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (pass.isEmpty || confirm.isEmpty) {
      showDemoMessage(context, 'Completa ambos campos');
      return;
    }
    if (pass != confirm) {
      showDemoMessage(context, 'Las contraseñas no coinciden');
      return;
    }
    if (pass.length < 8) {
      showDemoMessage(context, 'Mínimo 8 caracteres');
      return;
    }

    setState(() => _loading = true);
    try {
      await ApiService.resetPassword(widget.email, widget.code, pass);
      if (!mounted) return;
      showDemoMessage(context, 'Contraseña actualizada correctamente');
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on ApiException catch (e) {
      if (mounted) showDemoMessage(context, e.message);
    } catch (_) {
      if (mounted) showDemoMessage(context, 'Error de conexión');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RecoverScaffold(
      children: [
        const SizedBox(height: 70),
        const RichSubtitle('Ingresa tu nueva ', 'contraseña'),
        const SizedBox(height: 27),
        AppField(
          hint: 'Ingresa tu nueva contraseña',
          obscure: true,
          controller: _passCtrl,
        ),
        const SizedBox(height: 28),
        const RichSubtitle('Confirma tu nueva ', 'contraseña'),
        const SizedBox(height: 38),
        AppField(
          hint: 'Confirma tu nueva contraseña',
          obscure: true,
          textInputAction: TextInputAction.done,
          controller: _confirmCtrl,
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 8),
        Text(
          'Mínimo 8 caracteres, 1 mayúscula, 1 minúscula, 1 número',
          style: AppText.subtitle.copyWith(
            color: AppColors.hint,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 39),
        PrimaryButton(
          label: 'ACTUALIZAR CONTRASEÑA',
          onPressed: _loading ? null : _submit,
          loading: _loading,
        ),
      ],
    );
  }
}
