import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api.dart';
import 'auth_storage.dart';

class MilestoneService {
  /// 🔹 ADD MILESTONE
  static Future<bool> addMilestone({
    required String milestoneType,
    required DateTime dateAchieved,
    String? notes,
  }) async {
    try {
      final token = await AuthStorage.getToken();

      final res = await http.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.milestoneAdd),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "milestoneType": milestoneType,
          "dateAchieved": dateAchieved.toIso8601String(),
          "notes": notes,
        }),
      );

      return res.statusCode == 201;
    } catch (e) {
      print("Add Milestone Error: $e");
      return false;
    }
  }

  /// 🔹 FETCH ALL MILESTONES
  static Future<List<dynamic>> fetchMilestones() async {
    try {
      final token = await AuthStorage.getToken();

      final res = await http.get(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.milestoneAll),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body)['milestones'];
      }
    } catch (e) {
      print("Fetch Milestones Error: $e");
    }
    return [];
  }
}
