import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import 'auth_storage.dart';

class AuthService {
  static Future<bool> isAuthenticated() async {
    final token = await AuthStorage.getToken();

    if (token == null) return false;

    try {
      final res = await http.get(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.authenticated),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (res.statusCode == 200) {
        return true;
      } else {
        await AuthStorage.clear();
        return false;
      }
    } catch (_) {
      return false;
    }
  }
}
