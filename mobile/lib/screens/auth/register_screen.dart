import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../investor/investor_main_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'investor';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
      _selectedRole,
    );

    if (!mounted) return;

    if (success) {
      if (auth.isAdmin) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const InvestorMainScreen()),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Registrasi gagal'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buat Akun Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama Anda',
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  label: 'Alamat Email',
                  hint: 'nama@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                    if (!v.contains('@')) return 'Format email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Kata Sandi',
                  hint: 'Minimal 6 karakter',
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  validator: (v) {
                    if (v == null || v.length < 6) return 'Kata sandi minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Peran Akun',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  items: const [
                    DropdownMenuItem(value: 'investor', child: Text('Investor')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin Perusahaan')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedRole = v);
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 28),
                CustomButton(
                  text: 'Daftar Sekarang',
                  isLoading: auth.isLoading,
                  onPressed: _register,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
