import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import memori lokal
import '../services/api_service.dart';

class FormKuesionerPage extends StatefulWidget {
  final int idSiswa, idGuru;
  final String namaGuru, nipGuru; // FIX: Menambahkan parameter NIP
  
  const FormKuesionerPage({
    super.key,
    required this.idSiswa,
    required this.idGuru,
    required this.namaGuru,
    required this.nipGuru,
  });

  @override
  State<FormKuesionerPage> createState() => _FormKuesionerPageState();
}

class _FormKuesionerPageState extends State<FormKuesionerPage> {
  List questions = [];
  Map<int, int> answers = {};
  bool _isLoading = true;
  bool _isSubmitting = false;

  static const Color kPrimary = Color(0xFF1A5FA8);
  static const Color kBg      = Color(0xFFF0F4FA);
  static const Color kText    = Color(0xFF1A2340);
  static const Color kSubtext = Color(0xFF6B7A99);

  @override
  void initState() {
    super.initState();
    fetchPertanyaanDanDraft();
  }

  // ── FIX: Ambil Pertanyaan sekaligus Cek apakah ada Draft Tersimpan ──
  Future<void> fetchPertanyaanDanDraft() async {
    // 1. Ambil pertanyaan dari API
    final data = await ApiService.getPertanyaan();
    if (data != null && mounted) {
      setState(() {
        questions = data;
        _isLoading = false;
      });
    }

    // 2. Cek Draft di Memori Lokal
    final prefs = await SharedPreferences.getInstance();
    final draftStr = prefs.getString('draft_${widget.idSiswa}_${widget.idGuru}');
    
    if (draftStr != null && mounted) {
      final Map<String, dynamic> decoded = jsonDecode(draftStr);
      setState(() {
        answers = decoded.map((key, value) => MapEntry(int.parse(key), value as int));
      });
    }
  }

  // ── FIX: Fungsi Simpan Draft ──
  Future<void> simpanDraft() async {
    final prefs = await SharedPreferences.getInstance();
    // Ubah map jadi string JSON untuk disimpan
    final draftStr = jsonEncode(answers.map((key, value) => MapEntry(key.toString(), value)));
    await prefs.setString('draft_${widget.idSiswa}_${widget.idGuru}', draftStr);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(children: [
          Icon(Icons.save_rounded, color: Colors.white, size: 18),
          SizedBox(width: 8), Text('Draft berhasil disimpan secara lokal!'),
        ]),
        backgroundColor: Colors.blueGrey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.pop(context); // Keluar form setelah nyimpan draft
  }

