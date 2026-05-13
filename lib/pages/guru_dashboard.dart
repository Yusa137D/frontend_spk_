import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/sidebar_widget.dart';
import 'daftar_guru_kuesioner_page.dart';

class GuruDashboard extends StatefulWidget {
  final Map user;
  const GuruDashboard({super.key, required this.user});

  @override
  State<GuruDashboard> createState() => _GuruDashboardState();
}

class _GuruDashboardState extends State<GuruDashboard> {
  Map? nilaiSaya;
  bool _isLoadingNilai = false;

  static const Color _bg = Color(0xFFF1F5F9);
  static const Color _cardBg = Colors.white;
  static const Color _textPrimary = Color(0xFF1E293B);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _green = Color(0xFF22C55E);
  static const Color _accent = Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();
    fetchNilaiSaya();
  }

  Future<void> fetchNilaiSaya() async {
    setState(() => _isLoadingNilai = true);
    
    final data = await ApiService.getNilaiGuru(widget.user['id_user'].toString());
    if (data != null && mounted) {
      setState(() => nilaiSaya = data);
    }
    
    if (mounted) setState(() => _isLoadingNilai = false);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Deteksi apakah layar cukup lebar untuk mode Desktop
        bool isDesktop = constraints.maxWidth >= 800;

        return Scaffold(
          backgroundColor: _bg,
          // AppBar khusus Mobile untuk memunculkan tombol Hamburger (Sidebar)
          appBar: isDesktop
              ? null
              : AppBar(
                  backgroundColor: _cardBg,
                  foregroundColor: _textPrimary,
                  elevation: 0,
                  title: const Text("Dashboard Guru", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
          // Drawer berfungsi sebagai Sidebar tersembunyi di Mobile
          drawer: isDesktop ? null : Drawer(child: SidebarWidget(user: widget.user)),
          body: Row(
            children: [
              // Sidebar menempel permanen hanya di Desktop
              if (isDesktop) SidebarWidget(user: widget.user),
              Expanded(
                child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1200), // Batas lebar konten di Web
                        padding: const EdgeInsets.all(28), 
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, 
                          children: [
                            if (isDesktop) _buildTopBar(), 
                            if (isDesktop) const SizedBox(height: 28), 
                            _buildStatCards(constraints.maxWidth), 
                            const SizedBox(height: 28), 
                            _buildDetailNilaiSection(), 
                            const SizedBox(height: 28), 
                            _buildMenuNavigasi()
                          ]
                        )
                      )
                    )
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
          const Text("Dashboard Guru", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _textPrimary)),
          Text("Selamat datang, ${widget.user['username']}", style: const TextStyle(color: _textSecondary, fontSize: 13.5)),
        ]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(40)),
          child: Row(children: [
            CircleAvatar(radius: 16, backgroundColor: _accent, child: Text(widget.user['username'][0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 13))),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.user['username'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              Text(widget.user['role'], style: const TextStyle(fontSize: 10, color: _textSecondary)),
            ]),
          ]),
        ),
      ],
    );
  }

  Widget _buildStatCards(double screenWidth) {
    // Menyesuaikan lebar kartu statistik: Penuh (Mobile) atau Tetap (Desktop)
    double cardWidth = screenWidth < 600 ? double.infinity : 280;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _statCard(Icons.star_rounded, const Color(0xFF2563EB), const Color(0xFFEFF6FF), "Nilai TOPSIS", "${nilaiSaya?['nilai_topsis'] ?? '-'}", cardWidth),
        _statCard(Icons.emoji_events_rounded, const Color(0xFFF59E0B), const Color(0xFFFFFBEB), "Predikat", "${nilaiSaya?['predikat'] ?? '-'}", cardWidth),
        _statCard(Icons.assignment_turned_in_rounded, const Color(0xFF22C55E), const Color(0xFFF0FDF4), "Status", "Aktif", cardWidth),
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
          // Expanded mencegah teks Overflow di layar HP kecil
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

  Widget _buildDetailNilaiSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Detail Penilaian", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(18)), child: _buildNilaiGuruCard()),
    ]);
  }

  Widget _buildNilaiGuruCard() {
    if (_isLoadingNilai) return const Center(child: CircularProgressIndicator(color: _accent));
    if (nilaiSaya == null) return const Text("Data belum tersedia", style: TextStyle(color: _textSecondary));
    
    double nilai = double.tryParse(nilaiSaya!['nilai_topsis'].toString()) ?? 0;
    
    return Row(children: [
      SizedBox(
        width: 80, 
        height: 80, 
        child: Stack(
          alignment: Alignment.center, 
          children: [
            CircularProgressIndicator(value: nilai / 100, strokeWidth: 8, backgroundColor: const Color(0xFFE2E8F0), valueColor: const AlwaysStoppedAnimation<Color>(_accent)), 
            Text(nilai.toStringAsFixed(0), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))
          ]
        )
      ),
      const SizedBox(width: 24),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Text("Nilai TOPSIS: ${nilai.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), 
            const SizedBox(height: 6), 
            Text(nilaiSaya!['predikat'], style: const TextStyle(color: _green, fontWeight: FontWeight.w600)), 
            const SizedBox(height: 12), 
            LinearProgressIndicator(value: nilai / 100, backgroundColor: const Color(0xFFE2E8F0), valueColor: const AlwaysStoppedAnimation<Color>(_accent))
          ]
        )
      ),
    ]);
  }

  Widget _buildMenuNavigasi() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Aksi Cepat", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 14),
      Wrap(spacing: 16, runSpacing: 16, children: [
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DaftarGuruKuesionerPage(idUser: widget.user['id_user']))), 
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