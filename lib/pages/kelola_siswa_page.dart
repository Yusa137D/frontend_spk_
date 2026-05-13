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

  // URL Railway
  final String baseUrl = "https://web-production-1379e.up.railway.app/api";

  static const Color _bg = Color(0xFFF1F5F9);
  static const Color _cardBg = Colors.white;
  static const Color _accent = Color(0xFF8B5CF6); // Warna ungu khas Kelola Siswa
  static const Color _textPrimary = Color(0xFF1E293B);

  @override
  void initState() {
    super.initState();
    fetchDaftarSiswa();
  }

  // 1. AMBIL DATA SISWA
  Future<void> fetchDaftarSiswa() async {
    setState(() => isLoading = true);
    try {
      final response = await dio.get('$baseUrl/daftar-siswa');
      if (response.statusCode == 200) {
        setState(() => daftarSiswa = response.data);
      }
    } catch (e) {
      _showSnackBar("Gagal mengambil data siswa", Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // 2. FUNGSI UPDATE DATA
  Future<void> updateSiswa(int idUser, String nama, String nisn, String kelas, String email) async {
    try {
      final response = await dio.put(
        '$baseUrl/update-siswa/$idUser',
        data: {
          "nama_siswa": nama, 
          "nisn": nisn, 
          "kelas": kelas, 
          "email": email
        },
      );
      if (response.statusCode == 200) {
        _showSnackBar("Data siswa berhasil diperbarui", Colors.green);
        fetchDaftarSiswa(); // Refresh list
      }
    } catch (e) {
      _showSnackBar("Gagal memperbarui data", Colors.red);
    }
  }

  // 3. FUNGSI HAPUS DATA
  Future<void> hapusSiswa(int idUser) async {
    try {
      final response = await dio.delete('$baseUrl/hapus-siswa/$idUser');
      if (response.statusCode == 200) {
        _showSnackBar("Siswa berhasil dihapus", Colors.orange);
        fetchDaftarSiswa();
      }
    } catch (e) {
      _showSnackBar("Gagal menghapus siswa", Colors.red);
    }
  }

  // DIALOG EDIT (RESPONSIF MOBILE)
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
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            onPressed: () {
              updateSiswa(siswa['id_user'], nameCtrl.text, nisnCtrl.text, kelasCtrl.text, emailCtrl.text);
              Navigator.pop(ctx);
            },
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: _accent, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg), 
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Kelola Siswa', style: TextStyle(fontWeight: FontWeight.w700, color: _textPrimary)),
        backgroundColor: Colors.white, 
        elevation: 0, 
        iconTheme: const IconThemeData(color: _textPrimary),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800), // Batas lebar di Laptop
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: _accent))
                : daftarSiswa.isEmpty
                    ? const Center(child: Text("Belum ada data siswa", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(), // Scroll mantul khas HP
                        padding: const EdgeInsets.all(16),
                        itemCount: daftarSiswa.length,
                        itemBuilder: (context, index) {
                          final siswa = daftarSiswa[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: _cardBg, 
                              borderRadius: BorderRadius.circular(16), 
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: _accent.withOpacity(0.1), 
                                child: Text(
                                  siswa['nama_siswa'][0].toUpperCase(), 
                                  style: const TextStyle(color: _accent, fontWeight: FontWeight.bold)
                                )
                              ),
                              title: Text(
                                siswa['nama_siswa'], 
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text("NISN: ${siswa['nisn']} • Kelas: ${siswa['kelas']}"),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: Colors.orange, size: 22), 
                                    onPressed: () => showEditDialog(siswa)
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 22), 
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Hapus Siswa?"),
                                          content: Text("Data ${siswa['nama_siswa']} akan dihapus permanen."),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
                                            TextButton(
                                              onPressed: () { hapusSiswa(siswa['id_user']); Navigator.pop(context); },
                                              child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ),
      ),
    );
  }
}