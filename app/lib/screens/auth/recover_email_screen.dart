import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import 'recover_password_screen.dart';
import '../../widgets/entrance.dart';

class RecoverEmailScreen extends StatefulWidget {
  const RecoverEmailScreen({super.key});

  @override
  State<RecoverEmailScreen> createState() => _RecoverEmailScreenState();
}

class _RecoverEmailScreenState extends State<RecoverEmailScreen> {
  final _emailCtrl = TextEditingController();
  final _codeCtrls = List.generate(6, (_) => TextEditingController());
  final _codeFocuses = List.generate(6, (_) => FocusNode());
  bool _codeSent = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    for (final c in _codeCtrls) c.dispose();
    for (final f in _codeFocuses) f.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      showDemoMessage(context, 'Ingresa tu correo electrónico');
      return;
    }
    setState(() => _loading = true);
    try {
      await ApiService.forgotPassword(email);
      if (!mounted) return;
      setState(() => _codeSent = true);
      showDemoMessage(context, 'Si el correo existe, recibirás un código');
      _codeFocuses[0].requestFocus();
    } on ApiException catch (e) {
      if (mounted) showDemoMessage(context, e.message);
    } catch (_) {
      if (mounted) showDemoMessage(context, 'Error de conexión');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _validate() async {
    final code = _codeCtrls.map((c) => c.text).join();
    if (code.length != 6) {
      showDemoMessage(context, 'Ingresa el código completo');
      return;
    }
    setState(() => _loading = true);
    try {
      await ApiService.verifyResetCode(_emailCtrl.text.trim(), code);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(fadeRoute(RecoverPasswordScreen(
        email: _emailCtrl.text.trim(),
        code: code,
      )));
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
        const SizedBox(height: 37),
        const RichSubtitle('Ingresa tu ', 'correo electrónico'),
        const SizedBox(height: 41),
        AppField(
          hint: 'hola@ejemplo.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          controller: _emailCtrl,
          onSubmitted: (_) => _sendCode(),
        ),
        const SizedBox(height: 42),
        Center(
          child: PrimaryButton(
            label: _codeSent ? 'Reenviar código' : 'Enviar código',
            width: 160,
            height: 34,
            onPressed: _loading ? null : _sendCode,
            loading: _loading && !_codeSent,
          ),
        ),
        if (_codeSent) ...[
          const SizedBox(height: 29),
          Text(
            'Ingresa el código de 6 dígitos enviado a tu correo',
            style: AppText.subtitle,
          ),
          const SizedBox(height: 39),
          _buildCodeInput(),
          const SizedBox(height: 41),
          PrimaryButton(
            label: 'VALIDAR',
            onPressed: _loading ? null : _validate,
            loading: _loading && _codeSent,
          ),
        ],
      ],
    );
  }

  Widget _buildCodeInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        return Container(
          width: 44,
          height: 52,
          margin: EdgeInsets.only(right: i < 5 ? 8 : 0),
          child: TextField(
            controller: _codeCtrls[i],
            focusNode: _codeFocuses[i],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: AppText.label.copyWith(fontSize: 22),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppColors.field,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.purple, width: 1.5),
              ),
            ),
            onChanged: (val) {
              if (val.isNotEmpty && i < 5) {
                _codeFocuses[i + 1].requestFocus();
              }
              if (val.isEmpty && i > 0) {
                _codeFocuses[i - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }
}

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
                children: staggered([
                  const SizedBox(height: 38),
                  Text(
                    'Recuperar contraseña',
                    style: AppText.title.copyWith(fontSize: 24),
                  ),
                  ...children,
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
