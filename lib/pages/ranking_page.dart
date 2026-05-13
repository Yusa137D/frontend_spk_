import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage>
    with SingleTickerProviderStateMixin {
  List data = [];
  bool loading = true;
  late AnimationController _animController;

  static const Color kPrimary = Color(0xFF1A5FA8);
  static const Color kBg      = Color(0xFFF0F4FA);
  static const Color kText    = Color(0xFF1A2340);
  static const Color kSubtext = Color(0xFF6B7A99);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    fetchData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    final res = await ApiService.getRankingTopsis();
    if (res != null && mounted) {
      setState(() {
        data = res;
        loading = false;
      });
      _animController.forward();
    } else {
      if (mounted) setState(() => loading = false);
    }
  }

  double get _topNilai =>
      data.isEmpty ? 0 : (data[0]['nilai_ci'] as num).toDouble();

  double get _avgNilai {
    if (data.isEmpty) return 0;
    final sum = data.fold<double>(
        0, (s, e) => s + (e['nilai_ci'] as num).toDouble());
    return sum / data.length;
  }

  Map<String, Color> _predikatColor(String predikat) {
    switch (predikat.toLowerCase()) {
      case 'sangat baik':
        return {'bg': const Color(0xFFE8F5E9), 'text': const Color(0xFF2E7D32)};
      case 'baik':
        return {'bg': const Color(0xFFE3F2FD), 'text': const Color(0xFF1565C0)};
      case 'cukup':
        return {'bg': const Color(0xFFFFF8E1), 'text': const Color(0xFFF57F17)};
      default:
        return {'bg': const Color(0xFFFFEBEE), 'text': const Color(0xFFC62828)};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator(color: kPrimary))
            : _buildBody(),
      ),
    );
  }

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
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Ranking Guru TOPSIS',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: kText),
                          overflow: TextOverflow.ellipsis),
                      Text('Ranking guru berdasarkan metode TOPSIS',
                          style: TextStyle(fontSize: 11, color: kSubtext),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() => loading = true);
                    _animController.reset();
                    fetchData();
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

  Widget _buildBody() {
    // KUNCI ANTI-ERROR: MENGGUNAKAN LEBAR PASTI DENGAN MEDIAQUERY
    double screenWidth = MediaQuery.of(context).size.width;
    double availableWidth = screenWidth > 1200 ? 1160 : screenWidth - 40; // 40 adalah total padding horizontal
    
    // Hitung ukuran Card Statistik
    double cardWidth = availableWidth < 600 
        ? availableWidth 
        : (availableWidth < 900 ? (availableWidth / 2) - 10 : (availableWidth / 4) - 12);
        
    // Hitung ukuran Tabel Minimal 800
    double tableWidth = availableWidth < 800 ? 800 : availableWidth;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _StatCard(
                    icon: Icons.people_alt_rounded,
                    label: 'Total Guru',
                    value: '${data.length}',
                    sub: 'Guru terdaftar',
                    width: cardWidth,
                  ),
                  _StatCard(
                    icon: Icons.star_rounded,
                    label: 'Guru Dinilai',
                    value: '${data.length}',
                    sub: '100% dari total guru',
                    subColor: const Color(0xFF2E7D32),
                    width: cardWidth,
                  ),
                  _StatCard(
                    icon: Icons.emoji_events_rounded,
                    label: 'Nilai Tertinggi',
                    value: _topNilai.toStringAsFixed(4),
                    sub: data.isEmpty ? '-' : data[0]['nama_guru'],
                    width: cardWidth,
                  ),
                  _StatCard(
                    icon: Icons.bar_chart_rounded,
                    label: 'Rata-rata Nilai',
                    value: _avgNilai.toStringAsFixed(4),
                    sub: 'Dari seluruh guru',
                    width: cardWidth,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text('Daftar Ranking',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: kText)),
              const SizedBox(height: 14),

              // TABEL DATA AMAN DARI ERROR EXPANDED
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: tableWidth, // INI OBAT ERROR-NYA: Memberikan lebar pasti
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          child: Row(
                            children: const [
                              SizedBox(width: 60,
                                  child: Text('RANK', style: _headerStyle)),
                              Expanded(flex: 3,
                                  child: Text('NAMA GURU', style: _headerStyle)),
                              Expanded(flex: 2,
                                  child: Text('PREDIKAT', style: _headerStyle)),
                              Expanded(flex: 2,
                                  child: Text('NILAI', style: _headerStyle)),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFEEF2F9)),

                        ...List.generate(data.length, (i) {
                          final item   = data[i];
                          final ci     = (item['nilai_ci'] as num).toDouble();
                          final frac   = _topNilai > 0
                              ? (ci / _topNilai).clamp(0.0, 1.0)
                              : 0.0;
                          final colors = _predikatColor(item['predikat'] ?? '');
                          final delay  = i * 0.08;

                          return AnimatedBuilder(
                            animation: _animController,
                            builder: (_, __) {
                              final t = (_animController.value - delay).clamp(0.0, 1.0);
                              return Opacity(
                                opacity: t,
                                child: Transform.translate(
                                  offset: Offset(0, 18 * (1 - t)),
                                  child: _RankingRow(
                                    rank:         i + 1,
                                    nama:         item['nama_guru'] ?? '-',
                                    nip:          item['nip'] ?? '',
                                    predikat:     item['predikat'] ?? '-',
                                    nilai:        ci,
                                    barFraction:  frac,
                                    predikatBg:   colors['bg']!,
                                    predikatText: colors['text']!,
                                    isLast:       i == data.length - 1,
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),
              Center(
                child: Text(
                  '©️ 2024 SPK Guru · SDN Mranggen',
                  style: TextStyle(color: kSubtext, fontSize: 11),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  static const TextStyle _headerStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: Color(0xFF9AABCC),
    letterSpacing: 0.9,
  );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final String   sub;
  final Color    subColor;
  final double   width; 

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    this.subColor = const Color(0xFF9AABCC),
    required this.width,
  });

  static const Color kPrimary = Color(0xFF1A5FA8);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, 
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
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A2340)),
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
    );
  }
}

class _RankingRow extends StatelessWidget {
  final int    rank;
  final String nama;
  final String nip;
  final String predikat;
  final double nilai;
  final double barFraction;
  final Color  predikatBg;
  final Color  predikatText;
  final bool   isLast;

  const _RankingRow({
    required this.rank,
    required this.nama,
    required this.nip,
    required this.predikat,
    required this.nilai,
    required this.barFraction,
    required this.predikatBg,
    required this.predikatText,
    required this.isLast,
  });

  static const Color kPrimary = Color(0xFF1A5FA8);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Row(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: rank == 1
                            ? kPrimary
                            : const Color(0xFFF0F4FA),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('$rank',
                            style: TextStyle(
                                color: rank == 1
                                    ? Colors.white
                                    : const Color(0xFF6B7A99),
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ),
                    ),
                    if (rank == 1) ...[
                      const SizedBox(width: 3),
                      const Text('👑', style: TextStyle(fontSize: 13)),
                    ],
                  ],
                ),
              ),

              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 19,
                      backgroundColor: kPrimary.withOpacity(0.10),
                      child: const Icon(Icons.person_rounded,
                          color: kPrimary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nama,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Color(0xFF1A2340)),
                              overflow: TextOverflow.ellipsis),
                          if (nip.isNotEmpty)
                            Text('NIP. $nip',
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

              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: predikatBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(predikat,
                        style: TextStyle(
                            color:      predikatText,
                            fontSize:   12,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
              ),

              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Text(nilai.toStringAsFixed(4),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: kPrimary)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2F9),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: barFraction,
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: kPrimary,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
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