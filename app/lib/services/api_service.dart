import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://localhost:8000/api';
  }

  static Map<String, String> _headers([String? token]) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode != 200) {
      throw ApiException(
        data['detail'] is String
            ? data['detail'] as String
            : 'Error al iniciar sesión',
        resp.statusCode,
      );
    }
    return data;
  }

  static Future<Map<String, dynamic>> registerPatient({
    required String nombre,
    required String apellidoPaterno,
    String? apellidoMaterno,
    required String fechaNacimiento,
    required String email,
    required String password,
    required int idGenero,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/auth/register/patient'),
      headers: _headers(),
      body: jsonEncode({
        'nombre': nombre,
        'apellido_paterno': apellidoPaterno,
        if (apellidoMaterno != null && apellidoMaterno.isNotEmpty)
          'apellido_materno': apellidoMaterno,
        'fecha_nacimiento': fechaNacimiento,
        'email': email,
        'password': password,
        'id_genero': idGenero,
        'acepta_privacidad': true,
        'acepta_terminos': true,
      }),
    );
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode != 201) {
      throw ApiException(_extractError(data), resp.statusCode);
    }
    return data;
  }

  static Future<Map<String, dynamic>> registerSpecialist({
    required String nombre,
    required String apellidoPaterno,
    String? apellidoMaterno,
    required String fechaNacimiento,
    required String email,
    required String password,
    required int idGenero,
    required String cedula,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/auth/register/specialist'),
      headers: _headers(),
      body: jsonEncode({
        'nombre': nombre,
        'apellido_paterno': apellidoPaterno,
        if (apellidoMaterno != null && apellidoMaterno.isNotEmpty)
          'apellido_materno': apellidoMaterno,
        'fecha_nacimiento': fechaNacimiento,
        'email': email,
        'password': password,
        'id_genero': idGenero,
        'cedula': cedula,
        'acepta_privacidad': true,
        'acepta_terminos': true,
      }),
    );
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode != 201) {
      throw ApiException(_extractError(data), resp.statusCode);
    }
    return data;
  }

  static Future<Map<String, dynamic>> validateCedula(String cedula) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/auth/validate-cedula?cedula=$cedula'),
      headers: _headers(),
    );
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  // ── Especialista ──

  static Future<Map<String, dynamic>> vincularPaciente(
      String codigoPaciente, String token) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/especialista/vincular'),
      headers: _headers(token),
      body: jsonEncode({'codigo_paciente': codigoPaciente}),
    );
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode != 201) {
      throw ApiException(_extractError(data), resp.statusCode);
    }
    return data;
  }

  static Future<List<dynamic>> listarPacientes(String token) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/especialista/pacientes'),
      headers: _headers(token),
    );
    if (resp.statusCode != 200) {
      throw ApiException('Error al obtener pacientes', resp.statusCode);
    }
    return jsonDecode(resp.body) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> crearExpediente(
      int idPaciente, Map<String, dynamic> body, String token) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/especialista/pacientes/$idPaciente/expediente'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode != 201) {
      throw ApiException(_extractError(data), resp.statusCode);
    }
    return data;
  }

  static Future<Map<String, dynamic>> obtenerExpediente(
      int idPaciente, String token) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/especialista/pacientes/$idPaciente/expediente'),
      headers: _headers(token),
    );
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode == 404) {
      throw ApiException('not_found', resp.statusCode);
    }
    if (resp.statusCode != 200) {
      throw ApiException(_extractError(data), resp.statusCode);
    }
    return data;
  }

  static Future<Map<String, dynamic>> actualizarExpediente(
      int idPaciente, Map<String, dynamic> body, String token) async {
    final resp = await http.put(
      Uri.parse('$baseUrl/especialista/pacientes/$idPaciente/expediente'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode != 200) {
      throw ApiException(_extractError(data), resp.statusCode);
    }
    return data;
  }

  // ── Catálogos ──

  static Future<List<dynamic>> getCatalogo(String catalogo) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/catalogos/$catalogo'),
      headers: _headers(),
    );
    if (resp.statusCode != 200) {
      throw ApiException('Error al obtener catálogo', resp.statusCode);
    }
    return jsonDecode(resp.body) as List<dynamic>;
  }

  // ── Evaluación MoCA ──

  static Future<Map<String, dynamic>> generarCodigoSupervision(
      int idPaciente, String token) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/evaluacion/codigo'),
      headers: _headers(token),
      body: jsonEncode({'id_paciente': idPaciente}),
    );
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode != 201) throw ApiException(_extractError(data), resp.statusCode);
    return data;
  }

  static Future<Map<String, dynamic>> validarCodigoSupervision(
      String codigo, String token) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/evaluacion/validar-codigo'),
      headers: _headers(token),
      body: jsonEncode({'codigo': codigo}),
    );
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode != 201) throw ApiException(_extractError(data), resp.statusCode);
    return data;
  }

  static Future<Map<String, dynamic>> obtenerSesionMoca(
      int idMoca, String token) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/evaluacion/sesion/$idMoca'),
      headers: _headers(token),
    );
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode != 200) throw ApiException(_extractError(data), resp.statusCode);
    return data;
  }

  // ── Resultados MoCA ──

  static Future<List<dynamic>> guardarResultados(
      int idMoca, List<Map<String, dynamic>> resultados, String token) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/evaluacion/sesion/$idMoca/resultados'),
      headers: _headers(token),
      body: jsonEncode({'resultados': resultados}),
    );
    if (resp.statusCode != 201) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      throw ApiException(_extractError(data), resp.statusCode);
    }
    return jsonDecode(resp.body) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> finalizarMoca(
      int idMoca, int puntajeTotal, String clasificacion, String token) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/evaluacion/sesion/$idMoca/finalizar'),
      headers: _headers(token),
      body: jsonEncode({
        'puntaje_total': puntajeTotal,
        'clasificacion': clasificacion,
      }),
    );
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode != 200) {
      throw ApiException(_extractError(data), resp.statusCode);
    }
    return data;
  }

  static Future<List<dynamic>> obtenerResultados(
      int idMoca, String token) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/evaluacion/sesion/$idMoca/resultados'),
      headers: _headers(token),
    );
    if (resp.statusCode != 200) {
      throw ApiException('Error al obtener resultados', resp.statusCode);
    }
    return jsonDecode(resp.body) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> getProfile(String token) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/auth/profile'),
      headers: _headers(token),
    );
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode != 200) {
      throw ApiException(_extractError(data), resp.statusCode);
    }
    return data;
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? nombre,
    String? apellidoPaterno,
    String? apellidoMaterno,
  }) async {
    final body = <String, dynamic>{};
    if (nombre != null) body['nombre'] = nombre;
    if (apellidoPaterno != null) body['apellido_paterno'] = apellidoPaterno;
    if (apellidoMaterno != null) body['apellido_materno'] = apellidoMaterno;
    final resp = await http.put(
      Uri.parse('$baseUrl/auth/profile'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode != 200) {
      throw ApiException(_extractError(data), resp.statusCode);
    }
    return data;
  }

  static String _extractError(Map<String, dynamic> data) {
    if (data['detail'] is String) return data['detail'] as String;
    if (data['detail'] is List) {
      final errors = data['detail'] as List;
      if (errors.isNotEmpty) {
        final first = errors[0] as Map<String, dynamic>;
        return first['msg'] as String? ?? 'Error de validación';
      }
    }
    return 'Error desconocido';
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  const ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
