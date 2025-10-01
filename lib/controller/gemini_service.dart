import 'dart:convert';
import 'dart:io';
import 'package:ai_chatbot/controller/local_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class GeminiService {
  String? apikKey = dotenv.env['GEMINI_API_KEY'];
  String modelName = "gemini-2.0-flash-preview-image-generation";

  Future<Map<String, String?>?> sendRequest({
    required String question,
    required File? selectedImage,
  }) async {
    final String link =
        "https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apikKey";
    try {
      if (selectedImage == null) {
        Map<String, dynamic> body = {
          "contents": [
            {
              "parts": [
                {"text": question},
              ],
            },
          ],
          "generationConfig": {
            "responseModalities": ["TEXT", "IMAGE"],
          },
        };
        http.Response response = await http.post(
          Uri.parse(link),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );
        if (response.statusCode == 200) {
          Map<String, dynamic> data = jsonDecode(response.body);

          String? message;
          String? imageBase64;
          String? mimeType;
          final parts = data['candidates'][0]['content']['parts'] as List;

          for (var part in parts) {
            if (part.containsKey('text')) {
              message = part['text'];
            } else if (part.containsKey('inlineData')) {
              imageBase64 = part['inlineData']['data'];
              mimeType = part['inlineData']['mimeType']; // 👈
            }
          }
          String? extension;
          if (mimeType != null) {
            if (mimeType == "image/png") {
              extension = ".png";
            } else if (mimeType == "image/jpeg") {
              extension = ".jpg";
            } else if (mimeType == "image/svg") {
              extension = ".svg";
            } else {
              extension = null; // fallback
            }
          }
          String? imagePath;
          if (imageBase64 != null && extension != null) {
            imagePath = await LocalStorage.saveImage(
              image: imageBase64,
              extension: extension,
            );
          }

          return {'message': message, 'image': imagePath};
        } else {
          return null;
        }
      } else {
        List<int> imageBytes = await selectedImage.readAsBytes();
        String ext = p.extension(selectedImage.path).toLowerCase();
        String mimeType;
        switch (ext) {
          case ".jpg":
          case ".jpeg":
            mimeType = "image/jpeg";
            break;
          case ".png":
            mimeType = "image/png";
            break;
          case ".gif":
            mimeType = "image/gif";
            break;
          default:
            mimeType = "application/octet-stream"; // fallback
        }
        String base64String = base64Encode(imageBytes);

        Map<String, dynamic> body = {
          "contents": [
            {
              "parts": [
                {"text": question},
                {
                  "inlineData": {"mimeType": mimeType, "data": base64String},
                },
              ],
            },
          ],
          "generationConfig": {
            "responseModalities": ["TEXT", "IMAGE"],
          },
        };

        http.Response response = await http.post(
          Uri.parse(link),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> data = jsonDecode(response.body);
          String? message;
          String? imageBase64;
          String? mType;
          final parts = data['candidates'][0]['content']['parts'] as List;

          for (var part in parts) {
            if (part.containsKey('text')) {
              message = part['text'];
            } else if (part.containsKey('inlineData')) {
              imageBase64 = part['inlineData']['data'];
              mType = part['inlineData']['mimeType']; // 👈
            }
          }
          String? extension;
          if (mType != null) {
            if (mType == "image/png") {
              extension = ".png";
            } else if (mType == "image/jpeg") {
              extension = ".jpg";
            } else if (mType == "image/svg") {
              extension = ".svg";
            } else {
              extension = null; // fallback
            }
          }
          String? imagePath;
          if (imageBase64 != null && extension != null) {
            imagePath = await LocalStorage.saveImage(
              image: imageBase64,
              extension: extension,
            );
          }

          return {'message': message, 'image': imagePath};
        } else {
          return null;
        }
      }
    } catch (e) {
      return null;
    }
  }
}
