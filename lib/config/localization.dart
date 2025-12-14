import 'package:flutter/material.dart';

/// Simple localization service for Arabic/English
class AppLocalizations {
  static const String arabic = 'ar';
  static const String english = 'en';
  
  final String locale;
  
  AppLocalizations(this.locale);
  
  bool get isArabic => locale == arabic;
  bool get isEnglish => locale == english;
  
  // App strings
  String get appName => isArabic ? 'التفاسير' : 'Tafaseer';
  String get appSubtitle => isArabic ? 'تفاسير القرآن الكريم' : 'Quran Tafseer';
  
  // Home screen
  String get searchPlaceholder => isArabic ? 'البحث في التفاسير...' : 'Search Tafseer...';
  String get goToVerse => isArabic ? 'اذهب إلى آية' : 'Go to Verse';
  String get surah => isArabic ? 'السورة' : 'Surah';
  String get ayah => isArabic ? 'الآية' : 'Ayah';
  String get continueReading => isArabic ? 'متابعة القراءة' : 'Continue Reading';
  String get resume => isArabic ? 'استئناف' : 'Resume';
  String get quickAccess => isArabic ? 'الوصول السريع' : 'Quick Access';
  String get browseSurahs => isArabic ? 'تصفح السور' : 'Browse Surahs';
  String get surahsCount => isArabic ? '114 سورة' : '114 Chapters';
  String get bookmarks => isArabic ? 'المحفوظات' : 'Bookmarks';
  String savedCount(int count) => isArabic ? '$count محفوظ' : '$count saved';
  String get availableTafseer => isArabic ? 'التفاسير المتاحة' : 'Available Tafseer';
  
  // Settings
  String get settings => isArabic ? 'الإعدادات' : 'Settings';
  String get appearance => isArabic ? 'المظهر' : 'Appearance';
  String get reading => isArabic ? 'القراءة' : 'Reading';
  String get defaultTafseer => isArabic ? 'التفسير الافتراضي' : 'Default Tafseer';
  String get aboutApp => isArabic ? 'حول التطبيق' : 'About';
  String get developer => isArabic ? 'عن المطور' : 'Developer';
  String get termsAndConditions => isArabic ? 'الشروط والأحكام' : 'Terms & Conditions';
  String get privacyPolicy => isArabic ? 'سياسة الخصوصية' : 'Privacy Policy';
  String get version => isArabic ? 'الإصدار' : 'Version';
  String get tafseerCount => isArabic ? 'التفاسير المتاحة' : 'Available Tafseer';
  String get tafseerCountValue => isArabic ? '10 تفاسير' : '10 sources';
  String get language => isArabic ? 'اللغة' : 'Language';
  String get arabic => 'العربية';
  String get english => 'English';
  
  // Theme
  String get theme => isArabic ? 'المظهر' : 'Theme';
  String get themeSystem => isArabic ? 'تلقائي' : 'System';
  String get themeLight => isArabic ? 'فاتح' : 'Light';
  String get themeDark => isArabic ? 'داكن' : 'Dark';
  
  // Font
  String get arabicFontSize => isArabic ? 'حجم الخط العربي' : 'Arabic Font Size';
  String get selectDefaultTafseer => isArabic ? 'اختر التفسير الافتراضي' : 'Select Default Tafseer';
  
  // Search
  String get search => isArabic ? 'البحث' : 'Search';
  String get noResults => isArabic ? 'لا توجد نتائج' : 'No results';
  
  // Bookmarks screen
  String get noBookmarks => isArabic ? 'لا توجد محفوظات' : 'No bookmarks yet';
  
  // Text direction
  TextDirection get textDirection => isArabic ? TextDirection.rtl : TextDirection.ltr;
}
