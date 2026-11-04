import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/datasources/api_client.dart';
import '../data/models/user_model.dart';
import '../core/error/api_exception.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null && _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  Future<bool> checkAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');

      if (_token != null && _token!.isNotEmpty) {
        final res = await _apiClient.get('/auth/me');
        if (res['success'] == true && res['data'] != null) {
          _user = UserModel.fromJson(res['data']);
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
    } catch (_) {
      await logout();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiClient.post('/auth/login', {
        'email': email.trim(),
        'password': password,
      });

      if (res['success'] == true) {
        _token = res['data']['token'];
        _user = UserModel.fromJson(res['data']['user']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res['message'] ?? 'Login gagal';
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan sistem';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password, String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiClient.post('/auth/register', {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'role': role,
      });

      if (res['success'] == true) {
        _token = res['data']['token'];
        _user = UserModel.fromJson(res['data']['user']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res['message'] ?? 'Registrasi gagal';
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan sistem';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
    _user = null;
    notifyListeners();
  }
}

