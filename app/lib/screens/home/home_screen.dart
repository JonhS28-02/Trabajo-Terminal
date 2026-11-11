import 'package:flutter/material.dart';

import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../evaluation/enter_code_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.role = ''});

  final String role;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: topPad + 24,
        left: AppSizes.gutter,
        right: AppSizes.gutter,
        bottom: 28 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String?>(
            future: SessionService.getNombre(),
            builder: (context, snap) {
              final nombre = snap.data ?? '';
              return Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.gradient,
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: AppText.subtitle.copyWith(color: AppColors.hint),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nombre,
                          style: AppText.title.copyWith(fontSize: 22),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 40),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.gradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.psychology, color: Colors.white, size: 40),
                const SizedBox(height: 16),
                Text(
                  'Brain Test',
                  style: AppText.title.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 12),
                Text(
                  'Bienvenido a Brain Test. Tu perfil incluye un código QR '
                  'único que tu especialista puede escanear para vincularte '
                  'a su lista de pacientes.',
                  style: AppText.subtitle.copyWith(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (role == 'paciente') ...[
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                fadeRoute(const EnterCodeScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.field,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.purple.withAlpha(60),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.gradient,
                      ),
                      child: const Icon(Icons.psychology,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Evaluación MoCA',
                              style: AppText.label.copyWith(fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(
                            'Ingresa el código de tu especialista para iniciar',
                            style: AppText.subtitle
                                .copyWith(color: AppColors.hint, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: AppColors.hint, size: 22),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),

          Text('Información', style: AppText.title.copyWith(fontSize: 18)),
          const SizedBox(height: 16),
          _InfoTile(
            icon: Icons.qr_code_2,
            title: 'Tu código QR',
            desc: 'Ve a tu perfil para mostrar tu código QR al especialista.',
          ),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.person_search,
            title: 'Vinculación',
            desc: 'El especialista escaneará tu QR para agregarte como paciente.',
          ),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.security,
            title: 'Privacidad',
            desc: 'Tu información está protegida y solo será visible para '
                'los especialistas que autorices.',
          ),
        ],
      ),
    );
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días';
    if (h < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.desc,
  });

  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.purpleDark.withAlpha(80),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white70, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.label),
                const SizedBox(height: 4),
                Text(desc, style: AppText.subtitle.copyWith(color: AppColors.hint)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