  // ── Kirim Penilaian ──
  Future<void> submit() async {
    List payload = answers.entries.map((e) => {
      "id_user": widget.idSiswa,
      "id_guru": widget.idGuru,
      "id_pertanyaan": e.key,
      "skor": e.value,
    }).toList();

    setState(() => _isSubmitting = true);
    final success = await ApiService.simpanJawaban(payload);
    if (mounted) setState(() => _isSubmitting = false);

    if (success && mounted) {
      // FIX: Kalau sudah dikirim, hapus draft lokalnya
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('draft_${widget.idSiswa}_${widget.idGuru}');

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8), Text('Penilaian berhasil dikirim!'),
          ]),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  int get _answered => answers.length;
  int get _total    => questions.length;
  bool get _allAnswered => _answered == _total && _total > 0;

  // ── FIX: Bikin Tanggal Otomatis ──
  String _getBulan(int month) {
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return bulan[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: _isLoading ? const Center(child: CircularProgressIndicator(color: kPrimary)) : _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))]),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(width: 36, height: 36, decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: kText)),
                ),
                const SizedBox(width: 14),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Penilaian: ${widget.namaGuru}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
                    const Text('Berikan penilaian berdasarkan kriteria yang telah ditentukan.', style: TextStyle(fontSize: 11, color: kSubtext)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final now = DateTime.now();
    final bulanStr = _getBulan(now.month);
    final tahunStr = now.year.toString();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 3))],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 32, backgroundColor: kPrimary.withOpacity(0.10), child: const Icon(Icons.person_rounded, color: kPrimary, size: 34)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.namaGuru, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
                            const SizedBox(height: 4),
                            // FIX: Menampilkan NIP yang asli
                            Text('NIP. ${widget.nipGuru}', style: const TextStyle(fontSize: 12, color: kSubtext)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _metaRow('Tanggal Penilaian', _todayFormatted()),
                          const SizedBox(height: 4),
                          _metaRow('Penilai', 'Siswa / Anda'),
                          const SizedBox(height: 4),
                          // FIX: Menampilkan Periode Otomatis
                          _metaRow('Periode', '$bulanStr $tahunStr'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: kPrimary.withOpacity(0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: kPrimary.withOpacity(0.15))),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline_rounded, color: kPrimary, size: 18),
                      SizedBox(width: 10),
                      Expanded(child: Text('Berikan penilaian pada setiap aspek dengan memilih skala yang paling sesuai.', style: TextStyle(fontSize: 12, color: kPrimary))),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Text('$_answered / $_total pertanyaan dijawab', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kSubtext)),
                    const Spacer(),
                    Text('${_total > 0 ? (_answered / _total * 100).toInt() : 0}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kPrimary)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _total > 0 ? _answered / _total : 0,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFDDE4F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(kPrimary),
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.07), blurRadius: 20, offset: const Offset(0, 4))]),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        child: Row(
                          children: const [
                            SizedBox(width: 44, child: Text('No.', style: _headerStyle)),
                            Expanded(flex: 3, child: Text('Kriteria Penilaian', style: _headerStyle)),
                            Expanded(flex: 4, child: Center(child: Text('Skala Penilaian', style: _headerStyle))),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFEEF2F9)),

                      ...List.generate(questions.length, (i) {
                        final q   = questions[i];
                        final id  = q['id'] as int;
                        final sel = answers[id];
                        return _QuestionRow(
                          no: i + 1,
                          teks: q['teks'] ?? '',
                          deskripsi: q['deskripsi'] ?? '',
                          selected: sel,
                          isLast: i == questions.length - 1,
                          onChanged: (v) => setState(() => answers[id] = v),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: kPrimary.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: kPrimary.withOpacity(0.12))),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, color: kPrimary, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          spacing: 16,
                          children: const [
                            Text('Keterangan Skala Penilaian:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kText)),
                            Text('1 = Sangat Kurang', style: TextStyle(fontSize: 12, color: kSubtext)),
                            Text('2 = Kurang', style: TextStyle(fontSize: 12, color: kSubtext)),
                            Text('3 = Cukup', style: TextStyle(fontSize: 12, color: kSubtext)),
                            Text('4 = Baik', style: TextStyle(fontSize: 12, color: kSubtext)),
                            Text('5 = Sangat Baik', style: TextStyle(fontSize: 12, color: kSubtext)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),

        // ── Action bar ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -2))]),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: () => Navigator.maybePop(context),
                style: OutlinedButton.styleFrom(foregroundColor: kText, side: const BorderSide(color: Color(0xFFDDE4F0)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              const Spacer(),
              
              // FIX: Tombol Simpan Draft Sekarang Bekerja
              OutlinedButton.icon(
                onPressed: simpanDraft, // Panggil fungsinya
                icon: const Icon(Icons.save_outlined, size: 16),
                label: const Text('Simpan Draft', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                style: OutlinedButton.styleFrom(foregroundColor: kPrimary, side: BorderSide(color: kPrimary.withOpacity(0.4)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
              
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _allAnswered && !_isSubmitting ? submit : null,
                icon: _isSubmitting ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send_rounded, size: 16),
                label: Text(_isSubmitting ? 'Mengirim...' : 'Kirim Penilaian', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white, disabledBackgroundColor: const Color(0xFFB0C4DE), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metaRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 12, color: kSubtext))),
        const Text(': ', style: TextStyle(fontSize: 12, color: kSubtext)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kText)),
      ],
    );
  }

  String _todayFormatted() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')} ${_getBulan(now.month)} ${now.year}';
  }

  static const TextStyle _headerStyle = TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF9AABCC), letterSpacing: 0.8);
}

class _QuestionRow extends StatelessWidget {
  final int no; final String teks; final String deskripsi; final int? selected; final bool isLast; final void Function(int) onChanged;
  const _QuestionRow({required this.no, required this.teks, required this.deskripsi, required this.selected, required this.isLast, required this.onChanged});
  
  static const Color kPrimary = Color(0xFF1A5FA8);
  static const Color kText = Color(0xFF1A2340);
  static const Color kSubtext = Color(0xFF6B7A99);
  static const List<String> _scaleLabels = ['Sangat\nKurang', '', '', '', 'Sangat\nBaik'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(width: 28, height: 28, decoration: BoxDecoration(color: kPrimary.withOpacity(0.10), borderRadius: BorderRadius.circular(8)), child: Center(child: Text('$no', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kPrimary)))),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 36, height: 36, decoration: BoxDecoration(color: kPrimary.withOpacity(0.08), borderRadius: BorderRadius.circular(9)), child: const Icon(Icons.assignment_rounded, color: kPrimary, size: 18)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(teks, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kText)), if (deskripsi.isNotEmpty) ...[const SizedBox(height: 3), Text(deskripsi, style: const TextStyle(fontSize: 11, color: kSubtext), maxLines: 3, overflow: TextOverflow.ellipsis)]]))])),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(5, (j) { final val = j + 1; return SizedBox(width: 40, child: Center(child: Text('$val', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: selected == val ? kPrimary : const Color(0xFF9AABCC))))); })),
                    const SizedBox(height: 4),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(5, (j) { final val = j + 1; return SizedBox(width: 40, child: Radio<int>(value: val, groupValue: selected, onChanged: (v) => onChanged(v!), activeColor: kPrimary, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)); })),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(5, (j) { final label = _scaleLabels[j]; return SizedBox(width: 40, child: label.isNotEmpty ? Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: kSubtext)) : const SizedBox.shrink()); })),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: Color(0xFFF0F4FA), indent: 20, endIndent: 20),
      ],
    );
  }
}