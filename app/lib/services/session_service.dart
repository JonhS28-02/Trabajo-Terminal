import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _keyToken = 'access_token';
  static const _keyRole = 'role';
  static const _keyUserId = 'user_id';
  static const _keyNombre = 'nombre';
  static const _keyCodigo = 'codigo_paciente';

  static Future<void> save({
    required String token,
    required String role,
    required int userId,
    required String nombre,
    String? codigoPaciente,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyRole, role);
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyNombre, nombre);
    if (codigoPaciente != null) {
      await prefs.setString(_keyCodigo, codigoPaciente);
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  static Future<String?> getNombre() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNombre);
  }

  static Future<String?> getCodigoPaciente() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCodigo);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyNombre);
    await prefs.remove(_keyCodigo);
  }
}
