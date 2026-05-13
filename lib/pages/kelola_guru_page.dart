import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class KelolaGuruPage extends StatefulWidget {
  const KelolaGuruPage({super.key});

  @override
  State<KelolaGuruPage> createState() => _KelolaGuruPageState();
}

class _KelolaGuruPageState extends State<KelolaGuruPage> {
  List gurus = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGuru();
  }

  // 1. AMBIL DATA GURU
  Future<void> fetchGuru() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(Uri.parse("http://127.0.0.1:5000/api/daftar-guru"));
      if (res.statusCode == 200) {
        setState(() {
          gurus = jsonDecode(res.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Gagal mengambil data: $e", Colors.red);
    }
  }

  // 2. FUNGSI UPDATE GURU
  Future<void> updateGuru(int id, String nama, String nip, String kelas) async {
    try {
      final res = await http.put(
        Uri.parse("http://127.0.0.1:5000/api/guru/update/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nama_guru": nama,
          "nip": nip,
          "kelas": kelas,
        }),
      );

      if (res.statusCode == 200) {
        _showSnackBar("Data guru berhasil diperbarui", Colors.green);
        fetchGuru(); // Refresh data
      }
    } catch (e) {
      _showSnackBar("Gagal memperbarui data", Colors.red);
    }
  }

  // 3. FUNGSI HAPUS GURU
  Future<void> deleteGuru(int id) async {
    try {
      final res = await http.delete(Uri.parse("http://127.0.0.1:5000/api/guru/delete/$id"));
      if (res.statusCode == 200) {
        _showSnackBar("Guru berhasil dihapus", Colors.orange);
        fetchGuru();
      }
    } catch (e) {
      _showSnackBar("Gagal menghapus guru", Colors.red);
    }
  }

  // DIALOG EDIT GURU
  void _showEditDialog(Map guru) {
    final nameController = TextEditingController(text: guru['nama_guru']);
    final nipController = TextEditingController(text: guru['nip']);
    final kelasController = TextEditingController(text: guru['kelas']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Data Guru"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nama Guru")),
            TextField(controller: nipController, decoration: const InputDecoration(labelText: "NIP")),
            TextField(controller: kelasController, decoration: const InputDecoration(labelText: "Kelas")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Guru"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: gurus.length,
              itemBuilder: (context, i) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(gurus[i]['nama_guru'] ?? "Tanpa Nama", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("NIP: ${gurus[i]['nip']}\nKelas: ${gurus[i]['kelas']}"),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // TOMBOL EDIT
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditDialog(gurus[i]),
                      ),
                      // TOMBOL HAPUS
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Konfirmasi Hapus"),
                              content: Text("Yakin ingin menghapus ${gurus[i]['nama_guru']}?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
                                TextButton(
                                  onPressed: () {
                                    deleteGuru(gurus[i]['id_guru']);
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}