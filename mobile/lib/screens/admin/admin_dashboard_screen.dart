import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/investment_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../services/pdf_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_badge.dart';
import '../auth/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final prov = Provider.of<InvestmentProvider>(context, listen: false);
    await Future.wait([
      prov.fetchDashboardSummary(),
      prov.fetchAllInvestments(status: _selectedFilter),
    ]);
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda ingin keluar dari panel admin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _exportPdf() async {
    final prov = Provider.of<InvestmentProvider>(context, listen: false);
    final reportData = await prov.fetchReportData();

    if (!mounted) return;

    if (reportData != null) {
      try {
        await PdfService.generateAndPrintReport(reportData);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat PDF: $e'), backgroundColor: AppColors.error),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(prov.errorMessage ?? 'Gagal mengambil data laporan'), backgroundColor: AppColors.error),
      );
    }
  }

  void _showProofDialog(String imagePath) {
    final fullUrl = '${ApiConstants.uploadUrl}$imagePath';
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Foto Bukti Transfer', style: TextStyle(fontSize: 14)),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              child: Image.network(
                fullUrl,
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  );
                },
                errorBuilder: (_, _, _) => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Gagal memuat gambar bukti'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _verifyInvestment(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verifikasi Investasi'),
        content: Text('Apakah bukti transfer untuk ID #$id sudah valid dan dana telah masuk?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Verifikasi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final prov = Provider.of<InvestmentProvider>(context, listen: false);
      final success = await prov.updateStatus(id, 'verified');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Investasi #$id berhasil diverifikasi' : (prov.errorMessage ?? 'Gagal')),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  void _rejectInvestment(int id) async {
    final reasonController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Investasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Berikan catatan alasan penolakan (misal: nominal tidak sesuai, bukti buram):'),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(hintText: 'Alasan penolakan', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tolak', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final prov = Provider.of<InvestmentProvider>(context, listen: false);
      final success = await prov.updateStatus(id, 'rejected', notes: reasonController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Investasi #$id telah ditolak' : (prov.errorMessage ?? 'Gagal')),
            backgroundColor: success ? AppColors.warning : AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final investProv = Provider.of<InvestmentProvider>(context);
    final summary = investProv.dashboardSummary;
    final list = investProv.allInvestments;

    final target = summary != null ? double.parse(summary['project']['funding_target'].toString()) : 225000000.0;
    final verifiedAmount = summary != null ? double.parse(summary['total_verified_amount'].toString()) : 0.0;
    final percentage = summary != null ? double.parse(summary['funding_percentage'].toString()) : 0.0;
    final pendingCount = summary != null ? summary['pending_count'] ?? 0 : 0;
    final verifiedCount = summary != null ? summary['verified_count'] ?? 0 : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard Admin IGOTO', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Pengelolaan & Rekapitulasi Investor', style: TextStyle(fontSize: 10, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 22),
            tooltip: 'Ekspor Rekap PDF',
            onPressed: _exportPdf,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 20),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary Cards
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ringkasan Dana Pendanaan Meja Kursi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _cardMetric('Terkumpul', CurrencyFormatter.format(verifiedAmount), AppColors.success),
                        _cardMetric('Plafon Proyek', CurrencyFormatter.format(target), AppColors.textPrimary),
                        _cardMetric('Progres', '${percentage.toStringAsFixed(1)}%', AppColors.primary),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _badgeCount('Menunggu Verifikasi', pendingCount, const Color(0xFFD97706)),
                        _badgeCount('Terverifikasi', verifiedCount, AppColors.success),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Export PDF Button Banner
              CustomButton(
                text: 'Cetak & Ekspor Rekapitulasi PDF',
                icon: Icons.print,
                backgroundColor: const Color(0xFF0F766E),
                onPressed: _exportPdf,
              ),
              const SizedBox(height: 16),

              // Filter Chips
              Row(
                children: [
                  const Text('Filter: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterChip('Semua', 'all'),
                          _filterChip('Pending', 'pending'),
                          _filterChip('Verified', 'verified'),
                          _filterChip('Rejected', 'rejected'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Investments List
              if (investProv.isLoading) ...[
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                ),
              ] else if (list.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: const Text('Tidak ada pengajuan pada filter ini', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final item = list[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.investorName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                  Text('${item.phone} • ${item.bankName} (${item.accountNumber})', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                ],
                              ),
                              StatusBadge(status: item.status),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Modal Investasi', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                  Text(CurrencyFormatter.format(item.amount), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Total Pengembalian', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                  Text(CurrencyFormatter.format(item.totalReturn), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.success)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Proof & Actions
                          Row(
                            children: [
                              OutlinedButton.icon(
                                icon: const Icon(Icons.image_outlined, size: 16),
                                label: const Text('Bukti Foto', style: TextStyle(fontSize: 11)),
                                onPressed: () => _showProofDialog(item.transferProofPath),
                              ),
                              const Spacer(),
                              if (item.isPending) ...[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, visualDensity: VisualDensity.compact),
                                  onPressed: () => _verifyInvestment(item.id),
                                  child: const Text('Verifikasi', style: TextStyle(fontSize: 11)),
                                ),
                                const SizedBox(width: 6),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), visualDensity: VisualDensity.compact),
                                  onPressed: () => _rejectInvestment(item.id),
                                  child: const Text('Tolak', style: TextStyle(fontSize: 11)),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardMetric(String title, String val, Color col) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        Text(val, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: col)),
      ],
    );
  }

  Widget _badgeCount(String title, int count, Color col) {
    return Row(
      children: [
        CircleAvatar(radius: 10, backgroundColor: col.withValues(alpha: 0.15), child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: col))),
        const SizedBox(width: 6),
        Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
        selected: selected,
        onSelected: (_) {
          setState(() => _selectedFilter = value);
          Provider.of<InvestmentProvider>(context, listen: false).fetchAllInvestments(status: value);
        },
      ),
    );
  }
}
