import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/entrance.dart';

const _impresiones = [
  ('Normal', 'Cognición normal', Color(0xFF10B981)),
  ('DCL', 'Deterioro cognitivo leve', Color(0xFFF59E0B)),
  ('Alzheimer', 'Demencia tipo Alzheimer', Color(0xFFEF4444)),
  ('Vascular', 'Deterioro de origen vascular', Color(0xFF3B82F6)),
];

const _motivos = ['Primera valoración', 'Seguimiento', 'Queja de memoria', 'Referido por familiar', 'Cambio de conducta'];

const _acciones = {
  'Estudios': ['Laboratorios (B12, TSH, glucosa)', 'Neuroimagen (TAC o RM)', 'Valoración neuropsicológica completa'],
  'Referencias': ['Neurología', 'Psiquiatría', 'Geriatría'],
  'Intervención': [
    'Control de factores vasculares',
    'Valorar y tratar depresión',
    'Estimulación cognitiva',
    'Orientación a familia o cuidador',
  ],
};

const _plazos = [('3 meses', 91), ('6 meses', 182), ('12 meses', 365)];

String _dmy(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// Pantalla para registrar la impresión del especialista, sus observaciones y el plan de seguimiento.
/// Devuelve por `Navigator.pop` el cuerpo listo para enviar al backend.
class NotaClinicaScreen extends StatefulWidget {
  const NotaClinicaScreen({
    super.key,
    required this.paciente,
    this.idMoca,
    this.etiquetaEvaluacion,
    this.puntajeTotal,
    this.claseModelo,
    this.impresionActual,
  });

  final String paciente;
  final int? idMoca;
  final String? etiquetaEvaluacion;
  final int? puntajeTotal;
  final String? claseModelo;
  final String? impresionActual;

  @override
  State<NotaClinicaScreen> createState() => _NotaClinicaScreenState();
}

class _NotaClinicaScreenState extends State<NotaClinicaScreen> {
  final _notaCtrl = TextEditingController();
  final _otrasCtrl = TextEditingController();
  late String? _impresion = widget.impresionActual;
  String? _motivo;
  final _elegidas = <String>{};
  int? _plazoDias;
  DateTime? _seguimiento;

  @override
  void dispose() {
    _notaCtrl.dispose();
    _otrasCtrl.dispose();
    super.dispose();
  }

  bool get _hayCambios =>
      _notaCtrl.text.trim().isNotEmpty ||
      _otrasCtrl.text.trim().isNotEmpty ||
      _elegidas.isNotEmpty ||
      _motivo != null ||
      _seguimiento != null ||
      _impresion != widget.impresionActual;

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _seguimiento ?? hoy.add(const Duration(days: 182)),
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: 365 * 5)),
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.purple, surface: Color(0xFF1A1A1A)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _seguimiento = picked;
        _plazoDias = null;
      });
    }
  }

  void _guardar() {
    final partes = <String>[
      if (_motivo != null) 'Motivo: $_motivo.',
      if (_notaCtrl.text.trim().isNotEmpty) _notaCtrl.text.trim(),
    ];
    if (partes.isEmpty && _impresion != null) partes.add('Impresión diagnóstica: $_impresion.');
    if (partes.isEmpty) {
      showDemoMessage(context, 'Elija una impresión o escriba sus observaciones');
      return;
    }
    final plan = <String>[
      if (_plazoDias != null) 'Repetir MoCA en ${_plazos.firstWhere((p) => p.$2 == _plazoDias).$1}',
      ..._elegidas,
      if (_otrasCtrl.text.trim().isNotEmpty) _otrasCtrl.text.trim(),
    ];
    final s = _seguimiento;
    Navigator.of(context).pop(<String, dynamic>{
      'nota': partes.join(' '),
      if (plan.isNotEmpty) 'plan': plan.join('\n'),
      if (widget.idMoca != null) 'id_moca': widget.idMoca,
      if (widget.idMoca != null && _impresion != null) 'impresion_diagnostica': _impresion,
      if (s != null)
        'fecha_seguimiento':
            '${s.year}-${s.month.toString().padLeft(2, '0')}-${s.day.toString().padLeft(2, '0')}',
    });
  }

  Future<void> _salir() async {
    if (!_hayCambios) {
      Navigator.of(context).pop();
      return;
    }
    final descartar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('¿Descartar la nota?', style: AppText.title.copyWith(fontSize: 18)),
        content: Text('Lo que escribió no se guardará.',
            style: AppText.subtitle.copyWith(color: Colors.white70, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Seguir editando', style: AppText.label.copyWith(color: AppColors.hint)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Descartar', style: AppText.label.copyWith(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (descartar == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _salir();
      },
      child: Scaffold(
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.paddingOf(context).bottom),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
          ),
          child: PrimaryButton(label: 'GUARDAR NOTA', onPressed: _guardar),
        ),
        body: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top + 16,
            left: 20,
            right: 20,
            bottom: 24,
          ),
          children: staggered([
            Align(alignment: Alignment.centerLeft, child: CircleBackButton(onPressed: _salir)),
            const SizedBox(height: 16),
            Text('Nota clínica', style: AppText.title.copyWith(fontSize: 24)),
            const SizedBox(height: 6),
            Text(widget.paciente, style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 12)),
            const SizedBox(height: 16),
            if (widget.idMoca != null) ...[
              _contexto(),
              const SizedBox(height: 14),
              _Seccion(
                numero: 1,
                titulo: 'Su impresión diagnóstica',
                ayuda: 'Queda registrada para esta evaluación. Con DCL se calcula la progresión.',
                child: Column(children: [
                  for (final (clave, nombre, color) in _impresiones) ...[
                    _opcionImpresion(clave, nombre, color),
                    const SizedBox(height: 8),
                  ],
                  _opcionImpresion(null, 'Aún sin definir', AppColors.hint),
                ]),
              ),
              const SizedBox(height: 14),
            ],
            _Seccion(
              numero: widget.idMoca != null ? 2 : 1,
              titulo: 'Observaciones',
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Motivo de la consulta', style: AppText.subtitle.copyWith(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  for (final m in _motivos)
                    _Chip(
                      texto: m,
                      activo: _motivo == m,
                      onTap: () => setState(() => _motivo = _motivo == m ? null : m),
                    ),
                ]),
                const SizedBox(height: 14),
                _area(_notaCtrl, 'Hallazgos, conducta durante la prueba, lo que refiere el paciente o su familia…', 4),
              ]),
            ),
            const SizedBox(height: 14),
            _Seccion(
              numero: widget.idMoca != null ? 3 : 2,
              titulo: 'Plan',
              trailing: _elegidas.isEmpty
                  ? null
                  : Text('${_elegidas.length}', style: AppText.label.copyWith(color: AppColors.purple)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (final grupo in _acciones.entries) ...[
                  Text(grupo.key.toUpperCase(),
                      style: AppText.label.copyWith(color: Colors.white60, fontSize: 10.5, letterSpacing: 0.8)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 6, runSpacing: 6, children: [
                    for (final a in grupo.value)
                      _Chip(
                        texto: a,
                        activo: _elegidas.contains(a),
                        onTap: () => setState(() => _elegidas.contains(a) ? _elegidas.remove(a) : _elegidas.add(a)),
                      ),
                  ]),
                  const SizedBox(height: 14),
                ],
                _area(_otrasCtrl, 'Otras indicaciones…', 2),
              ]),
            ),
            const SizedBox(height: 14),
            _Seccion(
              numero: widget.idMoca != null ? 4 : 3,
              titulo: 'Próxima MoCA',
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  for (final (texto, dias) in _plazos) ...[
                    Expanded(
                      child: _Chip(
                        texto: texto,
                        activo: _plazoDias == dias,
                        centrado: true,
                        onTap: () => setState(() {
                          if (_plazoDias == dias) {
                            _plazoDias = null;
                            _seguimiento = null;
                          } else {
                            _plazoDias = dias;
                            _seguimiento = DateTime.now().add(Duration(days: dias));
                          }
                        }),
                      ),
                    ),
                    if (dias != _plazos.last.$2) const SizedBox(width: 8),
                  ],
                ]),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _elegirFecha,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.event, color: AppColors.purple, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _seguimiento == null ? 'Elegir otra fecha' : 'Seguimiento el ${_dmy(_seguimiento!)}',
                          style: _seguimiento == null ? AppText.hint : AppText.input,
                        ),
                      ),
                      if (_seguimiento != null)
                        GestureDetector(
                          onTap: () => setState(() {
                            _seguimiento = null;
                            _plazoDias = null;
                          }),
                          child: const Icon(Icons.close, color: AppColors.hint, size: 18),
                        ),
                    ]),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _contexto() {
    final clase = widget.claseModelo;
    final color = _impresiones.where((i) => i.$1 == clase).map((i) => i.$3).firstOrNull ?? AppColors.hint;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.purpleDark.withValues(alpha: 0.7),
          AppColors.purple.withValues(alpha: 0.30),
        ]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.etiquetaEvaluacion ?? '', style: AppText.label.copyWith(fontSize: 13)),
            if (clase != null) ...[
              const SizedBox(height: 6),
              Row(children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
                const SizedBox(width: 6),
                Text('El modelo sugiere $clase',
                    style: AppText.subtitle.copyWith(color: Colors.white70, fontSize: 11.5)),
              ]),
            ],
          ]),
        ),
        if (widget.puntajeTotal != null)
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${widget.puntajeTotal}/30', style: AppText.title.copyWith(fontSize: 20)),
            Text('MoCA', style: AppText.subtitle.copyWith(color: Colors.white70, fontSize: 10)),
          ]),
      ]),
    );
  }

  Widget _opcionImpresion(String? clave, String nombre, Color color) {
    final sel = _impresion == clave;
    return GestureDetector(
      onTap: () => setState(() => _impresion = clave),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: sel ? color.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sel ? color : Colors.white.withValues(alpha: 0.08), width: sel ? 1.5 : 1),
        ),
        child: Row(children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          const SizedBox(width: 12),
          Expanded(child: Text(nombre, style: AppText.label.copyWith(fontSize: 13.5))),
          if (clave != null && clave == widget.claseModelo)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text('modelo', style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 10.5)),
            ),
          Icon(sel ? Icons.radio_button_checked : Icons.radio_button_off,
              color: sel ? color : Colors.white24, size: 20),
        ]),
      ),
    );
  }

  Widget _area(TextEditingController ctrl, String hint, int lineas) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: TextField(
        controller: ctrl,
        minLines: lineas,
        maxLines: lineas + 4,
        maxLength: 1500,
        textCapitalization: TextCapitalization.sentences,
        style: AppText.input.copyWith(fontSize: 13.5, height: 1.45),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppText.hint.copyWith(fontSize: 13),
          border: InputBorder.none,
          isCollapsed: true,
          counterText: '',
        ),
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({required this.numero, required this.titulo, required this.child, this.ayuda, this.trailing});
  final int numero;
  final String titulo;
  final String? ayuda;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.field, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.gradient),
            child: Center(child: Text('$numero', style: AppText.label.copyWith(fontSize: 12))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(titulo, style: AppText.label.copyWith(fontSize: 15))),
          if (trailing != null) trailing!,
        ]),
        if (ayuda != null) ...[
          const SizedBox(height: 8),
          Text(ayuda!, style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 11, height: 1.4)),
        ],
        const SizedBox(height: 14),
        child,
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.texto, required this.activo, required this.onTap, this.centrado = false});
  final String texto;
  final bool activo;
  final bool centrado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        alignment: centrado ? Alignment.center : null,
        decoration: BoxDecoration(
          gradient: activo ? AppColors.gradient : null,
          color: activo ? null : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: activo ? AppColors.purple : Colors.white.withValues(alpha: 0.10)),
        ),
        child: Text(texto,
            style: AppText.subtitle.copyWith(
              fontSize: 12,
              color: activo ? Colors.white : Colors.white70,
              fontWeight: activo ? FontWeight.w600 : FontWeight.w400,
            )),
      ),
    );
  }
}
