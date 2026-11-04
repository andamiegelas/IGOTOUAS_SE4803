import 'package:flutter_test/flutter_test.dart';
import 'package:igoto_app/core/utils/currency_formatter.dart';
import 'package:igoto_app/data/models/project_model.dart';
import 'package:igoto_app/data/models/user_model.dart';

void main() {
  group('Unit Tests - Model & Utility', () {
    test('CurrencyFormatter formats Rupiah correctly', () {
      expect(CurrencyFormatter.format(1000000), 'Rp1.000.000');
      expect(CurrencyFormatter.formatPercent(9.01), '9.01%');
    });

    test('UserModel parses from JSON correctly', () {
      final json = {
        'id': 1,
        'name': 'Mikdam Huda',
        'email': 'mikdam@gmail.com',
        'role': 'investor'
      };
      final user = UserModel.fromJson(json);
      expect(user.id, 1);
      expect(user.name, 'Mikdam Huda');
      expect(user.isAdmin, false);
    });

    test('ProjectModel calculation values parse correctly', () {
      final json = {
        'id': 1,
        'company_name': 'CV. Karya Amanah Sejati',
        'project_name': 'Proyek Pengadaan Meja Kursi',
        'funding_target': '225000000.00',
        'profit_percentage': '9.01',
        'admin_fee': '0.00',
        'status': 'open',
        'total_verified': '22500000.00',
        'funding_percentage': '10.00'
      };
      final project = ProjectModel.fromJson(json);
      expect(project.fundingTarget, 225000000.0);
      expect(project.profitPercentage, 9.01);
      expect(project.totalVerified, 22500000.0);
      expect(project.fundingPercentage, 10.0);
    });
  });
}
