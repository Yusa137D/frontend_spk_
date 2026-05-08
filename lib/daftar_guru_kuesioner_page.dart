import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'form_kuesioner_page.dart';

class DaftarGuruKuesionerPage extends StatefulWidget {
  final int idUser;
  const DaftarGuruKuesionerPage({super.key, required this.idUser});

  @override
  State<DaftarGuruKuesionerPage> createState() =>
      _DaftarGuruKuesionerPageState();
}

class _DaftarGuruKuesionerPageState extends State<DaftarGuruKuesionerPage>
    with SingleTickerProviderStateMixin {
  List listGuru = [];
  List _filtered = [];
  bool _isLoading = true;
  final TextEditingController _searchCtrl = TextEditingController();
  late AnimationController _animController;

  // ── Brand colors ──────────────────────────────────────────────
  static const Color kPrimary = Color(0xFF1A5FA8);
  static const Color kBg      = Color(0xFFF0F4FA);
  static const Color kText    = Color(0xFF1A2340);
  static const Color kSubtext = Color(0xFF6B7A99);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _searchCtrl.addListener(_onSearch);
    fetchGuru();
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Logic (tidak diubah) ──────────────────────────────────────
  Future<void> fetchGuru() async {
    try {
      final response = await http
          .get(Uri.parse("http://127.0.0.1:5000/api/daftar-guru"));
      if (response.statusCode == 200) {
        setState(() {
          listGuru  = jsonDecode(response.body);
          _filtered = List.from(listGuru);
          _isLoading = false;
        });
        _animController.forward();
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // ── Search filter ─────────────────────────────────────────────
  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = listGuru.where((g) {
        final nama = (g['nama_guru'] ?? '').toString().toLowerCase();
        final nip  = (g['nip'] ?? '').toString().toLowerCase();
        return nama.contains(q) || nip.contains(q);
      }).toList();
    });
  }

  // ── Stat helpers ──────────────────────────────────────────────
  int get _totalGuru => listGuru
      .where((g) => g['id_guru'] != widget.idUser)
      .length;

  int get _sudahDinilai => listGuru
      .where((g) =>
          g['id_guru'] != widget.idUser &&
          (g['sudah_dinilai'] == true || g['sudah_dinilai'] == 1))
      .length;

  int get _belumDinilai => _totalGuru - _sudahDinilai;

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : _buildBody(),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: kBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 16, color: kText),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Pilih Guru untuk Dinilai',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: kText)),
                    Text('Pilih guru yang akan dilakukan penilaian kinerja.',
                        style: TextStyle(fontSize: 11, color: kSubtext)),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() => _isLoading = true);
                    _animController.reset();
                    fetchGuru();
                  },
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.refresh_rounded,
                        size: 18, color: kPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────
  Widget _buildBody() {
    // Build display list (exclude self — logic tidak diubah)
    final display = _filtered
        .where((g) => g['id_guru'] != widget.idUser)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search bar ──────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(fontSize: 13, color: kText),
                    decoration: InputDecoration(
                      hintText: 'Cari nama guru atau NIP...',
                      hintStyle: TextStyle(
                          fontSize: 13, color: kSubtext.withOpacity(0.7)),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Color(0xFF9AABCC), size: 20),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Stat cards ──────────────────────────────────────
          Row(
            children: [
              _StatCard(
                icon: Icons.people_alt_rounded,
                label: 'Total Guru',
                value: '$_totalGuru',
                sub: 'Guru terdaftar',
              ),
              const SizedBox(width: 14),
              _StatCard(
                icon: Icons.assignment_turned_in_rounded,
                label: 'Sudah Dinilai',
                value: '$_sudahDinilai',
                sub: _totalGuru > 0
                    ? '${(_sudahDinilai / _totalGuru * 100).toStringAsFixed(2)}% dari total guru'
                    : '0% dari total guru',
                subColor: const Color(0xFF2E7D32),
              ),
              const SizedBox(width: 14),
              _StatCard(
                icon: Icons.pending_actions_rounded,
                label: 'Belum Dinilai',
                value: '$_belumDinilai',
                sub: _totalGuru > 0
                    ? '${(_belumDinilai / _totalGuru * 100).toStringAsFixed(2)}% dari total guru'
                    : '0% dari total guru',
                subColor: const Color(0xFFF57F17),
              ),
              const SizedBox(width: 14),
              _StatCard(
                icon: Icons.calendar_month_rounded,
                label: 'Periode Penilaian',
                value: 'Mei 2024',
                sub: '01 Mei - 31 Mei 2024',
                valueFontSize: 15,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Table ───────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kPrimary.withOpacity(0.07),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  child: Row(
                    children: const [
                      SizedBox(width: 40,
                          child: Text('No', style: _headerStyle)),
                      Expanded(flex: 3,
                          child: Text('Nama Guru', style: _headerStyle)),
                      Expanded(flex: 2,
                          child: Text('NIP', style: _headerStyle)),
                      Expanded(flex: 2,
                          child: Text('Mata Pelajaran', style: _headerStyle)),
                      Expanded(flex: 2,
                          child: Text('Status Penilaian', style: _headerStyle)),
                      Expanded(flex: 2,
                          child: Text('Aksi', style: _headerStyle)),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFEEF2F9)),

                // Rows
                display.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 48, color: kSubtext.withOpacity(0.4)),
                            const SizedBox(height: 8),
                            Text('Tidak ada guru ditemukan',
                                style: TextStyle(color: kSubtext)),
                          ],
                        ),
                      )
                    : Column(
                        children: List.generate(display.length, (i) {
                          final guru  = display[i];
                          final delay = i * 0.07;
                          final sudah = guru['sudah_dinilai'] == true ||
                              guru['sudah_dinilai'] == 1;

                          return AnimatedBuilder(
                            animation: _animController,
                            builder: (_, __) {
                              final t = (_animController.value - delay)
                                  .clamp(0.0, 1.0);
                              return Opacity(
                                opacity: t,
                                child: Transform.translate(
                                  offset: Offset(0, 16 * (1 - t)),
                                  child: _GuruRow(
                                    no:          i + 1,
                                    nama:        guru['nama_guru'] ?? 'Guru',
                                    jabatan:     guru['jabatan'] ?? '',
                                    nip:         guru['nip'] ?? '-',
                                    mapel:       guru['mata_pelajaran'] ?? '-',
                                    sudahDinilai: sudah,
                                    isLast:      i == display.length - 1,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FormKuesionerPage(
                                          idSiswa:  widget.idUser,
                                          idGuru:   guru['id_guru'],
                                          namaGuru: guru['nama_guru'],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          // Info count
          Text(
            'Menampilkan ${display.length} dari $_totalGuru guru',
            style: TextStyle(color: kSubtext, fontSize: 12),
          ),

          const SizedBox(height: 28),
          Center(
            child: Text(
              '© 2024 SPK Guru · SDN Mranggen',
              style: TextStyle(color: kSubtext, fontSize: 11),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  static const TextStyle _headerStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: Color(0xFF9AABCC),
    letterSpacing: 0.8,
  );
}

// ── Stat Card ──────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final String   sub;
  final Color    subColor;
  final double   valueFontSize;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    this.subColor      = const Color(0xFF9AABCC),
    this.valueFontSize = 20,
  });

  static const Color kPrimary = Color(0xFF1A5FA8);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: kPrimary, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF6B7A99))),
                  const SizedBox(height: 3),
                  Text(value,
                      style: TextStyle(
                          fontSize:   valueFontSize,
                          fontWeight: FontWeight.w800,
                          color:      const Color(0xFF1A2340)),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(sub,
                      style: TextStyle(fontSize: 11, color: subColor),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Guru Row ───────────────────────────────────────────────────
class _GuruRow extends StatelessWidget {
  final int    no;
  final String nama;
  final String jabatan;
  final String nip;
  final String mapel;
  final bool   sudahDinilai;
  final bool   isLast;
  final VoidCallback onTap;

  const _GuruRow({
    required this.no,
    required this.nama,
    required this.jabatan,
    required this.nip,
    required this.mapel,
    required this.sudahDinilai,
    required this.isLast,
    required this.onTap,
  });

  static const Color kPrimary = Color(0xFF1A5FA8);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              // No
              SizedBox(
                width: 40,
                child: Text('$no',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7A99))),
              ),

              // Avatar + Nama
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: kPrimary.withOpacity(0.10),
                      child: const Icon(Icons.person_rounded,
                          color: kPrimary, size: 21),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nama,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: Color(0xFF1A2340)),
                              overflow: TextOverflow.ellipsis),
                          if (jabatan.isNotEmpty)
                            Text(jabatan,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF9AABCC)),
                                overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // NIP
              Expanded(
                flex: 2,
                child: Text(nip,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF4A5568)),
                    overflow: TextOverflow.ellipsis),
              ),

              // Mata Pelajaran
              Expanded(
                flex: 2,
                child: Text(mapel,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF4A5568)),
                    overflow: TextOverflow.ellipsis),
              ),

              // Status badge
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Icon(
                      sudahDinilai
                          ? Icons.check_circle_rounded
                          : Icons.hourglass_empty_rounded,
                      size: 15,
                      color: sudahDinilai
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFF57F17),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      sudahDinilai ? 'Sudah Dinilai' : 'Belum Dinilai',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sudahDinilai
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFF57F17),
                      ),
                    ),
                  ],
                ),
              ),

              // Aksi button
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: sudahDinilai
                              ? kPrimary.withOpacity(0.08)
                              : kPrimary,
                          borderRadius: BorderRadius.circular(8),
                          border: sudahDinilai
                              ? Border.all(
                                  color: kPrimary.withOpacity(0.3))
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              sudahDinilai
                                  ? Icons.visibility_rounded
                                  : Icons.person_add_alt_1_rounded,
                              size: 14,
                              color: sudahDinilai
                                  ? kPrimary
                                  : Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              sudahDinilai ? 'Lihat Detail' : 'Pilih Guru',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: sudahDinilai
                                    ? kPrimary
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
              height: 1,
              color: Color(0xFFF0F4FA),
              indent: 20,
              endIndent: 20),
      ],
    );
  }
}