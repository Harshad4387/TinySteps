import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../services/auth_storage.dart';

class VaccinationService {
  static Future<String?> _token() async {
    return await AuthStorage.getToken();
  }

  /// 📥 GET ALL
  static Future<List<dynamic>> getAllVaccinations() async {
    final token = await _token();

    final response = await http.get(
      Uri.parse(ApiConfig.baseUrl + ApiConfig.vaccinationAll),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['records'];
    } else {
      throw Exception("Failed to fetch vaccinations");
    }
  }

  /// ➕ ADD
  static Future<void> addVaccination({
    required String vaccineName,
    required DateTime dueDate,
    required String status,
    String notes = "",
  }) async {
    final token = await _token();

    final response = await http.post(
      Uri.parse(ApiConfig.baseUrl + ApiConfig.vaccinationAdd),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({
        "vaccineName": vaccineName,
        "dueDate": dueDate.toIso8601String(),
        "status": status,
        "notes": notes,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to add vaccination");
    }
  }
}
