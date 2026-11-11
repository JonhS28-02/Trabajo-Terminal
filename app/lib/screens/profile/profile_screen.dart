import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
  String _role = '';
  String? _codigo;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final nombre = await SessionService.getNombre() ?? '';
    final role = await SessionService.getRole() ?? '';
    final codigo = await SessionService.getCodigoPaciente();
    if (!mounted) return;
    setState(() {
      _nombre = nombre;
      _role = role;
      _codigo = codigo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final isPaciente = _role == 'paciente';

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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.gradient,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 50),
          ),
          const SizedBox(height: 20),

          if (isPaciente && _codigo != null) ...[
            GestureDetector(
              onTap: () => _showQrDialog(context),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.field,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Icon(Icons.qr_code_2, color: Colors.white70, size: 36),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca para ver tu QR',
              style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 11),
            ),
            const SizedBox(height: 16),
          ],

          Text(
            _nombre,
            style: AppText.title.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            isPaciente ? 'Paciente' : 'Especialista',
            style: AppText.subtitle.copyWith(color: AppColors.hint),
          ),

          if (isPaciente && _codigo != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.purpleDark.withAlpha(80),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'ID: $_codigo',
                style: AppText.label.copyWith(
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],

          const SizedBox(height: 28),

          PrimaryButton(
            label: 'EDITAR PERFIL',
            onPressed: () =>
                showDemoMessage(context, 'Edición de perfil (próximamente)'),
          ),

          const SizedBox(height: 40),

          // Logout
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
              child: Text('CERRAR SESIÓN', style: AppText.button.copyWith(color: Colors.redAccent)),
            ),
          ),
        ],
      ),
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
                child: const Text('Cerrar', style: TextStyle(color: AppColors.purpleDark)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
