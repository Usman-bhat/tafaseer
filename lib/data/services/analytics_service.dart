import 'package:flutter/foundation.dart';

/// Analytics service for tracking custom events
/// On web, analytics is handled by Firebase JS SDK in index.html
/// This service is a no-op - analytics events are not tracked via Dart
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  /// Log when a surah is viewed
  Future<void> logSurahViewed({
    required int surahId,
    required String surahName,
  }) async {
    // No-op: Web uses JS SDK, mobile will use platform-specific analytics
    debugPrint('Analytics: surah_viewed - $surahId: $surahName');
  }

  /// Log when a tafseer source is selected
  Future<void> logTafseerSelected({
    required int sourceId,
    required String sourceName,
  }) async {
    debugPrint('Analytics: tafseer_selected - $sourceId: $sourceName');
  }

  /// Log when an ayah is viewed
  Future<void> logAyahViewed({
    required int surahId,
    required int ayahNumber,
    required int tafseerSourceId,
  }) async {
    debugPrint('Analytics: ayah_viewed - $surahId:$ayahNumber (source $tafseerSourceId)');
  }

  /// Log when a bookmark is added
  Future<void> logBookmarkAdded({
    required int surahId,
    required int ayahNumber,
  }) async {
    debugPrint('Analytics: bookmark_added - $surahId:$ayahNumber');
  }

  /// Log when search is performed
  Future<void> logSearch({
    required String query,
    int? sourceId,
  }) async {
    debugPrint('Analytics: search - "$query"');
  }

  /// Log when tafseer chips are used to switch tafseer
  Future<void> logTafseerChipTapped({
    required int fromSourceId,
    required int toSourceId,
    required String toSourceName,
  }) async {
    debugPrint('Analytics: tafseer_chip_tapped - $fromSourceId -> $toSourceId');
  }

  /// Log share action
  Future<void> logShare({
    required int surahId,
    required int ayahNumber,
    required String contentType,
  }) async {
    debugPrint('Analytics: share - $surahId:$ayahNumber ($contentType)');
  }

  /// Set user property for preferred tafseer
  Future<void> setPreferredTafseer(int sourceId) async {
    debugPrint('Analytics: setPreferredTafseer - $sourceId');
  }

  /// Set user property for preferred language
  Future<void> setPreferredLanguage(String language) async {
    debugPrint('Analytics: setPreferredLanguage - $language');
  }
}
