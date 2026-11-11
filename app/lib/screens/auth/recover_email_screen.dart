import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import 'recover_password_screen.dart';

/// Frame "Recuperar contraseña" (correo + código de 6 dígitos).
class RecoverEmailScreen extends StatelessWidget {
  const RecoverEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RecoverScaffold(
      children: [
        const SizedBox(height: 37),
        const RichSubtitle('Ingresa tu ', 'correo electrónico'),
        const SizedBox(height: 41),
        const AppField(
          hint: 'hola@ejemplo.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 42),
        Center(
          child: PrimaryButton(
            label: 'Enviar código',
            width: 141,
            height: 34,
            onPressed: () => showDemoMessage(context, 'Código enviado (demo)'),
          ),
        ),
        const SizedBox(height: 29),
        Text(
          'Ingresa el código de 6 dígitos enviado a tu correo',
          style: AppText.subtitle,
        ),
        const SizedBox(height: 39),
        const CodeInput(),
        const SizedBox(height: 41),
        PrimaryButton(
          label: 'VALIDAR',
          onPressed: () => Navigator.of(context)
              .pushReplacement(fadeRoute(const RecoverPasswordScreen())),
        ),
      ],
    );
  }
}

/// Estructura común de las pantallas de recuperación: imagen, botón de
/// regresar y título.
class RecoverScaffold extends StatelessWidget {
  const RecoverScaffold({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: 32 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                const HeaderImage(asset: 'assets/images/recover.jpg'),
                Positioned(
                  left: 11,
                  top: MediaQuery.paddingOf(context).top + 8,
                  child: const CircleBackButton(),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 38),
                  Text(
                    'Recuperar contraseña',
                    style: AppText.title.copyWith(fontSize: 24),
                  ),
                  ...children,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
