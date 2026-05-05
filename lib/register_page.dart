import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _namaController = TextEditingController();
  final _indukController = TextEditingController(); // Untuk NIP/NISN
  final _kelasController = TextEditingController();
  
  String _selectedRole = 'Siswa'; // Default role
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (_userController.text.isEmpty || _passController.text.isEmpty || _indukController.text.isEmpty) {
      _showMsg("Semua field wajib diisi!", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:5000/api/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": _userController.text,
          "password": _passController.text,
          "nama_lengkap": _namaController.text,
          "role": _selectedRole,
          "nomor_induk": _indukController.text,
          "kelas": _kelasController.text,
        }),
      );

      final res = jsonDecode(response.body);

      if (response.statusCode == 201) {
        _showMsg("Registrasi Berhasil! Silakan Login", Colors.green);
        Navigator.pop(context); // Kembali ke Login
      } else {
        _showMsg(res['message'] ?? "Registrasi Gagal", Colors.red);
      }
    } catch (e) {
      _showMsg("Koneksi gagal ke server", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Akun Baru")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _namaController, decoration: const InputDecoration(labelText: "Nama Lengkap")),
              const SizedBox(height: 10),
              TextField(controller: _userController, decoration: const InputDecoration(labelText: "Username")),
              const SizedBox(height: 10),
              TextField(controller: _passController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
              const SizedBox(height: 10),
              
              // Dropdown Pilihan Role
              DropdownButtonFormField(
                value: _selectedRole,
                items: ['Siswa', 'Guru'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (val) => setState(() => _selectedRole = val.toString()),
                decoration: const InputDecoration(labelText: "Daftar Sebagai"),
              ),
              const SizedBox(height: 10),
              
              // Input NIP/NISN dinamis
              TextField(
                controller: _indukController, 
                decoration: InputDecoration(labelText: _selectedRole == 'Guru' ? "NIP" : "NISN")
              ),
              const SizedBox(height: 10),
              TextField(controller: _kelasController, decoration: const InputDecoration(labelText: "Kelas (Contoh: 10A)")),
              
              const SizedBox(height: 30),
              _isLoading 
                ? const CircularProgressIndicator() 
                : ElevatedButton(
                    onPressed: _handleRegister, 
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: const Text("DAFTAR SEKARANG")
                  ),
            ],
          ),
        ),
      ),
    );
  }
}