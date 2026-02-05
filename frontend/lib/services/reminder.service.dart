import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api.dart';
import 'auth_storage.dart';

class ReminderService {
  static Future<List<dynamic>> fetchTodayReminders() async {
    final token = await AuthStorage.getToken();

    final res = await http.get(
      Uri.parse(ApiConfig.baseUrl + ApiConfig.reminderToday),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to fetch reminders");
    }
  }
}
