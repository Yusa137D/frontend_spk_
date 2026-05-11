import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:html' as html;
import 'package:lottie/lottie.dart';

import 'daftar_guru_kuesioner_page.dart';
import 'ranking_page.dart';
import 'kelola_guru_page.dart';
import 'kelola_siswa_page.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  final Map user;
  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Dio _dio = Dio();
  Map? nilaiSaya;
  bool _isLoadingNilai = false;
  int _selectedMenu = 0;

  // Variabel penampung data nyata dari database
  int _totalGuru = 0;
  int _totalSiswa = 0;

  // ─── Color palette ────────────────────────────────────────────────────────
  static const Color _sidebarTop    = Color(0xFF1E3A8A);
  static const Color _sidebarBot    = Color(0xFF2563EB);
  static const Color _accent        = Color(0xFF2563EB);
  static const Color _bg            = Color(0xFFF1F5F9);
  static const Color _cardBg        = Colors.white;
  static const Color _textPrimary   = Color(0xFF1E293B);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _green         = Color(0xFF22C55E);

  @override
  void initState() {
    super.initState();
    if (_isGuru) fetchNilaiSaya();
    // Panggil fungsi hitung data jika yang login adalah Admin / Kepsek
    if (_isAdmin || _isKepsek) fetchDashboardStats(); 
  }

  bool get _isGuru  => widget.user['role'].toString().toLowerCase().contains('guru');
  bool get _isAdmin => widget.user['role'].toString().toLowerCase().contains('admin');
  bool get _isKepsek =>
      widget.user['role'].toString().toLowerCase().contains('kepala') ||
      widget.user['role'].toString().toLowerCase().contains('kepsek');
  bool get _isSiswa => widget.user['role'].toString().toLowerCase().contains('siswa');
  void _downloadLaporan() {
    html.window.open("http://127.0.0.1:5000/api/print-pdf", "_blank");
  }

  Future<void> fetchNilaiSaya() async {
    setState(() => _isLoadingNilai = true);
    try {
      final res = await _dio.get("http://127.0.0.1:5000/api/nilai-saya/${widget.user['id_user']}");
      if (res.statusCode == 200) {
        setState(() => nilaiSaya = res.data);
      }
    } catch (e) {
      debugPrint("Error fetching nilai: $e");
    } finally {
      if (mounted) setState(() => _isLoadingNilai = false);
    }
  }

  // Fungsi baru untuk mengambil total Guru dan Siswa
  Future<void> fetchDashboardStats() async {
    try {
      final res = await _dio.get("http://127.0.0.1:5000/api/dashboard-stats");
      if (res.statusCode == 200) {
        setState(() {
          _totalGuru = res.data['total_guru'] ?? 0;
          _totalSiswa = res.data['total_siswa'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint("Error fetching dashboard stats: $e");
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(child: _buildMainContent()), 
        ],
      ),
    );
  }

  // ═══════════════════════════ SIDEBAR ═════════════════════════════════════
  Widget _buildSidebar() {
    return Container(
      width: 240,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_sidebarTop, _sidebarBot],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 36),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.shield_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("SPK", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                    Text("Sistem Pendukung Keputusan", style: TextStyle(color: Colors.white60, fontSize: 9)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          _sideLabel("MENU UTAMA"),
          _sideItem(Icons.dashboard_rounded, "Dashboard", 0, () => setState(() => _selectedMenu = 0)),
if (_isGuru || _isSiswa)
  _sideItem(Icons.assignment_rounded, "Kuesioner", 1, () {
    Navigator.push(context, MaterialPageRoute(builder: (_) => DaftarGuruKuesionerPage(idUser: widget.user['id_user'])));
  }),
          _sideItem(Icons.bar_chart_rounded, "Ranking", 2, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const RankingPage()));
          }),

          if (_isAdmin || _isKepsek) ...[
            const SizedBox(height: 8),
            _sideLabel("ADMINISTRASI"),
            if (_isAdmin) ...[
              _sideItem(Icons.manage_accounts_rounded, "Kelola Guru", 3, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const KelolaGuruPage()));
              }),
              _sideItem(Icons.people_alt_rounded, "Kelola Siswa", 4, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const KelolaSiswaPage()));
              }),
            ],
            _sideItem(Icons.picture_as_pdf_rounded, "Cetak Laporan", 5, _downloadLaporan),
          ],

          const Spacer(),
          InkWell(
            onTap: _logout,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: const [
                  Icon(Icons.logout_rounded, color: Colors.white70, size: 18),
                  SizedBox(width: 10),
                  Text("Keluar", style: TextStyle(color: Colors.white, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════ MAIN CONTENT ════════════════════════════════
  Widget _buildMainContent() {
    return Container(
      color: _bg,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 28),
              _buildStatCards(), 
              if (_isGuru) ...[
                const SizedBox(height: 28),
                _buildDetailNilaiSection(),
              ],
              const SizedBox(height: 28),
              _buildMenuNavigasi(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Dashboard SPK", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _textPrimary)),
            Text("Selamat datang kembali, ${widget.user['username']}", style: const TextStyle(color: _textSecondary, fontSize: 13.5)),
          ],
        ),
        _userChip(),
      ],
    );
  }

  Widget _userChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(40)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isAdmin) 
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: AdminEasterEgg(),
            ),
          CircleAvatar(radius: 16, backgroundColor: _accent, child: Text(widget.user['username'][0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 13))),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.user['username'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              Text(widget.user['role'], style: const TextStyle(fontSize: 10, color: _textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    if (_isGuru) {
      return Row(
        children: [
          _statCard(Icons.star_rounded, const Color(0xFF2563EB), const Color(0xFFEFF6FF), "Nilai TOPSIS", "${nilaiSaya?['nilai_topsis'] ?? '-'}"),
          _statCard(Icons.emoji_events_rounded, const Color(0xFFF59E0B), const Color(0xFFFFFBEB), "Predikat", "${nilaiSaya?['predikat'] ?? '-'}"),
          _statCard(Icons.assignment_turned_in_rounded, const Color(0xFF22C55E), const Color(0xFFF0FDF4), "Status", "Aktif"),
        ],
      );
    } else {
      // TAMPILAN ADMIN / KEPSEK YANG BARU (DATA NYATA DARI DATABASE)
      return Row(
        children: [
          _statCard(Icons.admin_panel_settings_rounded, const Color(0xFF2563EB), const Color(0xFFEFF6FF), "Peran Akun", widget.user['role']),
          _statCard(Icons.groups_rounded, const Color(0xFFF59E0B), const Color(0xFFFFFBEB), "Total Guru", "$_totalGuru Terdaftar"),
          _statCard(Icons.school_rounded, const Color(0xFF22C55E), const Color(0xFFF0FDF4), "Total Siswa", "$_totalSiswa Terdaftar"),
        ],
      );
    }
  }

  Widget _statCard(IconData icon, Color color, Color bg, String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            Container(width: 50, height: 50, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color)),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(color: _textSecondary, fontSize: 12.5)),
              Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _textPrimary)), // Ukuran font sedikit disesuaikan
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailNilaiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Detail Penilaian", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(18)),
          child: _buildNilaiGuruCard(),
        ),
      ],
    );
  }

  Widget _buildNilaiGuruCard() {
    if (_isLoadingNilai) return const Center(child: CircularProgressIndicator(color: _accent));
    if (nilaiSaya == null) return const Text("Data belum tersedia", style: TextStyle(color: _textSecondary));

    double nilai = double.tryParse(nilaiSaya!['nilai_topsis'].toString()) ?? 0;
    return Row(
      children: [
        SizedBox(
          width: 80, height: 80,
          child: Stack(alignment: Alignment.center, children: [
            CircularProgressIndicator(value: nilai / 100, strokeWidth: 8, backgroundColor: const Color(0xFFE2E8F0), valueColor: const AlwaysStoppedAnimation<Color>(_accent)),
            Text("${nilai.toStringAsFixed(0)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ]),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Nilai TOPSIS: ${nilai.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(nilaiSaya!['predikat'], style: const TextStyle(color: _green, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: nilai / 100, backgroundColor: const Color(0xFFE2E8F0), valueColor: const AlwaysStoppedAnimation<Color>(_accent)),
          ]),
        ),
      ],
    );
  }

  Widget _buildMenuNavigasi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Aksi Cepat", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 16, runSpacing: 16,
          children: [
if (_isGuru || _isSiswa)
      _menuBox("Isi Kuesioner", Icons.assignment_rounded, const Color(0xFF2563EB), const Color(0xFFEFF6FF), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => DaftarGuruKuesionerPage(idUser: widget.user['id_user'])));
      }),
            if (_isKepsek || _isAdmin) ...[
              _menuBox("Lihat Ranking", Icons.leaderboard_rounded, const Color(0xFFF59E0B), const Color(0xFFFFFBEB), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RankingPage()));
              }),
              _menuBox("Cetak Laporan", Icons.picture_as_pdf_rounded, const Color(0xFF10B981), const Color(0xFFECFDF5), _downloadLaporan),
            ],
            if (_isAdmin) ...[
              _menuBox("Kelola Guru", Icons.manage_accounts_rounded, const Color(0xFFEF4444), const Color(0xFFFEF2F2), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const KelolaGuruPage()));
              }),
              _menuBox("Kelola Siswa", Icons.people_alt_rounded, const Color(0xFF8B5CF6), const Color(0xFFF5F3FF), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const KelolaSiswaPage()));
              }),
            ]
          ],
        ),
      ],
    );
  }

  Widget _sideLabel(String label) => Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 6), child: Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w700)));

  Widget _sideItem(IconData icon, String title, int index, VoidCallback onTap) {
    bool selected = _selectedMenu == index;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
        decoration: BoxDecoration(color: selected ? Colors.white.withOpacity(0.18) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [Icon(icon, color: selected ? Colors.white : Colors.white60, size: 19), const SizedBox(width: 12), Text(title, style: TextStyle(color: selected ? Colors.white : Colors.white70, fontSize: 13.5))]),
      ),
    );
  }

  Widget _menuBox(String title, IconData icon, Color color, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 155, padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 12, offset: const Offset(0, 4))]),
        child: Column(children: [Container(width: 52, height: 52, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color)), const SizedBox(height: 12), Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))]),
      ),
    );
  }
}

// Widget Robot Mungil untuk pendamping Nama Admin
class AdminEasterEgg extends StatelessWidget {
  const AdminEasterEgg({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 35,
      height: 35,
      child: Lottie.network(
        'https://assets9.lottiefiles.com/packages/lf20_xh83pj1c.json',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox(),
      ),
    );
  }
}