import 'package:flutter/material.dart';
import '../widgets/sidebar_widget.dart';
import 'daftar_guru_kuesioner_page.dart';

class SiswaDashboard extends StatelessWidget {
  final Map user;
  const SiswaDashboard({super.key, required this.user});

  static const Color _bg = Color(0xFFF1F5F9);
  static const Color _cardBg = Colors.white;
  static const Color _textPrimary = Color(0xFF1E293B);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _accent = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Cek apakah layar berukuran Desktop (lebar >= 800)
        bool isDesktop = constraints.maxWidth >= 800;

        return Scaffold(
          backgroundColor: _bg,
          // AppBar hanya muncul di mobile untuk memicu Drawer
          appBar: isDesktop
              ? null
              : AppBar(
                  backgroundColor: _cardBg,
                  foregroundColor: _textPrimary,
                  elevation: 0,
                  title: const Text("Dashboard Siswa", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
          // Sidebar masuk ke Drawer jika di Mobile
          drawer: isDesktop ? null : Drawer(child: SidebarWidget(user: user)),
          body: Row(
            children: [
              // Sidebar tampil di samping jika di Desktop
              if (isDesktop) SidebarWidget(user: user),
              Expanded(
                child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        padding: const EdgeInsets.all(28), 
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, 
                          children: [
                            if (isDesktop) _buildTopBar(), 
                            if (isDesktop) const SizedBox(height: 28), 
                            _buildStatCards(constraints.maxWidth), 
                            const SizedBox(height: 28), 
                            _buildMenuNavigasi(context)
                          ]
                        )
                      ),
                    ),
                  )
                )
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Dashboard Siswa", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _textPrimary)),
          Text("Selamat datang, ${user['username']}", style: const TextStyle(color: _textSecondary, fontSize: 13.5)),
        ]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(40)),
          child: Row(children: [
            CircleAvatar(radius: 16, backgroundColor: _accent, child: Text(user['username'][0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 13))),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user['username'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              Text(user['role'], style: const TextStyle(fontSize: 10, color: _textSecondary)),
            ]),
          ]),
        ),
      ],
    );
  }

  Widget _buildStatCards(double screenWidth) {
    // Jika layar sempit (HP), kartu akan memanjang ke bawah (double.infinity)
    double cardWidth = screenWidth < 600 ? double.infinity : 280;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _statCard(Icons.person_rounded, const Color(0xFF2563EB), const Color(0xFFEFF6FF), "Peran Akun", user['role'], cardWidth),
        _statCard(Icons.assignment_rounded, const Color(0xFFF59E0B), const Color(0xFFFFFBEB), "Tugas", "Menilai Guru", cardWidth),
        _statCard(Icons.check_circle_rounded, const Color(0xFF22C55E), const Color(0xFFF0FDF4), "Status", "Aktif", cardWidth),
      ],
    );
  }

  Widget _statCard(IconData icon, Color color, Color bg, String label, String value, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20), 
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(18)), 
      child: Row(
        children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color)), 
          const SizedBox(width: 16), 
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(label, style: const TextStyle(color: _textSecondary, fontSize: 12.5)), 
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textPrimary), overflow: TextOverflow.ellipsis)
              ]
            ),
          )
        ]
      )
    );
  }

  Widget _buildMenuNavigasi(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Aksi Cepat", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 14),
      Wrap(spacing: 16, runSpacing: 16, children: [
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DaftarGuruKuesionerPage(idUser: user['id_user']))), 
          child: Container(
            width: 155, 
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16), 
            decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 12, offset: const Offset(0, 4))]), 
            child: Column(
              children: [
                Container(width: 52, height: 52, decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.assignment_rounded, color: Color(0xFF2563EB))), 
                const SizedBox(height: 12), 
                const Text("Isi Kuesioner", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))
              ]
            )
          )
        ),
      ]),
    ]);
  }
}