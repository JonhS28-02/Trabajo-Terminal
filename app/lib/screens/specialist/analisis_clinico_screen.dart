import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/entrance.dart';
import 'nota_clinica_screen.dart';

const _clases = ['Normal', 'DCL', 'Alzheimer', 'Vascular'];

const _verde = Color(0xFF10B981);
const _ambar = Color(0xFFF59E0B);
const _rojo = Color(0xFFEF4444);
const _azul = Color(0xFF3B82F6);

const _colorClase = {'Normal': _verde, 'DCL': _ambar, 'Alzheimer': _rojo, 'Vascular': _azul};

const _nombreLargo = {
  'Normal': 'Cognición normal',
  'DCL': 'Deterioro cognitivo leve',
  'Alzheimer': 'Demencia tipo Alzheimer',
  'Vascular': 'Deterioro de origen vascular',
};

const _dominioCorto = {
  'D_visuoejecutiva': 'Visuoesp.',
  'D_denominacion': 'Identif.',
  'D_atencion': 'Atención',
  'D_lenguaje': 'Lenguaje',
  'D_abstraccion': 'Abstrac.',
  'D_recuerdo_diferido': 'Recuerdo',
  'D_orientacion': 'Orient.',
};

String _pct(num p) {
  final v = p * 100;
  if (v > 0 && v < 1) return '<1%';
  return '${v.round()}%';
}

