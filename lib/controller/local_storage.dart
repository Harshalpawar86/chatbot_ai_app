import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class LocalStorage {
  static dynamic database;
  static String getUniqueId() {
    String id =
        ("${Uuid().v4()}_${DateTime.fromMicrosecondsSinceEpoch(DateTime.now().microsecond).toString()}");
    return id;
  }

  static Future<void> openLocalDatabase() async {
    database = await sqflite.openDatabase(
      path.join(await sqflite.getDatabasesPath(), "AiChatbotDatabase.db"),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE information(
            id TEXT PRIMARY KEY,
            message TEXT,
            image TEXT,
            isuser INTEGER NOT NULL
          );

            ''');
      },
    );
  }

  static Future<bool> saveMessageLocally({
    required String? message,
    required bool isUser,
    required String? image,
  }) async {
    try {
      sqflite.Database localDb = await database;
      await localDb.insert('information', {
        'id': getUniqueId(),
        'message': message,
        'image': image,
        'isuser': (isUser) ? 1 : 0,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getData() async {
    sqflite.Database localDb = await database;
    return await localDb.query('information');
  }

  static Future deleteAllData() async {
    sqflite.Database localDb = await database;
    await localDb.delete('information');
  }

  static Future<String?> saveImage({
    required String image, // base64 string
    required String extension, // e.g., '.jpg', '.png'
  }) async {
    try {
      List<int> imageBytes = base64Decode(image);

      final Directory dir = await getApplicationDocumentsDirectory();

      final String filename =
          "gemini_image_${DateTime.now().millisecondsSinceEpoch}$extension";

      final File file = File(path.join(dir.path, filename));

      await file.writeAsBytes(imageBytes);

      return file.path;
    } catch (e) {
      return null;
    }
  }
}
