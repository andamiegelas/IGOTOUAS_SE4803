import 'package:flutter/material.dart';
import '../data/datasources/api_client.dart';
import '../data/models/project_model.dart';
import '../core/error/api_exception.dart';

class ProjectProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  ProjectModel? _activeProject;
  bool _isLoading = false;
  String? _errorMessage;

  ProjectModel? get activeProject => _activeProject;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchActiveProject() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiClient.get('/projects/active');
      if (res['success'] == true && res['data'] != null) {
        _activeProject = ProjectModel.fromJson(res['data']);
      } else {
        _errorMessage = res['message'] ?? 'Gagal memuat data proyek';
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan sistem';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Pure logic for investment simulation
  Map<String, double> calculateSimulation(double amount) {
    if (_activeProject == null || amount <= 0) {
      return {
        'grossProfit': 0.0,
        'adminFee': 0.0,
        'netProfit': 0.0,
        'totalReturn': 0.0,
      };
    }

    final profitPercentage = _activeProject!.profitPercentage;
    final adminFee = _activeProject!.adminFee;

    final grossProfit = amount * (profitPercentage / 100);
    final netProfit = grossProfit - adminFee;
    final totalReturn = amount + netProfit;

    return {
      'grossProfit': grossProfit,
      'adminFee': adminFee,
      'netProfit': netProfit,
      'totalReturn': totalReturn,
    };
  }
}

