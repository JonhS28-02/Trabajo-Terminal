import 'package:flutter/material.dart';

import '../../widgets/app_widgets.dart';
import 'recover_email_screen.dart';

/// Frame "Recuperar contraseña" (nueva contraseña).
class RecoverPasswordScreen extends StatelessWidget {
  const RecoverPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RecoverScaffold(
      children: [
        const SizedBox(height: 70),
        const RichSubtitle('Ingresa tu nueva ', 'contraseña'),
        const SizedBox(height: 27),
        const AppField(hint: 'Ingresa tu nueva contraseña', obscure: true),
        const SizedBox(height: 28),
        const RichSubtitle('Confirma tu nueva ', 'contraseña'),
        const SizedBox(height: 38),
        const AppField(
          hint: 'Confirma tu nueva contraseña',
          obscure: true,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 39),
        PrimaryButton(
          label: 'ACTUALIZAR CONTRASEÑA',
          onPressed: () {
            showDemoMessage(context, 'Contraseña actualizada (demo)');
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
