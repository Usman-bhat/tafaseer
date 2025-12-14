import 'package:go_router/go_router.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/surah_list/surah_list_screen.dart';
import '../presentation/screens/tafseer_view/tafseer_view_screen.dart';
import '../presentation/screens/search/search_screen.dart';
import '../presentation/screens/bookmarks/bookmarks_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/about/developer_screen.dart';
import '../presentation/screens/about/terms_screen.dart';
import '../presentation/screens/about/privacy_policy_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/surahs',
      name: 'surahs',
      builder: (context, state) => const SurahListScreen(),
    ),
    GoRoute(
      path: '/surah/:surahId',
      name: 'surah',
      builder: (context, state) {
        final surahId = int.parse(state.pathParameters['surahId']!);
        return TafseerViewScreen(surahId: surahId);
      },
    ),
    GoRoute(
      path: '/surah/:surahId/ayah/:ayahNumber',
      name: 'ayah',
      builder: (context, state) {
        final surahId = int.parse(state.pathParameters['surahId']!);
        final ayahNumber = int.parse(state.pathParameters['ayahNumber']!);
        return TafseerViewScreen(surahId: surahId, initialAyah: ayahNumber);
      },
    ),
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/bookmarks',
      name: 'bookmarks',
      builder: (context, state) => const BookmarksScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/developer',
      name: 'developer',
      builder: (context, state) => const DeveloperScreen(),
    ),
    GoRoute(
      path: '/terms',
      name: 'terms',
      builder: (context, state) => const TermsScreen(),
    ),
    GoRoute(
      path: '/privacy',
      name: 'privacy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
  ],
);
