/// Bookmark model for saving reading progress and favorite verses
class Bookmark {
  final int? id;
  final int surahNumber;
  final int ayahNumber;
  final int? tafseerSourceId;
  final DateTime createdAt;
  final String? note;
  final BookmarkType type;

  const Bookmark({
    this.id,
    required this.surahNumber,
    required this.ayahNumber,
    this.tafseerSourceId,
    required this.createdAt,
    this.note,
    this.type = BookmarkType.bookmark,
  });

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'] as int?,
      surahNumber: map['surah_number'] as int,
      ayahNumber: map['ayah_number'] as int,
      tafseerSourceId: map['tafseer_source_id'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
      note: map['note'] as String?,
      type: BookmarkType.values[map['type'] as int? ?? 0],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'tafseer_source_id': tafseerSourceId,
      'created_at': createdAt.toIso8601String(),
      'note': note,
      'type': type.index,
    };
  }

  Bookmark copyWith({
    int? id,
    int? surahNumber,
    int? ayahNumber,
    int? tafseerSourceId,
    DateTime? createdAt,
    String? note,
    BookmarkType? type,
  }) {
    return Bookmark(
      id: id ?? this.id,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      tafseerSourceId: tafseerSourceId ?? this.tafseerSourceId,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      type: type ?? this.type,
    );
  }
}

enum BookmarkType {
  bookmark,    // Regular bookmark
  lastRead,    // Last reading position
  favorite,    // Favorite verse
  note,        // Verse with personal note
}

/// Reading progress model
class ReadingProgress {
  final int surahNumber;
  final int ayahNumber;
  final int tafseerSourceId;
  final DateTime lastReadAt;
  final double scrollPosition;

  const ReadingProgress({
    required this.surahNumber,
    required this.ayahNumber,
    required this.tafseerSourceId,
    required this.lastReadAt,
    this.scrollPosition = 0.0,
  });

  factory ReadingProgress.fromMap(Map<String, dynamic> map) {
    return ReadingProgress(
      surahNumber: map['surah_number'] as int,
      ayahNumber: map['ayah_number'] as int,
      tafseerSourceId: map['tafseer_source_id'] as int,
      lastReadAt: DateTime.parse(map['last_read_at'] as String),
      scrollPosition: (map['scroll_position'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'tafseer_source_id': tafseerSourceId,
      'last_read_at': lastReadAt.toIso8601String(),
      'scroll_position': scrollPosition,
    };
  }
}
