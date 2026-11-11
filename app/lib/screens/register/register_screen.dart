import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import 'credentials_screen.dart';
import 'validation_screen.dart';

enum UserRole { specialist, patient }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  UserRole _role = UserRole.specialist;
  final _nombre = TextEditingController();
  final _apellidoP = TextEditingController();
  final _apellidoM = TextEditingController();
  final _birthDate = TextEditingController();
  DateTime? _selectedDate;
  int _idGenero = 1;

  bool _nombreTouched = false;
  bool _apPTouched = false;
  String? _nombreError;
  bool _nombreValid = false;
  String? _apPError;
  bool _apPValid = false;
  String? _dateError;
  bool _dateValid = false;

  void _onNombreChanged(String _) {
    _nombreTouched = true;
    _validateNombre();
  }

  void _validateNombre() {
    if (!_nombreTouched) return;
    setState(() {
      if (_nombre.text.trim().isEmpty) {
        _nombreError = 'Ingresa tu nombre';
        _nombreValid = false;
      } else {
        _nombreError = null;
        _nombreValid = true;
      }
    });
  }

  void _onApPChanged(String _) {
    _apPTouched = true;
    _validateApP();
  }

  void _validateApP() {
    if (!_apPTouched) return;
    setState(() {
      if (_apellidoP.text.trim().isEmpty) {
        _apPError = 'Ingresa tu apellido paterno';
        _apPValid = false;
      } else {
        _apPError = null;
        _apPValid = true;
      }
    });
  }

  void _validateDate() {
    setState(() {
      if (_selectedDate == null) {
        _dateError = 'Selecciona tu fecha de nacimiento';
        _dateValid = false;
      } else {
        final now = DateTime.now();
        final age = now.year -
            _selectedDate!.year -
            ((now.month < _selectedDate!.month ||
                    (now.month == _selectedDate!.month &&
                        now.day < _selectedDate!.day))
                ? 1
                : 0);
        if (age < 18) {
          _dateError = 'Debes ser mayor de 18 años';
          _dateValid = false;
        } else {
          _dateError = null;
          _dateValid = true;
        }
      }
    });
  }

  @override
  void dispose() {
    _nombre.dispose();
    _apellidoP.dispose();
    _apellidoM.dispose();
    _birthDate.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 60),
      firstDate: DateTime(1900),
      lastDate: now,
      locale: const Locale('es'),
    );
    if (date == null) return;
    _selectedDate = date;
    _birthDate.text = '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
    _validateDate();
  }

  void _continue() {
    _nombreTouched = true;
    _apPTouched = true;
    _validateNombre();
    _validateApP();
    _validateDate();
    if (_nombreError != null || _apPError != null || _dateError != null) return;

    final data = {
      'nombre': _nombre.text.trim(),
      'apellido_paterno': _apellidoP.text.trim(),
      'apellido_materno': _apellidoM.text.trim(),
      'fecha_nacimiento':
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
      'id_genero': _idGenero,
      'role': _role == UserRole.specialist ? 'especialista' : 'paciente',
    };

    final next = _role == UserRole.specialist
        ? ValidationScreen(userData: data)
        : CredentialsScreen(userData: data);
    Navigator.of(context).push(fadeRoute(next));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: 28 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _RolePicker(
                  role: _role,
                  onChanged: (r) => setState(() => _role = r),
                ),
                Positioned(
                  left: 15,
                  top: MediaQuery.paddingOf(context).top + 8,
                  child: CircleBackButton(
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text('Registro', style: AppText.title),
                  const SizedBox(height: 27),
                  const RichSubtitle('Ingresa tus ', 'datos'),
                  const SizedBox(height: 17),
                  ..._fields(),
                  const SizedBox(height: 17),
                  _GenderSelector(
                    value: _idGenero,
                    onChanged: (v) => setState(() => _idGenero = v),
                  ),
                  const SizedBox(height: 39),
                  PrimaryButton(label: 'CONTINUAR', onPressed: _continue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _fields() {
    const gap = SizedBox(height: 12);
    return [
      LabeledField(
        label: 'Nombre',
        gap: 14,
        field: AppField(
          hint: 'Nombre',
          height: 34,
          controller: _nombre,
          onChanged: _onNombreChanged,
          errorText: _nombreError,
          isValid: _nombreValid,
        ),
      ),
      gap,
      LabeledField(
        label: 'Apellido Paterno',
        gap: 14,
        field: AppField(
          hint: 'Apellido Paterno',
          height: 34,
          controller: _apellidoP,
          onChanged: _onApPChanged,
          errorText: _apPError,
          isValid: _apPValid,
        ),
      ),
      gap,
      LabeledField(
        label: 'Apellido Materno',
        gap: 14,
        field: AppField(
          hint: 'Apellido Materno',
          height: 34,
          controller: _apellidoM,
        ),
      ),
      gap,
      LabeledField(
        label: 'Fecha de nacimiento',
        gap: 14,
        field: AppField(
          hint: 'DD/MM/AAAA',
          height: 34,
          readOnly: true,
          controller: _birthDate,
          onTap: _pickDate,
          textInputAction: TextInputAction.done,
          errorText: _dateError,
          isValid: _dateValid,
        ),
      ),
    ];
  }
}

class _GenderSelector extends StatelessWidget {
  const _GenderSelector({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  static const _options = [
    (1, 'Masculino'),
    (2, 'Femenino'),
    (3, 'No binario'),
    (4, 'Prefiero no decir'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Género', style: AppText.label),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _options.map((opt) {
            final selected = value == opt.$1;
            return GestureDetector(
              onTap: () => onChanged(opt.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: selected ? AppColors.gradient : null,
                  color: selected ? null : AppColors.field,
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                ),
                child: Text(
                  opt.$2,
                  style: AppText.input.copyWith(
                    fontSize: 12,
                    color: selected ? Colors.white : AppColors.hint,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _RolePicker extends StatelessWidget {
  const _RolePicker({required this.role, required this.onChanged});

  final UserRole role;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 203,
          child: _RoleOption(
            asset: 'assets/images/register_specialist.jpg',
            label: 'Especialista',
            selected: role == UserRole.specialist,
            radius: const BorderRadius.only(bottomLeft: Radius.circular(30)),
            onTap: () => onChanged(UserRole.specialist),
          ),
        ),
        Expanded(
          flex: 201,
          child: _RoleOption(
            asset: 'assets/images/register_patient.jpg',
            label: 'Paciente',
            selected: role == UserRole.patient,
            radius: const BorderRadius.only(bottomRight: Radius.circular(30)),
            onTap: () => onChanged(UserRole.patient),
          ),
        ),
      ],
    );
  }
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.asset,
    required this.label,
    required this.selected,
    required this.radius,
    required this.onTap,
  });

  final String asset;
  final String label;
  final bool selected;
  final BorderRadius radius;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 301,
            padding: EdgeInsets.only(bottom: selected ? 3 : 0),
            decoration: BoxDecoration(
              gradient: selected ? AppColors.gradient : null,
              borderRadius: radius,
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: SizedBox.expand(
                child: Image.asset(asset, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 7),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: selected ? 1 : 0.5,
            child: Text(label, style: AppText.label.copyWith(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
