import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  List data = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final res = await http.get(Uri.parse("http://127.0.0.1:5000/api/hitung-topsis"));
    setState(() { data = jsonDecode(res.body); loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ranking Guru TOPSIS")),
      body: loading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) => ListTile(
              leading: CircleAvatar(child: Text("${i+1}")),
              title: Text(data[i]['nama_guru']),
              subtitle: Text("Predikat: ${data[i]['predikat']}"),
              trailing: Text(data[i]['nilai_ci'].toStringAsFixed(4)),
            ),
          ),
    );
  }
}