import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api.dart';
import 'auth_storage.dart';

class FeedingService {
  /// 🔹 GET TODAY FEEDING FOR AN INFANT
  static Future<List<Map<String, dynamic>>> fetchTodayFeeding(
    String infantId,
  ) async {
    try {
      final token = await AuthStorage.getToken();

      final uri = Uri.parse(
        ApiConfig.baseUrl + ApiConfig.feedingToday,
      ).replace(queryParameters: {
        "infantId": infantId,
      });

      final res = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (res.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
          jsonDecode(res.body),
        );
      } else {
        print("Feeding fetch error ${res.statusCode}");
        print(res.body);
      }
    } catch (e) {
      print("Feeding fetch exception: $e");
    }

    return [];
  }

  /// 🔹 ADD FEEDING SCHEDULE
  static Future<bool> addFeeding({
    required String infantId,
    required String type,
    required String quantity,
    String? notes,
    required List<String> times,
    bool isRecurring = true,
  }) async {
    try {
      final token = await AuthStorage.getToken();

      final payload = {
        "infantId": infantId,
        "type": type,
        "quantity": quantity,
        "notes": notes,
        "isRecurring": isRecurring,
        "times": times,
      };

      final res = await http.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.feedingAdd),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      return res.statusCode == 201;
    } catch (e) {
      print("Add feeding error: $e");
      return false;
    }
  }
}
