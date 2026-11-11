# Brain Test · App móvil (Flutter)

App para Android e iOS del TT 2026-B141. Por ahora solo tiene la interfaz y la
navegación del diseño de Figma; el backend (FastAPI) todavía no está conectado,
así que los botones solo llevan a la siguiente pantalla.

## Flujo implementado

```
Animación de entrada ─► Inicio de sesión ─┬─► Recuperar contraseña (correo + código) ─► Nueva contraseña
                                          └─► Animación ─► Registro ─┬─ Especialista ─► Validación de cédula ─► Credenciales
                                                                     └─ Paciente ──────────────────────────────► Credenciales
```

## Estructura

| Ruta | Contenido |
|---|---|
| `lib/theme/app_theme.dart` | Colores, tamaños y tipografía (Inter) tomados de Figma |
| `lib/widgets/app_widgets.dart` | Botón, campo de texto, botón de regresar, imagen de cabecera, código de 6 dígitos |
| `lib/screens/splash_screen.dart` | Animación de entrada (frames "Animacion 7 → 5") |
| `lib/screens/auth/` | Inicio de sesión y recuperar contraseña |
| `lib/screens/register/` | Animación de registro, Registro, Validación y Credenciales |
| `assets/images/` | Imágenes exportadas del archivo de Figma |

## Correr la app

```bash
flutter pub get
flutter run
```

- **Android:** abre un emulador desde Android Studio (o `flutter emulators --launch <id>`).
- **iOS:** necesita Xcode completo y CocoaPods en la Mac.

La tipografía Inter se descarga con `google_fonts` la primera vez que se abre la app.
