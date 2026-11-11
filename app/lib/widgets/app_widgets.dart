import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// Botón con degradado morado (INICIAR SESION, CONTINUAR, VALIDAR, ...).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = double.infinity,
    this.height = AppSizes.buttonHeight,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.gradient,
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(label, style: AppText.button),
          ),
        ),
      ),
    );
  }
}

/// Punto morado que marca el campo activo.
class GradientDot extends StatelessWidget {
  const GradientDot({super.key, this.size = 17});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.purpleDark, AppColors.purple],
        ),
      ),
    );
  }
}

class _GradientCheck extends StatelessWidget {
  const _GradientCheck();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.purpleDark, AppColors.purple],
        ),
      ),
      child: const Icon(Icons.check, color: Colors.white, size: 14),
    );
  }
}

class AppField extends StatefulWidget {
  const AppField({
    super.key,
    required this.hint,
    this.controller,
    this.obscure = false,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.height = AppSizes.fieldHeight,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.onChanged,
    this.errorText,
    this.isValid = false,
  });

  final String hint;
  final TextEditingController? controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final double height;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool isValid;

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    final hasError = widget.errorText != null;
    final showGradient = focused || widget.isValid;
    final showErrorBorder = hasError && !focused && !widget.isValid;
    final hasBorder = showGradient || showErrorBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: widget.height,
          padding: EdgeInsets.all(hasBorder ? 2 : 0),
          decoration: BoxDecoration(
            gradient: showGradient ? AppColors.gradient : null,
            color: showErrorBorder ? Colors.redAccent : null,
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: hasBorder ? const Color(0xFF232323) : AppColors.field,
              borderRadius: BorderRadius.circular(
                AppSizes.radius - (hasBorder ? 2 : 0),
              ),
            ),
            padding: EdgeInsets.only(
              left: hasBorder ? 14 : 16,
              right: hasBorder ? 13 : 15,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: _focus,
                    controller: widget.controller,
                    obscureText: widget.obscure,
                    readOnly: widget.readOnly,
                    onTap: widget.onTap,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    onSubmitted: widget.onSubmitted,
                    onChanged: widget.onChanged,
                    style: AppText.input,
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: AppText.hint,
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
                if (widget.isValid)
                  const _GradientCheck()
                else if (focused && widget.onChanged == null)
                  const GradientDot(),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 14, color: Colors.redAccent),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: AppText.subtitle.copyWith(
                      color: Colors.redAccent,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Etiqueta en negritas + campo, con el espaciado del diseño.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.field,
    this.gap = 32,
  });

  final String label;
  final Widget field;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label),
        SizedBox(height: gap),
        field,
      ],
    );
  }
}

/// Texto con una parte en negritas: "Ingresa tus **datos**".
class RichSubtitle extends StatelessWidget {
  const RichSubtitle(
    this.normal,
    this.bold, {
    super.key,
    this.fontSize = 12,
    this.center = false,
  });

  final String normal;
  final String bold;
  final double fontSize;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: AppText.subtitle.copyWith(fontSize: fontSize),
        children: [
          TextSpan(text: normal),
          TextSpan(text: bold, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
      textAlign: center ? TextAlign.center : TextAlign.start,
    );
  }
}

/// Botón circular de regresar (40 px, degradado morado).
class CircleBackButton extends StatelessWidget {
  const CircleBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.gradient,
      ),
      child: Material(
        type: MaterialType.transparency,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed ?? () => Navigator.of(context).maybePop(),
          child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

/// Imagen de cabecera con esquinas inferiores de 30 px y desenfoque leve.
class HeaderImage extends StatelessWidget {
  const HeaderImage({
    super.key,
    required this.asset,
    this.height = 292,
    this.blur = 1,
  });

  final String asset;
  final double height;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(AppSizes.headerRadius),
      ),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: blur,
            sigmaY: blur,
            tileMode: TileMode.clamp,
          ),
          child: Image.asset(asset, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

/// Seis casillas para el código, con salto automático.
class CodeInput extends StatefulWidget {
  const CodeInput({super.key, this.length = 6, this.onCompleted});

  final int length;
  final ValueChanged<String>? onCompleted;

  @override
  State<CodeInput> createState() => _CodeInputState();
}

class _CodeInputState extends State<CodeInput> {
  late final _controllers =
      List.generate(widget.length, (_) => TextEditingController());
  late final _focusNodes = List.generate(widget.length, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radius),
      borderSide: BorderSide.none,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (i) {
        return Padding(
          padding: EdgeInsets.only(left: i == 0 ? 0 : 7),
          child: SizedBox(
            width: 35,
            height: 49,
            child: TextField(
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: AppText.input.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: AppColors.codeBox,
                contentPadding: EdgeInsets.zero,
                enabledBorder: border,
                border: border,
                focusedBorder: border.copyWith(
                  borderSide: const BorderSide(color: AppColors.purple, width: 2),
                ),
              ),
              onChanged: (v) {
                if (v.isNotEmpty && i < widget.length - 1) {
                  _focusNodes[i + 1].requestFocus();
                } else if (v.isNotEmpty && i == widget.length - 1) {
                  final code = _controllers.map((c) => c.text).join();
                  if (code.length == widget.length) {
                    widget.onCompleted?.call(code);
                  }
                } else if (v.isEmpty && i > 0) {
                  _focusNodes[i - 1].requestFocus();
                }
              },
            ),
          ),
        );
      }),
    );
  }
}

/// Transición de desvanecimiento (equivale al "Smart animate" de Figma
/// entre pantallas distintas).
Route<T> fadeRoute<T>(Widget page, {int ms = 450}) {
  return PageRouteBuilder<T>(
    transitionDuration: Duration(milliseconds: ms),
    reverseTransitionDuration: Duration(milliseconds: ms),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      child: child,
    ),
  );
}

void showDemoMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.purpleDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
}
