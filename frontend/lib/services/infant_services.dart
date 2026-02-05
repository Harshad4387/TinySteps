import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api.dart';
import '../models/infant_models.dart';
import 'auth_storage.dart';

class InfantService {
  /// 🔹 FETCH MY INFANTS (USED BY HOME PAGE)
  static Future<List<Infant>> fetchMyInfants() async {
    try {
      final token = await AuthStorage.getToken();

      final res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/infant/my"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => Infant.fromJson(e)).toList();
      } else {
        print("Fetch Infant Error ${res.statusCode}");
        print(res.body);
      }
    } catch (e) {
      print("Fetch Infant Exception: $e");
    }
    return [];
  }

  /// 🔹 ADD INFANT
  static Future<bool> addInfant(Map<String, dynamic> payload) async {
    try {
      final token = await AuthStorage.getToken();

      final res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/infant/add"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(payload),
      );

      return res.statusCode == 201;
    } catch (e) {
      print("Add Infant Error: $e");
      return false;
    }
  }
}