String _fecha(String? iso) {
  final d = DateTime.tryParse(iso ?? '');
  if (d == null) return '';
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

String _fechaCorta(String? iso) {
  final d = DateTime.tryParse(iso ?? '');
  if (d == null) return '';
  return '${d.day}/${d.month}/${d.year % 100}';
}

String _signo(int v) => v > 0 ? '+$v' : (v == 0 ? '0' : '−${v.abs()}');

/// Resumen visual del modelo, perfil cognitivo, evolución y notas clínicas de un paciente.
class AnalisisClinicoScreen extends StatefulWidget {
  const AnalisisClinicoScreen({super.key, required this.patient});
  final Map<String, dynamic> patient;

  @override
  State<AnalisisClinicoScreen> createState() => _AnalisisClinicoScreenState();
}

class _AnalisisClinicoScreenState extends State<AnalisisClinicoScreen> {
  Map<String, dynamic>? _data;
  List<Map<String, dynamic>> _notas = [];
  bool _loading = true;
  String? _error;
  int _sel = 0;

  int get _idPaciente => widget.patient['id_paciente'] as int;

  List<Map<String, dynamic>> get _evals =>
      ((_data?['evaluaciones'] as List<dynamic>?) ?? []).cast<Map<String, dynamic>>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool keepSelection = false}) async {
    try {
      final token = await SessionService.getToken();
      if (token == null) return;
      final res = await Future.wait([
        ApiService.analisisPaciente(_idPaciente, token),
        ApiService.listarNotas(_idPaciente, token),
      ]);
      if (!mounted) return;
      setState(() {
        _data = res[0] as Map<String, dynamic>;
        _notas = (res[1] as List<dynamic>).cast<Map<String, dynamic>>();
        _loading = false;
        _error = null;
        if (!keepSelection || _sel >= _evals.length) {
          _sel = _evals.lastIndexWhere((e) => e['prediccion'] != null);
          if (_sel < 0) _sel = math.max(0, _evals.length - 1);
        }
      });
    } on ApiException catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.message; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = 'Error de conexión'; });
    }
  }

  List<Map<String, dynamic>> _dominios(Map<String, dynamic> e) =>
      (e['dominios'] as List<dynamic>).cast<Map<String, dynamic>>();

  bool _completa(Map<String, dynamic> e) => _dominios(e).every((d) => d['puntaje'] != null);

  Map<String, dynamic>? get _anterior {
    for (int i = _sel - 1; i >= 0; i--) {
      if (_completa(_evals[i])) return _evals[i];
    }
    return null;
  }

  Future<void> _nuevaNota() async {
    final eval = _evals.isEmpty ? null : _evals[_sel];
    final pred = eval?['prediccion'] as Map<String, dynamic>?;
    final body = await Navigator.of(context).push<Map<String, dynamic>>(
      slideUpRoute(NotaClinicaScreen(
        paciente: (_data!['paciente'] as Map<String, dynamic>)['nombre'] as String,
        idMoca: eval?['id_moca'] as int?,
        etiquetaEvaluacion: eval == null ? null : 'Evaluación #${_sel + 1} · ${_fecha(eval['fecha'] as String?)}',
        puntajeTotal: eval?['puntaje_total'] as int?,
        claseModelo: pred?['clase_predicha'] as String?,
        impresionActual: eval?['impresion_diagnostica'] as String?,
      )),
    );
    if (body == null || !mounted) return;
    try {
      final token = await SessionService.getToken();
      if (token == null) return;
      await ApiService.crearNota(_idPaciente, body, token);
      await _load(keepSelection: true);
      if (mounted) showDemoMessage(context, 'Nota guardada');
    } on ApiException catch (e) {
      if (mounted) showDemoMessage(context, e.message);
    } catch (_) {
      if (mounted) showDemoMessage(context, 'Error de conexión');
    }
  }

  void _verAlcances() {
    final avisos = [
      ...((_data?['avisos_paciente'] as List<dynamic>?) ?? []).cast<String>(),
      ...((_data?['avisos'] as List<dynamic>?) ?? []).cast<String>(),
      'Los antecedentes que no están marcados en el expediente se toman como ausentes.',
    ];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Text('Sobre estas estimaciones', style: AppText.title.copyWith(fontSize: 18)),
            const SizedBox(height: 14),
            for (final a in avisos)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(Icons.circle, size: 5, color: AppColors.hint),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(a, style: AppText.subtitle.copyWith(color: Colors.white70, fontSize: 12.5, height: 1.5)),
                  ),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _loading || _error != null
          ? null
          : FloatingActionButton.extended(
              onPressed: _nuevaNota,
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.edit_note),
              label: Text('Nueva nota', style: AppText.label.copyWith(fontSize: 13)),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.purple))
          : RefreshIndicator(
              color: AppColors.purple,
              onRefresh: () => _load(keepSelection: true),
              child: ListView(
                padding: EdgeInsets.only(
                  top: MediaQuery.paddingOf(context).top + 16,
                  left: 20,
                  right: 20,
                  bottom: 96 + MediaQuery.paddingOf(context).bottom,
                ),
                children: staggered(_error != null ? _errorBody() : _body()),
              ),
            ),
    );
  }

  List<Widget> _errorBody() => [
        const Align(alignment: Alignment.centerLeft, child: CircleBackButton()),
        const SizedBox(height: 80),
        const Icon(Icons.cloud_off, color: AppColors.hint, size: 56),
        const SizedBox(height: 16),
        Text(_error!, textAlign: TextAlign.center, style: AppText.subtitle.copyWith(fontSize: 13)),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'REINTENTAR',
          onPressed: () {
            setState(() => _loading = true);
            _load();
          },
        ),
      ];

  List<Widget> _body() {
    final pac = _data!['paciente'] as Map<String, dynamic>;
    final esc = pac['escolaridad_anios'];
    final eval = _evals.isEmpty ? null : _evals[_sel];
    final pred = eval?['prediccion'] as Map<String, dynamic>?;

    return [
      Row(children: [
        const CircleBackButton(),
        const Spacer(),
        IconButton(
          onPressed: _verAlcances,
          tooltip: 'Sobre estas estimaciones',
          icon: const Icon(Icons.info_outline, color: Colors.white70),
        ),
      ]),
      const SizedBox(height: 12),
      Text('Análisis clínico', style: AppText.title.copyWith(fontSize: 24)),
      const SizedBox(height: 6),
      Text(
        '${pac['nombre']} · ${(pac['edad'] as num).round()} años · ${pac['sexo']}'
        '${esc != null ? ' · $esc años de escolaridad' : ''}',
        style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 12),
      ),
      const SizedBox(height: 16),
      if (eval == null)
        _vacio()
      else ...[
        if (_evals.length > 1) ...[
          _selector(),
          const SizedBox(height: 14),
        ],
        // La clave reinicia las animaciones de las gráficas al cambiar de evaluación.
        KeyedSubtree(key: ValueKey('resumen-$_sel'), child: _cardResumen(eval, pred)),
        const SizedBox(height: 14),
        KeyedSubtree(key: ValueKey('perfil-$_sel'), child: _cardPerfil(eval)),
        if (_evals.where((e) => e['puntaje_total'] != null).length > 1) ...[
          const SizedBox(height: 14),
          _cardEvolucion(),
        ],
        if (pred != null) ...[
          const SizedBox(height: 14),
          KeyedSubtree(key: ValueKey('prog-$_sel'), child: _cardProgresion(eval, pred)),
          const SizedBox(height: 14),
          KeyedSubtree(key: ValueKey('fact-$_sel'), child: _cardFactores(pred)),
        ],
        const SizedBox(height: 14),
        _cardAntecedentes(),
      ],
      const SizedBox(height: 14),
      _cardNotas(),
    ];
  }

  Widget _vacio() => _Card(
        icon: Icons.assessment_outlined,
        titulo: 'Sin evaluaciones completadas',
        child: Text(
          'Cuando el paciente termine una prueba MoCA, aquí aparecerá el resumen. Mientras tanto puede registrar notas.',
          style: AppText.subtitle.copyWith(color: AppColors.hint, height: 1.5),
        ),
      );

  Widget _selector() {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _evals.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final e = _evals[i];
          final sel = i == _sel;
          final clase = (e['prediccion'] as Map<String, dynamic>?)?['clase_predicha'] as String?;
          return GestureDetector(
            onTap: () => setState(() => _sel = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? AppColors.purpleDark.withValues(alpha: 0.6) : AppColors.field,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: sel ? AppColors.purple : Colors.transparent, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(children: [
                    Text('#${i + 1} · ${e['puntaje_total'] ?? '–'}/30',
                        style: AppText.label.copyWith(fontSize: 13)),
                    if (clase != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: _colorClase[clase]),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 2),
                  Text(_fecha(e['fecha'] as String?),
                      style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 10)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Resumen ──

  List<_Hallazgo> _hallazgos(Map<String, dynamic> eval, Map<String, dynamic>? pred) {
    final out = <_Hallazgo>[];
    final doms = _dominios(eval).where((d) => d['puntaje'] != null).toList();

    final bajos = doms.where((d) => (d['puntaje'] as int) / (d['maximo'] as int) <= 0.5).toList()
      ..sort((a, b) => ((a['puntaje'] as int) / (a['maximo'] as int))
          .compareTo((b['puntaje'] as int) / (b['maximo'] as int)));
    if (bajos.isNotEmpty) {
      out.add(_Hallazgo(
        Icons.south_east,
        _rojo,
        'Más afectados: ${bajos.take(3).map((d) => '${d['etiqueta']} ${d['puntaje']}/${d['maximo']}').join(' · ')}',
      ));
    } else if (doms.isNotEmpty) {
      out.add(const _Hallazgo(Icons.check_circle_outline, _verde, 'Ningún dominio por debajo de la mitad de su puntaje'));
    }

    final ant = _anterior;
    if (ant != null && eval['puntaje_total'] != null && ant['puntaje_total'] != null) {
      final cambio = (eval['puntaje_total'] as int) - (ant['puntaje_total'] as int);
      final previo = {for (final d in _dominios(ant)) d['clave']: d['puntaje'] as int?};
      Map<String, dynamic>? peor;
      var caida = 0;
      for (final d in doms) {
        final p = previo[d['clave']];
        if (p != null && (d['puntaje'] as int) - p < caida) {
          caida = (d['puntaje'] as int) - p;
          peor = d;
        }
      }
      out.add(_Hallazgo(
        cambio < 0 ? Icons.trending_down : (cambio > 0 ? Icons.trending_up : Icons.trending_flat),
        cambio < 0 ? _rojo : (cambio > 0 ? _verde : AppColors.hint),
        cambio == 0
            ? 'Sin cambio en el total desde el ${_fecha(ant['fecha'] as String?)}'
            : 'Total ${_signo(cambio)} desde el ${_fecha(ant['fecha'] as String?)}'
                '${peor != null ? '; mayor caída en ${peor['etiqueta']} (${_signo(caida)})' : ''}',
      ));
    }

    if (pred != null) {
      final prog = pred['progresion'] as Map<String, dynamic>;
      if (prog['aplica'] == true) {
        final alerta = prog['alerta'] == true;
        out.add(_Hallazgo(
          Icons.speed,
          alerta ? _rojo : _verde,
          'Progresión a Alzheimer ${_pct(prog['probabilidad'] as num)}: '
              '${alerta ? 'sobre' : 'bajo'} el umbral de alerta',
        ));
      }
      final base = pred['base'] as Map<String, dynamic>?;
      if (base != null && base['clase_predicha'] != pred['clase_predicha']) {
        out.add(_Hallazgo(Icons.compare_arrows, _ambar,
            'Sin antecedentes, el modelo apunta a ${_nombreLargo[base['clase_predicha']]}'));
      }
    }
    return out;
  }

  Widget _cardResumen(Map<String, dynamic> eval, Map<String, dynamic>? pred) {
    final total = eval['puntaje_total'] as int?;
    final ant = _anterior;
    final delta = (total != null && ant?['puntaje_total'] != null) ? total - (ant!['puntaje_total'] as int) : null;
    final hallazgos = _hallazgos(eval, pred);

    if (pred == null) {
      return _Card(
        icon: Icons.summarize_outlined,
        titulo: 'Resumen',
        trailing: Text('${total ?? '–'}/30', style: AppText.label.copyWith(fontSize: 15)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Sin estimación para esta evaluación. ${eval['motivo_sin_prediccion'] ?? ''}',
              style: AppText.subtitle.copyWith(color: _ambar, height: 1.5)),
          for (final h in hallazgos) ...[const SizedBox(height: 10), h],
        ]),
      );
    }

    final clase = pred['clase_predicha'] as String;
    final probs = pred['probabilidades'] as Map<String, dynamic>;
    final conf = pred['confianza'] as Map<String, dynamic>;
    final color = _colorClase[clase]!;
    final p = (probs[clase] as num).toDouble();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.20), AppColors.field, AppColors.field],
          stops: const [0, 0.55, 1],
        ),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: p),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => SizedBox(
                  width: 108,
                  height: 108,
                  child: CustomPaint(
                    painter: _RingPainter(v, color),
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('${(v * 100).round()}%', style: AppText.title.copyWith(fontSize: 26, color: color)),
                        Text('probabilidad', style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 9.5)),
                      ]),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('El modelo sugiere', style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 11)),
                  const SizedBox(height: 3),
                  Text(_nombreLargo[clase]!, style: AppText.title.copyWith(fontSize: 19, color: color, height: 1.15)),
                  const SizedBox(height: 10),
                  _Confianza(nivel: conf['nivel'] as String, motivo: conf['motivo'] as String),
                  const SizedBox(height: 10),
                  Row(children: [
                    Text('MoCA ', style: AppText.subtitle.copyWith(color: Colors.white70, fontSize: 12)),
                    Text('${total ?? '–'}/30', style: AppText.label.copyWith(fontSize: 15)),
                    if (delta != null) ...[
                      const SizedBox(width: 8),
                      _Delta(delta),
                    ],
                  ]),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (_, t, __) => ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 12,
                child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  for (final c in _clases)
                    Expanded(
                      flex: math.max(1, ((probs[c] as num) * 1000 * t).round()),
                      child: ColoredBox(color: _colorClase[c]!),
                    ),
                  if (t < 1)
                    Expanded(
                      flex: math.max(1, (1000 * (1 - t)).round()),
                      child: ColoredBox(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final c in _clases)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: _colorClase[c])),
                  const SizedBox(width: 4),
                  Text('$c ${_pct(probs[c] as num)}',
                      style: AppText.subtitle.copyWith(
                        fontSize: 10.5,
                        color: c == clase ? Colors.white : Colors.white60,
                        fontWeight: c == clase ? FontWeight.w700 : FontWeight.w400,
                      )),
                ]),
            ],
          ),
          if (hallazgos.isNotEmpty) ...[
            Divider(color: Colors.white.withValues(alpha: 0.08), height: 28),
            for (int i = 0; i < hallazgos.length; i++) ...[
              if (i > 0) const SizedBox(height: 9),
              hallazgos[i],
            ],
          ],
        ],
      ),
    );
  }

  // ── Perfil cognitivo ──

  Widget _cardPerfil(Map<String, dynamic> eval) {
    final doms = _dominios(eval);
    final ant = _anterior;
    final previo = {
      for (final d in (ant == null ? <Map<String, dynamic>>[] : _dominios(ant))) d['clave'] as String: d['puntaje'] as int?,
    };
    final actual = [for (final d in doms) d['puntaje'] == null ? 0.0 : (d['puntaje'] as int) / (d['maximo'] as int)];
    final anterior = ant == null
        ? null
        : [for (final d in doms) previo[d['clave']] == null ? 0.0 : previo[d['clave']]! / (d['maximo'] as int)];

    return _Card(
      icon: Icons.radar,
      titulo: 'Perfil cognitivo',
      trailing: ant == null
          ? null
          : Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 14, height: 2, color: Colors.white38),
              const SizedBox(width: 5),
              Text('anterior', style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 10.5)),
            ]),
      child: Column(children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (_, t, __) => SizedBox(
            height: 230,
            width: double.infinity,
            child: CustomPaint(
              painter: _RadarPainter(
                actual: actual,
                anterior: anterior,
                etiquetas: [for (final d in doms) _dominioCorto[d['clave']] ?? d['etiqueta'] as String],
                t: t,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final d in doms) _chipDominio(d, previo[d['clave']])],
        ),
      ]),
    );
  }

  Widget _chipDominio(Map<String, dynamic> d, int? previo) {
    final p = d['puntaje'] as int?;
    final mx = d['maximo'] as int;
    final frac = p == null ? 0.0 : p / mx;
    final color = p == null ? AppColors.hint : (frac >= 0.8 ? _verde : (frac > 0.5 ? _ambar : _rojo));
    final delta = (p != null && previo != null) ? p - previo : null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(_dominioCorto[d['clave']] ?? d['etiqueta'] as String,
            style: AppText.subtitle.copyWith(fontSize: 11.5, color: Colors.white70)),
        const SizedBox(width: 6),
        Text(p == null ? '–' : '$p/$mx', style: AppText.label.copyWith(fontSize: 12)),
        if (delta != null && delta != 0) ...[
          const SizedBox(width: 5),
          Text(delta > 0 ? '▲$delta' : '▼${delta.abs()}',
              style: AppText.label.copyWith(fontSize: 10.5, color: delta > 0 ? _verde : _rojo)),
        ],
      ]),
    );
  }

  // ── Evolución ──

  Widget _cardEvolucion() {
    final idx = [for (int i = 0; i < _evals.length; i++) if (_evals[i]['puntaje_total'] != null) i];
    final totales = [for (final i in idx) (_evals[i]['puntaje_total'] as int).toDouble()];
    final colores = [
      for (final i in idx)
        _colorClase[(_evals[i]['prediccion'] as Map<String, dynamic>?)?['clase_predicha']] ?? Colors.white54,
    ];
    final fechas = [for (final i in idx) _fechaCorta(_evals[i]['fecha'] as String?)];
    final cambio = (totales.last - totales.first).round();
    final dias = DateTime.parse(_evals[idx.last]['fecha'] as String)
        .difference(DateTime.parse(_evals[idx.first]['fecha'] as String))
        .inDays;

    return _Card(
      icon: Icons.show_chart,
      titulo: 'Evolución',
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        _Delta(cambio),
        const SizedBox(width: 6),
        Text(dias == 0 ? 'mismo día' : 'en $dias días',
            style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 10.5)),
      ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        LayoutBuilder(builder: (context, c) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (d) {
              final n = totales.length;
              final x = (d.localPosition.dx - _TrendPainter.padIzq) / (c.maxWidth - _TrendPainter.padIzq - _TrendPainter.padDer);
              final k = (x * (n - 1)).round().clamp(0, n - 1);
              setState(() => _sel = idx[k]);
            },
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, t, __) => SizedBox(
                height: 170,
                width: double.infinity,
                child: CustomPaint(
                  painter: _TrendPainter(
                    totales: totales,
                    colores: colores,
                    fechas: fechas,
                    seleccionado: idx.indexOf(_sel),
                    t: t,
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 6),
        Text('El color de cada punto es la clase que sugiere el modelo. Toque un punto para ver esa evaluación.',
            style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 10.5, height: 1.4)),
      ]),
    );
  }

  // ── Progresión ──

  Widget _cardProgresion(Map<String, dynamic> eval, Map<String, dynamic> pred) {
    final prog = pred['progresion'] as Map<String, dynamic>;
    if (prog['aplica'] != true) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: AppColors.field, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          const Icon(Icons.speed, color: AppColors.hint, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Progresión a Alzheimer: se calcula solo en DCL. Registre DCL como impresión en una nota para verla.',
              style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 11.5, height: 1.4),
            ),
          ),
        ]),
      );
    }

    final p = (prog['probabilidad'] as num).toDouble();
    final umbral = (prog['umbral'] as num).toDouble();
    final tasa = (prog['tasa_base'] as num).toDouble();
    final alerta = prog['alerta'] == true;
    final conocida = prog['origen_clase'] == 'conocida';
    final color = alerta ? _rojo : _verde;
    final escala = math.max(0.5, p * 1.15);

    return _Card(
      icon: Icons.speed,
      titulo: 'Progresión a Alzheimer',
      trailing: _Pill(texto: alerta ? 'Priorizar seguimiento' : 'Sin alerta', color: color),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: p),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) =>
                Text('${(v * 100).round()}%', style: AppText.title.copyWith(fontSize: 32, color: color)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('de que la siguiente visita sea Alzheimer',
                  style: AppText.subtitle.copyWith(color: Colors.white70, fontSize: 11.5)),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: p),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => SizedBox(
            height: 46,
            width: double.infinity,
            child: CustomPaint(painter: _GaugePainter(valor: v, umbral: umbral, tasa: tasa, escala: escala)),
          ),
        ),
        const SizedBox(height: 4),
        Row(children: [
          Icon(conocida ? Icons.verified_outlined : Icons.auto_awesome, size: 14, color: AppColors.hint),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              conocida ? 'Con su impresión diagnóstica de DCL' : 'Con la clase del modelo; registre su impresión para afinarla',
              style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 11),
            ),
          ),
        ]),
      ]),
    );
  }

  // ── Factores ──

  Widget _cardFactores(Map<String, dynamic> pred) {
    final clase = pred['clase_predicha'] as String;
    final factores = (pred['factores'] as List<dynamic>).cast<Map<String, dynamic>>();
    final maximo = factores.fold<double>(0.001, (m, f) => math.max(m, (f['aporte'] as num).abs().toDouble()));
    final color = _colorClase[clase]!;

    return _Card(
      icon: Icons.insights,
      titulo: 'Qué pesó más',
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('en contra', style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 10)),
        const SizedBox(width: 6),
        const Icon(Icons.swap_horiz, size: 14, color: AppColors.hint),
        const SizedBox(width: 6),
        Text('a favor', style: AppText.subtitle.copyWith(color: color, fontSize: 10)),
      ]),
      child: Column(children: [
        for (final f in factores)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Expanded(
                flex: 6,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(f['etiqueta'] as String,
                      style: AppText.subtitle.copyWith(fontSize: 12), overflow: TextOverflow.ellipsis),
                  Text(f['valor'] as String, style: AppText.label.copyWith(fontSize: 12)),
                ]),
              ),
              Expanded(
                flex: 7,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: (f['aporte'] as num).toDouble() / maximo),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => SizedBox(
                    height: 14,
                    child: CustomPaint(painter: _DivergingPainter(v, color)),
                  ),
                ),
              ),
            ]),
          ),
      ]),
    );
  }

  // ── Antecedentes ──

  Widget _cardAntecedentes() {
    final ants = (_data!['antecedentes'] as List<dynamic>?)?.cast<Map<String, dynamic>>();
    final si = (ants ?? []).where((a) => a['presente'] == true).toList();
    return _Card(
      icon: Icons.assignment_outlined,
      titulo: 'Antecedentes considerados',
      trailing: ants == null ? null : Text('${si.length}/11', style: AppText.label.copyWith(color: AppColors.hint)),
      child: ants == null
          ? Text('Sin expediente: el modelo usó solo la MoCA, edad, sexo y escolaridad.',
              style: AppText.subtitle.copyWith(color: AppColors.hint, height: 1.5))
          : si.isEmpty
              ? Text('Ninguno marcado en el expediente.', style: AppText.subtitle.copyWith(color: AppColors.hint))
              : Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [for (final a in si) _Pill(texto: a['etiqueta'] as String, color: AppColors.purple)],
                ),
    );
  }

  // ── Notas ──

  Widget _cardNotas() {
    final idAIndice = {for (int i = 0; i < _evals.length; i++) _evals[i]['id_moca'] as int: i + 1};
    return _Card(
      icon: Icons.edit_note,
      titulo: 'Notas clínicas y plan',
      trailing: Text('${_notas.length}', style: AppText.label.copyWith(color: AppColors.hint)),
      child: _notas.isEmpty
          ? Text('Aún no hay notas. Registre su impresión, las acciones a tomar y la fecha de seguimiento.',
              style: AppText.subtitle.copyWith(color: AppColors.hint, height: 1.5))
          : Column(
              children: [
                for (int i = 0; i < _notas.length; i++) ...[
                  if (i > 0) Divider(color: Colors.white.withValues(alpha: 0.08), height: 22),
                  _nota(_notas[i], idAIndice),
                ],
              ],
            ),
    );
  }

  Widget _nota(Map<String, dynamic> n, Map<int, int> idAIndice) {
    final dx = n['impresion_diagnostica'] as String?;
    final idMoca = n['id_moca'] as int?;
    final plan = n['plan'] as String?;
    final seg = n['fecha_seguimiento'] as String?;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(_fecha(n['created_at'] as String?), style: AppText.label.copyWith(fontSize: 12)),
          if (idMoca != null && idAIndice[idMoca] != null) ...[
            const SizedBox(width: 8),
            Text('Evaluación #${idAIndice[idMoca]}',
                style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 11)),
          ],
          const Spacer(),
          if (dx != null) _Pill(texto: dx, color: _colorClase[dx] ?? AppColors.purple),
        ]),
        const SizedBox(height: 6),
        Text(n['nota'] as String, style: AppText.subtitle.copyWith(fontSize: 12.5, height: 1.5)),
        if (plan != null && plan.isNotEmpty) ...[
          const SizedBox(height: 6),
          _Linea(icon: Icons.checklist, color: Colors.white70, texto: plan),
        ],
        if (seg != null) ...[
          const SizedBox(height: 6),
          _Linea(icon: Icons.event, color: AppColors.purple, texto: 'Seguimiento: ${_fecha(seg)}'),
        ],
      ],
    );
  }
}

