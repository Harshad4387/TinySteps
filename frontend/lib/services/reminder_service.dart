import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/reminder_model.dart';
import '../config/api.dart';
import '../services/auth_storage.dart';

class ReminderService {
  static Future<List<Reminder>> fetchTodayReminders() async {
    final token = await AuthStorage.getToken();
    final user = await AuthStorage.getUser();

    if (token == null || user == null) {
      throw Exception("User not authenticated");
    }

    final parentId = user["_id"];

    final url =
        "${ApiConfig.baseUrl}${ApiConfig.reminderToday}/$parentId";

    final res = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Reminder.fromJson(e)).toList();
    } else {
      throw Exception(
        "Failed to load reminders (${res.statusCode})",
      );
    }
  }
}
