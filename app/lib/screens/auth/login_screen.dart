import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../main_shell.dart';
import '../register/register_transition_screen.dart';
import 'recover_email_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (email.isEmpty || pass.isEmpty) {
      showDemoMessage(context, 'Completa todos los campos');
      return;
    }

    setState(() => _loading = true);

    try {
      final data = await ApiService.login(email, pass);
      await SessionService.save(
        token: data['access_token'] as String,
        role: data['role'] as String,
        userId: data['user_id'] as int,
        nombre: data['nombre'] as String,
        codigoPaciente: data['codigo_paciente'] as String?,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(fadeRoute(const MainShell()));
    } on ApiException catch (e) {
      if (mounted) showDemoMessage(context, e.message);
    } catch (_) {
      if (mounted) showDemoMessage(context, 'Error de conexión. Verifica tu red.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: 28 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeaderImage(
              asset: 'assets/images/login.jpg',
              height: 279,
              blur: 1.5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 51),
                  Text('Inicio de sesión', style: AppText.title),
                  const SizedBox(height: 27),
                  const RichSubtitle(
                      'Inicia sesión con tus ', 'credenciales'),
                  const SizedBox(height: 38),
                  LabeledField(
                    label: 'Correo electrónico',
                    field: AppField(
                      hint: 'hola@ejemplo.com',
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailCtrl,
                    ),
                  ),
                  const SizedBox(height: 33),
                  LabeledField(
                    label: 'Contraseña',
                    field: AppField(
                      hint: 'Ingresa tu contraseña',
                      obscure: true,
                      textInputAction: TextInputAction.done,
                      controller: _passCtrl,
                      onSubmitted: (_) => _login(),
                    ),
                  ),
                  const SizedBox(height: 38),
                  PrimaryButton(
                    label: 'INICIAR SESIÓN',
                    onPressed: _loading ? null : _login,
                    loading: _loading,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: _Link(
                      normal: 'Recupera tu ',
                      bold: 'contraseña',
                      onTap: () => Navigator.of(context)
                          .push(fadeRoute(const RecoverEmailScreen())),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: _Link(
                      normal: '¿No tienes una cuenta? ',
                      bold: 'Regístrate',
                      onTap: () => Navigator.of(context).push(
                        fadeRoute(const RegisterTransitionScreen(), ms: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({required this.normal, required this.bold, required this.onTap});

  final String normal;
  final String bold;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: RichSubtitle(normal, bold, center: true),
      ),
    );
  }
}