// ── Piezas visuales ──

class _Card extends StatelessWidget {
  const _Card({required this.icon, required this.titulo, required this.child, this.trailing});
  final IconData icon;
  final String titulo;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.field, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: AppColors.purple, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(titulo, style: AppText.label.copyWith(fontSize: 13))),
            if (trailing != null) trailing!,
          ]),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.texto, required this.color});
  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(texto, style: AppText.label.copyWith(fontSize: 10.5, color: Colors.white)),
    );
  }
}

class _Delta extends StatelessWidget {
  const _Delta(this.valor);
  final int valor;

  @override
  Widget build(BuildContext context) {
    final color = valor > 0 ? _verde : (valor < 0 ? _rojo : AppColors.hint);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(7)),
      child: Text(valor == 0 ? '=' : (valor > 0 ? '▲ $valor' : '▼ ${valor.abs()}'),
          style: AppText.label.copyWith(fontSize: 11, color: color)),
    );
  }
}

class _Confianza extends StatelessWidget {
  const _Confianza({required this.nivel, required this.motivo});
  final String nivel;
  final String motivo;

  @override
  Widget build(BuildContext context) {
    final n = {'baja': 1, 'media': 2, 'alta': 3}[nivel] ?? 1;
    final color = [_rojo, _ambar, _verde][n - 1];
    return Tooltip(
      message: motivo,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 4),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (int i = 1; i <= 3; i++)
          Container(
            width: 5,
            height: 6.0 + 3 * i,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(
              color: i <= n ? color : Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        const SizedBox(width: 4),
        Text('Confianza $nivel', style: AppText.label.copyWith(fontSize: 11.5, color: color)),
      ]),
    );
  }
}

