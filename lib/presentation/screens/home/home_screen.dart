import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/providers.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _selectedSurah;
  int? _selectedAyah;
  List<Surah> _surahs = [];
  int _ayahCount = 7;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<SurahProvider>().loadSurahs();
      context.read<BookmarksProvider>().loadBookmarks();
      await _loadSurahs();
    });
  }

  Future<void> _loadSurahs() async {
    final surahProvider = context.read<SurahProvider>();
    await surahProvider.loadSurahs();
    if (mounted) {
      setState(() {
        _surahs = surahProvider.surahs;
        if (_surahs.isNotEmpty && _selectedSurah == null) {
          _selectedSurah = 1;
          _ayahCount = _surahs.first.ayahCount;
          _selectedAyah = 1;
        }
      });
    }
  }

  void _onSurahChanged(int? surahId) {
    if (surahId == null) return;
    final surah = _surahs.firstWhere((s) => s.id == surahId);
    setState(() {
      _selectedSurah = surahId;
      _ayahCount = surah.ayahCount;
      _selectedAyah = 1;
    });
  }

  void _goToVerse() {
    if (_selectedSurah != null && _selectedAyah != null) {
      context.push('/surah/$_selectedSurah/ayah/$_selectedAyah');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookmarks = context.watch<BookmarksProvider>();
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          // Islamic pattern background
          Positioned.fill(
            child: CustomPaint(
              painter: _IslamicPatternPainter(
                color: isDark ? Colors.white : AppColors.primary,
                opacity: isDark ? 0.03 : 0.04,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: CustomScrollView(
              slivers: [
            // Header with title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App title row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.watch<AppStateProvider>().isArabic ? 'التفاسير' : 'Tafaseer',
                              style: AppTypography.arabicDisplay.copyWith(
                                color: AppColors.primary,
                              ),
                            ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1),
                            const SizedBox(height: 4),
                            Text(
                              context.watch<AppStateProvider>().isArabic ? 'تفاسير القرآن الكريم' : 'Quran Tafseer',
                              style: AppTypography.arabicCaption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ).animate().fadeIn(delay: 200.ms),
                          ],
                        ),
                        IconButton(
                          onPressed: () => context.push('/settings'),
                          icon: const Icon(Icons.settings_outlined),
                          style: IconButton.styleFrom(
                            backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Search / Go to Verse Section
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: isDark ? AppColors.darkDivider : AppColors.divider,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search bar
                          InkWell(
                            onTap: () => context.push('/search'),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.md,
                              ),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search_rounded,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    context.read<AppStateProvider>().isArabic ? 'البحث في التفاسير...' : 'Search in Tafseer...',
                                    style: AppTypography.arabicCaption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: AppSpacing.lg),
                          
                          // Go to verse section
                          Text(
                            context.read<AppStateProvider>().isArabic ? 'اذهب إلى آية' : 'Go to Verse',
                            style: AppTypography.arabicCaption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkText : AppColors.text,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          
                          // Surah and Ayah dropdowns
                          Row(
                            children: [
                              // Surah dropdown
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      value: _selectedSurah,
                                      isExpanded: true,
                                      hint: Text(
                                        'السورة',
                                        style: AppTypography.arabicCaption,
                                      ),
                                      icon: const Icon(Icons.keyboard_arrow_down),
                                      items: _surahs.map((surah) {
                                        return DropdownMenuItem<int>(
                                          value: surah.id,
                                          child: Text(
                                            '${surah.id}. ${surah.nameArabic}',
                                            style: AppTypography.arabicCaption.copyWith(
                                              color: isDark ? AppColors.darkText : AppColors.text,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: _onSurahChanged,
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: AppSpacing.md),
                              
                              // Ayah dropdown
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      value: _selectedAyah,
                                      isExpanded: true,
                                      hint: Text(
                                        'الآية',
                                        style: AppTypography.arabicCaption,
                                      ),
                                      icon: const Icon(Icons.keyboard_arrow_down),
                                      items: List.generate(_ayahCount, (i) => i + 1).map((num) {
                                        return DropdownMenuItem<int>(
                                          value: num,
                                          child: Text(
                                            '$num',
                                            style: AppTypography.arabicCaption.copyWith(
                                              color: isDark ? AppColors.darkText : AppColors.text,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) => setState(() => _selectedAyah = val),
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: AppSpacing.md),
                              
                              // Go button
                              ElevatedButton(
                                onPressed: _goToVerse,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg,
                                    vertical: AppSpacing.md,
                                  ),
                                ),
                                child: const Icon(Icons.arrow_forward_rounded),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                    
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Continue reading card
                    if (bookmarks.lastProgress != null)
                      _ContinueReadingCard(progress: bookmarks.lastProgress!)
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideY(begin: 0.1),
                  ],
                ),
              ),
            ),
            
            // Quick actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.read<AppStateProvider>().isArabic ? 'الوصول السريع' : 'Quick Access',
                      style: AppTypography.arabicCaption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkText : AppColors.text,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.menu_book_rounded,
                            title: context.read<AppStateProvider>().isArabic ? 'تصفح السور' : 'Browse Surahs',
                            subtitle: context.read<AppStateProvider>().isArabic ? '114 سورة' : '114 Chapters',
                            color: AppColors.primary,
                            onTap: () => context.push('/surahs'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _QuickActionCard(
                            imagePath: 'assets/icons/quran_bookmark.png',
                            title: context.read<AppStateProvider>().isArabic ? 'المحفوظات' : 'Bookmarks',
                            subtitle: context.read<AppStateProvider>().isArabic 
                                ? '${bookmarks.bookmarks.length} محفوظ' 
                                : '${bookmarks.bookmarks.length} saved',
                            color: AppColors.secondary,
                            onTap: () => context.push('/bookmarks'),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
            
            // Featured Tafaseer
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  context.read<AppStateProvider>().isArabic ? 'التفاسير المتاحة' : 'Available Tafseer',
                  style: AppTypography.arabicCaption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.text,
                  ),
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            
            // Tafseer sources - Grid layout
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.5,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final source = context.read<TafseerProvider>().availableSources[index];
                    return _TafseerGridCard(source: source)
                      .animate()
                      .fadeIn(delay: (600 + index * 50).ms)
                      .scale(begin: const Offset(0.95, 0.95));
                  },
                  childCount: context.read<TafseerProvider>().availableSources.length,
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  final ReadingProgress progress;

  const _ContinueReadingCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final surahProvider = context.watch<SurahProvider>();
    final surah = surahProvider.getSurahById(progress.surahNumber);
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  'assets/icons/book_reading.png',
                  width: 24,
                  height: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                context.read<AppStateProvider>().isArabic ? 'متابعة القراءة' : 'Continue Reading',
                style: AppTypography.arabicCaption.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.read<AppStateProvider>().isArabic 
                ? (surah?.nameArabic ?? 'سورة ${progress.surahNumber}')
                : (surah?.nameEnglish ?? 'Surah ${progress.surahNumber}'),
            style: AppTypography.arabicTitle.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.read<AppStateProvider>().isArabic 
                ? 'الآية ${progress.ayahNumber}' 
                : 'Ayah ${progress.ayahNumber}',
            style: AppTypography.arabicCaption.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push(
                '/surah/${progress.surahNumber}/ayah/${progress.ayahNumber}',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
              ),
              child: Text(
                context.read<AppStateProvider>().isArabic ? 'استئناف' : 'Resume',
                style: AppTypography.arabicCaption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    this.icon,
    this.imagePath,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Material(
      color: isDark ? AppColors.darkSurface : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isDark ? AppColors.darkDivider : AppColors.divider,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: imagePath != null
                    ? Image.asset(imagePath!, width: 22, height: 22, color: color)
                    : Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: AppTypography.arabicCaption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.arabicCaption.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TafseerSourceCard extends StatelessWidget {
  final dynamic source;

  const _TafseerSourceCard({required this.source});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Material(
      color: isDark ? AppColors.darkSurface : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: () {
          context.read<AppStateProvider>().setSelectedTafseerSource(source.id);
          context.push('/surahs');
        },
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isDark ? AppColors.darkDivider : AppColors.divider,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                source.nameArabic,
                style: AppTypography.arabicCaption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.text,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                source.author ?? source.nameEnglish,
                style: AppTypography.arabicCaption.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid-style tafseer source card
class _TafseerGridCard extends StatelessWidget {
  final dynamic source;

  const _TafseerGridCard({required this.source});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isArabic = context.read<AppStateProvider>().isArabic;
    
    return Material(
      color: isDark ? AppColors.darkSurface : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: () {
          context.read<AppStateProvider>().setSelectedTafseerSource(source.id);
          context.push('/surahs');
        },
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isArabic ? source.nameArabic : source.nameEnglish,
                      style: AppTypography.arabicCaption.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark ? AppColors.darkText : AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (source.author != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        source.author!,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small chip-style tafseer source button
class _TafseerChip extends StatelessWidget {
  final dynamic source;

  const _TafseerChip({required this.source});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Material(
      color: isDark ? AppColors.darkSurface : AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          context.read<AppStateProvider>().setSelectedTafseerSource(source.id);
          context.push('/surahs');
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkDivider : AppColors.divider,
            ),
          ),
          child: Text(
            source.nameArabic,
            style: AppTypography.arabicCaption.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkText : AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}

/// Islamic geometric pattern painter for background
class _IslamicPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;

  _IslamicPatternPainter({
    required this.color,
    this.opacity = 0.05,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const patternSize = 50.0;
    
    for (double x = 0; x < size.width + patternSize; x += patternSize) {
      for (double y = 0; y < size.height + patternSize; y += patternSize) {
        _drawStarPattern(canvas, Offset(x, y), patternSize / 2, paint);
      }
    }
  }

  void _drawStarPattern(Canvas canvas, Offset center, double radius, Paint paint) {
    // 8-pointed star pattern (common in Islamic art)
    final path = Path();
    const points = 8;
    final innerRadius = radius * 0.4;
    
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : innerRadius;
      final angle = (i * math.pi / points) - math.pi / 2;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
    
    // Inner decorative circle
    canvas.drawCircle(center, innerRadius * 0.4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

