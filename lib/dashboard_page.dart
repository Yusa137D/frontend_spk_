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
  int _selectedMenu = 0;

  // ─── Color palette (matches reference blue gradient) ───────────────────────
  static const Color _sidebarTop    = Color(0xFF1E3A8A);
  static const Color _sidebarBot    = Color(0xFF2563EB);
  static const Color _accent        = Color(0xFF2563EB);
  static const Color _accentLight   = Color(0xFFEFF6FF);
  static const Color _bg            = Color(0xFFF1F5F9);
  static const Color _cardBg        = Colors.white;
  static const Color _textPrimary   = Color(0xFF1E293B);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _green         = Color(0xFF22C55E);

  @override
  void initState() {
    super.initState();
    if (_isGuru) fetchNilaiSaya();
  }

  bool get _isGuru  => widget.user['role'].toString().toLowerCase().contains('guru');
  bool get _isAdmin => widget.user['role'].toString().toLowerCase().contains('admin');
  bool get _isKepsek =>
      widget.user['role'].toString().toLowerCase().contains('kepala') ||
      widget.user['role'].toString().toLowerCase().contains('kepsek');

  Future<void> fetchNilaiSaya() async {
    setState(() => _isLoadingNilai = true);
    try {
      final res = await http.get(
        Uri.parse(
            "http://127.0.0.1:5000/api/nilai-saya/${widget.user['id_user']}"),
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
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
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
        boxShadow: [
          BoxShadow(color: Color(0x3300177B), blurRadius: 16, offset: Offset(4, 0)),
        ],
      ),
      child: Column(
        children: [
          // ── Logo ─────────────────────────────────────────
          const SizedBox(height: 36),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.shield_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("SPK",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1)),
                    Text("Sistem Pendukung Keputusan",
                        style: TextStyle(
                            color: Colors.white60,
                            fontSize: 9,
                            letterSpacing: 0.3)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),

          // ── Nav label ────────────────────────────────────
          _sideLabel("MENU UTAMA"),

          _sideItem(Icons.dashboard_rounded, "Dashboard", 0, () {
            setState(() => _selectedMenu = 0);
          }),

          _sideItem(Icons.assignment_rounded, "Kuesioner", 1, () {
            setState(() => _selectedMenu = 1);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    DaftarGuruKuesionerPage(idUser: widget.user['id_user']),
              ),
            );
          }),

          _sideItem(Icons.bar_chart_rounded, "Ranking", 2, () {
            setState(() => _selectedMenu = 2);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RankingPage()),
            );
          }),

          if (_isAdmin) ...[
            const SizedBox(height: 8),
            _sideLabel("ADMINISTRASI"),
            _sideItem(Icons.manage_accounts_rounded, "Kelola Guru", 3, () {
              setState(() => _selectedMenu = 3);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KelolaGuruPage()),
              );
            }),
          ],

          const Spacer(),

          // ── Help box ─────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: Colors.white70, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Hubungi admin untuk bantuan",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8), fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          // ── Logout ───────────────────────────────────────
          InkWell(
            onTap: _logout,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: const [
                  Icon(Icons.logout_rounded, color: Colors.white70, size: 18),
                  SizedBox(width: 10),
                  Text("Keluar",
                      style: TextStyle(color: Colors.white, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sideLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(label,
            style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2)),
      ),
    );
  }

  Widget _sideItem(
      IconData icon, String title, int index, VoidCallback onTap) {
    final bool selected = _selectedMenu == index;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? Colors.white : Colors.white60, size: 19),
            const SizedBox(width: 12),
            Text(title,
                style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13.5)),
            if (selected) ...[
              const Spacer(),
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════ MAIN CONTENT ════════════════════════════════

  Widget _buildMainContent() {
    return Container(
      height: double.infinity,
      color: _bg,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
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

  // ── Top bar ──────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Dashboard SPK",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                    letterSpacing: -0.5)),
            const SizedBox(height: 3),
            Text(
              "Selamat datang kembali, ${widget.user['nama_lengkap']}",
              style:
                  const TextStyle(color: _textSecondary, fontSize: 13.5),
            ),
          ],
        ),
        Row(
          children: [
            // Notification bell
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 8,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: const Icon(Icons.notifications_none_rounded,
                  color: _textSecondary, size: 20),
            ),
            const SizedBox(width: 12),
            // User chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 8,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: _accent,
                    child: Text(
                      widget.user['nama_lengkap'][0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user['nama_lengkap'],
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: _textPrimary),
                      ),
                      Text(
                        widget.user['role'],
                        style: const TextStyle(
                            fontSize: 10, color: _textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 16, color: _textSecondary),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Stat cards ───────────────────────────────────────────────────────────

  Widget _buildStatCards() {
    return Row(
      children: [
        _statCard(
          icon: Icons.star_rounded,
          iconColor: const Color(0xFF2563EB),
          iconBg: const Color(0xFFEFF6FF),
          label: "Nilai TOPSIS",
          value: _isGuru
              ? "${nilaiSaya?['nilai_topsis'] ?? '-'}"
              : "-",
        ),
        _statCard(
          icon: Icons.emoji_events_rounded,
          iconColor: const Color(0xFFF59E0B),
          iconBg: const Color(0xFFFFFBEB),
          label: "Predikat",
          value: _isGuru
              ? "${nilaiSaya?['predikat'] ?? '-'}"
              : "-",
        ),
        _statCard(
          icon: Icons.assignment_turned_in_rounded,
          iconColor: const Color(0xFF22C55E),
          iconBg: const Color(0xFFF0FDF4),
          label: "Status",
          value: _isGuru ? "Aktif" : "-",
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: _textSecondary, fontSize: 12.5)),
                  const SizedBox(height: 4),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Detail Nilai Guru ────────────────────────────────────────────────────

  Widget _buildDetailNilaiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Detail Penilaian",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textPrimary)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: _buildNilaiGuruCard(),
        ),
      ],
    );
  }

  Widget _buildNilaiGuruCard() {
    if (_isLoadingNilai) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(color: _accent),
      ));
    }

    if (nilaiSaya == null) {
      return Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: _textSecondary, size: 18),
          const SizedBox(width: 10),
          const Text("Data belum tersedia",
              style: TextStyle(color: _textSecondary)),
        ],
      );
    }

    double nilai =
        double.tryParse(nilaiSaya!['nilai_topsis'].toString()) ?? 0;

    return Row(
      children: [
        // Score ring
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: nilai / 100,
                strokeWidth: 8,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(_accent),
              ),
              Text(
                "${nilai.toStringAsFixed(0)}",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Nilai TOPSIS: ${nilai.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      nilaiSaya!['predikat'],
                      style: const TextStyle(
                          color: _green,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: nilai / 100,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(_accent),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Menu Navigasi ────────────────────────────────────────────────────────

  Widget _buildMenuNavigasi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Aksi Cepat",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textPrimary)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            if (_isGuru || widget.user['role'].toString().toLowerCase().contains('siswa'))
              _menuBox(
                "Isi Kuesioner",
                Icons.assignment_rounded,
                const Color(0xFF2563EB),
                const Color(0xFFEFF6FF),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DaftarGuruKuesionerPage(
                        idUser: widget.user['id_user']),
                  ),
                ),
              ),

            if (_isKepsek || _isAdmin)
              _menuBox(
                "Lihat Ranking",
                Icons.leaderboard_rounded,
                const Color(0xFFF59E0B),
                const Color(0xFFFFFBEB),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RankingPage()),
                ),
              ),

            if (_isAdmin)
              _menuBox(
                "Kelola Guru",
                Icons.manage_accounts_rounded,
                const Color(0xFFEF4444),
                const Color(0xFFFEF2F2),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KelolaGuruPage()),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _menuBox(String title, IconData icon, Color color, Color bgColor,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 155,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 12),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: _textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}