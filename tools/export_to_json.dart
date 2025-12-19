#!/usr/bin/env dart
/// Script to export SQLite databases to JSON files for web platform
/// Run: dart run tools/export_to_json.dart

import 'dart:convert';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

/// Surah names in Arabic (fallback)
const surahNamesArabic = [
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

const surahNamesEnglish = [
  'Al-Fatiha', 'Al-Baqarah', 'Aal-Imran', 'An-Nisa', 'Al-Maidah', 'Al-Anam', 'Al-Araf',
  'Al-Anfal', 'At-Tawbah', 'Yunus', 'Hud', 'Yusuf', 'Ar-Rad', 'Ibrahim', 'Al-Hijr',
  'An-Nahl', 'Al-Isra', 'Al-Kahf', 'Maryam', 'Ta-Ha', 'Al-Anbiya', 'Al-Hajj', 'Al-Muminun',
  'An-Nur', 'Al-Furqan', 'Ash-Shuara', 'An-Naml', 'Al-Qasas', 'Al-Ankabut', 'Ar-Rum',
  'Luqman', 'As-Sajdah', 'Al-Ahzab', 'Saba', 'Fatir', 'Ya-Sin', 'As-Saffat', 'Sad',
  'Az-Zumar', 'Ghafir', 'Fussilat', 'Ash-Shura', 'Az-Zukhruf', 'Ad-Dukhan', 'Al-Jathiyah',
  'Al-Ahqaf', 'Muhammad', 'Al-Fath', 'Al-Hujurat', 'Qaf', 'Adh-Dhariyat', 'At-Tur',
  'An-Najm', 'Al-Qamar', 'Ar-Rahman', 'Al-Waqiah', 'Al-Hadid', 'Al-Mujadila', 'Al-Hashr',
  'Al-Mumtahanah', 'As-Saf', 'Al-Jumuah', 'Al-Munafiqun', 'At-Taghabun', 'At-Talaq', 'At-Tahrim',
  'Al-Mulk', 'Al-Qalam', 'Al-Haqqah', 'Al-Maarij', 'Nuh', 'Al-Jinn', 'Al-Muzzammil', 'Al-Muddaththir',
  'Al-Qiyamah', 'Al-Insan', 'Al-Mursalat', 'An-Naba', 'An-Naziat', 'Abasa', 'At-Takwir',
  'Al-Infitar', 'Al-Mutaffifin', 'Al-Inshiqaq', 'Al-Buruj', 'At-Tariq', 'Al-Ala', 'Al-Ghashiyah',
  'Al-Fajr', 'Al-Balad', 'Ash-Shams', 'Al-Layl', 'Ad-Duhaa', 'Ash-Sharh', 'At-Tin', 'Al-Alaq',
  'Al-Qadr', 'Al-Bayyinah', 'Az-Zalzalah', 'Al-Adiyat', 'Al-Qariah', 'At-Takathur', 'Al-Asr',
  'Al-Humazah', 'Al-Fil', 'Quraysh', 'Al-Maun', 'Al-Kawthar', 'Al-Kafirun', 'An-Nasr',
  'Al-Masad', 'Al-Ikhlas', 'Al-Falaq', 'An-Nas',
];

/// Tafseer sources (8 from tafaseer.db + 2 separate databases = 10 total)
const tafseerSources = [
  // From tafaseer.db (IDs 1-8)
  {'id': 1, 'name_arabic': 'الطبري', 'name_english': 'Tafsir al-Tabari', 'db': 'tafaseer', 'source_id': 1},
  {'id': 2, 'name_arabic': 'ابن كثير', 'name_english': 'Tafsir Ibn Kathir', 'db': 'tafaseer', 'source_id': 2},
  {'id': 3, 'name_arabic': 'السعدي', 'name_english': 'Tafsir al-Saadi', 'db': 'tafaseer', 'source_id': 3},
  {'id': 4, 'name_arabic': 'القرطبي', 'name_english': 'Tafsir al-Qurtubi', 'db': 'tafaseer', 'source_id': 4},
  {'id': 5, 'name_arabic': 'البغوي', 'name_english': 'Tafsir al-Baghawi', 'db': 'tafaseer', 'source_id': 5},
  {'id': 6, 'name_arabic': 'ابن عاشور', 'name_english': 'Tafsir Ibn Ashur', 'db': 'tafaseer', 'source_id': 6},
  {'id': 7, 'name_arabic': 'إعراب القرآن', 'name_english': 'Eerab al-Quran', 'db': 'tafaseer', 'source_id': 7},
  {'id': 8, 'name_arabic': 'الوسيط', 'name_english': 'Tafsir al-Waseet', 'db': 'tafaseer', 'source_id': 8},
  // From separate databases (IDs 9-10)
  {'id': 9, 'name_arabic': 'الكشاف', 'name_english': 'Tafsir al-Kashshaf', 'db': 'kashaf', 'source_id': 9},
  {'id': 10, 'name_arabic': 'مفاتيح الغيب', 'name_english': 'Tafsir al-Razi', 'db': 'razi', 'source_id': 10},
];

void main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  final baseDir = Directory.current.path;
  final assetsDir = p.join(baseDir, 'assets/databases');
  final outputDir = p.join(baseDir, 'assets/data');
  
  print('🚀 Starting JSON export...');
  print('📂 Base dir: $baseDir\n');
  
  // Create output directories
  await Directory(outputDir).create(recursive: true);
  
  // Open databases
  final tafaseerDb = await databaseFactory.openDatabase(
    p.join(assetsDir, 'tafaseer.db'),
    options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
  );
  final raziDb = await databaseFactory.openDatabase(
    p.join(assetsDir, 'razi.sqlite'),
    options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
  );
  final kashafDb = await databaseFactory.openDatabase(
    p.join(assetsDir, 'kashaf.db'),
    options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
  );
  
  print('📂 Databases opened\n');
  
  // 1. Export surahs from razi.sqlite sura table
  await exportSurahsFromRazi(raziDb, outputDir);
  
  // 2. Export ayahs (Quran text) from razi.sqlite mybook.title
  await exportAyahsFromRazi(raziDb, outputDir);
  
  // 3. Export tafseer for each source
  for (final source in tafseerSources) {
    final sourceId = source['id'] as int;
    final nameEn = source['name_english'] as String;
    final dbName = source['db'] as String;
    final dbSourceId = source['source_id'] as int;
    
    print('📚 Exporting $nameEn (source $sourceId)...');
    
    final sourceDir = Directory(p.join(outputDir, 'tafseer_$sourceId'));
    await sourceDir.create(recursive: true);
    
    if (dbName == 'tafaseer') {
      await exportTafaseerDb(tafaseerDb, sourceId, dbSourceId, sourceDir.path);
    } else if (dbName == 'kashaf') {
      await exportKashafDb(kashafDb, sourceId, sourceDir.path);
    } else if (dbName == 'razi') {
      await exportRaziDb(raziDb, sourceId, sourceDir.path);
    }
    
    print('  ✓ tafseer_$sourceId/surah_*.json');
  }
  
  await tafaseerDb.close();
  await raziDb.close();
  await kashafDb.close();
  
  print('\n✅ Export complete! Files saved to: $outputDir');
}

