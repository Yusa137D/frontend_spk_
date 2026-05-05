import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'daftar_guru_kuesioner_page.dart';
import 'ranking_page.dart';
import 'kelola_guru_page.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  final Map user;
  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map? nilaiSaya;
  bool _isLoadingNilai = false;

  @override
  void initState() {
    super.initState();
    // Normalisasi role ke huruf kecil untuk pengecekan awal
    String roleLower = widget.user['role'].toString().toLowerCase();
    if (roleLower.contains('guru')) {
      fetchNilaiSaya();
    }
  }

  Future<void> fetchNilaiSaya() async {
    setState(() => _isLoadingNilai = true);
    try {
      final res = await http.get(
        Uri.parse("http://127.0.0.1:5000/api/nilai-saya/${widget.user['id_user']}"),
      );
      if (res.statusCode == 200) {
        setState(() => nilaiSaya = jsonDecode(res.body));
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingNilai = false);
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Normalisasi role agar fleksibel membaca "Kepala Sekolah" atau "Kepsek"
    String role = widget.user['role'].toString().toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard SPK"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _logout, 
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Selamat Datang,", style: TextStyle(color: Colors.grey[700])),
            Text(
              widget.user['nama_lengkap'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // TAMPILAN NILAI KHUSUS GURU
            if (role.contains('guru')) ...[
              const Text("Nilai Kinerja Anda:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildNilaiGuruCard(),
            ],

            const Divider(height: 40),
            const Text("Menu Navigasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // MENU: KUESIONER (Muncul untuk Siswa & Guru)
            if (role.contains('siswa') || role.contains('guru'))
              _menuItem(
                context,
                "Isi Kuesioner Penilaian",
                Icons.assignment_turned_in,
                Colors.blue,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DaftarGuruKuesionerPage(idUser: widget.user['id_user']),
                  ),
                ),
              ),

            // MENU: RANKING (Muncul untuk Kepsek/Kepala Sekolah & Admin)
            // Menggunakan .contains agar "Kepala Sekolah" terdeteksi
            if (role.contains('kepala') || role.contains('kepsek') || role.contains('admin'))
              _menuItem(
                context,
                "Lihat Ranking & Akumulasi Guru",
                Icons.leaderboard,
                Colors.orange,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RankingPage()),
                ),
              ),

            // MENU: KELOLA DATA (Hanya untuk Admin)
            if (role.contains('admin'))
              _menuItem(
                context,
                "Kelola Data Guru",
                Icons.settings_suggest,
                Colors.red,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KelolaGuruPage()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNilaiGuruCard() {
    if (_isLoadingNilai) return const Center(child: CircularProgressIndicator());
    if (nilaiSaya == null) return const Card(child: ListTile(title: Text("Data belum tersedia")));

    return Card(
      color: Colors.indigo[50],
      child: ListTile(
        leading: const Icon(Icons.workspace_premium, color: Colors.indigo, size: 40),
        title: Text("Skor: ${nilaiSaya!['nilai_topsis']}"),
        subtitle: Text("Predikat: ${nilaiSaya!['predikat']}"),
      ),
    );
  }

  Widget _menuItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}