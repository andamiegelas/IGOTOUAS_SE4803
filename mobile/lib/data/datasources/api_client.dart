import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/error/api_exception.dart';

class ApiClient {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final token = await _getToken();
    final headers = <String, String>{};
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  dynamic _processResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      body = {'message': response.body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      final msg = body is Map && body['message'] != null ? body['message'] : 'Terjadi kesalahan (${response.statusCode})';
      throw ApiException(msg, response.statusCode);
    }
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server backend. Pastikan server aktif dan IP benar.');
    } on http.ClientException {
      throw ApiException('Gagal melakukan koneksi jaringan');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = await _getHeaders();
      final response = await http
          .post(uri, headers: headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server backend. Pastikan server aktif dan IP benar.');
    } on http.ClientException {
      throw ApiException('Gagal melakukan koneksi jaringan');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = await _getHeaders();
      final response = await http
          .put(uri, headers: headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server backend');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  Future<dynamic> uploadMultipart(
    String endpoint,
    Map<String, String> fields,
    File file,
    String fileField,
  ) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = await _getHeaders(isMultipart: true);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      request.fields.addAll(fields);

      final multipartFile = await http.MultipartFile.fromPath(fileField, file.path);
      request.files.add(multipartFile);

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server backend untuk upload foto');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }
}