/// Export surahs from razi.sqlite sura table
Future<void> exportSurahsFromRazi(Database db, String outputDir) async {
  print('📖 Exporting surahs from razi.sqlite...');
  
  final results = await db.query('sura', orderBy: 'sid ASC');
  
  final surahs = results.map((row) => {
    'id': row['sid'],
    'name_arabic': (row['stitle'] as String?)?.replaceAll('سورة ', '') ?? surahNamesArabic[(row['sid'] as int) - 1],
    'name_english': surahNamesEnglish[(row['sid'] as int) - 1],
    'ayah_count': row['sAyah'],
    'revelation_type': row['sType'],
    'revelation_type_english': (row['sType'] as String?)?.contains('مكي') == true ? 'Meccan' : 'Medinan',
  }).toList();
  
  final file = File(p.join(outputDir, 'surahs.json'));
  await file.writeAsString(jsonEncode(surahs));
  print('  ✓ surahs.json (${surahs.length} surahs)');
}

/// Export ayahs from razi.sqlite mybook.title (contains Quran text with ayah numbers)
Future<void> exportAyahsFromRazi(Database db, String outputDir) async {
  print('📜 Exporting Quran ayahs from razi.sqlite mybook.title...');
  
  final ayahsDir = Directory(p.join(outputDir, 'ayahs'));
  await ayahsDir.create(recursive: true);
  
  for (int surahId = 1; surahId <= 114; surahId++) {
    final results = await db.query(
      'mybook',
      columns: ['title', 'babnum'],
      where: 'cate = ?',
      whereArgs: [surahId.toString()],
      orderBy: 'babnum ASC',
    );
    
    final ayahs = <Map<String, dynamic>>[];
    
    for (final row in results) {
      final title = row['title'] as String? ?? '';
      
      // Extract ayah number from title - look for (number) at the end
      // Some rows have multiple ayahs like "text (1) text (2) text (3)"
      final regex = RegExp(r'\((\d+)\)');
      final matches = regex.allMatches(title);
      
      if (matches.isNotEmpty) {
        // Get the last ayah number mentioned
        final lastAyahNum = int.parse(matches.last.group(1)!);
        
        // If there's only one ayah, add it directly
        if (matches.length == 1) {
          final text = title.replaceAll(regex, '').trim();
          ayahs.add({
            'ayah_number': lastAyahNum,
            'text_arabic': text,
            'surah_id': surahId,
          });
        } else {
          // Multiple ayahs - split them
          final firstAyahNum = int.parse(matches.first.group(1)!);
          // Just use the whole text with the first ayah number
          final text = title.replaceAll(regex, '').trim();
          ayahs.add({
            'ayah_number': firstAyahNum,
            'text_arabic': text,
            'surah_id': surahId,
            'covers_ayahs': '$firstAyahNum-$lastAyahNum',
          });
        }
      } else {
        // No ayah number found, use babnum
        final babnum = row['babnum'] as int? ?? ayahs.length + 1;
        ayahs.add({
          'ayah_number': babnum,
          'text_arabic': title,
          'surah_id': surahId,
        });
      }
    }
    
    final file = File(p.join(ayahsDir.path, 'surah_$surahId.json'));
    await file.writeAsString(jsonEncode(ayahs));
  }
  print('  ✓ ayahs/surah_*.json (114 files)');
}

