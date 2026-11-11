import 'package:brain_test/main.dart';
import 'package:brain_test/screens/auth/login_screen.dart';
import 'package:brain_test/screens/main_shell.dart';
import 'package:brain_test/screens/register/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('splash termina en login y "Regístrate" abre el registro',
      (tester) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BrainTestApp());
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    final register = find.textContaining('Regístrate', findRichText: true);
    await tester.ensureVisible(register);
    await tester.pumpAndSettle();
    await tester.tap(register);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterScreen), findsOneWidget);

    await tester.tap(find.text('Paciente'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('CONTINUAR'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONTINUAR'));
    await tester.pumpAndSettle();
    expect(find.text('Credenciales'), findsOneWidget);
  });

  testWidgets('login lleva al MainShell con bottom nav', (tester) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BrainTestApp());
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.ensureVisible(find.text('INICIAR SESIÓN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('INICIAR SESIÓN'));
    await tester.pumpAndSettle();
    expect(find.byType(MainShell), findsOneWidget);
    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('EVALUACION'), findsOneWidget);
    expect(find.text('MOCA'), findsOneWidget);
    expect(find.text('PERFIL'), findsOneWidget);
  });

  testWidgets('evaluation flow starts and shows trail making', (tester) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BrainTestApp());
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    // Go to main shell
    await tester.ensureVisible(find.text('INICIAR SESIÓN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('INICIAR SESIÓN'));
    await tester.pumpAndSettle();

    // Tap "INICIAR EVALUACIÓN" on home
    final startBtn = find.text('INICIAR EVALUACIÓN').first;
    await tester.ensureVisible(startBtn);
    await tester.pumpAndSettle();
    await tester.tap(startBtn);
    await tester.pumpAndSettle();

    // Should show the first section: trail making
    expect(find.text('Alternancia de trazos'), findsOneWidget);
    expect(find.text('Sección 1 de 14'), findsOneWidget);
  });
}
