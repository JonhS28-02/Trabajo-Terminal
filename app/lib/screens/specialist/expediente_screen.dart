import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/entrance.dart';

/// Valores de `indicador_modelo` que el modelo de predicción sí utiliza.
const _indicadoresModelo = {
  'DIABETES', 'HIPERTENSION', 'HIPERLIPIDEMIA', 'DEPRESION', 'PSIQUIATRICA', 'TCE',
  'EPILEPSIA', 'CARDIOVASCULAR', 'ACV_TIA', 'ALCOHOL_ABUSO', 'DROGAS',
};

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

  List<Map<String, dynamic>> _escolaridades = [];
  List<Map<String, dynamic>> _ocupaciones = [];
  List<Map<String, dynamic>> _enfermedades = [];
  List<Map<String, dynamic>> _parentescos = [];
  List<Map<String, dynamic>> _consumoAlcohol = [];
  List<Map<String, dynamic>> _consumoTabaco = [];

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
    if (_idEscolaridad == null || _idOcupacion == null || _idAlcohol == null || _idTabaco == null) {
      showDemoMessage(context, 'Completa escolaridad, ocupación, alcohol y tabaco');
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
            .map((a) => {'id_parentesco': a.idParentesco, 'id_enfermedad': a.idEnfermedad})
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

  int get _completos =>
      [_idEscolaridad, _idOcupacion, _idAlcohol, _idTabaco].where((v) => v != null).length;

  @override
  Widget build(BuildContext context) {
    final nombre = widget.patient['nombre'] as String? ?? '';
    final apellido = widget.patient['apellido_paterno'] as String? ?? '';
    final codigo = widget.patient['codigo_paciente'] as String? ?? '';

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.purple)),
      );
    }

    return Scaffold(
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.paddingOf(context).bottom),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
        ),
        child: PrimaryButton(
          label: _isEdit ? 'GUARDAR CAMBIOS' : 'CREAR EXPEDIENTE',
          loading: _saving,
          onPressed: _save,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top + 16,
          left: 20,
          right: 20,
          bottom: 24,
        ),
        children: staggered([
          const Align(alignment: Alignment.centerLeft, child: CircleBackButton()),
          const SizedBox(height: 16),
          Text(_isEdit ? 'Expediente clínico' : 'Nuevo expediente',
              style: AppText.title.copyWith(fontSize: 24)),
          const SizedBox(height: 14),
          _cabecera(nombre, apellido, codigo),
          const SizedBox(height: 14),

          _Seccion(
            icon: Icons.school_outlined,
            titulo: 'Datos generales',
            children: [
              const _Etiqueta('Escolaridad'),
              _DropdownField(
                value: _idEscolaridad,
                items: _escolaridades
                    .map((e) => _DropItem(e['id'] as int, '${e['nombre']} (${e['anios'] ?? 0} años)'))
                    .toList(),
                hint: 'Selecciona escolaridad',
                onChanged: (v) => setState(() => _idEscolaridad = v),
              ),
              const SizedBox(height: 14),
              const _Etiqueta('Ocupación'),
              _DropdownField(
                value: _idOcupacion,
                items: _ocupaciones.map((e) => _DropItem(e['id'] as int, e['nombre'] as String)).toList(),
                hint: 'Selecciona ocupación',
                onChanged: (v) => setState(() => _idOcupacion = v),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _Seccion(
            icon: Icons.local_bar_outlined,
            titulo: 'Hábitos',
            children: [
              const _Etiqueta('Consumo de alcohol'),
              _opciones(_consumoAlcohol, _idAlcohol, (v) => setState(() => _idAlcohol = v)),
              const SizedBox(height: 14),
              const _Etiqueta('Consumo de tabaco'),
              _opciones(_consumoTabaco, _idTabaco, (v) => setState(() => _idTabaco = v)),
            ],
          ),
          const SizedBox(height: 14),

          _Seccion(
            icon: Icons.medical_information_outlined,
            titulo: 'Antecedentes personales',
            trailing: _Contador(_enfSeleccionadas.length),
            children: [
              Row(children: [
                const _PuntoModelo(),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Lo usa el modelo de predicción. Lo que no marques se toma como ausente.',
                    style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 11),
                  ),
                ),
              ]),
              const SizedBox(height: 6),
              ..._buildEnfermedades(),
            ],
          ),
          const SizedBox(height: 14),

          _Seccion(
            icon: Icons.family_restroom,
            titulo: 'Antecedentes familiares',
            trailing: _Contador(_antecedentes.length),
            children: [
              if (_antecedentes.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text('Sin antecedentes familiares registrados.',
                      style: AppText.subtitle.copyWith(color: AppColors.hint)),
                ),
              ..._buildAntecedentes(),
              GestureDetector(
                onTap: _addAntecedente,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.purple.withValues(alpha: 0.6)),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.add, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text('Agregar antecedente', style: AppText.label.copyWith(fontSize: 13)),
                  ]),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _cabecera(String nombre, String apellido, String codigo) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.purpleDark.withValues(alpha: 0.7),
          AppColors.purple.withValues(alpha: 0.35),
        ]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.14)),
          child: Center(
            child: Text(nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                style: AppText.title.copyWith(fontSize: 20)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$nombre $apellido', style: AppText.label.copyWith(fontSize: 15)),
            const SizedBox(height: 2),
            Text('ID: $codigo', style: AppText.subtitle.copyWith(color: Colors.white70, fontSize: 11)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('$_completos/4', style: AppText.label.copyWith(fontSize: 15)),
          Text('obligatorios', style: AppText.subtitle.copyWith(color: Colors.white70, fontSize: 10)),
        ]),
      ]),
    );
  }

  Widget _opciones(List<Map<String, dynamic>> items, int? seleccion, ValueChanged<int> onTap) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final e in items)
          _ChipSeleccion(
            texto: e['nombre'] as String,
            seleccionado: seleccion == e['id'],
            onTap: () => onTap(e['id'] as int),
          ),
      ],
    );
  }

  List<Widget> _buildEnfermedades() {
    final porCategoria = <String, List<Map<String, dynamic>>>{};
    for (final enf in _enfermedades) {
      porCategoria.putIfAbsent(enf['categoria'] as String? ?? 'General', () => []).add(enf);
    }
    return [
      for (final entry in porCategoria.entries) ...[
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Text(entry.key.toUpperCase(),
              style: AppText.label.copyWith(color: Colors.white70, fontSize: 10.5, letterSpacing: 0.8)),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final enf in entry.value)
              _ChipSeleccion(
                texto: enf['nombre'] as String? ?? '',
                seleccionado: _enfSeleccionadas.contains(enf['id']),
                usaModelo: _indicadoresModelo.contains(enf['indicador_modelo']),
                onTap: () => setState(() {
                  final id = enf['id'] as int;
                  _enfSeleccionadas.contains(id) ? _enfSeleccionadas.remove(id) : _enfSeleccionadas.add(id);
                }),
              ),
          ],
        ),
      ],
    ];
  }

  List<Widget> _buildAntecedentes() {
    return List.generate(_antecedentes.length, (i) {
      final ant = _antecedentes[i];
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(children: [
                _DropdownField(
                  value: ant.idParentesco,
                  items: _parentescos.map((e) => _DropItem(e['id'] as int, e['nombre'] as String)).toList(),
                  hint: 'Parentesco',
                  onChanged: (v) => setState(() => ant.idParentesco = v!),
                  compact: true,
                ),
                const SizedBox(height: 8),
                _DropdownField(
                  value: ant.idEnfermedad,
                  items: _enfermedades.map((e) => _DropItem(e['id'] as int, e['nombre'] as String)).toList(),
                  hint: 'Enfermedad',
                  onChanged: (v) => setState(() => ant.idEnfermedad = v!),
                  compact: true,
                ),
              ]),
            ),
            const SizedBox(width: 6),
            IconButton(
              onPressed: () => setState(() => _antecedentes.removeAt(i)),
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
              tooltip: 'Quitar antecedente',
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

class _Seccion extends StatelessWidget {
  const _Seccion({required this.icon, required this.titulo, required this.children, this.trailing});
  final IconData icon;
  final String titulo;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.field, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.gradient),
              child: Icon(icon, color: Colors.white, size: 17),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(titulo, style: AppText.label.copyWith(fontSize: 15))),
            if (trailing != null) trailing!,
          ]),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: AppText.subtitle.copyWith(color: Colors.white70, fontSize: 12)),
    );
  }
}

