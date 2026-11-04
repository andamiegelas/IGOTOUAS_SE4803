import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/investment_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../services/camera_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/status_badge.dart';
import '../auth/login_screen.dart';

class InvestorMainScreen extends StatefulWidget {
  const InvestorMainScreen({super.key});

  @override
  State<InvestorMainScreen> createState() => _InvestorMainScreenState();
}

class _InvestorMainScreenState extends State<InvestorMainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProjectProvider>(context, listen: false).fetchActiveProject();
      Provider.of<InvestmentProvider>(context, listen: false).fetchMyInvestments();
    });
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    final tabs = [
      _buildProjectTab(),
      _buildLocationTab(),
      _buildInvestTab(),
      _buildHistoryTab(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'IGOTO Mobile',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'Halo, ${user?.name ?? "Investor"}',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 20),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Proyek',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Lokasi Peta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Pengajuan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }

  // TAB 1: PROYEK & SIMULASI
  Widget _buildProjectTab() {
    final projectProv = Provider.of<ProjectProvider>(context);
    final project = projectProv.activeProject;

    if (projectProv.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (project == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Belum ada data proyek aktif'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => projectProv.fetchActiveProject(),
              child: const Text('Muat Ulang'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => projectProv.fetchActiveProject(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Project Header Card
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          project.companyName,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Bagi Hasil: ${project.profitPercentage}%',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    project.projectName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    project.description,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const Divider(height: 24),

                  // Progress Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Terkumpul:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      Text(
                        '${project.fundingPercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (project.fundingPercentage / 100).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Dana Terverifikasi', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          Text(
                            CurrencyFormatter.format(project.totalVerified),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.success),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Target Plafon', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          Text(
                            CurrencyFormatter.format(project.fundingTarget),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Simulation Widget
            _SimulationWidget(project: project),
            const SizedBox(height: 16),

            // Action Button
            CustomButton(
              text: 'Ajukan Investasi Proyek Ini',
              icon: Icons.monetization_on_outlined,
              onPressed: () {
                setState(() => _currentIndex = 2);
              },
            ),
          ],
        ),
      ),
    );
  }

  // TAB 2: PETA LOKASI GOOGLE MAPS
  Widget _buildLocationTab() {
    final project = Provider.of<ProjectProvider>(context).activeProject;
    final location = project?.location;

    const defaultLat = -6.974001;
    const defaultLng = 107.630348;

    final lat = location?.latitude ?? defaultLat;
    final lng = location?.longitude ?? defaultLng;
    final title = location?.title ?? 'Workshop Furniture CV. Karya Amanah Sejati';
    final address = location?.address ?? 'Jl. Telekomunikasi No. 1, Terusan Buahbatu, Bandung';

    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('workshop_marker'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: title,
          snippet: 'Lokasi Workshop dan Produksi Furniture',
        ),
      ),
    };

    return Column(
      children: [
        // Map Container
        Expanded(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(lat, lng),
              zoom: 15.0,
            ),
            markers: markers,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
          ),
        ),

        // Location Detail Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.error, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                address,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                'Koordinat: $lat, $lng',
                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // TAB 3: PENGAJUAN INVESTASI (FORM + KAMERA)
  Widget _buildInvestTab() {
    return const _InvestmentFormView();
  }

  // TAB 4: RIWAYAT PENGAJUAN
  Widget _buildHistoryTab() {
    final investProv = Provider.of<InvestmentProvider>(context);
    final list = investProv.myInvestments;

    if (investProv.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => investProv.fetchMyInvestments(),
        child: Center(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text('Belum ada riwayat pengajuan investasi'),
                const SizedBox(height: 6),
                const Text('Pengajuan yang Anda buat akan muncul di sini', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() => _currentIndex = 2),
                  child: const Text('Mulai Investasi Sekarang'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => investProv.fetchMyInvestments(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
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
                    Text('ID #${item.id}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    StatusBadge(status: item.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.format(item.amount),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.account_balance, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('${item.bankName} - ${item.accountNumber}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Keuntungan (${item.profitPercentage}%):', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    Text(CurrencyFormatter.format(item.netProfit), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Pengembalian:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    Text(CurrencyFormatter.format(item.totalReturn), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
                if (item.notes != null && item.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('Catatan Admin: ${item.notes}', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.error)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// SIMULATION WIDGET
class _SimulationWidget extends StatefulWidget {
  final dynamic project;
  const _SimulationWidget({required this.project});

  @override
  State<_SimulationWidget> createState() => _SimulationWidgetState();
}

class _SimulationWidgetState extends State<_SimulationWidget> {
  final _amountController = TextEditingController(text: '1000000');
  double _amount = 1000000;

  void _calculate() {
    final parsed = double.tryParse(_amountController.text.replaceAll('.', '').replaceAll(',', '')) ?? 0.0;
    setState(() => _amount = parsed);
  }

  @override
  Widget build(BuildContext context) {
    final projectProv = Provider.of<ProjectProvider>(context, listen: false);
    final sim = projectProv.calculateSimulation(_amount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.calculate_outlined, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Kalkulator Simulasi Investasi',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          CustomTextField(
            controller: _amountController,
            label: 'Nominal Investasi (Rupiah)',
            hint: 'Contoh: 1000000',
            keyboardType: TextInputType.number,
            onChanged: (_) => _calculate(),
          ),
          const SizedBox(height: 8),

          // Quick nominal chips
          Wrap(
            spacing: 6,
            children: [1000000, 2500000, 5000000, 10000000].map((val) {
              return ChoiceChip(
                label: Text(CurrencyFormatter.format(val), style: const TextStyle(fontSize: 10)),
                selected: _amount == val.toDouble(),
                onSelected: (_) {
                  _amountController.text = val.toString();
                  _calculate();
                },
              );
            }).toList(),
          ),
          const Divider(height: 20),

          // Simulation results
          _simRow('Modal Investasi', CurrencyFormatter.format(_amount)),
          _simRow('Estimasi Keuntungan (${widget.project.profitPercentage}%)', CurrencyFormatter.format(sim['grossProfit']!), isPositive: true),
          _simRow('Biaya Administrasi', CurrencyFormatter.format(sim['adminFee']!)),
          const Divider(height: 12),
          _simRow('Total Pengembalian', CurrencyFormatter.format(sim['totalReturn']!), isBold: true),
        ],
      ),
    );
  }

  Widget _simRow(String label, String value, {bool isPositive = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: isBold ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 14 : 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isPositive ? AppColors.success : (isBold ? AppColors.primary : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

// FORM VIEW WITH HARDWARE CAMERA INPUT
class _InvestmentFormView extends StatefulWidget {
  const _InvestmentFormView();

  @override
  State<_InvestmentFormView> createState() => _InvestmentFormViewState();
}

class _InvestmentFormViewState extends State<_InvestmentFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bankController = TextEditingController();
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();

  File? _capturedProof;
  final CameraService _cameraService = CameraService();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bankController.dispose();
    _accountController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _takePhoto() async {
    final photo = await _cameraService.takePhoto();
    if (photo != null) {
      setState(() => _capturedProof = photo);
    }
  }

  void _pickGallery() async {
    final img = await _cameraService.pickFromGallery();
    if (img != null) {
      setState(() => _capturedProof = img);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_capturedProof == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wajib mengambil foto bukti transfer menggunakan kamera!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final project = Provider.of<ProjectProvider>(context, listen: false).activeProject;
    if (project == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proyek aktif tidak ditemukan')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.replaceAll('.', '').replaceAll(',', '')) ?? 0.0;
    final investProv = Provider.of<InvestmentProvider>(context, listen: false);

    final success = await investProv.submitInvestment(
      projectId: project.id,
      investorName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      bankName: _bankController.text.trim(),
      accountNumber: _accountController.text.trim(),
      amount: amount,
      transferProof: _capturedProof!,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengajuan investasi berhasil dikirim!'),
          backgroundColor: AppColors.success,
        ),
      );
      // Reset form
      _phoneController.clear();
      _bankController.clear();
      _accountController.clear();
      _amountController.clear();
      setState(() => _capturedProof = null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(investProv.errorMessage ?? 'Gagal mengirim pengajuan'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final investProv = Provider.of<InvestmentProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Silakan transfer ke Rekening CV. Karya Amanah Sejati (BCA: 1234567890), lalu foto bukti pembayaran langsung menggunakan kamera.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF1E3A8A)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _nameController,
              label: 'Nama Lengkap Investor',
              hint: 'Sesuai rekening',
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 14),

            CustomTextField(
              controller: _phoneController,
              label: 'Nomor WhatsApp / HP',
              hint: 'Contoh: 08123456789',
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nomor HP wajib diisi' : null,
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _bankController,
                    label: 'Nama Bank',
                    hint: 'Contoh: BCA / Mandiri',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Bank wajib diisi' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _accountController,
                    label: 'Nomor Rekening',
                    hint: 'Nomor rekening Anda',
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Nomor rekening wajib diisi' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            CustomTextField(
              controller: _amountController,
              label: 'Nominal Dana yang Diinvestasikan (Rp)',
              hint: 'Contoh: 1000000',
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Nominal wajib diisi';
                final n = double.tryParse(v);
                if (n == null || n <= 0) return 'Nominal harus lebih dari 0';
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Camera Capture Section
            const Text(
              'Foto Bukti Pembayaran / Struk Transfer (Kamera)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  if (_capturedProof != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        _capturedProof!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.check_circle, color: AppColors.success, size: 16),
                        SizedBox(width: 6),
                        Text('Foto Bukti Siap Diunggah', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success)),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.camera_alt, size: 18),
                          label: const Text('Buka Kamera', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                          ),
                          onPressed: _takePhoto,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.photo_library, size: 18),
                          label: const Text('Pilih Galeri', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.border),
                          ),
                          onPressed: _pickGallery,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            CustomButton(
              text: 'Kirim Pengajuan Investasi',
              icon: Icons.send,
              isLoading: investProv.isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
