import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int _step = 1; // 1 = Input Email, 2 = Input OTP & Password Baru
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPassController = TextEditingController();

  final Dio _dio = Dio();
  bool _isLoading = false;
  bool _obscurePass = true;

  // ─── Colors ───
  static const Color _blue = Color(0xFF2563EB);
  static const Color _blueDark = Color(0xFF1E3A8A);
  static const Color _textMain = Color(0xFF1E293B);
  static const Color _inputBg = Color(0xFFF8FAFC);
  static const Color _border = Color(0xFFE2E8F0);

  void _showMsg(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ==========================================
  // TAHAP 1: REQUEST OTP (VIA WA)
  // ==========================================
  Future<void> _requestOTP() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.endsWith("@gmail.com")) {
      _showMsg("Masukkan email @gmail.com yang valid!", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _dio.post(
        "https://web-production-1379e.up.railway.app/api/forgot-password",
        data: {"email": email},
      );

      if (response.statusCode == 200) {
        _showMsg("Kode OTP telah dikirim ke WhatsApp Anda!", Colors.green);
        setState(() => _step = 2); // Pindah ke halaman input OTP
      }
    } on DioException catch (e) {
      String msg = e.response?.data['message'] ?? "Gagal mengirim OTP";
      _showMsg(msg, Colors.red);
    } catch (e) {
      _showMsg("Koneksi gagal ke server", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ==========================================
  // TAHAP 2: RESET PASSWORD
  // ==========================================
  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final newPass = _newPassController.text;

    if (otp.isEmpty || newPass.isEmpty) {
      _showMsg("Isi semua field yang kosong!", Colors.orange);
      return;
    }
    if (newPass.length < 6) {
      _showMsg("Password minimal 6 karakter!", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _dio.post(
        "https://web-production-1379e.up.railway.app/api/reset-password",
        data: {"email": email, "otp": otp, "new_password": newPass},
      );

      if (response.statusCode == 200) {
        _showMsg("Password berhasil diperbarui! Silakan login.", Colors.green);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context); // Kembali ke halaman Login
        });
      }
    } on DioException catch (e) {
      String msg = e.response?.data['message'] ?? "OTP Salah atau Kadaluarsa";
      _showMsg(msg, Colors.red);
    } catch (e) {
      _showMsg("Koneksi gagal ke server", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: _blueDark,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Pemulihan Akun", style: TextStyle(fontSize: 16)),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(40),
            margin: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: _blue,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _step == 1 ? "Lupa Password?" : "Verifikasi OTP",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _textMain,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _step == 1
                      ? "Masukkan email terdaftar Anda. Kami akan mengirimkan kode pemulihan ke nomor WhatsApp yang terhubung dengan email ini."
                      : "Masukkan kode 6 digit yang baru saja kami kirim ke WhatsApp Anda.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13.5,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),

                // --- KONDISI TAHAP 1 (MINTA OTP) ---
                if (_step == 1) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Email Terdaftar",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        color: _textMain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _inputField(
                    controller: _emailController,
                    hint: "contoh@gmail.com",
                    icon: Icons.email_outlined,
                    type: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 32),
                  _actionBtn("KIRIM KODE OTP (VIA WA)", _requestOTP),
                ]
                // --- KONDISI TAHAP 2 (INPUT OTP & PASSWORD BARU) ---
                else ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Kode OTP WhatsApp",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        color: _textMain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _inputField(
                    controller: _otpController,
                    hint: "Masukkan 6 digit angka",
                    icon: Icons.pin_outlined,
                    type: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Password Baru",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        color: _textMain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _inputField(
                    controller: _newPassController,
                    hint: "Minimal 6 karakter",
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                  ),
                  const SizedBox(height: 32),
                  _actionBtn("SIMPAN PASSWORD BARU", _resetPassword),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => setState(() {
                      _step = 1;
                      _otpController.clear();
                      _newPassController.clear();
                    }),
                    child: const Text(
                      "Ganti Email / Kirim Ulang",
                      style: TextStyle(color: _blue),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ──
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && _obscurePass,
      keyboardType: type,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0BEC5)),
        prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePass
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              )
            : null,
        filled: true,
        fillColor: _inputBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _blue, width: 1.8),
        ),
      ),
    );
  }

  Widget _actionBtn(String label, VoidCallback action) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _blue))
          : ElevatedButton(
              onPressed: action,
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
    );
  }
}
