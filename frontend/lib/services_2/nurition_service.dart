import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/server2.dart';

class NutritionService {
  static Future<Map<String, dynamic>?> getDietPlan(
      Map<String, dynamic> payload) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.nutrition),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        print("Diet API error: ${res.statusCode}");
        print(res.body);
      }
    } catch (e) {
      print("Diet API exception: $e");
    }
    return null;
  }
}
