class InvestmentModel {
  final int id;
  final int projectId;
  final int userId;
  final String investorName;
  final String phone;
  final String bankName;
  final String accountNumber;
  final double amount;
  final double profitPercentage;
  final double grossProfit;
  final double adminFee;
  final double netProfit;
  final double totalReturn;
  final String transferProofPath;
  final String status;
  final String? notes;
  final String createdAt;
  final String? verifiedAt;

  InvestmentModel({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.investorName,
    required this.phone,
    required this.bankName,
    required this.accountNumber,
    required this.amount,
    required this.profitPercentage,
    required this.grossProfit,
    required this.adminFee,
    required this.netProfit,
    required this.totalReturn,
    required this.transferProofPath,
    required this.status,
    this.notes,
    required this.createdAt,
    this.verifiedAt,
  });

  factory InvestmentModel.fromJson(Map<String, dynamic> json) {
    return InvestmentModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      projectId: json['project_id'] is int ? json['project_id'] : int.parse(json['project_id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      investorName: json['investor_name'] ?? '',
      phone: json['phone'] ?? '',
      bankName: json['bank_name'] ?? '',
      accountNumber: json['account_number'] ?? '',
      amount: json['amount'] != null ? double.parse(json['amount'].toString()) : 0.0,
      profitPercentage: json['profit_percentage'] != null ? double.parse(json['profit_percentage'].toString()) : 0.0,
      grossProfit: json['gross_profit'] != null ? double.parse(json['gross_profit'].toString()) : 0.0,
      adminFee: json['admin_fee'] != null ? double.parse(json['admin_fee'].toString()) : 0.0,
      netProfit: json['net_profit'] != null ? double.parse(json['net_profit'].toString()) : 0.0,
      totalReturn: json['total_return'] != null ? double.parse(json['total_return'].toString()) : 0.0,
      transferProofPath: json['transfer_proof_path'] ?? '',
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      createdAt: json['created_at'] ?? '',
      verifiedAt: json['verified_at'],
    );
  }

  bool get isPending => status == 'pending';
  bool get isVerified => status == 'verified';
  bool get isRejected => status == 'rejected';
}

