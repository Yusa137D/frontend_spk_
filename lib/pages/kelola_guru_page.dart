import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class KelolaGuruPage extends StatefulWidget {
  const KelolaGuruPage({super.key});

  @override
  State<KelolaGuruPage> createState() => _KelolaGuruPageState();
}

class _KelolaGuruPageState extends State<KelolaGuruPage> {
  List gurus = [];
  bool _isLoading = true;

  // Instance Dio dan URL Railway
  final Dio _dio = Dio();
  final String baseUrl = "https://web-production-1379e.up.railway.app/api";

  @override
  void initState() {
    super.initState();
    fetchGuru();
  }

  // 1. AMBIL DATA GURU
  Future<void> fetchGuru() async {
    setState(() => _isLoading = true);
    try {
      final res = await _dio.get("$baseUrl/guru"); 
      if (res.statusCode == 200) {
        setState(() {
          gurus = res.data; 
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Gagal API: ${e.response?.statusCode}", Colors.red);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Terjadi error sistem, cek console!", Colors.red);
    }
  }

  // 2. FUNGSI UPDATE GURU
  Future<void> updateGuru(int id, String nama, String nip, String kelas) async {
    try {
      final res = await _dio.put(
        "$baseUrl/guru/update/$id",
        data: {
          "nama_guru": nama,
          "nip": nip,
          "kelas": kelas,
        },
      );

      if (res.statusCode == 200) {
        _showSnackBar("Data guru berhasil diperbarui", Colors.green);
        fetchGuru(); 
      }
    } catch (e) {
      _showSnackBar("Gagal memperbarui data", Colors.red);
    }
  }

  // 3. FUNGSI HAPUS GURU
  Future<void> deleteGuru(int id) async {
    try {
      final res = await _dio.delete("$baseUrl/guru/delete/$id");
      if (res.statusCode == 200) {
        _showSnackBar("Guru berhasil dihapus", Colors.orange);
        fetchGuru();
      }
    } catch (e) {
      _showSnackBar("Gagal menghapus guru", Colors.red);
    }
  }

  // DIALOG EDIT GURU (RESPONSIF MOBILE)
  void _showEditDialog(Map guru) {
    final nameController = TextEditingController(text: guru['nama_guru']);
    final nipController = TextEditingController(text: guru['nip']);
    final kelasController = TextEditingController(text: guru['kelas']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Edit Data Guru", style: TextStyle(fontWeight: FontWeight.bold)),
        // SingleChildScrollView agar form bisa di-scroll saat keyboard HP muncul
        content: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, // Menghindari tertutup keyboard
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Nama Guru",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nipController,
                  decoration: InputDecoration(
                    labelText: "NIP",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: kelasController,
                  decoration: InputDecoration(
                    labelText: "Kelas",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              updateGuru(
                guru['id_guru'],
                nameController.text,
                nipController.text,
                kelasController.text,
              );
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg), 
        backgroundColor: color,
        behavior: SnackBarBehavior.floating, // Snackbar melayang keren di HP
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Latar belakang abu-abu muda khas dashboard modern
      appBar: AppBar(
        title: const Text("Kelola Guru", style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // SafeArea agar konten tidak menabrak status bar atau poni layar HP
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800), // Membatasi lebar maksimal di Laptop
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
                : gurus.isEmpty 
                    ? const Center(child: Text("Belum ada data guru", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(), // Efek scroll empuk khas mobile
                        padding: const EdgeInsets.all(16),
                        itemCount: gurus.length,
                        itemBuilder: (context, i) {
                          final guru = gurus[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.indigo.withOpacity(0.1),
                                  child: const Icon(Icons.person, color: Colors.indigo),
                                ),
                                title: Text(
                                  guru['nama_guru'] ?? "Tanpa Nama",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    "NIP: ${guru['nip']}\nKelas: ${guru['kelas']}",
                                    style: TextStyle(height: 1.4, color: Colors.grey.shade700),
                                  ),
                                ),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                                      onPressed: () => _showEditDialog(guru),
                                      tooltip: "Edit Guru",
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_rounded, color: Colors.red),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                            title: const Text("Konfirmasi Hapus", style: TextStyle(fontWeight: FontWeight.bold)),
                                            content: Text("Yakin ingin menghapus ${guru['nama_guru']}? Data yang dihapus tidak bisa dikembalikan."),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                                onPressed: () {
                                                  deleteGuru(guru['id_guru']);
                                                  Navigator.pop(context);
                                                },
                                                child: const Text("Hapus"),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      tooltip: "Hapus Guru",
                                    ),
                                  ],
                                ),
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