import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_colors.dart';
import '../services/supabase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();

  String _avatar = 'boy';
  bool _isRegister = false;
  bool _isLoading = false;
  bool _showPass = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _namaCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error_outline,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  msg,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: isSuccess
              ? Colors.green.shade700
              : Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: Duration(seconds: isSuccess ? 3 : 4),
        ),
      );
  }

Future<void> _submit() async {
  FocusManager.instance.primaryFocus?.unfocus();
  if (mounted) ScaffoldMessenger.of(context).clearSnackBars();

  final email    = _emailCtrl.text.trim();
  final password = _passwordCtrl.text.trim();
  final nama     = _namaCtrl.text.trim();

  if (email.isEmpty || password.isEmpty) {
    _snack('Email dan password wajib diisi!');
    return;
  }
  if (password.length < 6) {
    _snack('Password minimal 6 karakter');
    return;
  }
  if (_isRegister && nama.isEmpty) {
    _snack('Nama Kode wajib diisi!');
    return;
  }

  setState(() => _isLoading = true);
  try {
    if (_isRegister) {
      final res = await SupabaseService.signUp(
        email: email,
        password: password,
        nama: nama,
        avatar: _avatar,
      );

      if (res.user == null) throw Exception('Pendaftaran gagal');
      if (res.session == null) {
        if (!mounted) return;
        _snack(
          'Berhasil! Cek email untuk verifikasi sebelum bertugas.',
          isSuccess: true,
        );
        setState(() => _isRegister = false);
        return;
      }
      return;

    } else {
      await SupabaseService.signIn(email: email, password: password);
      return;
    }

  } on AuthException catch (e) {
    if (!mounted) return;
    _snack(_friendlyError(e.message));
  } catch (e) {
    if (!mounted) return; 
    _snack('Ada yang tidak beres. Coba lagi sebentar ya!');
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  String _friendlyError(String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('invalid login') ||
        lower.contains('invalid credentials')) {
      return 'Email atau password salah. Periksa kembali ya!';
    }
    if (lower.contains('already registered')) {
      return 'Email ini sudah terdaftar. Langsung masuk saja!';
    }
    if (lower.contains('not confirmed') ||
        lower.contains('email not confirmed')) {
      return 'Kamu belum verifikasi email. Cek inbox kamu dulu!';
    }
    if (lower.contains('network') ||
        lower.contains('socket') ||
        lower.contains('connection') ||
        lower.contains('unreachable') ||
        lower.contains('failed host')) {
      return 'Tidak ada koneksi internet. '
          'Pastikan kamu terhubung ke Wi-Fi atau data seluler.';
    }
    if (lower.contains('timeout')) {
      return 'Koneksi terlalu lambat. Coba lagi dalam beberapa saat ya!';
    }
    return 'Ada yang tidak beres. Coba lagi sebentar ya!';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.primary,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            const Icon(Icons.security, size: 72, color: AppColors.amber),
            const SizedBox(height: 16),
            Text(
              _isRegister ? 'IDENTITAS DETEKTIF' : 'MASUK MARKAS',
              style: GoogleFonts.bebasNeue(fontSize: 36, color: Colors.white),
            ),
            Text(
              _isRegister
                  ? 'Daftarkan diri sebelum bertugas!'
                  : 'Selamat datang kembali, Detektif!',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 32),

            if (_isRegister) ...[
              const Text(
                'Pilih Foto Profil:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAvatarOption('boy', Icons.face),
                  const SizedBox(width: 20),
                  _buildAvatarOption('girl', Icons.face_3),
                ],
              ),
              const SizedBox(height: 20),
              _buildField(
                controller: _namaCtrl,
                label: 'Nama Kode (Codename)',
                icon: Icons.badge,
              ),
              const SizedBox(height: 14),
            ],

            _buildField(
              controller: _emailCtrl,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _passwordCtrl,
              label: 'Password',
              icon: Icons.lock_outline,
              obscure: !_showPass,
              suffix: IconButton(
                icon: Icon(
                  _showPass ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white54,
                  size: 20,
                ),
                onPressed: () => setState(() => _showPass = !_showPass),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        _isRegister ? 'CETAK KARTU & MULAI' : 'MASUK',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () => setState(() {
                _isRegister = !_isRegister;
                _emailCtrl.clear();
                _passwordCtrl.clear();
                _namaCtrl.clear();
                ScaffoldMessenger.of(context).clearSnackBars();
              }),
              child: Text(
                _isRegister
                    ? 'Sudah punya akun? Masuk di sini'
                    : 'Belum punya akun? Daftar sekarang',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white60,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
  }) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscure,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white10,
      prefixIcon: Icon(icon, color: AppColors.amber),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.amber, width: 1.5),
      ),
    ),
  );

  Widget _buildAvatarOption(String type, IconData icon) {
    final isSelected = _avatar == type;
    return GestureDetector(
      onTap: () => setState(() => _avatar = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.amber : Colors.white10,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Colors.white, width: 2.5)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.amber.withValues(alpha: 0.5),
                    blurRadius: 16,
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: 46,
          color: isSelected ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}
