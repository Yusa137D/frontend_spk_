import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dashboard_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:5000/api/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": _userController.text,
          "password": _passController.text,
        }),
      );

      // Cek apakah widget masih ada di layar sebelum navigasi
      if (!mounted) return;

      final res = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Ambil data user dari respons backend
        Map userData = res['user'];

        // NAVIGASI KE DASHBOARD
        // Kita kirim data 'userData' ke parameter 'user' di DashboardPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage(user: userData),
          ),
        );
      } else {
        _showMsg(res['message'] ?? "Login Gagal", Colors.red);
      }
    } catch (e) {
      if (!mounted) return;
      _showMsg("Koneksi ke server gagal!", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school, size: 80, color: Colors.indigo),
                const SizedBox(height: 10),
                const Text(
                  "SPK KINERJA GURU",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _userController,
                  decoration: const InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 25),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.indigo,
                        ),
                        child: const Text("LOGIN", style: TextStyle(color: Colors.white)),
                      ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterPage()),
                    );
                  },
                  child: const Text("Belum punya akun? Daftar di sini"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}