import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/providers.dart';
import '../../theme/app_theme.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookmarksProvider>().loadBookmarks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bookmarksProvider = context.watch<BookmarksProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'العلامات المرجعية',
          style: AppTypography.arabicTitle.copyWith(
            fontSize: 20,
            color: isDark ? AppColors.darkText : AppColors.text,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Bookmarks'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: bookmarksProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _BookmarksList(
                  bookmarks: bookmarksProvider.bookmarks
                      .where((b) => b.type == BookmarkType.bookmark)
                      .toList(),
                  emptyMessage: 'No bookmarks yet',
                  emptyIcon: Icons.bookmark_border_rounded,
                ),
                _BookmarksList(
                  bookmarks: bookmarksProvider.favorites,
                  emptyMessage: 'No favorites yet',
                  emptyIcon: Icons.favorite_border_rounded,
                ),
              ],
            ),
    );
  }
}

class _BookmarksList extends StatelessWidget {
  final List<Bookmark> bookmarks;
  final String emptyMessage;
  final IconData emptyIcon;

  const _BookmarksList({
    required this.bookmarks,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Your saved items will appear here',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        return _BookmarkTile(bookmark: bookmark)
            .animate()
            .fadeIn(delay: (index * 50).ms)
            .slideX(begin: 0.05);
      },
    );
  }
}

class _BookmarkTile extends StatelessWidget {
  final Bookmark bookmark;

  const _BookmarkTile({required this.bookmark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surahProvider = context.watch<SurahProvider>();
    final surah = surahProvider.getSurahById(bookmark.surahNumber);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Dismissible(
        key: Key('bookmark_${bookmark.id}'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) {
          if (bookmark.id != null) {
            context.read<BookmarksProvider>().removeBookmark(bookmark.id!);
          }
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(Icons.delete_rounded, color: Colors.white),
        ),
        child: Material(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: InkWell(
            onTap: () => context.push(
              '/surah/${bookmark.surahNumber}/ayah/${bookmark.ayahNumber}',
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isDark ? AppColors.darkDivider : AppColors.divider,
                ),
              ),
              child: Row(
                children: [
                  // Surah number
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${bookmark.surahNumber}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: AppSpacing.md),
                  
                  // Bookmark info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surah?.nameArabic ?? 'سورة ${bookmark.surahNumber}',
                          style: AppTypography.arabicBody.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkText : AppColors.text,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Ayah ${bookmark.ayahNumber}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            if (bookmark.tafseerSourceId != null) ...[
                              const Text(' • '),
                              Text(
                                TafseerSource.getById(bookmark.tafseerSourceId!)?.nameArabic ?? '',
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 12,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (bookmark.note != null && bookmark.note!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              bookmark.note!,
                              style: theme.textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textLight,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
