import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/models.dart';

/// Database service for managing all tafseer databases
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _tafaseerDb;
  Database? _raziDb;
  Database? _kashafDb;
  Database? _userDb;

  bool _isInitialized = false;
  bool _isWebPlatform = false;
  String? _initError;

  bool get isInitialized => _isInitialized;
  bool get isWebPlatform => _isWebPlatform;
  String? get initError => _initError;

  /// Initialize all databases
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Web platform can't use pre-existing SQLite databases  
    if (kIsWeb) {
      _isWebPlatform = true;
      _initError = 'Web platform: Please use Android, iOS, or macOS for full database support.';
      _isInitialized = true;
      return;
    }

    try {
      await _initTafaseerDb();
      await _initRaziDb();
      await _initKashafDb();
      await _initUserDb();
      _isInitialized = true;
    } catch (e) {
      _initError = 'Failed to initialize database: $e';
      _isInitialized = true;
    }
  }

  Future<String> _getDatabasePath(String dbName) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    return join(documentsDir.path, dbName);
  }

  Future<void> _copyDatabaseFromAssets(String assetPath, String targetPath) async {
    final file = File(targetPath);
    if (!await file.exists()) {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
    }
  }

  Future<void> _initTafaseerDb() async {
    final path = await _getDatabasePath('tafaseer.db');
    await _copyDatabaseFromAssets('assets/databases/tafaseer.db', path);
    _tafaseerDb = await openDatabase(path, readOnly: true);
  }

  Future<void> _initRaziDb() async {
    final path = await _getDatabasePath('razi.sqlite');
    await _copyDatabaseFromAssets('assets/databases/razi.sqlite', path);
    _raziDb = await openDatabase(path, readOnly: true);
  }

  Future<void> _initKashafDb() async {
    final path = await _getDatabasePath('kashaf.db');
    await _copyDatabaseFromAssets('assets/databases/kashaf.db', path);
    _kashafDb = await openDatabase(path, readOnly: true);
  }

  Future<void> _initUserDb() async {
    final path = await _getDatabasePath('user_data.db');
    _userDb = await openDatabase(
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

  // ==================== SURAH QUERIES ====================

  /// Get all surahs with metadata
  Future<List<Surah>> getAllSurahs() async {
    if (_isWebPlatform || _raziDb == null) return _getDefaultSurahs();
    try {
      final results = await _raziDb!.query('sura', orderBy: 'sid ASC');
      return results.map((map) => Surah.fromMap(map)).toList();
    } catch (e) {
      return _getDefaultSurahs();
    }
  }

  /// Get default surahs list for web/fallback
  List<Surah> _getDefaultSurahs() {
    return List.generate(114, (i) => Surah(
      id: i + 1,
      nameArabic: _surahNamesArabic[i],
      ayahCount: _surahAyahCounts[i],
      revelationType: i < 86 ? 'مكيّة' : 'مدنيّة',
    ));
  }

  /// Get a single surah by ID
  Future<Surah?> getSurahById(int surahId) async {
    if (_isWebPlatform || _raziDb == null) {
      if (surahId >= 1 && surahId <= 114) {
        return Surah(
          id: surahId,
          nameArabic: _surahNamesArabic[surahId - 1],
          ayahCount: _surahAyahCounts[surahId - 1],
          revelationType: surahId <= 86 ? 'مكيّة' : 'مدنيّة',
        );
      }
      return null;
    }
    try {
      final results = await _raziDb!.query(
        'sura',
        where: 'sid = ?',
        whereArgs: [surahId],
      );
      if (results.isEmpty) return null;
      return Surah.fromMap(results.first);
    } catch (e) {
      return null;
    }
  }

  // ==================== AYAH QUERIES ====================

  /// Get all ayahs for a surah (from Razi database which has Quran text)
  Future<List<Ayah>> getAyahsForSurah(int surahId) async {
    if (_isWebPlatform || _raziDb == null) return [];
    try {
      final results = await _raziDb!.query(
        'mybook',
        where: 'cate = ?',
        whereArgs: [surahId.toString()],
        orderBy: 'babnum ASC',
      );
      return results.map((map) => Ayah.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get a single ayah
  Future<Ayah?> getAyah(int surahId, int ayahNumber) async {
    if (_isWebPlatform || _raziDb == null) return null;
    try {
      final results = await _raziDb!.query(
        'mybook',
        where: 'cate = ? AND babnum = ?',
        whereArgs: [surahId.toString(), ayahNumber],
      );
      if (results.isEmpty) return null;
      return Ayah.fromMap(results.first);
    } catch (e) {
      return null;
    }
  }

  // ==================== TAFSEER QUERIES ====================

  /// Get tafseer for a specific ayah from the main tafaseer.db
  Future<List<TafseerEntry>> getTafseerForAyah(int surahId, int ayahNumber) async {
    if (_isWebPlatform || _tafaseerDb == null) return [];
    try {
      final results = await _tafaseerDb!.query(
        'Tafseer',
        where: 'sura = ? AND ayah = ?',
        whereArgs: [surahId, ayahNumber],
      );
      return results.map((map) => TafseerEntry.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get tafseer from a specific source for an ayah
  Future<TafseerEntry?> getTafseerBySource(int surahId, int ayahNumber, int sourceId) async {
    if (_isWebPlatform) return null;
    
    try {
      // Handle special sources
      if (sourceId == 9) {
        return await _getKashafTafseer(surahId, ayahNumber);
      } else if (sourceId == 10) {
        return await _getRaziTafseer(surahId, ayahNumber);
      }

      if (_tafaseerDb == null) return null;
      
      final results = await _tafaseerDb!.query(
        'Tafseer',
        where: 'sura = ? AND ayah = ? AND tafseer = ?',
        whereArgs: [surahId, ayahNumber, sourceId],
      );
      if (results.isEmpty) return null;
      return TafseerEntry.fromMap(results.first);
    } catch (e) {
      return null;
    }
  }

  /// Get Kashaf tafseer (from separate database)
  Future<TafseerEntry?> _getKashafTafseer(int surahId, int ayahNumber) async {
    if (_kashafDb == null) return null;
    try {
      // Kashaf is organized by surah name, need to find matching entry
      final surah = await getSurahById(surahId);
      if (surah == null) return null;

      // Query by chapter name - this is approximate matching
      final results = await _kashafDb!.query(
        'alzmksherytfseer',
        where: 'chapter LIKE ?',
        whereArgs: ['%${surah.nameArabic}%'],
      );
      
      // Return combined content for the surah
      if (results.isEmpty) return null;
      
      // Find content matching the ayah number pattern
      for (final row in results) {
        final title = row['title'] as String? ?? '';
        if (title.contains('($ayahNumber)')) {
          return TafseerEntry.fromKashafMap(row, surahId, ayahNumber);
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get Razi tafseer (from separate database)
  Future<TafseerEntry?> _getRaziTafseer(int surahId, int ayahNumber) async {
    if (_raziDb == null) return null;
    try {
      final results = await _raziDb!.query(
        'mybook',
        where: 'cate = ? AND babnum = ?',
        whereArgs: [surahId.toString(), ayahNumber],
      );
      if (results.isEmpty) return null;
      return TafseerEntry.fromRaziMap(results.first);
    } catch (e) {
      return null;
    }
  }

  /// Get all available tafseer sources
  List<TafseerSource> getAllTafseerSources() {
    return TafseerSource.allSources;
  }

  // ==================== SEARCH QUERIES ====================

  /// Search across all tafseer content
  Future<List<TafseerEntry>> searchTafseer(String query, {int? sourceId, int limit = 50}) async {
    if (_isWebPlatform) return [];
    
    final List<TafseerEntry> results = [];

    try {
      // Search in main tafaseer.db
      if (_tafaseerDb != null) {
        String whereClause = 'nass LIKE ?';
        List<dynamic> whereArgs = ['%$query%'];
        
        if (sourceId != null && sourceId <= 8) {
          whereClause += ' AND tafseer = ?';
          whereArgs.add(sourceId);
        }

        final tafaseerResults = await _tafaseerDb!.query(
          'Tafseer',
          where: whereClause,
          whereArgs: whereArgs,
          limit: limit,
        );
        results.addAll(tafaseerResults.map((m) => TafseerEntry.fromMap(m)));
      }

      // Search in Kashaf if no specific source or source is 9
      if (_kashafDb != null && (sourceId == null || sourceId == 9)) {
        final kashafResults = await _kashafDb!.query(
          'alzmksherytfseer',
          where: 'content LIKE ?',
          whereArgs: ['%$query%'],
          limit: limit ~/ 2,
        );
        for (final row in kashafResults) {
          results.add(TafseerEntry(
            tafseerSourceId: 9,
            surahNumber: 0, // Need to parse from chapter
            ayahNumber: 0,
            text: row['content'] as String? ?? '',
            source: TafseerSource.getById(9),
          ));
        }
      }

      // Search in Razi if no specific source or source is 10
      if (_raziDb != null && (sourceId == null || sourceId == 10)) {
        final raziResults = await _raziDb!.query(
          'mybook',
          where: 'details LIKE ?',
          whereArgs: ['%$query%'],
          limit: limit ~/ 2,
        );
        results.addAll(raziResults.map((m) => TafseerEntry.fromRaziMap(m)));
      }
    } catch (e) {
      // Handle error
    }

    return results;
  }

  // ==================== BOOKMARK QUERIES ====================

  /// Save a bookmark
  Future<int> saveBookmark(Bookmark bookmark) async {
    if (_userDb == null) return -1;
    try {
      return await _userDb!.insert('bookmarks', bookmark.toMap());
    } catch (e) {
      return -1;
    }
  }

  /// Get all bookmarks
  Future<List<Bookmark>> getAllBookmarks() async {
    if (_userDb == null) return [];
    try {
      final results = await _userDb!.query(
        'bookmarks',
        orderBy: 'created_at DESC',
      );
      return results.map((m) => Bookmark.fromMap(m)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get bookmarks by type
  Future<List<Bookmark>> getBookmarksByType(BookmarkType type) async {
    if (_userDb == null) return [];
    try {
      final results = await _userDb!.query(
        'bookmarks',
        where: 'type = ?',
        whereArgs: [type.index],
        orderBy: 'created_at DESC',
      );
      return results.map((m) => Bookmark.fromMap(m)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Delete a bookmark
  Future<void> deleteBookmark(int id) async {
    if (_userDb == null) return;
    try {
      await _userDb!.delete('bookmarks', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      // Handle error
    }
  }

  /// Check if ayah is bookmarked
  Future<bool> isBookmarked(int surahNumber, int ayahNumber) async {
    if (_userDb == null) return false;
    try {
      final results = await _userDb!.query(
        'bookmarks',
        where: 'surah_number = ? AND ayah_number = ?',
        whereArgs: [surahNumber, ayahNumber],
      );
      return results.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ==================== READING PROGRESS ====================

  /// Save reading progress
  Future<void> saveReadingProgress(ReadingProgress progress) async {
    if (_userDb == null) return;
    try {
      await _userDb!.insert(
        'reading_progress',
        progress.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      // Handle error
    }
  }

  /// Get last reading progress
  Future<ReadingProgress?> getLastReadingProgress() async {
    if (_userDb == null) return null;
    try {
      final results = await _userDb!.query(
        'reading_progress',
        orderBy: 'last_read_at DESC',
        limit: 1,
      );
      if (results.isEmpty) return null;
      return ReadingProgress.fromMap(results.first);
    } catch (e) {
      return null;
    }
  }

  /// Get reading progress for a surah
  Future<ReadingProgress?> getReadingProgressForSurah(int surahNumber) async {
    if (_userDb == null) return null;
    try {
      final results = await _userDb!.query(
        'reading_progress',
        where: 'surah_number = ?',
        whereArgs: [surahNumber],
        orderBy: 'last_read_at DESC',
        limit: 1,
      );
      if (results.isEmpty) return null;
      return ReadingProgress.fromMap(results.first);
    } catch (e) {
      return null;
    }
  }

  // ==================== SEARCH HISTORY ====================

  /// Save search query to history
  Future<void> saveSearchQuery(String query) async {
    if (_userDb == null) return;
    try {
      await _userDb!.insert('search_history', {
        'query': query,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Handle error
    }
  }

  /// Get recent search queries
  Future<List<String>> getRecentSearches({int limit = 10}) async {
    if (_userDb == null) return [];
    try {
      final results = await _userDb!.query(
        'search_history',
        orderBy: 'created_at DESC',
        limit: limit,
      );
      return results.map((m) => m['query'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    if (_userDb == null) return;
    try {
      await _userDb!.delete('search_history');
    } catch (e) {
      // Handle error
    }
  }

  /// Close all database connections
  Future<void> close() async {
    await _tafaseerDb?.close();
    await _raziDb?.close();
    await _kashafDb?.close();
    await _userDb?.close();
    _isInitialized = false;
  }

  // ==================== FALLBACK DATA ====================
  
  static const List<String> _surahNamesArabic = [
    'الفاتحة', 'البقرة', 'آل عمران', 'النساء', 'المائدة', 'الأنعام',
    'الأعراف', 'الأنفال', 'التوبة', 'يونس', 'هود', 'يوسف',
    'الرعد', 'إبراهيم', 'الحجر', 'النحل', 'الإسراء', 'الكهف',
    'مريم', 'طه', 'الأنبياء', 'الحج', 'المؤمنون', 'النور',
    'الفرقان', 'الشعراء', 'النمل', 'القصص', 'العنكبوت', 'الروم',
    'لقمان', 'السجدة', 'الأحزاب', 'سبأ', 'فاطر', 'يس',
    'الصافات', 'ص', 'الزمر', 'غافر', 'فصلت', 'الشورى',
    'الزخرف', 'الدخان', 'الجاثية', 'الأحقاف', 'محمد', 'الفتح',
    'الحجرات', 'ق', 'الذاريات', 'الطور', 'النجم', 'القمر',
    'الرحمن', 'الواقعة', 'الحديد', 'المجادلة', 'الحشر', 'الممتحنة',
    'الصف', 'الجمعة', 'المنافقون', 'التغابن', 'الطلاق', 'التحريم',
    'الملك', 'القلم', 'الحاقة', 'المعارج', 'نوح', 'الجن',
    'المزمل', 'المدثر', 'القيامة', 'الإنسان', 'المرسلات', 'النبأ',
    'النازعات', 'عبس', 'التكوير', 'الانفطار', 'المطففين', 'الانشقاق',
    'البروج', 'الطارق', 'الأعلى', 'الغاشية', 'الفجر', 'البلد',
    'الشمس', 'الليل', 'الضحى', 'الشرح', 'التين', 'العلق',
    'القدر', 'البينة', 'الزلزلة', 'العاديات', 'القارعة', 'التكاثر',
    'العصر', 'الهمزة', 'الفيل', 'قريش', 'الماعون', 'الكوثر',
    'الكافرون', 'النصر', 'المسد', 'الإخلاص', 'الفلق', 'الناس',
  ];

  static const List<int> _surahAyahCounts = [
    7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111,
    43, 52, 99, 128, 111, 110, 98, 135, 112, 78, 118, 64,
    77, 227, 93, 88, 69, 60, 34, 30, 73, 54, 45, 83,
    182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29,
    18, 45, 60, 49, 62, 55, 78, 96, 29, 22, 24, 13,
    14, 11, 11, 18, 12, 12, 30, 52, 52, 44, 28, 28,
    20, 56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25,
    22, 17, 19, 26, 30, 20, 15, 21, 11, 8, 8, 19,
    5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3,
    6, 3, 5, 4, 5, 6,
  ];
}
