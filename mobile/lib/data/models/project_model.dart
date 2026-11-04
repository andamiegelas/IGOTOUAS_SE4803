import 'location_model.dart';

class ProjectModel {
  final int id;
  final String companyName;
  final String projectName;
  final String description;
  final double fundingTarget;
  final double profitPercentage;
  final double adminFee;
  final String status;
  final double totalVerified;
  final double fundingPercentage;
  final LocationModel? location;

  ProjectModel({
    required this.id,
    required this.companyName,
    required this.projectName,
    required this.description,
    required this.fundingTarget,
    required this.profitPercentage,
    required this.adminFee,
    required this.status,
    required this.totalVerified,
    required this.fundingPercentage,
    this.location,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      companyName: json['company_name'] ?? '',
      projectName: json['project_name'] ?? '',
      description: json['description'] ?? '',
      fundingTarget: json['funding_target'] != null ? double.parse(json['funding_target'].toString()) : 0.0,
      profitPercentage: json['profit_percentage'] != null ? double.parse(json['profit_percentage'].toString()) : 0.0,
      adminFee: json['admin_fee'] != null ? double.parse(json['admin_fee'].toString()) : 0.0,
      status: json['status'] ?? 'open',
      totalVerified: json['total_verified'] != null ? double.parse(json['total_verified'].toString()) : 0.0,
      fundingPercentage: json['funding_percentage'] != null ? double.parse(json['funding_percentage'].toString()) : 0.0,
      location: json['location'] != null ? LocationModel.fromJson(json['location']) : null,
    );
  }
}

