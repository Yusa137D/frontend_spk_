import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Import Dio untuk Exception Handling
import '../services/api_service.dart'; // Import ApiService

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _userController   = TextEditingController();
  final _waController     = TextEditingController();
  final _passController   = TextEditingController();
  final _namaController   = TextEditingController();
  final _indukController  = TextEditingController();
  final _kelasController  = TextEditingController();

  String _selectedRole = 'Siswa';
  bool _isLoading      = false;
  bool _obscurePass    = true;

  static const Color _blue     = Color(0xFF2563EB);
  static const Color _blueDark = Color(0xFF1E3A8A);
  static const Color _textMain = Color(0xFF1E293B);
  static const Color _textSub  = Color(0xFF64748B);
  static const Color _border   = Color(0xFFE2E8F0);
  static const Color _inputBg  = Color(0xFFF8FAFC);
  static const Color _infoBg   = Color(0xFFEFF6FF);

  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.]+@gmail\.com$").hasMatch(email);
  }

  // ── Logic Bersih dengan ApiService (TIDAK ADA YANG DIUBAH) ──
  Future<void> _handleRegister() async {
    if (_userController.text.isEmpty ||
        _waController.text.isEmpty ||
        _passController.text.isEmpty ||
        _indukController.text.isEmpty) {
      _showMsg("Semua field wajib diisi!", Colors.orange);
      return;
    }

    if (!_isValidEmail(_userController.text.trim())) {
      _showMsg("Gunakan format email @gmail.com yang valid!", Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ApiService.dio.post("/register", data: {
        "username":     _namaController.text.trim(),
        "email":        _userController.text.trim(),
        "no_wa":        _waController.text.trim(),
        "password":     _passController.text,
        "role":         _selectedRole,
        "nomor_induk":  _indukController.text.trim(),
        "kelas":        _kelasController.text.trim(),
      });

      if (response.statusCode == 201 && mounted) {
        _showMsg("Registrasi Berhasil! Silakan Login", Colors.green);
        Navigator.pop(context);
      }
    } on DioException catch (e) {
      String errorMessage = "Registrasi Gagal";
      if (e.response != null && e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      _showMsg(errorMessage, Colors.red);
    } catch (e) {
      _showMsg("Koneksi gagal ke server", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
        title: const Text(
          "Daftar Akun Baru",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      // ── MENGGUNAKAN LAYOUT BUILDER AGAR RESPONSIF ──
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Jika layar sempit (HP), sembunyikan banner kiri
          if (constraints.maxWidth < 800) {
            return Center(child: _buildRegisterForm());
          } else {
            // Jika layar lebar (Laptop), tampilkan Banner dan Form berdampingan
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 5, child: _buildBanner()),
                Expanded(flex: 6, child: Center(child: _buildRegisterForm())),
              ],
            );
          }
        },
      ),
    );
  }

  // ── WIDGET BANNER KIRI (Khusus Layar Besar) ──
  Widget _buildBanner() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -50, right: -50, child: _decorCircle(200, Colors.white.withOpacity(0.06))),
          Positioned(top: 130, right: 30, child: _decorCircle(90, Colors.white.withOpacity(0.05))),
          Positioned(bottom: 60, left: -70, child: _decorCircle(230, Colors.white.withOpacity(0.05))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.school_rounded, color: _blue, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("SPK Kinerja Guru", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                        Text("Sistem Pendukung Keputusan", style: TextStyle(color: Colors.white60, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 52),
                const Text("Buat Akun Baru", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, height: 1.2)),
                const SizedBox(height: 14),
                Text("Daftarkan akun Anda untuk mulai menggunakan\nsistem penilaian kinerja guru secara mudah\ndan terintegrasi.", style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13.5, height: 1.65)),
                const SizedBox(height: 44),
                _featureItem(Icons.verified_user_rounded, "Akses Aman", "Data Anda dilindungi dengan sistem keamanan berlapis."),
                const SizedBox(height: 22),
                _featureItem(Icons.person_rounded, "Mudah Digunakan", "Interface sederhana untuk pengalaman pengguna yang lebih baik."),
                const SizedBox(height: 22),
                _featureItem(Icons.bar_chart_rounded, "Terintegrasi", "Semua proses penilaian terhubung dalam satu sistem."),
                const Spacer(),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Sudah punya akun? ", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text("Masuk di sini", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13, decoration: TextDecoration.underline, decorationColor: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── WIDGET FORM PENDAFTARAN ──
  Widget _buildRegisterForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600), // Batas lebar di Laptop agar tidak melar
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.person_add_rounded, color: _blue, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Form Pendaftaran", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textMain)),
                      SizedBox(height: 3),
                      Text("Lengkapi data berikut untuk membuat akun baru", style: TextStyle(color: _textSub, fontSize: 12.5)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),
            Divider(color: Colors.grey.shade100, thickness: 1.5),
            const SizedBox(height: 24),

            _fieldLabel("Nama Lengkap"),
            const SizedBox(height: 8),
            _inputField(controller: _namaController, hint: "Masukkan nama lengkap Anda", icon: Icons.person_outline_rounded),

            const SizedBox(height: 18),
            _fieldLabel("Email Gmail"),
            const SizedBox(height: 8),
            _inputField(controller: _userController, hint: "contoh@gmail.com", icon: Icons.alternate_email_rounded, type: TextInputType.emailAddress),

            const SizedBox(height: 18),
            _fieldLabel("Nomor WhatsApp Aktif"),
            const SizedBox(height: 8),
            _inputField(controller: _waController, hint: "Contoh: 081234567890", icon: Icons.phone_android_rounded, type: TextInputType.phone),

            const SizedBox(height: 18),
            _fieldLabel("Password"),
            const SizedBox(height: 8),
            _inputField(controller: _passController, hint: "Masukkan password", icon: Icons.lock_outline_rounded, isPassword: true),

            const SizedBox(height: 18),
            _fieldLabel("Daftar Sebagai"),
            const SizedBox(height: 8),
            _dropdownRole(),

            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel(_selectedRole == 'Guru' ? "NIP" : "NISN"),
                      const SizedBox(height: 8),
                      _inputField(controller: _indukController, hint: _selectedRole == 'Guru' ? "Masukkan NIP" : "Masukkan NISN", icon: Icons.badge_outlined),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel("Kelas (Contoh: 10A)"),
                      const SizedBox(height: 8),
                      _inputField(controller: _kelasController, hint: "Contoh: 10A", icon: Icons.class_outlined),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _infoBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_rounded, color: _blue, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Informasi", style: TextStyle(color: _blue, fontWeight: FontWeight.w700, fontSize: 13)),
                        SizedBox(height: 4),
                        Text("Pastikan data yang Anda masukkan sudah benar.\nData tidak dapat diubah setelah akun dibuat.", style: TextStyle(color: Color(0xFF1D4ED8), fontSize: 12, height: 1.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _blue))
                  : ElevatedButton.icon(
                      onPressed: _handleRegister,
                      icon: const Icon(Icons.person_add_rounded, size: 18),
                      label: const Text("DAFTAR SEKARANG", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── KOMPONEN BANTUAN UI ──
  Widget _fieldLabel(String label) => Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: _textMain));

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
      style: const TextStyle(fontSize: 14, color: _textMain),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
        prefixIcon: Icon(icon, color: _textSub, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: _textSub, size: 20),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              )
            : null,
        filled: true,
        fillColor: _inputBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _blue, width: 1.8)),
      ),
    );
  }

  Widget _dropdownRole() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRole,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _textSub),
          items: ['Siswa', 'Guru'].map((r) {
            return DropdownMenuItem(
              value: r,
              child: Row(
                children: [
                  Icon(r == 'Guru' ? Icons.school_rounded : Icons.person_rounded, color: _blue, size: 18),
                  const SizedBox(width: 10),
                  Text(r, style: const TextStyle(fontSize: 14, color: _textMain)),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedRole = val.toString()),
        ),
      ),
    );
  }

  Widget _featureItem(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12.5, height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _decorCircle(double size, Color color) => Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}