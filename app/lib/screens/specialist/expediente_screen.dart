import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class ExpedienteScreen extends StatefulWidget {
  const ExpedienteScreen({super.key, required this.patient});

  final Map<String, dynamic> patient;

  @override
  State<ExpedienteScreen> createState() => _ExpedienteScreenState();
}

class _ExpedienteScreenState extends State<ExpedienteScreen> {
  bool _loading = true;
  bool _saving = false;
  bool _isEdit = false;

  // Catálogos
  List<Map<String, dynamic>> _escolaridades = [];
  List<Map<String, dynamic>> _ocupaciones = [];
  List<Map<String, dynamic>> _enfermedades = [];
  List<Map<String, dynamic>> _parentescos = [];
  List<Map<String, dynamic>> _consumoAlcohol = [];
  List<Map<String, dynamic>> _consumoTabaco = [];

  // Selecciones
  int? _idEscolaridad;
  int? _idOcupacion;
  int? _idAlcohol;
  int? _idTabaco;
  final Set<int> _enfSeleccionadas = {};
  final List<_AntFamiliar> _antecedentes = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    try {
      final results = await Future.wait([
        ApiService.getCatalogo('escolaridad'),
        ApiService.getCatalogo('ocupacion'),
        ApiService.getCatalogo('enfermedades'),
        ApiService.getCatalogo('parentesco'),
        ApiService.getCatalogo('consumo-alcohol'),
        ApiService.getCatalogo('consumo-tabaco'),
      ]);
      _escolaridades = results[0].cast<Map<String, dynamic>>();
      _ocupaciones = results[1].cast<Map<String, dynamic>>();
      _enfermedades = results[2].cast<Map<String, dynamic>>();
      _parentescos = results[3].cast<Map<String, dynamic>>();
      _consumoAlcohol = results[4].cast<Map<String, dynamic>>();
      _consumoTabaco = results[5].cast<Map<String, dynamic>>();

      final tieneExp = widget.patient['tiene_expediente'] as bool? ?? false;
      if (tieneExp) await _loadExpediente();

      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        showDemoMessage(context, 'Error al cargar catálogos');
      }
    }
  }

  Future<void> _loadExpediente() async {
    try {
      final token = await SessionService.getToken();
      if (token == null) return;
      final idPaciente = widget.patient['id_paciente'] as int;
      final data = await ApiService.obtenerExpediente(idPaciente, token);

      _isEdit = true;
      _idEscolaridad = data['id_escolaridad'] as int?;
      _idOcupacion = data['id_ocupacion'] as int?;
      _idAlcohol = data['id_consumo_alcohol'] as int?;
      _idTabaco = data['id_consumo_tabaco'] as int?;

      final enfs = data['enfermedades'] as List<dynamic>? ?? [];
      _enfSeleccionadas.addAll(enfs.cast<int>());

      final ants = data['antecedentes_familiares'] as List<dynamic>? ?? [];
      for (final a in ants) {
        final m = a as Map<String, dynamic>;
        _antecedentes.add(_AntFamiliar(
          idParentesco: m['id_parentesco'] as int,
          idEnfermedad: m['id_enfermedad'] as int,
        ));
      }
    } on ApiException catch (e) {
      if (e.message == 'not_found') return;
    }
  }

  Future<void> _save() async {
    if (_idEscolaridad == null ||
        _idOcupacion == null ||
        _idAlcohol == null ||
        _idTabaco == null) {
      showDemoMessage(context, 'Completa todos los campos obligatorios');
      return;
    }

    setState(() => _saving = true);
    try {
      final token = await SessionService.getToken();
      if (token == null) return;
      final idPaciente = widget.patient['id_paciente'] as int;

      final body = {
        'id_escolaridad': _idEscolaridad,
        'id_ocupacion': _idOcupacion,
        'id_consumo_alcohol': _idAlcohol,
        'id_consumo_tabaco': _idTabaco,
        'enfermedades': _enfSeleccionadas.toList(),
        'antecedentes_familiares': _antecedentes
            .map((a) => {
                  'id_parentesco': a.idParentesco,
                  'id_enfermedad': a.idEnfermedad,
                })
            .toList(),
      };

      if (_isEdit) {
        await ApiService.actualizarExpediente(idPaciente, body, token);
      } else {
        await ApiService.crearExpediente(idPaciente, body, token);
      }

      if (!mounted) return;
      showDemoMessage(context, _isEdit ? 'Expediente actualizado' : 'Expediente creado');
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (mounted) showDemoMessage(context, e.message);
    } catch (_) {
      if (mounted) showDemoMessage(context, 'Error de conexión');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = widget.patient['nombre'] as String? ?? '';
    final apellido = widget.patient['apellido_paterno'] as String? ?? '';

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.purple))
          : SingleChildScrollView(
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + 16,
                left: AppSizes.gutter,
                right: AppSizes.gutter,
                bottom: 28 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleBackButton(),
                  const SizedBox(height: 24),
                  Text(
                    _isEdit ? 'Editar expediente' : 'Nuevo expediente',
                    style: AppText.title.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$nombre $apellido',
                    style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 14),
                  ),
                  const SizedBox(height: 28),

                  // ── Escolaridad ──
                  _SectionTitle('Escolaridad'),
                  const SizedBox(height: 12),
                  _DropdownField(
                    value: _idEscolaridad,
                    items: _escolaridades.map((e) => _DropItem(
                      e['id'] as int,
                      '${e['nombre']} (${e['anios'] ?? 0} años)',
                    )).toList(),
                    hint: 'Selecciona escolaridad',
                    onChanged: (v) => setState(() => _idEscolaridad = v),
                  ),

                  const SizedBox(height: 24),

                  // ── Ocupación ──
                  _SectionTitle('Ocupación'),
                  const SizedBox(height: 12),
                  _DropdownField(
                    value: _idOcupacion,
                    items: _ocupaciones.map((e) => _DropItem(
                      e['id'] as int,
                      e['nombre'] as String,
                    )).toList(),
                    hint: 'Selecciona ocupación',
                    onChanged: (v) => setState(() => _idOcupacion = v),
                  ),

                  const SizedBox(height: 24),

                  // ── Consumo alcohol ──
                  _SectionTitle('Consumo de alcohol'),
                  const SizedBox(height: 12),
                  _DropdownField(
                    value: _idAlcohol,
                    items: _consumoAlcohol.map((e) => _DropItem(
                      e['id'] as int,
                      e['nombre'] as String,
                    )).toList(),
                    hint: 'Selecciona nivel de consumo',
                    onChanged: (v) => setState(() => _idAlcohol = v),
                  ),

                  const SizedBox(height: 24),

                  // ── Consumo tabaco ──
                  _SectionTitle('Consumo de tabaco'),
                  const SizedBox(height: 12),
                  _DropdownField(
                    value: _idTabaco,
                    items: _consumoTabaco.map((e) => _DropItem(
                      e['id'] as int,
                      e['nombre'] as String,
                    )).toList(),
                    hint: 'Selecciona nivel de consumo',
                    onChanged: (v) => setState(() => _idTabaco = v),
                  ),

                  const SizedBox(height: 28),

                  // ── Enfermedades ──
                  _SectionTitle('Enfermedades del paciente'),
                  const SizedBox(height: 4),
                  Text(
                    'Selecciona las que apliquen',
                    style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 11),
                  ),
                  const SizedBox(height: 12),
                  _buildEnfermedades(),

                  const SizedBox(height: 28),

                  // ── Antecedentes familiares ──
                  _SectionTitle('Antecedentes familiares'),
                  const SizedBox(height: 12),
                  ..._buildAntecedentes(),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _addAntecedente,
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.gradient,
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Text('Agregar antecedente', style: AppText.label.copyWith(fontSize: 13)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  PrimaryButton(
                    label: _isEdit ? 'GUARDAR CAMBIOS' : 'CREAR EXPEDIENTE',
                    loading: _saving,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEnfermedades() {
    String? lastCat;
    final widgets = <Widget>[];
    for (final enf in _enfermedades) {
      final cat = enf['categoria'] as String? ?? '';
      if (cat != lastCat) {
        lastCat = cat;
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            cat,
            style: AppText.subtitle.copyWith(
              color: AppColors.purple,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ));
      }
      final id = enf['id'] as int;
      final selected = _enfSeleccionadas.contains(id);
      widgets.add(
        GestureDetector(
          onTap: () => setState(() {
            selected ? _enfSeleccionadas.remove(id) : _enfSeleccionadas.add(id);
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: selected ? AppColors.gradient : null,
                    border: selected ? null : Border.all(color: AppColors.hint, width: 1.5),
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    enf['nombre'] as String? ?? '',
                    style: AppText.input.copyWith(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }

  List<Widget> _buildAntecedentes() {
    return List.generate(_antecedentes.length, (i) {
      final ant = _antecedentes[i];
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _DropdownField(
                    value: ant.idParentesco,
                    items: _parentescos.map((e) => _DropItem(
                      e['id'] as int,
                      e['nombre'] as String,
                    )).toList(),
                    hint: 'Parentesco',
                    onChanged: (v) => setState(() => ant.idParentesco = v!),
                    compact: true,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _antecedentes.removeAt(i)),
                  child: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _DropdownField(
              value: ant.idEnfermedad,
              items: _enfermedades.map((e) => _DropItem(
                e['id'] as int,
                e['nombre'] as String,
              )).toList(),
              hint: 'Enfermedad',
              onChanged: (v) => setState(() => ant.idEnfermedad = v!),
              compact: true,
            ),
          ],
        ),
      );
    });
  }

  void _addAntecedente() {
    setState(() {
      _antecedentes.add(_AntFamiliar(
        idParentesco: _parentescos.isNotEmpty ? _parentescos.first['id'] as int : 1,
        idEnfermedad: _enfermedades.isNotEmpty ? _enfermedades.first['id'] as int : 1,
      ));
    });
  }
}

class _AntFamiliar {
  int idParentesco;
  int idEnfermedad;
  _AntFamiliar({required this.idParentesco, required this.idEnfermedad});
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppText.label.copyWith(fontSize: 16));
  }
}

class _DropItem {
  final int id;
  final String label;
  const _DropItem(this.id, this.label);
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
    this.compact = false,
  });

  final int? value;
  final List<_DropItem> items;
  final String hint;
  final ValueChanged<int?> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 40 : 51,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: compact ? const Color(0xFF2A2A2A) : AppColors.field,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF2A2A2A),
          hint: Text(hint, style: AppText.hint.copyWith(fontSize: compact ? 12 : 14)),
          style: AppText.input.copyWith(fontSize: compact ? 12 : 14),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.hint, size: 20),
          items: items.map((item) => DropdownMenuItem(
            value: item.id,
            child: Text(item.label, overflow: TextOverflow.ellipsis),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
