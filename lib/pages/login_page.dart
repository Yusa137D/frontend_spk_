import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Import Dio untuk Exception Handling
import '../services/api_service.dart'; // Import ApiService
import 'dashboard_page.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePass = true;

  // ─── Colors ───────────────────────────────────────────────────────────────
  static const Color _blue = Color(0xFF2563EB);
  static const Color _textMain = Color(0xFF1E293B);
  static const Color _textSub = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _inputBg = Color(0xFFF8FAFC);

  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.]+@gmail\.com$").hasMatch(email);
  }

  // ── Logic Bersih dengan ApiService ─────────────────────────────
  Future<void> _handleLogin() async {
    if (_userController.text.isEmpty || _passController.text.isEmpty) {
      _showMsg("Email dan password tidak boleh kosong!", Colors.orange);
      return;
    }

    if (!_isValidEmail(_userController.text.trim())) {
      _showMsg("Gunakan format email @gmail.com yang valid!", Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final response = await ApiService.dio.post("/login", data: {
        "email": _userController.text.trim(),
        "password": _passController.text,
      });

      if (!mounted) return;
      
      final res = response.data;
      Map userData = res['user'];
      String namaTampilan = userData['username'] ?? "User";

      _showMsg("Selamat datang, $namaTampilan!", Colors.green);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage(user: userData)),
      );
      
    } on DioException catch (e) {
      if (!mounted) return;
      _showMsg(e.response?.data['message'] ?? "Email atau Password salah!", Colors.red);
    } catch (e) {
      if (!mounted) return;
      _showMsg("Koneksi ke server gagal!", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -60,
                    right: -60,
                    child: _decorCircle(220, Colors.white.withOpacity(0.06)),
                  ),
                  Positioned(
                    bottom: 80,
                    left: -80,
                    child: _decorCircle(280, Colors.white.withOpacity(0.05)),
                  ),
                  Positioned(
                    top: 200,
                    right: 40,
                    child: _decorCircle(100, Colors.white.withOpacity(0.07)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 52,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.school_rounded,
                                color: _blue,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "SPK Kinerja Guru",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  "Sistem Pendukung Keputusan",
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 60),

                        const Text(
                          "Sistem Penilaian\nKinerja Guru",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Mendukung penilaian kinerja guru secara\nobjektif, transparan, dan berkelanjutan.",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 48),

                        _featureItem(
                          Icons.verified_user_rounded,
                          "Penilaian Objektif",
                          "Proses penilaian berdasarkan kriteria yang terukur dan transparan.",
                        ),
                        const SizedBox(height: 24),
                        _featureItem(
                          Icons.bar_chart_rounded,
                          "Data Terintegrasi",
                          "Semua data penilaian tersimpan aman dan terintegrasi dalam sistem.",
                        ),
                        const SizedBox(height: 24),
                        _featureItem(
                          Icons.groups_rounded,
                          "Mendukung Pengembangan",
                          "Hasil penilaian digunakan untuk pengembangan kompetensi guru.",
                        ),

                        const Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 4,
            child: Container(
              color: const Color(0xFFF1F5F9),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 48,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 30,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              color: _blue,
                              size: 38,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Center(
                          child: Text(
                            "SPK KINERJA GURU",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: _textMain,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Center(
                          child: Text(
                            "Silakan masuk menggunakan email Gmail",
                            style: TextStyle(color: _textSub, fontSize: 13.5),
                          ),
                        ),

                        const SizedBox(height: 36),

                        const Text(
                          "Email Gmail",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                            color: _textMain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _inputField(
                          controller: _userController,
                          hint: "contoh@gmail.com",
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Password",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                            color: _textMain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _inputField(
                          controller: _passController,
                          hint: "Masukkan password",
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                        ),

                        const SizedBox(height: 28),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Lupa Password?",
                              style: TextStyle(
                                color: _blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: _blue,
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _blue,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    "LOGIN",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: Colors.grey.shade200),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                "atau",
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: Colors.grey.shade200),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterPage(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.person_add_outlined,
                              size: 18,
                              color: _blue,
                            ),
                            label: const Text(
                              "Belum punya akun? Daftar di sini",
                              style: TextStyle(
                                color: _blue,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: _border,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && _obscurePass,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: _textMain),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
        prefixIcon: Icon(icon, color: _textSub, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePass
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _textSub,
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

  Widget _featureItem(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12.5,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _decorCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}