import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class FoodAnalysisService {
  static const String _apiUrl =
      "https://gvksth6m-5000.inc1.devtunnels.ms/api/pregnancy/analyze-food";

  static final ImagePicker _picker = ImagePicker();

  /// Pick image from Camera or Gallery
  static Future<File?> pickImage(ImageSource source) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: source, imageQuality: 80);

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  /// Send image to backend API
  static Future<Map<String, dynamic>> analyzeFood(File imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse(_apiUrl));

    request.files.add(
      await http.MultipartFile.fromPath(
        'image', // backend expects this key
        imageFile.path,
      ),
    );

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      throw Exception("Food analysis failed");
    }
  }
}