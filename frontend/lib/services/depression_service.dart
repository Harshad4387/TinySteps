import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/mlapi.dart';

class DepressionService {
  static Future<Map<String, dynamic>?> predictDepression(
      Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.depressionUrl),
        headers: const {
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        // Helpful debug
        print("❌ API Error ${response.statusCode}");
        print(response.body);
      }
    } catch (e) {
      print("❌ Depression API Exception: $e");
    }
    return null;
  }
}
