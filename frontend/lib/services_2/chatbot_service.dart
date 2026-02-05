import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/server2.dart';
import '../services/auth_storage.dart';

class ChatbotService {
  static Future<String?> _token() async {
    return await AuthStorage.getToken();
  }

  static Future<ChatbotResponse> sendMessage(String message) async {
    final token = await _token();

    final response = await http.post(
      Uri.parse(ApiConfig.baseUrl + ApiConfig.chatbot),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({
        "message": message,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ChatbotResponse.fromJson(data['response']);
    } else {
      throw Exception("Chatbot failed to respond");
    }
  }
}

/// 📦 RESPONSE MODEL
class ChatbotResponse {
  final String reply;
  final String careContext;
  final String tone;
  final List<String> importantNotes;

  ChatbotResponse({
    required this.reply,
    required this.careContext,
    required this.tone,
    required this.importantNotes,
  });

  factory ChatbotResponse.fromJson(Map<String, dynamic> json) {
    return ChatbotResponse(
      reply: json['reply'],
      careContext: json['careContext'],
      tone: json['tone'],
      importantNotes:
          List<String>.from(json['importantNotes'] ?? []),
    );
  }
}
