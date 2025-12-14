/// Ayah (verse) model representing a single verse of the Quran
class Ayah {
  final int surahNumber;
  final int ayahNumber;
  final String text;
  final bool isFavorite;

  const Ayah({
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
    this.isFavorite = false,
  });

  factory Ayah.fromMap(Map<String, dynamic> map) {
    // Parse ayah number from title like "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ (1)"
    final title = map['title'] as String? ?? '';
    int ayahNum = map['babnum'] as int? ?? 0;
    
    // Clean the text - remove the ayah number in parentheses for display
    String cleanText = title;
    final regex = RegExp(r'\s*\(\d+\)\s*$');
    cleanText = cleanText.replaceAll(regex, '').trim();
    
    return Ayah(
      surahNumber: int.tryParse(map['cate'].toString()) ?? 0,
      ayahNumber: ayahNum,
      text: cleanText,
      isFavorite: (map['fav'] as int?) == 1,
    );
  }

  factory Ayah.fromTafaseerMap(Map<String, dynamic> map) {
    return Ayah(
      surahNumber: map['sura'] as int,
      ayahNumber: map['ayah'] as int,
      text: '', // Text comes from Razi database
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sura': surahNumber,
      'ayah': ayahNumber,
      'text': text,
      'fav': isFavorite ? 1 : 0,
    };
  }

  Ayah copyWith({
    int? surahNumber,
    int? ayahNumber,
    String? text,
    bool? isFavorite,
  }) {
    return Ayah(
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      text: text ?? this.text,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Returns formatted ayah number in Arabic numerals
  String get arabicAyahNumber {
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return ayahNumber.toString().split('').map((d) => arabicNumerals[int.parse(d)]).join();
  }
}
