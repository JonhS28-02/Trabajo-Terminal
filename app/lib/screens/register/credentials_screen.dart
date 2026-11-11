import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../main_shell.dart';

class CredentialsScreen extends StatefulWidget {
  const CredentialsScreen({super.key, required this.userData});

  final Map<String, dynamic> userData;

  @override
  State<CredentialsScreen> createState() => _CredentialsScreenState();
}

class _CredentialsScreenState extends State<CredentialsScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _emailTouched = false;
  bool _passTouched = false;
  String? _emailError;
  bool _emailValid = false;
  String? _passError;
  bool _passValid = false;

  void _onEmailChanged(String _) {
    _emailTouched = true;
    _validateEmail();
  }

  void _validateEmail() {
    if (!_emailTouched) return;
    final email = _emailCtrl.text.trim();
    setState(() {
      if (email.isEmpty) {
        _emailError = 'Ingresa tu correo electrónico';
        _emailValid = false;
      } else if (!RegExp(r'^[\w.\-+]+@[\w.\-]+\.\w+$').hasMatch(email)) {
        _emailError = 'Ingresa un correo válido';
        _emailValid = false;
      } else {
        _emailError = null;
        _emailValid = true;
      }
    });
  }

  void _onPassChanged(String _) {
    _passTouched = true;
    _validatePass();
  }

  void _validatePass() {
    if (!_passTouched) return;
    final pass = _passCtrl.text;
    setState(() {
      if (pass.isEmpty) {
        _passError = 'Ingresa tu contraseña';
        _passValid = false;
      } else if (pass.length < 8) {
        _passError = 'Mínimo 8 caracteres';
        _passValid = false;
      } else if (!RegExp(r'[A-Z]').hasMatch(pass)) {
        _passError = 'Falta al menos una mayúscula';
        _passValid = false;
      } else if (!RegExp(r'[a-z]').hasMatch(pass)) {
        _passError = 'Falta al menos una minúscula';
        _passValid = false;
      } else if (!RegExp(r'\d').hasMatch(pass)) {
        _passError = 'Falta al menos un número';
        _passValid = false;
      } else {
        _passError = null;
        _passValid = true;
      }
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    _emailTouched = true;
    _passTouched = true;
    _validateEmail();
    _validatePass();
    if (_emailError != null || _passError != null) return;

    setState(() => _loading = true);

    try {
      final email = _emailCtrl.text.trim();
      final pass = _passCtrl.text;
      final d = widget.userData;
      final isSpecialist = d['role'] == 'especialista';

      final Map<String, dynamic> data;
      if (isSpecialist) {
        data = await ApiService.registerSpecialist(
          nombre: d['nombre'] as String,
          apellidoPaterno: d['apellido_paterno'] as String,
          apellidoMaterno: d['apellido_materno'] as String?,
          fechaNacimiento: d['fecha_nacimiento'] as String,
          email: email,
          password: pass,
          idGenero: d['id_genero'] as int,
          cedula: d['cedula'] as String,
        );
      } else {
        data = await ApiService.registerPatient(
          nombre: d['nombre'] as String,
          apellidoPaterno: d['apellido_paterno'] as String,
          apellidoMaterno: d['apellido_materno'] as String?,
          fechaNacimiento: d['fecha_nacimiento'] as String,
          email: email,
          password: pass,
          idGenero: d['id_genero'] as int,
        );
      }

      await SessionService.save(
        token: data['access_token'] as String,
        role: data['role'] as String,
        userId: data['user_id'] as int,
        nombre: data['nombre'] as String,
        codigoPaciente: data['codigo_paciente'] as String?,
      );

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        fadeRoute(const MainShell()),
        (_) => false,
      );
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
            Stack(
              children: [
                const HeaderImage(asset: 'assets/images/credentials.jpg'),
                Positioned(
                  left: 15,
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
                  Text('Credenciales', style: AppText.title),
                  const SizedBox(height: 27),
                  const RichSubtitle(
                    'Ingresa tus credenciales para el ',
                    'inicio de sesión',
                  ),
                  const SizedBox(height: 38),
                  LabeledField(
                    label: 'Correo electrónico',
                    field: AppField(
                      hint: 'hola@ejemplo.com',
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailCtrl,
                      onChanged: _onEmailChanged,
                      errorText: _emailError,
                      isValid: _emailValid,
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
                      onSubmitted: (_) => _register(),
                      onChanged: _onPassChanged,
                      errorText: _passError,
                      isValid: _passValid,
                    ),
                  ),
                  const SizedBox(height: 80),
                  PrimaryButton(
                    label: 'REGISTRARME',
                    loading: _loading,
                    onPressed: _register,
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
