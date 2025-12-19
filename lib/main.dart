import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'data/database/database_service.dart';
import 'data/providers/providers.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Use path URL strategy for web (removes # from URLs and enables deep linking)
  usePathUrlStrategy();
  
  // Set preferred orientations (skip on web as it's not supported)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  // Note: Firebase is initialized separately - see firebase_init.dart for mobile
  // Web uses Firebase JS SDK from index.html

  try {
    // Initialize database
    await DatabaseService().initialize();
  } catch (e) {
    debugPrint('Database initialization failed: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => SurahProvider()),
        ChangeNotifierProvider(create: (_) => TafseerProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => BookmarksProvider()),
      ],
      child: const TafaseerApp(),
    ),
  );
}
