import 'dart:io';
import 'package:flutter/material.dart';
import '../data/datasources/api_client.dart';
import '../data/models/investment_model.dart';
import '../services/notification_service.dart';
import '../core/error/api_exception.dart';

class InvestmentProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final NotificationService _notificationService = NotificationService();

  List<InvestmentModel> _myInvestments = [];
  List<InvestmentModel> _allInvestments = [];
  Map<String, dynamic>? _dashboardSummary;
  bool _isLoading = false;
  String? _errorMessage;

  List<InvestmentModel> get myInvestments => _myInvestments;
  List<InvestmentModel> get allInvestments => _allInvestments;
  Map<String, dynamic>? get dashboardSummary => _dashboardSummary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> submitInvestment({
    required int projectId,
    required String investorName,
    required String phone,
    required String bankName,
    required String accountNumber,
    required double amount,
    required File transferProof,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fields = {
        'project_id': projectId.toString(),
        'investor_name': investorName,
        'phone': phone,
        'bank_name': bankName,
        'account_number': accountNumber,
        'amount': amount.toString(),
      };

      final res = await _apiClient.uploadMultipart(
        '/investments',
        fields,
        transferProof,
        'transfer_proof',
      );

      if (res['success'] == true) {
        // Trigger local notification
        await _notificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: 'Pengajuan Investasi Berhasil!',
          body: 'Pengajuan Rp ${amount.toStringAsFixed(0)} telah terkirim dan sedang menunggu verifikasi admin.',
        );

        await fetchMyInvestments();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res['message'] ?? 'Gagal mengajukan investasi';
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan sistem saat mengirim data';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> fetchMyInvestments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiClient.get('/investments/my');
      if (res['success'] == true && res['data'] != null) {
        final List list = res['data'];
        _myInvestments = list.map((e) => InvestmentModel.fromJson(e)).toList();
      } else {
        _errorMessage = res['message'] ?? 'Gagal memuat riwayat investasi';
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan sistem';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllInvestments({String? status}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String endpoint = '/admin/investments';
      if (status != null && status.isNotEmpty && status != 'all') {
        endpoint += '?status=$status';
      }

      final res = await _apiClient.get(endpoint);
      if (res['success'] == true && res['data'] != null) {
        final List list = res['data'];
        _allInvestments = list.map((e) => InvestmentModel.fromJson(e)).toList();
      } else {
        _errorMessage = res['message'] ?? 'Gagal memuat data investasi';
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan sistem';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateStatus(int id, String status, {String? notes}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiClient.put('/admin/investments/$id/status', {
        'status': status,
        'notes': notes,
      });

      if (res['success'] == true) {
        // Trigger notification
        await _notificationService.showNotification(
          id: id,
          title: 'Status Investasi Diperbarui',
          body: 'Pengajuan ID #$id telah diubah menjadi: ${status.toUpperCase()}',
        );

        await fetchAllInvestments();
        await fetchDashboardSummary();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res['message'] ?? 'Gagal memperbarui status';
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

  Future<void> fetchDashboardSummary() async {
    try {
      final res = await _apiClient.get('/admin/dashboard');
      if (res['success'] == true && res['data'] != null) {
        _dashboardSummary = res['data'];
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> fetchReportData() async {
    try {
      final res = await _apiClient.get('/admin/report-data');
      if (res['success'] == true && res['data'] != null) {
        return res['data'];
      }
    } catch (e) {
      _errorMessage = 'Gagal mengambil data laporan: $e';
    }
    return null;
  }
}

