import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FormKuesionerPage extends StatefulWidget {
  final int idSiswa, idGuru;
  final String namaGuru;
  const FormKuesionerPage({super.key, required this.idSiswa, required this.idGuru, required this.namaGuru});

  @override
  State<FormKuesionerPage> createState() => _FormKuesionerPageState();
}

class _FormKuesionerPageState extends State<FormKuesionerPage> {
  List questions = [];
  Map<int, int> answers = {};

  @override
  void initState() {
    super.initState();
    fetchPertanyaan();
  }

  Future<void> fetchPertanyaan() async {
    final res = await http.get(Uri.parse("http://127.0.0.1:5000/api/pertanyaan"));
    setState(() => questions = jsonDecode(res.body));
  }

  Future<void> submit() async {
    List payload = answers.entries.map((e) => {
      "id_user": widget.idSiswa, "id_guru": widget.idGuru, "id_pertanyaan": e.key, "skor": e.value
    }).toList();

    final res = await http.post(Uri.parse("http://127.0.0.1:5000/api/simpan-jawaban"),
        headers: {"Content-Type": "application/json"}, body: jsonEncode(payload));

    if (res.statusCode == 200) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Penilaian: ${widget.namaGuru}")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, i) => Column(
                children: [
                  ListTile(title: Text(questions[i]['teks'])),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (index) => 
                    Radio(value: index + 1, groupValue: answers[questions[i]['id']], 
                    onChanged: (v) => setState(() => answers[questions[i]['id']] = v as int))
                  )),
                ],
              ),
            ),
          ),
          ElevatedButton(onPressed: submit, child: const Text("KIRIM")),
        ],
      ),
    );
  }
}