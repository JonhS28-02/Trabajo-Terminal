import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import 'credentials_screen.dart';

class ValidationScreen extends StatefulWidget {
  const ValidationScreen({super.key, required this.userData});

  final Map<String, dynamic> userData;

  @override
  State<ValidationScreen> createState() => _ValidationScreenState();
}

class _ValidationScreenState extends State<ValidationScreen> {
  final _cedulaCtrl = TextEditingController();
  bool _loading = false;
  bool _validated = false;
  String? _especialidad;
  String? _nombreSep;

  @override
  void dispose() {
    _cedulaCtrl.dispose();
    super.dispose();
  }

  Future<void> _validate() async {
    final cedula = _cedulaCtrl.text.trim();
    if (cedula.isEmpty) {
      showDemoMessage(context, 'Ingresa tu cédula profesional');
      return;
    }
    if (!RegExp(r'^\d{6,8}$').hasMatch(cedula)) {
      showDemoMessage(context, 'La cédula debe tener entre 6 y 8 dígitos');
      return;
    }

    setState(() => _loading = true);

    try {
      final data = await ApiService.validateCedula(cedula);
      if (data['valid'] == true) {
        setState(() {
          _validated = true;
          _especialidad = data['especialidad'] as String?;
          _nombreSep = data['nombre'] as String?;
        });
      } else {
        if (mounted) {
          showDemoMessage(
            context,
            data['message'] as String? ??
                'Cédula no válida para profesional de salud',
          );
        }
      }
    } catch (_) {
      if (mounted) {
        showDemoMessage(context, 'Error al validar. Verifica tu conexión.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _continue() {
    if (!_validated) {
      showDemoMessage(context, 'Primero valida tu cédula profesional');
      return;
    }

    final data = Map<String, dynamic>.from(widget.userData);
    data['cedula'] = _cedulaCtrl.text.trim();

    Navigator.of(context).push(fadeRoute(CredentialsScreen(userData: data)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 15, top: 8),
                child: CircleBackButton(),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 17),
                    Text('Validación', style: AppText.title),
                    const SizedBox(height: 17),
                    const RichSubtitle(
                      'Ingresa tu ',
                      'cédula profesional',
                      fontSize: 14,
                    ),
                    const SizedBox(height: 33),
                    AppField(
                      hint: '000000000',
                      height: 43,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      controller: _cedulaCtrl,
                      onSubmitted: (_) => _validate(),
                    ),
                    const SizedBox(height: 44),
                    Center(
                      child: PrimaryButton(
                        label: 'VALIDAR',
                        width: 205,
                        loading: _loading,
                        onPressed: _validated ? null : _validate,
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: _validated
                          ? Padding(
                              padding: const EdgeInsets.only(top: 45),
                              child: _VerifiedData(
                                especialidad: _especialidad ?? '',
                                nombre: _nombreSep ?? '',
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 40),
                    PrimaryButton(
                      label: 'CONTINUAR',
                      onPressed: _continue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerifiedData extends StatelessWidget {
  const _VerifiedData({required this.especialidad, required this.nombre});

  final String especialidad;
  final String nombre;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ShaderMask(
              shaderCallback: AppColors.gradient.createShader,
              child: const Icon(Icons.check_rounded,
                  size: 84, color: Colors.white),
            ),
          ),
          const SizedBox(height: 40),
          const RichSubtitle(
              'Verificación completada, ', 'comprueba tus datos'),
          const SizedBox(height: 29),
          Text('Nombre', style: AppText.label),
          const SizedBox(height: 22),
          Center(
              child:
                  Text(nombre, style: AppText.input.copyWith(fontSize: 12))),
          const SizedBox(height: 49),
          Text('Especialidad', style: AppText.label),
          const SizedBox(height: 39),
          Center(child: Text(especialidad, style: AppText.input)),
        ],
      ),
    );
  }
}
