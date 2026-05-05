import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'form_kuesioner_page.dart';

class DaftarGuruKuesionerPage extends StatefulWidget {
  final int idUser; // ID User yang sedang login (bisa siswa/guru)
  const DaftarGuruKuesionerPage({super.key, required this.idUser});

  @override
  State<DaftarGuruKuesionerPage> createState() => _DaftarGuruKuesionerPageState();
}

class _DaftarGuruKuesionerPageState extends State<DaftarGuruKuesionerPage> {
  List listGuru = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGuru();
  }

  Future<void> fetchGuru() async {
    try {
      final response = await http.get(Uri.parse("http://127.0.0.1:5000/api/daftar-guru"));
      if (response.statusCode == 200) {
        setState(() {
          listGuru = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Guru untuk Dinilai")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: listGuru.length,
            itemBuilder: (context, i) {
              // LOGIC: Guru tidak boleh menilai dirinya sendiri
              if (listGuru[i]['id_guru'] == widget.idUser) return const SizedBox.shrink();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(listGuru[i]['nama_guru'] ?? "Guru"),
                  subtitle: Text("NIP: ${listGuru[i]['nip']}"),
                  trailing: const Icon(Icons.rate_review, color: Colors.blue),
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (context) => FormKuesionerPage(
                      idSiswa: widget.idUser,
                      idGuru: listGuru[i]['id_guru'],
                      namaGuru: listGuru[i]['nama_guru']
                    )
                  )),
                ),
              );
            },
          ),
    );
  }
}