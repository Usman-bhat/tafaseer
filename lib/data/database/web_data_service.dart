import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';

/// Web-specific data service that loads JSON files instead of SQLite
class WebDataService {
  static final WebDataService _instance = WebDataService._internal();
  factory WebDataService() => _instance;
  WebDataService._internal();

  // Cache loaded data
  List<Surah>? _surahs;
  final Map<int, List<Ayah>> _ayahsCache = {};
  final Map<String, List<TafseerEntry>> _tafseerCache = {};

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize the web data service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Pre-load surahs list (small file, always needed)
      await loadSurahs();
      _isInitialized = true;
    } catch (e) {
      print('WebDataService init error: $e');
      _isInitialized = true;
    }
  }

  // ==================== SURAH QUERIES ====================

  /// Load surahs from JSON
  Future<List<Surah>> loadSurahs() async {
    if (_surahs != null) return _surahs!;
    
    try {
      final jsonString = await rootBundle.loadString('assets/data/surahs.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _surahs = jsonList.map((json) => Surah(
        id: json['id'],
        nameArabic: json['name_arabic'],
        nameEnglish: json['name_english'],
        ayahCount: json['ayah_count'],
        revelationType: json['revelation_type'],
      )).toList();
      return _surahs!;
    } catch (e) {
      // Return default surahs if JSON fails to load
      return _getDefaultSurahs();
    }
  }

  Future<List<Surah>> getAllSurahs() async {
    return await loadSurahs();
  }

  Future<Surah?> getSurahById(int surahId) async {
    final surahs = await loadSurahs();
    try {
      return surahs.firstWhere((s) => s.id == surahId);
    } catch (_) {
      return null;
    }
  }

  // ==================== AYAH QUERIES ====================

  /// Load ayahs for a surah from JSON
  Future<List<Ayah>> getAyahsForSurah(int surahId) async {
    if (_ayahsCache.containsKey(surahId)) {
      return _ayahsCache[surahId]!;
    }
    
    try {
      final jsonString = await rootBundle.loadString('assets/data/ayahs/surah_$surahId.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final ayahs = jsonList.map((json) => Ayah(
        surahNumber: json['surah_id'],
        ayahNumber: json['ayah_number'],
        text: json['text_arabic'] ?? '',
      )).toList();
      _ayahsCache[surahId] = ayahs;
      return ayahs;
    } catch (e) {
      return [];
    }
  }

  Future<Ayah?> getAyah(int surahId, int ayahNumber) async {
    final ayahs = await getAyahsForSurah(surahId);
    try {
      return ayahs.firstWhere((a) => a.ayahNumber == ayahNumber);
    } catch (_) {
      return null;
    }
  }

  // ==================== TAFSEER QUERIES ====================

  /// Load tafseer for a surah from a specific source
  Future<List<TafseerEntry>> getTafseerForSurah(int surahId, int sourceId) async {
    final cacheKey = '${sourceId}_$surahId';
    if (_tafseerCache.containsKey(cacheKey)) {
      return _tafseerCache[cacheKey]!;
    }
    
    try {
      final jsonString = await rootBundle.loadString('assets/data/tafseer_$sourceId/surah_$surahId.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<TafseerEntry> tafseer = jsonList.map((json) => TafseerEntry(
        surahNumber: json['surah_id'] as int,
        ayahNumber: json['ayah_number'] as int,
        text: (json['text'] as String?) ?? '',
        tafseerSourceId: (json['source_id'] as int?) ?? sourceId,
      )).toList();
      _tafseerCache[cacheKey] = tafseer;
      return tafseer;
    } catch (e) {
      return [];
    }
  }

  /// Get tafseer by source for a specific ayah
  Future<TafseerEntry?> getTafseerBySource(int surahId, int ayahNumber, int sourceId) async {
    final tafseerList = await getTafseerForSurah(surahId, sourceId);
    try {
      return tafseerList.firstWhere((t) => t.ayahNumber == ayahNumber);
    } catch (_) {
      return null;
    }
  }

  /// Search tafseer (limited functionality for web)
  Future<List<TafseerEntry>> searchTafseer(String query, {int? sourceId}) async {
    // For web, we can only search in cached data
    // Full search would require loading all files which is expensive
    final results = <TafseerEntry>[];
    
    for (final entry in _tafseerCache.entries) {
      for (final tafseer in entry.value) {
        if (tafseer.text.contains(query)) {
          if (sourceId == null || tafseer.tafseerSourceId == sourceId) {
            results.add(tafseer);
            if (results.length >= 50) return results;
          }
        }
      }
    }
    
    return results;
  }

  // ==================== USER DATA (LOCAL STORAGE) ====================
  
  // For bookmarks and reading progress, we'll use browser localStorage
  // These are implemented with shared_preferences which works on web

  // ==================== HELPER METHODS ====================

  List<Surah> _getDefaultSurahs() {
    const names = [
      'الفاتحة', 'البقرة', 'آل عمران', 'النساء', 'المائدة', 'الأنعام', 'الأعراف',
      'الأنفال', 'التوبة', 'يونس', 'هود', 'يوسف', 'الرعد', 'إبراهيم', 'الحجر',
      'النحل', 'الإسراء', 'الكهف', 'مريم', 'طه', 'الأنبياء', 'الحج', 'المؤمنون',
      'النور', 'الفرقان', 'الشعراء', 'النمل', 'القصص', 'العنكبوت', 'الروم',
      'لقمان', 'السجدة', 'الأحزاب', 'سبأ', 'فاطر', 'يس', 'الصافات', 'ص',
      'الزمر', 'غافر', 'فصلت', 'الشورى', 'الزخرف', 'الدخان', 'الجاثية',
      'الأحقاف', 'محمد', 'الفتح', 'الحجرات', 'ق', 'الذاريات', 'الطور',
      'النجم', 'القمر', 'الرحمن', 'الواقعة', 'الحديد', 'المجادلة', 'الحشر',
      'الممتحنة', 'الصف', 'الجمعة', 'المنافقون', 'التغابن', 'الطلاق', 'التحريم',
      'الملك', 'القلم', 'الحاقة', 'المعارج', 'نوح', 'الجن', 'المزمل', 'المدثر',
      'القيامة', 'الإنسان', 'المرسلات', 'النبأ', 'النازعات', 'عبس', 'التكوير',
      'الانفطار', 'المطففين', 'الانشقاق', 'البروج', 'الطارق', 'الأعلى', 'الغاشية',
      'الفجر', 'البلد', 'الشمس', 'الليل', 'الضحى', 'الشرح', 'التين', 'العلق',
      'القدر', 'البينة', 'الزلزلة', 'العاديات', 'القارعة', 'التكاثر', 'العصر',
      'الهمزة', 'الفيل', 'قريش', 'الماعون', 'الكوثر', 'الكافرون', 'النصر',
      'المسد', 'الإخلاص', 'الفلق', 'الناس',
    ];
    const ayahCounts = [
      7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, 128, 111,
      110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34, 30, 73, 54, 45,
      83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18, 45, 60, 49, 62, 55,
      78, 96, 29, 22, 24, 13, 14, 11, 11, 18, 12, 12, 30, 52, 52, 44, 28, 28, 20, 56,
      40, 31, 50, 40, 46, 42, 29, 19, 36, 25, 22, 17, 19, 26, 30, 20, 15, 21, 11,
      8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3, 6, 3, 5, 4, 5, 6,
    ];
    
    return List.generate(114, (i) => Surah(
      id: i + 1,
      nameArabic: names[i],
      ayahCount: ayahCounts[i],
      revelationType: i < 86 ? 'مكيّة' : 'مدنيّة',
    ));
  }

  /// Clear all caches
  void clearCache() {
    _surahs = null;
    _ayahsCache.clear();
    _tafseerCache.clear();
  }
}