class _Hallazgo extends StatelessWidget {
  const _Hallazgo(this.icon, this.color, this.texto);
  final IconData icon;
  final Color color;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.16), shape: BoxShape.circle),
        child: Icon(icon, size: 14, color: color),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(texto, style: AppText.subtitle.copyWith(fontSize: 12.5, height: 1.4)),
        ),
      ),
    ]);
  }
}

class _Linea extends StatelessWidget {
  const _Linea({required this.icon, required this.color, required this.texto});
  final IconData icon;
  final Color color;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(top: 1), child: Icon(icon, size: 15, color: color)),
      const SizedBox(width: 7),
      Expanded(child: Text(texto, style: AppText.subtitle.copyWith(fontSize: 11.5, height: 1.5, color: Colors.white70))),
    ]);
  }
}

// ── Gráficas ──

class _RingPainter extends CustomPainter {
  _RingPainter(this.valor, this.color);
  final double valor;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 6;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = Colors.white.withValues(alpha: 0.08);
    canvas.drawCircle(c, r, base);
    final arco = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi / 2, 2 * math.pi * valor.clamp(0.0, 1.0), false, arco);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.valor != valor || old.color != color;
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({required this.actual, required this.anterior, required this.etiquetas, required this.t});
  final List<double> actual;
  final List<double>? anterior;
  final List<String> etiquetas;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final n = actual.length;
    final c = Offset(size.width / 2, size.height / 2 + 4);
    final r = math.min(size.width / 2 - 52, size.height / 2 - 22);
    Offset punto(int i, double f) {
      final a = -math.pi / 2 + 2 * math.pi * i / n;
      return c + Offset(math.cos(a), math.sin(a)) * (r * f);
    }

    final rejilla = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.08);
    for (final nivel in [0.25, 0.5, 0.75, 1.0]) {
      final path = Path();
      for (int i = 0; i < n; i++) {
        final p = punto(i, nivel);
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path..close(), rejilla);
    }
    for (int i = 0; i < n; i++) {
      canvas.drawLine(c, punto(i, 1), rejilla);
    }

    Path poligono(List<double> v, double escala) {
      final path = Path();
      for (int i = 0; i < n; i++) {
        final p = punto(i, v[i] * escala);
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      return path..close();
    }

    if (anterior != null) {
      canvas.drawPath(
        poligono(anterior!, 1),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.white38,
      );
    }
    final forma = poligono(actual, t);
    canvas.drawPath(forma, Paint()..color = AppColors.purple.withValues(alpha: 0.35));
    canvas.drawPath(
      forma,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFB07CFF),
    );
    for (int i = 0; i < n; i++) {
      final f = actual[i];
      final color = f >= 0.8 ? _verde : (f > 0.5 ? _ambar : _rojo);
      canvas.drawCircle(punto(i, f * t), 4, Paint()..color = color);
    }

    for (int i = 0; i < n; i++) {
      final tp = TextPainter(
        text: TextSpan(text: etiquetas[i], style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
        textDirection: TextDirection.ltr,
      )..layout();
      final p = punto(i, 1.0) + (punto(i, 1.0) - c) / r * 14;
      final dx = (p.dx - c.dx).abs() < 4 ? -tp.width / 2 : (p.dx > c.dx ? 0.0 : -tp.width);
      tp.paint(canvas, Offset(p.dx + dx, p.dy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.t != t || old.actual != actual;
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.totales,
    required this.colores,
    required this.fechas,
    required this.seleccionado,
    required this.t,
  });
  final List<double> totales;
  final List<Color> colores;
  final List<String> fechas;
  final int seleccionado;
  final double t;

  static const padIzq = 26.0;
  static const padDer = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    const arriba = 10.0, abajo = 22.0;
    final w = size.width - padIzq - padDer;
    final h = size.height - arriba - abajo;
    double y(double v) => arriba + h * (1 - v / 30);
    double x(int i) => padIzq + (totales.length == 1 ? w / 2 : w * i / (totales.length - 1));

    canvas.drawRect(Rect.fromLTRB(padIzq, y(30), padIzq + w, y(26)), Paint()..color = _verde.withValues(alpha: 0.10));
    canvas.drawRect(Rect.fromLTRB(padIzq, y(26), padIzq + w, y(18)), Paint()..color = _ambar.withValues(alpha: 0.07));
    canvas.drawRect(Rect.fromLTRB(padIzq, y(18), padIzq + w, y(0)), Paint()..color = _rojo.withValues(alpha: 0.06));

    void etiqueta(String s, Offset o, {Color color = Colors.white54, bool centro = false}) {
      final tp = TextPainter(
        text: TextSpan(text: s, style: TextStyle(color: color, fontSize: 9.5)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(centro ? o.dx - tp.width / 2 : o.dx, o.dy - tp.height / 2));
    }

    for (final v in [18.0, 26.0, 30.0]) {
      etiqueta('${v.round()}', Offset(4, y(v)));
    }

    final linea = Path();
    for (int i = 0; i < totales.length; i++) {
      final p = Offset(x(i), y(totales[i]));
      i == 0 ? linea.moveTo(p.dx, p.dy) : linea.lineTo(p.dx, p.dy);
    }
    final metricas = linea.computeMetrics().toList();
    for (final m in metricas) {
      canvas.drawPath(
        m.extractPath(0, m.length * t),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round
          ..color = Colors.white70,
      );
    }

    for (int i = 0; i < totales.length; i++) {
      final p = Offset(x(i), y(totales[i]));
      final sel = i == seleccionado;
      if (sel) canvas.drawCircle(p, 10, Paint()..color = colores[i].withValues(alpha: 0.25));
      canvas.drawCircle(p, sel ? 6 : 4.5, Paint()..color = colores[i]);
      canvas.drawCircle(
        p,
        sel ? 6 : 4.5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.black,
      );
      etiqueta('${totales[i].round()}', Offset(p.dx, p.dy - 15), color: Colors.white, centro: true);
      if (totales.length <= 6 || i == 0 || i == totales.length - 1 || sel) {
        etiqueta(fechas[i], Offset(p.dx, size.height - 8), centro: true);
      }
    }
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.t != t || old.seleccionado != seleccionado || old.totales.length != totales.length;
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.valor, required this.umbral, required this.tasa, required this.escala});
  final double valor;
  final double umbral;
  final double tasa;
  final double escala;

  @override
  void paint(Canvas canvas, Size size) {
    const alto = 12.0;
    final w = size.width;
    double x(double v) => w * (v / escala).clamp(0.0, 1.0);
    final rr = RRect.fromRectAndRadius(Rect.fromLTWH(0, 8, w, alto), const Radius.circular(6));
    canvas.save();
    canvas.clipRRect(rr);
    canvas.drawRect(Rect.fromLTWH(0, 8, x(umbral), alto), Paint()..color = _verde.withValues(alpha: 0.35));
    canvas.drawRect(Rect.fromLTWH(x(umbral), 8, w - x(umbral), alto), Paint()..color = _rojo.withValues(alpha: 0.35));
    canvas.restore();

    final px = x(valor);
    final aguja = Path()
      ..moveTo(px - 6, 0)
      ..lineTo(px + 6, 0)
      ..lineTo(px, 8)
      ..close();
    canvas.drawPath(aguja, Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(px - 1.25, 6, 2.5, alto + 4), Paint()..color = Colors.white);

    void marca(double v, String s) {
      canvas.drawRect(Rect.fromLTWH(x(v) - 0.5, 8, 1, alto), Paint()..color = Colors.white54);
      final tp = TextPainter(
        text: TextSpan(text: s, style: const TextStyle(color: Colors.white60, fontSize: 9.5)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset((x(v) - tp.width / 2).clamp(0.0, w - tp.width), 8 + alto + 6));
    }

    marca(umbral, 'umbral ${(umbral * 100).round()}%');
    if ((x(tasa) - x(umbral)).abs() > 70) marca(tasa, 'promedio ${(tasa * 100).round()}%');
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.valor != valor;
}

class _DivergingPainter extends CustomPainter {
  _DivergingPainter(this.valor, this.color);

  /// De −1 (en contra) a 1 (a favor).
  final double valor;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final medio = size.width / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 3, size.width, 8), const Radius.circular(4)),
      Paint()..color = Colors.white.withValues(alpha: 0.06),
    );
    final largo = medio * valor.abs().clamp(0.0, 1.0);
    final rect = valor >= 0 ? Rect.fromLTWH(medio, 3, largo, 8) : Rect.fromLTWH(medio - largo, 3, largo, 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()..color = valor >= 0 ? color : Colors.white38,
    );
    canvas.drawRect(Rect.fromLTWH(medio - 0.75, 0, 1.5, size.height), Paint()..color = Colors.white54);
  }

  @override
  bool shouldRepaint(_DivergingPainter old) => old.valor != valor || old.color != color;
}
