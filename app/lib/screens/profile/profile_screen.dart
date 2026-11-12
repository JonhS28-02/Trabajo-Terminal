import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _nombre = '';
  String _apellidoPaterno = '';
  String _apellidoMaterno = '';
  String _email = '';
  String _role = '';
  String? _codigo;
  String? _cedula;
  String? _especialidad;
  String _fechaNacimiento = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final token = await SessionService.getToken();
    if (token == null || !mounted) return;
    try {
      final data = await ApiService.getProfile(token);
      if (!mounted) return;
      setState(() {
        _nombre = data['nombre'] as String? ?? '';
        _apellidoPaterno = data['apellido_paterno'] as String? ?? '';
        _apellidoMaterno = data['apellido_materno'] as String? ?? '';
        _email = data['email'] as String? ?? '';
        _role = data['role'] as String? ?? '';
        _codigo = data['codigo_paciente'] as String?;
        _cedula = data['cedula'] as String?;
        _especialidad = data['especialidad'] as String?;
        _fechaNacimiento = data['fecha_nacimiento'] as String? ?? '';
        _loading = false;
      });
    } catch (_) {
      final nombre = await SessionService.getNombre() ?? '';
      final role = await SessionService.getRole() ?? '';
      final codigo = await SessionService.getCodigoPaciente();
      if (!mounted) return;
      setState(() {
        _nombre = nombre;
        _role = role;
        _codigo = codigo;
        _loading = false;
      });
    }
  }

  String get _fullName {
    final parts = [_nombre, _apellidoPaterno, _apellidoMaterno]
        .where((s) => s.isNotEmpty);
    return parts.join(' ');
  }

  void _openEditSheet() {
    final nombreCtrl = TextEditingController(text: _nombre);
    final apCtrl = TextEditingController(text: _apellidoPaterno);
    final amCtrl = TextEditingController(text: _apellidoMaterno);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: AppSizes.gutter,
          right: AppSizes.gutter,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Editar perfil', style: AppText.title.copyWith(fontSize: 18)),
            const SizedBox(height: 20),
            Text('Nombre', style: AppText.label.copyWith(fontSize: 12)),
            const SizedBox(height: 8),
            AppField(hint: 'Nombre', controller: nombreCtrl),
            const SizedBox(height: 16),
            Text('Apellido paterno', style: AppText.label.copyWith(fontSize: 12)),
            const SizedBox(height: 8),
            AppField(hint: 'Apellido paterno', controller: apCtrl),
            const SizedBox(height: 16),
            Text('Apellido materno', style: AppText.label.copyWith(fontSize: 12)),
            const SizedBox(height: 8),
            AppField(hint: 'Apellido materno', controller: amCtrl),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'GUARDAR',
              onPressed: () async {
                final token = await SessionService.getToken();
                if (token == null) return;
                try {
                  await ApiService.updateProfile(
                    token: token,
                    nombre: nombreCtrl.text.trim(),
                    apellidoPaterno: apCtrl.text.trim(),
                    apellidoMaterno: amCtrl.text.trim(),
                  );
                  await SessionService.save(
                    token: token,
                    role: _role,
                    userId: 0,
                    nombre: nombreCtrl.text.trim(),
                    codigoPaciente: _codigo,
                  );
                  if (!ctx.mounted) return;
                  Navigator.of(ctx).pop();
                  _loadProfile();
                  if (mounted) {
                    showDemoMessage(context, 'Perfil actualizado');
                  }
                } on ApiException catch (e) {
                  if (ctx.mounted) showDemoMessage(ctx, e.message);
                } catch (_) {
                  if (ctx.mounted) showDemoMessage(ctx, 'Error de conexión');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final isPaciente = _role == 'paciente';

    if (_loading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: topPad + 100),
          child: const CircularProgressIndicator(color: AppColors.purple),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: topPad + 24,
        left: AppSizes.gutter,
        right: AppSizes.gutter,
        bottom: 28 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),

          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.gradient,
            ),
            child: Center(
              child: Text(
                _nombre.isNotEmpty ? _nombre[0].toUpperCase() : '?',
                style: AppText.title.copyWith(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            _fullName,
            style: AppText.title.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.purple.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.purple.withAlpha(60)),
            ),
            child: Text(
              isPaciente ? 'Paciente' : 'Especialista',
              style: AppText.subtitle.copyWith(color: AppColors.purple, fontSize: 12),
            ),
          ),

          const SizedBox(height: 24),

          // Info section
          _infoCard([
            if (_email.isNotEmpty)
              _infoRow(Icons.email_outlined, 'Correo', _email),
            if (_fechaNacimiento.isNotEmpty)
              _infoRow(Icons.cake_outlined, 'Nacimiento', _fechaNacimiento),
          ]),

          if (!isPaciente && (_cedula != null || _especialidad != null)) ...[
            const SizedBox(height: 12),
            _infoCard([
              if (_cedula != null)
                _infoRow(Icons.badge_outlined, 'Cédula profesional', _cedula!),
              if (_especialidad != null)
                _infoRow(Icons.medical_services_outlined, 'Especialidad', _especialidad!),
            ]),
          ],

          if (isPaciente && _codigo != null) ...[
            const SizedBox(height: 12),
            _infoCard([
              _infoRow(Icons.qr_code_2, 'Código paciente', _codigo!),
            ]),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showQrDialog(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.field,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.purple.withAlpha(60)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.qr_code_2, color: AppColors.purple, size: 20),
                    const SizedBox(width: 8),
                    Text('Ver mi código QR',
                        style: AppText.label.copyWith(color: AppColors.purple, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 28),

          PrimaryButton(
            label: 'EDITAR PERFIL',
            onPressed: _openEditSheet,
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                await SessionService.clear();
                if (!context.mounted) return;
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
              child: Text('CERRAR SESIÓN',
                  style: AppText.button.copyWith(color: Colors.redAccent)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    final filtered = children.where((w) => w is! SizedBox).toList();
    if (filtered.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          for (int i = 0; i < filtered.length; i++) ...[
            filtered[i],
            if (i < filtered.length - 1) ...[
              const SizedBox(height: 4),
              Divider(color: Colors.white.withAlpha(15), height: 16),
            ],
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.purple, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppText.subtitle.copyWith(
                      color: AppColors.hint, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value,
                  style: AppText.label.copyWith(fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  void _showQrDialog(BuildContext context) {
    if (_codigo == null) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tu código QR',
                style: AppText.title.copyWith(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              QrImageView(
                data: _codigo!,
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF1A1230),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF1A1230),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _codigo!,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Muestra este código a tu especialista',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cerrar',
                    style: TextStyle(color: AppColors.purpleDark)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
