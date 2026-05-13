import 'package:flutter/material.dart';
import 'dart:html' as html;

import '../pages/login_page.dart';
import '../pages/daftar_guru_kuesioner_page.dart';
import '../pages/ranking_page.dart';
import '../pages/kelola_guru_page.dart';
import '../pages/kelola_siswa_page.dart';

class SidebarWidget extends StatelessWidget {
  final Map user;
  const SidebarWidget({super.key, required this.user});

  bool get _isGuru => user['role'].toString().toLowerCase().contains('guru');
  bool get _isAdmin => user['role'].toString().toLowerCase().contains('admin');
  bool get _isKepsek =>
      user['role'].toString().toLowerCase().contains('kepala') ||
      user['role'].toString().toLowerCase().contains('kepsek');
  bool get _isSiswa => user['role'].toString().toLowerCase().contains('siswa');

  void _downloadLaporan() {
    html.window.open(
      "https://web-production-1379e.up.railway.app/api/print-pdf",
      "_blank",
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 36),
          _buildLogo(),
          const SizedBox(height: 36),
          _sideLabel("MENU UTAMA"),
          _sideItem(Icons.dashboard_rounded, "Dashboard", true, () {}),

          if (_isGuru || _isSiswa)
            _sideItem(Icons.assignment_rounded, "Kuesioner", false, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      DaftarGuruKuesionerPage(idUser: user['id_user']),
                ),
              );
            }),

          _sideItem(Icons.bar_chart_rounded, "Ranking", false, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RankingPage()),
            );
          }),

          if (_isAdmin || _isKepsek) ...[
            const SizedBox(height: 8),
            _sideLabel("ADMINISTRASI"),
            if (_isAdmin) ...[
              _sideItem(
                Icons.manage_accounts_rounded,
                "Kelola Guru",
                false,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const KelolaGuruPage()),
                  );
                },
              ),
              _sideItem(Icons.people_alt_rounded, "Kelola Siswa", false, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KelolaSiswaPage()),
                );
              }),
            ],
            _sideItem(
              Icons.picture_as_pdf_rounded,
              "Cetak Laporan",
              false,
              _downloadLaporan,
            ),
          ],
          const Spacer(),
          InkWell(
            onTap: () => _logout(context),
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.logout_rounded, color: Colors.white70, size: 18),
                  SizedBox(width: 10),
                  Text(
                    "Keluar",
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
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
            child: const Icon(
              Icons.shield_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "SPK",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                "Sistem Pendukung Keputusan",
                style: TextStyle(color: Colors.white60, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sideLabel(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white38,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _sideItem(
    IconData icon,
    String title,
    bool selected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : Colors.white60,
              size: 19,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white70,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
