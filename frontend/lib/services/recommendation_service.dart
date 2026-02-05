import 'dart:convert';
import 'package:http/http.dart' as http;

class RecommendationService {
  static const String baseUrl = "https://3lf2s3sn-5000.inc1.devtunnels.ms/full-recommendation";

  static Future<Map<String, dynamic>> getRecommendations({
    required int ageMonths,
    required String gender,
    required String season,
    required String category,
    required String priceRange,
    required int safetyLevel,
    required int softnessLevel,
  }) async {
    final url = Uri.parse("$baseUrl");

    final body = {
      "age_months": ageMonths,
      "gender": gender,
      "season": season,
      "category": category,
      "price_range": priceRange,
      "safety_level": safetyLevel,
      "softness_level": softnessLevel
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to get recommendations");
    }
  }
}
