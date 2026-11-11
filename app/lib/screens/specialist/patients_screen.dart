import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import 'add_patient_screen.dart';
import 'expediente_screen.dart';
import 'moca_code_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  List<Map<String, dynamic>> _patients = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final token = await SessionService.getToken();
      if (token == null) return;
      final list = await ApiService.listarPacientes(token);
      if (!mounted) return;
      setState(() {
        _patients = list.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        showDemoMessage(context, 'Error al cargar pacientes');
      }
    }
  }

  void _goToAdd() async {
    final added = await Navigator.of(context).push<bool>(
      fadeRoute(const AddPatientScreen()),
    );
    if (added == true) _load();
  }

  void _goToPatient(Map<String, dynamic> patient) async {
    final tieneExp = patient['tiene_expediente'] as bool? ?? false;
    if (!tieneExp) {
      await Navigator.of(context).push(
        fadeRoute(ExpedienteScreen(patient: patient)),
      );
      _load();
      return;
    }

    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _PatientActions(patient: patient),
    );
    if (action == null || !mounted) return;

    if (action == 'expediente') {
      await Navigator.of(context).push(
        fadeRoute(ExpedienteScreen(patient: patient)),
      );
    } else if (action == 'moca') {
      await Navigator.of(context).push(
        fadeRoute(MocaCodeScreen(patient: patient)),
      );
    }
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.purple))
          : _patients.isEmpty
              ? _Empty(onAdd: _goToAdd)
              : RefreshIndicator(
                  color: AppColors.purple,
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      top: topPad + 24,
                      left: AppSizes.gutter,
                      right: AppSizes.gutter,
                      bottom: 100,
                    ),
                    itemCount: _patients.length + 1,
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text('Pacientes', style: AppText.title.copyWith(fontSize: 26)),
                              ),
                              GestureDetector(
                                onTap: _goToAdd,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppColors.gradient,
                                  ),
                                  child: const Icon(Icons.person_add, color: Colors.white, size: 22),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      final p = _patients[i - 1];
                      return _PatientCard(
                        patient: p,
                        onTap: () => _goToPatient(p),
                      );
                    },
                  ),
                ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 20),
            Text(
              'Sin pacientes',
              style: AppText.title.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 12),
            Text(
              'Agrega pacientes escaneando su QR o ingresando su código de 8 dígitos.',
              textAlign: TextAlign.center,
              style: AppText.subtitle.copyWith(color: AppColors.hint),
            ),
            const SizedBox(height: 32),
            PrimaryButton(label: 'AGREGAR PACIENTE', onPressed: onAdd),
          ],
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient, required this.onTap});

  final Map<String, dynamic> patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final nombre = patient['nombre'] as String? ?? '';
    final apellido = patient['apellido_paterno'] as String? ?? '';
    final codigo = patient['codigo_paciente'] as String? ?? '';
    final tieneExp = patient['tiene_expediente'] as bool? ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: tieneExp ? AppColors.gradient : null,
                color: tieneExp ? null : AppColors.purpleDark.withValues(alpha: 0.4),
              ),
              child: Icon(
                tieneExp ? Icons.assignment_turned_in : Icons.person,
                color: Colors.white70,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$nombre $apellido',
                    style: AppText.label,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: $codigo',
                    style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 11),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: tieneExp
                    ? AppColors.purpleDark.withValues(alpha: 0.5)
                    : Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tieneExp ? 'Expediente' : 'Pendiente',
                style: AppText.subtitle.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: tieneExp ? AppColors.purple : Colors.orange,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.hint, size: 20),
          ],
        ),
      ),
    );
  }
}

class _PatientActions extends StatelessWidget {
  const _PatientActions({required this.patient});
  final Map<String, dynamic> patient;

  @override
  Widget build(BuildContext context) {
    final nombre = patient['nombre'] as String? ?? '';
    final apellido = patient['apellido_paterno'] as String? ?? '';
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$nombre $apellido',
              style: AppText.label.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 20),
            _ActionTile(
              icon: Icons.assignment,
              label: 'Ver expediente',
              subtitle: 'Consultar o editar expediente clínico',
              onTap: () => Navigator.pop(context, 'expediente'),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.psychology,
              label: 'Evaluación MoCA',
              subtitle: 'Generar código para iniciar evaluación',
              onTap: () => Navigator.pop(context, 'moca'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.gradient,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppText.label),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppText.subtitle.copyWith(
                      color: AppColors.hint,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.hint, size: 20),
          ],
        ),
      ),
    );
  }
}
