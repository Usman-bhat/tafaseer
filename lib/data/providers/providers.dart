import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/database/database_service.dart';
import '../../data/models/models.dart';

/// App state provider for global app settings
class AppStateProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  double _arabicFontSize = 20.0;
  int _selectedTafseerSourceId = 1; // Default to Tabari
  String _language = 'ar'; // Default to Arabic
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  double get arabicFontSize => _arabicFontSize;
  int get selectedTafseerSourceId => _selectedTafseerSourceId;
  String get language => _language;
  bool get isArabic => _language == 'ar';
  bool get isEnglish => _language == 'en';
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    final themeModeIndex = prefs.getInt('theme_mode') ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];
    
    _arabicFontSize = prefs.getDouble('arabic_font_size') ?? 20.0;
    _selectedTafseerSourceId = prefs.getInt('selected_tafseer_source') ?? 1;
    _language = prefs.getString('language') ?? 'ar';
    
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    notifyListeners();
  }

  Future<void> setArabicFontSize(double size) async {
    _arabicFontSize = size.clamp(14.0, 32.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('arabic_font_size', _arabicFontSize);
    notifyListeners();
  }

  Future<void> setSelectedTafseerSource(int sourceId) async {
    _selectedTafseerSourceId = sourceId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_tafseer_source', sourceId);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    notifyListeners();
  }
}

/// Surah data provider
class SurahProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  
  List<Surah> _surahs = [];
  bool _isLoading = false;
  String? _error;

  List<Surah> get surahs => _surahs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSurahs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _surahs = await _db.getAllSurahs();
    } catch (e) {
      _error = 'Failed to load surahs: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Surah? getSurahById(int id) {
    try {
      return _surahs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Tafseer data provider
class TafseerProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  
  List<Ayah> _ayahs = [];
  Map<int, List<TafseerEntry>> _tafseerCache = {};
  TafseerEntry? _currentTafseer;
  int _currentSurahId = 1;
  int _currentAyahNumber = 1;
  int _selectedSourceId = 1;
  bool _isLoading = false;
  String? _error;

  List<Ayah> get ayahs => _ayahs;
  TafseerEntry? get currentTafseer => _currentTafseer;
  int get currentSurahId => _currentSurahId;
  int get currentAyahNumber => _currentAyahNumber;
  int get selectedSourceId => _selectedSourceId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<TafseerSource> get availableSources => TafseerSource.allSources;

  Future<void> loadAyahsForSurah(int surahId) async {
    _isLoading = true;
    _error = null;
    _currentSurahId = surahId;
    notifyListeners();

    try {
      _ayahs = await _db.getAyahsForSurah(surahId);
      _tafseerCache.clear();
    } catch (e) {
      _error = 'Failed to load ayahs: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTafseerForAyah(int ayahNumber, {int? sourceId}) async {
    _currentAyahNumber = ayahNumber;
    if (sourceId != null) {
      _selectedSourceId = sourceId;
    }

    // Check cache
    final cacheKey = _currentAyahNumber * 100 + _selectedSourceId;
    if (_tafseerCache.containsKey(cacheKey)) {
      final cached = _tafseerCache[cacheKey]!;
      _currentTafseer = cached.isNotEmpty ? cached.first : null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final tafseer = await _db.getTafseerBySource(
        _currentSurahId, 
        ayahNumber, 
        _selectedSourceId,
      );
      _currentTafseer = tafseer;
      
      // Cache it
      _tafseerCache[cacheKey] = tafseer != null ? [tafseer] : [];
    } catch (e) {
      _error = 'Failed to load tafseer: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSelectedSource(int sourceId) {
    _selectedSourceId = sourceId;
    loadTafseerForAyah(_currentAyahNumber);
  }

  Ayah? getAyahByNumber(int number) {
    try {
      return _ayahs.firstWhere((a) => a.ayahNumber == number);
    } catch (_) {
      return null;
    }
  }
}

/// Search provider
class SearchProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  
  List<TafseerEntry> _results = [];
  List<String> _recentSearches = [];
  String _query = '';
  int? _filterSourceId;
  bool _isSearching = false;

  List<TafseerEntry> get results => _results;
  List<String> get recentSearches => _recentSearches;
  String get query => _query;
  int? get filterSourceId => _filterSourceId;
  bool get isSearching => _isSearching;

  Future<void> loadRecentSearches() async {
    _recentSearches = await _db.getRecentSearches();
    notifyListeners();
  }

  Future<void> search(String query, {int? sourceId}) async {
    if (query.isEmpty) {
      _results = [];
      notifyListeners();
      return;
    }

    _query = query;
    _filterSourceId = sourceId;
    _isSearching = true;
    notifyListeners();

    try {
      _results = await _db.searchTafseer(query, sourceId: sourceId);
      await _db.saveSearchQuery(query);
      await loadRecentSearches();
    } catch (e) {
      _results = [];
    }

    _isSearching = false;
    notifyListeners();
  }

  void setFilterSource(int? sourceId) {
    _filterSourceId = sourceId;
    if (_query.isNotEmpty) {
      search(_query, sourceId: sourceId);
    }
  }

  Future<void> clearHistory() async {
    await _db.clearSearchHistory();
    _recentSearches = [];
    notifyListeners();
  }
}

/// Bookmarks provider
class BookmarksProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  
  List<Bookmark> _bookmarks = [];
  ReadingProgress? _lastProgress;
  bool _isLoading = false;

  List<Bookmark> get bookmarks => _bookmarks;
  List<Bookmark> get favorites => _bookmarks.where((b) => b.type == BookmarkType.favorite).toList();
  ReadingProgress? get lastProgress => _lastProgress;
  bool get isLoading => _isLoading;

  Future<void> loadBookmarks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _bookmarks = await _db.getAllBookmarks();
      _lastProgress = await _db.getLastReadingProgress();
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addBookmark({
    required int surahNumber,
    required int ayahNumber,
    int? tafseerSourceId,
    String? note,
    BookmarkType type = BookmarkType.bookmark,
  }) async {
    final bookmark = Bookmark(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      tafseerSourceId: tafseerSourceId,
      createdAt: DateTime.now(),
      note: note,
      type: type,
    );

    await _db.saveBookmark(bookmark);
    await loadBookmarks();
  }

  Future<void> removeBookmark(int id) async {
    await _db.deleteBookmark(id);
    await loadBookmarks();
  }

  Future<bool> isAyahBookmarked(int surahNumber, int ayahNumber) async {
    return await _db.isBookmarked(surahNumber, ayahNumber);
  }

  Future<void> saveProgress({
    required int surahNumber,
    required int ayahNumber,
    required int tafseerSourceId,
    double scrollPosition = 0.0,
  }) async {
    final progress = ReadingProgress(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      tafseerSourceId: tafseerSourceId,
      lastReadAt: DateTime.now(),
      scrollPosition: scrollPosition,
    );

    await _db.saveReadingProgress(progress);
    _lastProgress = progress;
    notifyListeners();
  }
}
