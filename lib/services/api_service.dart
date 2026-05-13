import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // Instance Dio terpusat
  static final Dio dio = Dio(
    BaseOptions(
      // GANTI titik koma (;) jadi koma (,) di akhir baris baseUrl
      baseUrl: "https://web-production-1379e.up.railway.app/api", 
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {"Content-Type": "application/json"},
    ),
  );

  // 1. Dashboard Stats
  static Future<Map<String, dynamic>?> getDashboardStats() async {
    try {
      final res = await dio.get("/dashboard-stats");
      if (res.statusCode == 200) return res.data;
    } catch (e) { 
      debugPrint("Error getDashboardStats: $e"); 
    }
    return null;
  }

  // 2. Nilai Guru
  static Future<Map<String, dynamic>?> getNilaiGuru(String idUser) async {
    try {
      final res = await dio.get("/nilai-saya/$idUser");
      if (res.statusCode == 200) return res.data;
    } catch (e) { 
      debugPrint("Error getNilaiGuru: $e"); 
    }
    return null;
  }

  // 3. Ambil Daftar Guru
  static Future<List?> getDaftarGuru(int idUser) async {
    try {
      final res = await dio.get("/daftar-guru/$idUser");
      if (res.statusCode == 200) return res.data;
    } catch (e) { 
      debugPrint("Error getDaftarGuru: $e"); 
    }
    return null;
  }

  // 4. Ambil Daftar Pertanyaan Kuesioner
  static Future<List?> getPertanyaan() async {
    try {
      final res = await dio.get("/pertanyaan");
      if (res.statusCode == 200) return res.data;
    } catch (e) { 
      debugPrint("Error getPertanyaan: $e"); 
    }
    return null;
  }

  // 5. Simpan Jawaban Kuesioner
  static Future<bool> simpanJawaban(List payload) async {
    try {
      final res = await dio.post("/simpan-jawaban", data: payload);
      // Railway kadang mengembalikan 201 untuk proses create/simpan
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) { 
      debugPrint("Error simpanJawaban: $e"); 
    }
    return false;
  }

  // 6. Ambil Ranking TOPSIS
  static Future<List?> getRankingTopsis() async {
    try {
      final res = await dio.get("/hitung-topsis");
      if (res.statusCode == 200) return res.data;
    } catch (e) { 
      debugPrint("Error getRankingTopsis: $e"); 
    }
    return null;
  }
}