/// Export tafseer from tafaseer.db (8 sources)
Future<void> exportTafaseerDb(Database db, int sourceId, int dbSourceId, String outputDir) async {
  for (int surahId = 1; surahId <= 114; surahId++) {
    final results = await db.query(
      'Tafseer',
      where: 'sura = ? AND tafseer = ?',
      whereArgs: [surahId, dbSourceId],
      orderBy: 'ayah ASC',
    );
    
    final tafseer = results.map((row) => {
      'ayah_number': row['ayah'],
      'text': row['nass'] ?? '',
      'surah_id': surahId,
      'source_id': sourceId,
    }).toList();
    
    final file = File(p.join(outputDir, 'surah_$surahId.json'));
    await file.writeAsString(jsonEncode(tafseer));
  }
}

/// Export tafseer from kashaf.db
/// Structure: chapter = surah name, title = ayah text, content = tafseer
Future<void> exportKashafDb(Database db, int sourceId, String outputDir) async {
  // Build a mapping of chapter names to surah IDs
  final chapterToSurah = <String, int>{
    'سورة فاتحة الكتاب': 1,
  };
  
  // Add all surah names
  for (int i = 0; i < 114; i++) {
    chapterToSurah['سورة ${surahNamesArabic[i]}'] = i + 1;
  }
  
  // Get all distinct chapters ordered
  final chapters = await db.rawQuery(
    "SELECT DISTINCT chapter FROM alzmksherytfseer WHERE chapter != 'مقدمة التفسير للعلامة الزمخشري' ORDER BY id"
  );
  
  // Export per surah
  for (int surahId = 1; surahId <= 114; surahId++) {
    final surahName = surahNamesArabic[surahId - 1];
    
    // Find matching chapter name
    String? chapterPattern;
    if (surahId == 1) {
      chapterPattern = 'سورة فاتحة الكتاب';
    } else {
      // Try different patterns
      for (final ch in chapters) {
        final chapter = ch['chapter'] as String? ?? '';
        if (chapter.contains(surahName)) {
          chapterPattern = chapter;
          break;
        }
      }
    }
    
    List<Map<String, dynamic>> results = [];
    if (chapterPattern != null) {
      results = await db.query(
        'alzmksherytfseer',
        where: 'chapter = ?',
        whereArgs: [chapterPattern],
        orderBy: 'id ASC',
      );
    }
    
    // Format results - title is ayah text, content is tafseer
    final tafseer = <Map<String, dynamic>>[];
    for (int i = 0; i < results.length; i++) {
      final row = results[i];
      final title = row['title'] as String? ?? '';
      final content = row['content'] as String? ?? '';
      
      // Extract ayah number from title
      final regex = RegExp(r'\((\d+)\)');
      final match = regex.firstMatch(title);
      final ayahNum = match != null ? int.parse(match.group(1)!) : i + 1;
      
      tafseer.add({
        'ayah_number': ayahNum,
        'ayah_text': title,
        'text': content,
        'surah_id': surahId,
        'source_id': sourceId,
      });
    }
    
    final file = File(p.join(outputDir, 'surah_$surahId.json'));
    await file.writeAsString(jsonEncode(tafseer));
  }
}

/// Export tafseer from razi.sqlite
/// Structure: cate = surah number, title = ayah text, details = tafseer
Future<void> exportRaziDb(Database db, int sourceId, String outputDir) async {
  for (int surahId = 1; surahId <= 114; surahId++) {
    final results = await db.query(
      'mybook',
      where: 'cate = ?',
      whereArgs: [surahId.toString()],
      orderBy: 'babnum ASC',
    );
    
    final tafseer = <Map<String, dynamic>>[];
    for (final row in results) {
      final title = row['title'] as String? ?? '';
      final details = row['details'] as String? ?? '';
      
      // Extract ayah number from title
      final regex = RegExp(r'\((\d+)\)');
      final matches = regex.allMatches(title);
      
      int ayahNum = row['babnum'] as int? ?? tafseer.length + 1;
      String? coversAyahs;
      
      if (matches.isNotEmpty) {
        final firstAyahNum = int.parse(matches.first.group(1)!);
        final lastAyahNum = int.parse(matches.last.group(1)!);
        ayahNum = firstAyahNum;
        if (firstAyahNum != lastAyahNum) {
          coversAyahs = '$firstAyahNum-$lastAyahNum';
        }
      }
      
      final entry = {
        'ayah_number': ayahNum,
        'ayah_text': title,
        'text': details,
        'surah_id': surahId,
        'source_id': sourceId,
      };
      
      if (coversAyahs != null) {
        entry['covers_ayahs'] = coversAyahs;
      }
      
      tafseer.add(entry);
    }
    
    final file = File(p.join(outputDir, 'surah_$surahId.json'));
    await file.writeAsString(jsonEncode(tafseer));
  }
}