class _Contador extends StatelessWidget {
  const _Contador(this.n);
  final int n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: n > 0 ? AppColors.purple.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('$n', style: AppText.label.copyWith(fontSize: 12)),
    );
  }
}

class _PuntoModelo extends StatelessWidget {
  const _PuntoModelo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF59E0B)),
    );
  }
}

class _ChipSeleccion extends StatelessWidget {
  const _ChipSeleccion({
    required this.texto,
    required this.seleccionado,
    required this.onTap,
    this.usaModelo = false,
  });
  final String texto;
  final bool seleccionado;
  final bool usaModelo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          gradient: seleccionado ? AppColors.gradient : null,
          color: seleccionado ? null : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: seleccionado ? AppColors.purple : Colors.white.withValues(alpha: 0.10),
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (seleccionado) ...[
            const Icon(Icons.check, color: Colors.white, size: 14),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(texto,
                style: AppText.subtitle.copyWith(
                  fontSize: 12.5,
                  color: seleccionado ? Colors.white : Colors.white70,
                  fontWeight: seleccionado ? FontWeight.w600 : FontWeight.w400,
                )),
          ),
          if (usaModelo) ...[
            const SizedBox(width: 6),
            const _PuntoModelo(),
          ],
        ]),
      ),
    );
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
      height: compact ? 42 : 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF2A2A2A),
          hint: Text(hint, style: AppText.hint.copyWith(fontSize: compact ? 12.5 : 14)),
          style: AppText.input.copyWith(fontSize: compact ? 12.5 : 14),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.hint, size: 20),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item.id,
                    child: Text(item.label, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
