// IO-specific database implementation
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';

export 'package:sqflite/sqflite.dart' show Database;

Future<String> getDatabasePath(String dbName) async {
  final documentsDir = await getApplicationDocumentsDirectory();
  return join(documentsDir.path, dbName);
}

Future<void> copyDatabaseFromAssets(String assetPath, String targetPath) async {
  final file = File(targetPath);
  if (!await file.exists()) {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    await file.writeAsBytes(bytes, flush: true);
  }
}

Future<Database> openDatabaseFile(String path, {bool readOnly = false}) async {
  return await openDatabase(path, readOnly: readOnly);
}

Future<Database> createUserDatabase(String path) async {
  return await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE bookmarks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          surah_number INTEGER NOT NULL,
          ayah_number INTEGER NOT NULL,
          tafseer_source_id INTEGER,
          created_at TEXT NOT NULL,
          note TEXT,
          type INTEGER DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE reading_progress (
          surah_number INTEGER NOT NULL,
          tafseer_source_id INTEGER NOT NULL,
          ayah_number INTEGER NOT NULL,
          last_read_at TEXT NOT NULL,
          scroll_position REAL DEFAULT 0.0,
          PRIMARY KEY (surah_number, tafseer_source_id)
        )
      ''');
      await db.execute('''
        CREATE TABLE search_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          query TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    },
  );
}
