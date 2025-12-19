import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import 'web_data_service.dart';

/// Database service for managing all tafseer databases
/// On web, uses WebDataService with JSON files
/// On mobile, would use SQLite (not implemented in this simplified version)
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Web data service for JSON loading
  final WebDataService _webDataService = WebDataService();

  bool _isInitialized = false;
  String? _initError;

  bool get isInitialized => _isInitialized;
  bool get isWebPlatform => kIsWeb;
  String? get initError => _initError;

  /// Initialize database/data service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // For now, use web data service for all platforms
      // Mobile SQLite can be added later with conditional imports
      await _webDataService.initialize();
      _isInitialized = true;
    } catch (e) {
      _initError = 'Failed to initialize: $e';
      _isInitialized = true;
    }
  }

  // ==================== SURAH QUERIES ====================

  /// Get all surahs with metadata
  Future<List<Surah>> getAllSurahs() async {
    return await _webDataService.getAllSurahs();
  }

  /// Get a single surah by ID
  Future<Surah?> getSurahById(int surahId) async {
    return await _webDataService.getSurahById(surahId);
  }

  // ==================== AYAH QUERIES ====================

  /// Get all ayahs for a surah
  Future<List<Ayah>> getAyahsForSurah(int surahId) async {
    return await _webDataService.getAyahsForSurah(surahId);
  }

  /// Get a single ayah
  Future<Ayah?> getAyah(int surahId, int ayahNumber) async {
    return await _webDataService.getAyah(surahId, ayahNumber);
  }

  // ==================== TAFSEER QUERIES ====================

  /// Get tafseer for a specific ayah
  Future<List<TafseerEntry>> getTafseerForAyah(int surahId, int ayahNumber) async {
    // Load from all sources
    final List<TafseerEntry> results = [];
    for (int sourceId = 1; sourceId <= 10; sourceId++) {
      final entry = await _webDataService.getTafseerBySource(surahId, ayahNumber, sourceId);
      if (entry != null) {
        results.add(entry);
      }
    }
    return results;
  }

  /// Get tafseer from a specific source for an ayah
  Future<TafseerEntry?> getTafseerBySource(int surahId, int ayahNumber, int sourceId) async {
    return await _webDataService.getTafseerBySource(surahId, ayahNumber, sourceId);
  }

  /// Get all available tafseer sources
  List<TafseerSource> getAllTafseerSources() {
    return TafseerSource.allSources;
  }

  // ==================== SEARCH QUERIES ====================

  /// Search across all tafseer content
  Future<List<TafseerEntry>> searchTafseer(String query, {int? sourceId, int limit = 50}) async {
    return await _webDataService.searchTafseer(query, sourceId: sourceId);
  }

  // ==================== BOOKMARK QUERIES (Web uses SharedPreferences) ====================

  /// Save a bookmark - delegated to provider
  Future<int> saveBookmark(Bookmark bookmark) async {
    // Handled by BookmarksProvider with SharedPreferences
    return -1;
  }

  /// Get all bookmarks
  Future<List<Bookmark>> getAllBookmarks() async {
    return [];
  }

  /// Get bookmarks by type
  Future<List<Bookmark>> getBookmarksByType(BookmarkType type) async {
    return [];
  }

  /// Delete a bookmark
  Future<void> deleteBookmark(int id) async {}

  /// Check if ayah is bookmarked
  Future<bool> isBookmarked(int surahNumber, int ayahNumber) async {
    return false;
  }

  // ==================== READING PROGRESS ====================

  /// Save reading progress
  Future<void> saveReadingProgress(ReadingProgress progress) async {}

  /// Get last reading progress
  Future<ReadingProgress?> getLastReadingProgress() async {
    return null;
  }

  /// Get reading progress for a surah
  Future<ReadingProgress?> getReadingProgressForSurah(int surahNumber) async {
    return null;
  }

  // ==================== SEARCH HISTORY ====================

  /// Save search query to history
  Future<void> saveSearchQuery(String query) async {}

  /// Get recent search queries
  Future<List<String>> getRecentSearches({int limit = 10}) async {
    return [];
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {}

  /// Close all database connections
  Future<void> close() async {
    _isInitialized = false;
  }
}
