import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';

class DashboardGuruPage extends StatefulWidget {
  final int idGuru;
  final String namaGuru;
  const DashboardGuruPage({super.key, required this.idGuru, required this.namaGuru});

  @override
  State<DashboardGuruPage> createState() => _DashboardGuruPageState();
}

class _DashboardGuruPageState extends State<DashboardGuruPage> {
  Map<String, dynamic>? evaluasi;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEvaluasi();
  }

  Future<void> fetchEvaluasi() async {
    try {
      final response = await http.get(Uri.parse("http://127.0.0.1:5000/api/evaluasi-saya/${widget.idGuru}"));
      if (response.statusCode == 200) {
        setState(() {
          evaluasi = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Guru"),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage())))
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Halo, ${widget.namaGuru}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("Hasil evaluasi kinerja anda periode ini:"),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 5,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(20),
                      title: const Text("Nilai Preferensi (Ci)"),
                      subtitle: Text("Predikat: ${evaluasi?['predikat'] ?? 'Belum Dinilai'}"),
                      trailing: Text(evaluasi?['nilai_ci']?.toStringAsFixed(4) ?? "0.0000", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}