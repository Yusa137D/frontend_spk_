import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class KelolaSiswaPage extends StatefulWidget {
  const KelolaSiswaPage({super.key});

  @override
  State<KelolaSiswaPage> createState() => _KelolaSiswaPageState();
}

class _KelolaSiswaPageState extends State<KelolaSiswaPage> {
  final Dio dio = Dio();
  List daftarSiswa = [];
  bool isLoading = true;

  static const Color _bg = Color(0xFFF1F5F9);
  static const Color _cardBg = Colors.white;
  static const Color _accent = Color(0xFF8B5CF6);
  static const Color _textPrimary = Color(0xFF1E293B);

  @override
  void initState() {
    super.initState();
    fetchDaftarSiswa();
  }

  Future<void> fetchDaftarSiswa() async {
    setState(() => isLoading = true);
    try {
      final response = await dio.get('http://127.0.0.1:5000/api/daftar-siswa');
      if (response.statusCode == 200) {
        setState(() => daftarSiswa = response.data);
      }
    } catch (e) {
      debugPrint("Error fetching siswa: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // --- FUNGSI UPDATE DATA ---
  Future<void> updateSiswa(int idUser, String nama, String nisn, String kelas, String email) async {
    try {
      final response = await dio.put(
        'http://127.0.0.1:5000/api/update-siswa/$idUser',
        data: {"nama_siswa": nama, "nisn": nisn, "kelas": kelas, "email": email},
      );
      if (response.statusCode == 200) {
        fetchDaftarSiswa(); // Refresh list
        if (mounted) Navigator.pop(context); // Tutup dialog
      }
    } catch (e) {
      debugPrint("Gagal Update: $e");
    }
  }

  // --- DIALOG EDIT ---
  void showEditDialog(Map siswa) {
    final nameCtrl = TextEditingController(text: siswa['nama_siswa']);
    final nisnCtrl = TextEditingController(text: siswa['nisn']);
    final kelasCtrl = TextEditingController(text: siswa['kelas']);
    final emailCtrl = TextEditingController(text: siswa['email']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Data Siswa", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(nameCtrl, "Nama Lengkap", Icons.person),
              _buildField(nisnCtrl, "NISN", Icons.badge),
              _buildField(kelasCtrl, "Kelas", Icons.school),
              _buildField(emailCtrl, "Email", Icons.email),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () => updateSiswa(siswa['id_user'], nameCtrl.text, nisnCtrl.text, kelasCtrl.text, emailCtrl.text),
            child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: _accent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> hapusSiswa(int idUser) async {
    try {
      final response = await dio.delete('http://127.0.0.1:5000/api/hapus-siswa/$idUser');
      if (response.statusCode == 200) fetchDaftarSiswa();
    } catch (e) {
      debugPrint("Gagal Hapus: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Kelola Siswa', style: TextStyle(fontWeight: FontWeight.w700, color: _textPrimary)),
        backgroundColor: _bg, elevation: 0, iconTheme: const IconThemeData(color: _textPrimary),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: daftarSiswa.length,
              itemBuilder: (context, index) {
                final siswa = daftarSiswa[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 4))]),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: CircleAvatar(backgroundColor: const Color(0xFFF5F3FF), child: Text(siswa['nama_siswa'][0].toUpperCase(), style: const TextStyle(color: _accent, fontWeight: FontWeight.bold))),
                    title: Text(siswa['nama_siswa'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    subtitle: Text("NISN: ${siswa['nisn']} • Kelas: ${siswa['kelas']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // TOMBOL EDIT
                        IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.orange), onPressed: () => showEditDialog(siswa)),
                        // TOMBOL HAPUS
                        IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.red), onPressed: () => hapusSiswa(siswa['id_user'])),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}