# التفاسير - Tafaseer App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)

A beautiful, modern Quran Tafseer (interpretation) application built with Flutter.

[العربية](#العربية) | [English](#english)

</div>

---

## العربية

### 📖 عن التطبيق

تطبيق **التفاسير** هو تطبيق إسلامي حديث ومتطور يقدم تفاسير القرآن الكريم من 10 مصادر موثوقة. يتميز التطبيق بتصميم أنيق وسهولة الاستخدام ودعم العمل دون اتصال بالإنترنت.

### ✨ المميزات

- 📚 **10 تفاسير مختلفة** - الطبري، ابن كثير، السعدي، القرطبي، البغوي، ابن عاشور، الكشاف، مفاتيح الغيب، إعراب القرآن، الوسيط
- 🔍 **البحث المتقدم** - البحث في جميع التفاسير
- 🔖 **المحفوظات** - حفظ الآيات والتفاسير المفضلة
- 📱 **متعدد المنصات** - Android, iOS, Web, macOS
- 🌙 **الوضع المظلم** - دعم السمة الفاتحة والداكنة
- ✏️ **خط عثماني** - عرض القرآن بالخط العثماني الأصيل
- 📍 **متابعة القراءة** - حفظ آخر موضع قراءة تلقائياً
- 🔤 **تحكم بحجم الخط** - ضبط حجم الخط العربي

### 📦 التثبيت

```bash
# استنساخ المستودع
git clone https://github.com/yourusername/tafaseer.git
cd tafaseer/tafaseer_app

# تثبيت التبعيات
flutter pub get

# تشغيل التطبيق
flutter run
```

---

## English

### 📖 About

**Tafaseer** is a modern, premium Islamic application that provides Quran interpretations from 10 reliable sources. The app features an elegant design, ease of use, and offline support.

### ✨ Features

- 📚 **10 Tafseer Sources** - Tabari, Ibn Kathir, Saadi, Qurtubi, Baghawy, Ibn Ashur, Kashaf, Razi, Eerab, Waseet
- 🔍 **Advanced Search** - Search across all tafseer content
- 🔖 **Bookmarks** - Save favorite verses and tafseer
- 📱 **Multi-platform** - Android, iOS, Web, macOS
- 🌙 **Dark Mode** - Light and dark theme support
- ✏️ **Uthmani Font** - Authentic Quranic script display
- 📍 **Auto-save Progress** - Resume reading where you left off
- 🔤 **Font Size Control** - Adjustable Arabic font size

### 🏗️ Project Structure

```
tafaseer_app/
├── lib/
│   ├── main.dart              # Entry point
│   ├── app.dart               # App configuration
│   ├── config/                # Routes and configuration
│   ├── data/
│   │   ├── database/          # SQLite service
│   │   ├── models/            # Data models
│   │   └── providers/         # State management
│   └── presentation/
│       ├── screens/           # UI screens
│       └── theme/             # App theming
└── assets/
    ├── databases/             # SQLite databases
    └── fonts/                 # Custom fonts
```

### 📦 Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/tafaseer.git
cd tafaseer/tafaseer_app

# Install dependencies
flutter pub get

# Run the app
flutter run

# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release
```

### 🛠️ Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Provider
- **Navigation**: GoRouter
- **Database**: SQLite (sqflite)
- **Animations**: flutter_animate
- **Fonts**: Amiri, UthmanicHafs

### 📊 Database Sources

| Source | Description | Entries |
|--------|-------------|---------|
| tafaseer.db | 8 major tafseer | ~50,000+ |
| razi.sqlite | Al-Razi + Quran text | ~15,000+ |
| kashaf.db | Al-Kashshaf | ~6,000+ |

### 📄 License

Code is licensed under the MIT License. See the `LICENSE` file for details.

Quranic texts and tafseer content included in `assets/` are the property of their respective authors/publishers. Please verify redistribution rights before reuse.

### 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

<div align="center">

Made with ❤️ for the Ummah

</div>
