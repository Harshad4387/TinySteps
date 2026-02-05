import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../services/auth_storage.dart';

class SleepService {
  static Future<String?> _token() async {
    return await AuthStorage.getToken();
  }

  /// ➕ Add sleep entry (NO infantId)
  static Future<bool> addSleep({
    required DateTime sleepStart,
    required DateTime sleepEnd,
  }) async {
    final token = await _token();

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/sleep/add"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({
        "sleepStart": sleepStart.toIso8601String(),
        "sleepEnd": sleepEnd.toIso8601String(),
      }),
    );

    return response.statusCode == 201;
  }

  /// 📅 Get today sleep summary (NO infantId)
  static Future<Map<String, dynamic>> getTodaySleep() async {
    final token = await _token();

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/sleep/today"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to fetch sleep data");
    }
  }
}

