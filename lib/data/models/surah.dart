/// Surah model representing a chapter of the Quran
class Surah {
  final int id;
  final String nameArabic;
  final String? nameEnglish;
  final int ayahCount;
  final String revelationType; // Makki or Madani
  final bool isFavorite;

  const Surah({
    required this.id,
    required this.nameArabic,
    this.nameEnglish,
    required this.ayahCount,
    required this.revelationType,
    this.isFavorite = false,
  });

  factory Surah.fromMap(Map<String, dynamic> map) {
    return Surah(
      id: map['sid'] as int,
      nameArabic: map['stitle'] as String,
      nameEnglish: map['stitle_en'] as String?,
      ayahCount: map['sAyah'] as int,
      revelationType: map['sType'] as String? ?? 'مكيّة',
      isFavorite: (map['sfav'] as int?) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sid': id,
      'stitle': nameArabic,
      'stitle_en': nameEnglish,
      'sAyah': ayahCount,
      'sType': revelationType,
      'sfav': isFavorite ? 1 : 0,
    };
  }

  Surah copyWith({
    int? id,
    String? nameArabic,
    String? nameEnglish,
    int? ayahCount,
    String? revelationType,
    bool? isFavorite,
  }) {
    return Surah(
      id: id ?? this.id,
      nameArabic: nameArabic ?? this.nameArabic,
      nameEnglish: nameEnglish ?? this.nameEnglish,
      ayahCount: ayahCount ?? this.ayahCount,
      revelationType: revelationType ?? this.revelationType,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Get English name for the surah
  static const Map<int, String> englishNames = {
    1: 'Al-Fatiha', 2: 'Al-Baqarah', 3: 'Ali Imran', 4: 'An-Nisa',
    5: 'Al-Ma\'idah', 6: 'Al-An\'am', 7: 'Al-A\'raf', 8: 'Al-Anfal',
    9: 'At-Tawbah', 10: 'Yunus', 11: 'Hud', 12: 'Yusuf',
    13: 'Ar-Ra\'d', 14: 'Ibrahim', 15: 'Al-Hijr', 16: 'An-Nahl',
    17: 'Al-Isra', 18: 'Al-Kahf', 19: 'Maryam', 20: 'Ta-Ha',
    21: 'Al-Anbiya', 22: 'Al-Hajj', 23: 'Al-Mu\'minun', 24: 'An-Nur',
    25: 'Al-Furqan', 26: 'Ash-Shu\'ara', 27: 'An-Naml', 28: 'Al-Qasas',
    29: 'Al-Ankabut', 30: 'Ar-Rum', 31: 'Luqman', 32: 'As-Sajdah',
    33: 'Al-Ahzab', 34: 'Saba', 35: 'Fatir', 36: 'Ya-Sin',
    37: 'As-Saffat', 38: 'Sad', 39: 'Az-Zumar', 40: 'Ghafir',
    41: 'Fussilat', 42: 'Ash-Shura', 43: 'Az-Zukhruf', 44: 'Ad-Dukhan',
    45: 'Al-Jathiyah', 46: 'Al-Ahqaf', 47: 'Muhammad', 48: 'Al-Fath',
    49: 'Al-Hujurat', 50: 'Qaf', 51: 'Adh-Dhariyat', 52: 'At-Tur',
    53: 'An-Najm', 54: 'Al-Qamar', 55: 'Ar-Rahman', 56: 'Al-Waqi\'ah',
    57: 'Al-Hadid', 58: 'Al-Mujadilah', 59: 'Al-Hashr', 60: 'Al-Mumtahanah',
    61: 'As-Saff', 62: 'Al-Jumu\'ah', 63: 'Al-Munafiqun', 64: 'At-Taghabun',
    65: 'At-Talaq', 66: 'At-Tahrim', 67: 'Al-Mulk', 68: 'Al-Qalam',
    69: 'Al-Haqqah', 70: 'Al-Ma\'arij', 71: 'Nuh', 72: 'Al-Jinn',
    73: 'Al-Muzzammil', 74: 'Al-Muddathir', 75: 'Al-Qiyamah', 76: 'Al-Insan',
    77: 'Al-Mursalat', 78: 'An-Naba', 79: 'An-Nazi\'at', 80: 'Abasa',
    81: 'At-Takwir', 82: 'Al-Infitar', 83: 'Al-Mutaffifin', 84: 'Al-Inshiqaq',
    85: 'Al-Buruj', 86: 'At-Tariq', 87: 'Al-A\'la', 88: 'Al-Ghashiyah',
    89: 'Al-Fajr', 90: 'Al-Balad', 91: 'Ash-Shams', 92: 'Al-Layl',
    93: 'Ad-Duha', 94: 'Ash-Sharh', 95: 'At-Tin', 96: 'Al-Alaq',
    97: 'Al-Qadr', 98: 'Al-Bayyinah', 99: 'Az-Zalzalah', 100: 'Al-Adiyat',
    101: 'Al-Qari\'ah', 102: 'At-Takathur', 103: 'Al-Asr', 104: 'Al-Humazah',
    105: 'Al-Fil', 106: 'Quraysh', 107: 'Al-Ma\'un', 108: 'Al-Kawthar',
    109: 'Al-Kafirun', 110: 'An-Nasr', 111: 'Al-Masad', 112: 'Al-Ikhlas',
    113: 'Al-Falaq', 114: 'An-Nas',
  };

  String get englishName => englishNames[id] ?? 'Surah $id';
}
