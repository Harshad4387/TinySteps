import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/server2.dart';

class InfantAwarenessService {
  static Future<Map<String, dynamic>?> checkRisk(
      Map<String, dynamic> payload) async {
    try {
      final uri =
          Uri.parse(ApiConfig.baseUrl + ApiConfig.Awareness);

      print("➡️ AWARENESS API URL: $uri");
      print("➡️ PAYLOAD: ${jsonEncode(payload)}");

      final res = await http
          .post(
            uri,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      print("⬅️ RESPONSE STATUS: ${res.statusCode}");
      print("⬅️ RESPONSE BODY: ${res.body}");

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print("❌ Awareness API error: $e");
    }
    return null;
  }
}
