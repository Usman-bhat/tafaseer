/// Tafseer source information
class TafseerSource {
  final int id;
  final String nameArabic;
  final String nameEnglish;
  final String? author;
  final String? description;

  const TafseerSource({
    required this.id,
    required this.nameArabic,
    required this.nameEnglish,
    this.author,
    this.description,
  });

  factory TafseerSource.fromMap(Map<String, dynamic> map) {
    return TafseerSource(
      id: map['ID'] as int,
      nameArabic: map['Name'] as String,
      nameEnglish: map['NameE'] as String? ?? '',
    );
  }

  /// Predefined tafseer sources
  static const List<TafseerSource> allSources = [
    TafseerSource(id: 1, nameArabic: 'الطبري', nameEnglish: 'tabary', author: 'ابن جرير الطبري'),
    TafseerSource(id: 2, nameArabic: 'ابن كثير', nameEnglish: 'katheer', author: 'ابن كثير'),
    TafseerSource(id: 3, nameArabic: 'السعدي', nameEnglish: 'saadi', author: 'عبد الرحمن السعدي'),
    TafseerSource(id: 4, nameArabic: 'القرطبي', nameEnglish: 'qortobi', author: 'الإمام القرطبي'),
    TafseerSource(id: 5, nameArabic: 'البغوي', nameEnglish: 'baghawy', author: 'الإمام البغوي'),
    TafseerSource(id: 6, nameArabic: 'ابن عاشور', nameEnglish: 'tanweer', author: 'محمد الطاهر ابن عاشور'),
    TafseerSource(id: 7, nameArabic: 'إعراب القرآن', nameEnglish: 'eerab', author: 'قاسم دعاس'),
    TafseerSource(id: 8, nameArabic: 'الوسيط', nameEnglish: 'waseet', author: 'محمد سيد طنطاوي'),
    // Additional sources from separate databases
    TafseerSource(id: 9, nameArabic: 'الكشاف', nameEnglish: 'kashaf', author: 'الزمخشري'),
    TafseerSource(id: 10, nameArabic: 'مفاتيح الغيب', nameEnglish: 'razi', author: 'فخر الدين الرازي'),
  ];

  static TafseerSource? getById(int id) {
    try {
      return allSources.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Tafseer entry containing the interpretation text
class TafseerEntry {
  final int tafseerSourceId;
  final int surahNumber;
  final int ayahNumber;
  final String text;
  final TafseerSource? source;

  const TafseerEntry({
    required this.tafseerSourceId,
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
    this.source,
  });

  factory TafseerEntry.fromMap(Map<String, dynamic> map) {
    final sourceId = map['tafseer'] as int;
    return TafseerEntry(
      tafseerSourceId: sourceId,
      surahNumber: map['sura'] as int,
      ayahNumber: map['ayah'] as int,
      text: map['nass'] as String? ?? '',
      source: TafseerSource.getById(sourceId),
    );
  }

  factory TafseerEntry.fromKashafMap(Map<String, dynamic> map, int surahNum, int ayahNum) {
    return TafseerEntry(
      tafseerSourceId: 9, // Kashaf
      surahNumber: surahNum,
      ayahNumber: ayahNum,
      text: map['content'] as String? ?? '',
      source: TafseerSource.getById(9),
    );
  }

  factory TafseerEntry.fromRaziMap(Map<String, dynamic> map) {
    return TafseerEntry(
      tafseerSourceId: 10, // Razi
      surahNumber: int.tryParse(map['cate'].toString()) ?? 0,
      ayahNumber: map['babnum'] as int? ?? 0,
      text: map['details'] as String? ?? '',
      source: TafseerSource.getById(10),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tafseer': tafseerSourceId,
      'sura': surahNumber,
      'ayah': ayahNumber,
      'nass': text,
    };
  }
}
