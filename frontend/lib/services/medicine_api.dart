import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/medicine_model.dart';
import '../config/api.dart';

class MedicineApi {
  static Future<List<Medicine>> searchMedicine(String query) async {
    final uri = Uri.parse(
      "${ApiConfig.baseUrl}${ApiConfig.medicineCall}",
    ).replace(queryParameters: {
      "q": query,
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      final List products = decoded['products'] ?? [];

      return products
          .map((item) => Medicine.fromJson(item))
          .toList();
    } else {
      throw Exception("Failed to fetch medicines");
    }
  }
}
