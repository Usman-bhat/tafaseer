import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/providers.dart';
import '../../theme/app_theme.dart';

class TafseerViewScreen extends StatefulWidget {
  final int surahId;
  final int? initialAyah;

  const TafseerViewScreen({
    super.key,
    required this.surahId,
    this.initialAyah,
  });

  @override
  State<TafseerViewScreen> createState() => _TafseerViewScreenState();
}

class _TafseerViewScreenState extends State<TafseerViewScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentAyahIndex = 0;
  bool _showTafseer = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    final tafseerProvider = context.read<TafseerProvider>();
    await tafseerProvider.loadAyahsForSurah(widget.surahId);
    
    if (widget.initialAyah != null && tafseerProvider.ayahs.isNotEmpty) {
      final index = tafseerProvider.ayahs.indexWhere(
        (a) => a.ayahNumber == widget.initialAyah,
      );
      if (index >= 0) {
        setState(() => _currentAyahIndex = index);
      }
    }
    
    if (tafseerProvider.ayahs.isNotEmpty) {
      final ayah = tafseerProvider.ayahs[_currentAyahIndex];
      tafseerProvider.loadTafseerForAyah(ayah.ayahNumber);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _goToNextAyah() {
    final tafseerProvider = context.read<TafseerProvider>();
    if (_currentAyahIndex < tafseerProvider.ayahs.length - 1) {
      setState(() => _currentAyahIndex++);
      final ayah = tafseerProvider.ayahs[_currentAyahIndex];
      tafseerProvider.loadTafseerForAyah(ayah.ayahNumber);
      _saveProgress();
    }
  }

  void _goToPreviousAyah() {
    final tafseerProvider = context.read<TafseerProvider>();
    if (_currentAyahIndex > 0) {
      setState(() => _currentAyahIndex--);
      final ayah = tafseerProvider.ayahs[_currentAyahIndex];
      tafseerProvider.loadTafseerForAyah(ayah.ayahNumber);
      _saveProgress();
    }
  }

  void _saveProgress() {
    final tafseerProvider = context.read<TafseerProvider>();
    if (tafseerProvider.ayahs.isEmpty) return;
    
    final ayah = tafseerProvider.ayahs[_currentAyahIndex];
    context.read<BookmarksProvider>().saveProgress(
      surahNumber: widget.surahId,
      ayahNumber: ayah.ayahNumber,
      tafseerSourceId: tafseerProvider.selectedSourceId,
    );
  }

  void _showTafseerSourcePicker() {
    final tafseerProvider = context.read<TafseerProvider>();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _TafseerSourceBottomSheet(
        sources: tafseerProvider.availableSources,
        selectedId: tafseerProvider.selectedSourceId,
        onSourceSelected: (sourceId) {
          tafseerProvider.setSelectedSource(sourceId);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _bookmarkCurrentAyah() async {
    final tafseerProvider = context.read<TafseerProvider>();
    if (tafseerProvider.ayahs.isEmpty) return;
    
    final ayah = tafseerProvider.ayahs[_currentAyahIndex];
    await context.read<BookmarksProvider>().addBookmark(
      surahNumber: widget.surahId,
      ayahNumber: ayah.ayahNumber,
      tafseerSourceId: tafseerProvider.selectedSourceId,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bookmark added'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _shareContent() {
    final tafseerProvider = context.read<TafseerProvider>();
    if (tafseerProvider.ayahs.isEmpty) return;
    
    final ayah = tafseerProvider.ayahs[_currentAyahIndex];
    final tafseer = tafseerProvider.currentTafseer;
    
    final text = '''
${ayah.text}

[سورة ${widget.surahId} - آية ${ayah.ayahNumber}]

${tafseer?.text ?? ''}
    ''';
    
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied for sharing'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _copyContent() {
    final tafseerProvider = context.read<TafseerProvider>();
    if (tafseerProvider.ayahs.isEmpty) return;
    
    final ayah = tafseerProvider.ayahs[_currentAyahIndex];
    final tafseer = tafseerProvider.currentTafseer;
    
    final text = '${ayah.text}\n\n${tafseer?.text ?? ''}';
    Clipboard.setData(ClipboardData(text: text));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tafseerProvider = context.watch<TafseerProvider>();
    final surahProvider = context.watch<SurahProvider>();
    final appState = context.watch<AppStateProvider>();
    final surah = surahProvider.getSurahById(widget.surahId);
    
    final currentAyah = tafseerProvider.ayahs.isNotEmpty
        ? tafseerProvider.ayahs[_currentAyahIndex]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              surah?.nameArabic ?? 'سورة ${widget.surahId}',
              style: AppTypography.arabicCaption.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkText : AppColors.text,
              ),
            ),
            if (currentAyah != null)
              Text(
                'Ayah ${currentAyah.ayahNumber} of ${surah?.ayahCount ?? tafseerProvider.ayahs.length}',
                style: theme.textTheme.labelSmall,
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _bookmarkCurrentAyah,
            icon: const Icon(Icons.bookmark_border_rounded),
            tooltip: 'Bookmark',
          ),
          IconButton(
            onPressed: _showTafseerSourcePicker,
            icon: const Icon(Icons.library_books_rounded),
            tooltip: 'Change Tafseer',
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert_rounded),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Copy'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Share'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'copy') _copyContent();
              if (value == 'share') _shareContent();
            },
          ),
        ],
      ),
      body: tafseerProvider.isLoading && tafseerProvider.ayahs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Tafseer source indicator
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        TafseerSource.getById(tafseerProvider.selectedSourceId)?.nameArabic ?? 'Unknown',
                        style: AppTypography.arabicCaption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! > 0) {
                        _goToPreviousAyah();
                      } else if (details.primaryVelocity! < 0) {
                        _goToNextAyah();
                      }
                    },
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Quran verse
                          if (currentAyah != null)
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [AppColors.darkSurface, AppColors.darkSurfaceVariant]
                                      : [AppColors.surface, AppColors.surfaceVariant.withOpacity(0.5)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                border: Border.all(
                                  color: AppColors.secondary.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Ayah number badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.goldGradient,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      currentAyah.arabicAyahNumber,
                                      style: const TextStyle(
                                        fontFamily: 'Amiri',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  // Verse text
                                  Text(
                                    currentAyah.text,
                                    style: AppTypography.quranVerse.copyWith(
                                      fontSize: appState.arabicFontSize + 6,
                                      color: isDark ? AppColors.darkText : AppColors.text,
                                    ),
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.rtl,
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 300.ms),
                          
                          const SizedBox(height: AppSpacing.lg),
                          
                          // Toggle tafseer
                          Row(
                            children: [
                              Text(
                                'التفسير',
                                style: AppTypography.arabicCaption.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.darkText : AppColors.text,
                                ),
                              ),
                              const Spacer(),
                              Switch(
                                value: _showTafseer,
                                onChanged: (value) => setState(() => _showTafseer = value),
                                activeColor: AppColors.primary,
                              ),
                            ],
                          ),
                          
                          // Tafseer content
                          if (_showTafseer) ...[
                            const Divider(),
                            const SizedBox(height: AppSpacing.md),
                            if (tafseerProvider.isLoading)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else if (tafseerProvider.currentTafseer != null)
                              Text(
                                tafseerProvider.currentTafseer!.text,
                                style: AppTypography.tafseerText.copyWith(
                                  fontSize: appState.arabicFontSize,
                                  color: isDark ? AppColors.darkText : AppColors.text,
                                  height: 2.2,
                                ),
                                textDirection: TextDirection.rtl,
                              ).animate().fadeIn(duration: 300.ms)
                            else
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        size: 48,
                                        color: theme.colorScheme.outline,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No tafseer available for this ayah in the selected source',
                                        style: theme.textTheme.bodyMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                          
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      
      // Navigation bar
      bottomNavigationBar: tafseerProvider.ayahs.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Previous button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _currentAyahIndex > 0 ? _goToPreviousAyah : null,
                        icon: const Icon(Icons.chevron_left_rounded),
                        label: const Text('Previous'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                          foregroundColor: isDark ? AppColors.darkText : AppColors.text,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: AppSpacing.md),
                    
                    // Ayah selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentAyahIndex + 1} / ${tafseerProvider.ayahs.length}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: AppSpacing.md),
                    
                    // Next button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _currentAyahIndex < tafseerProvider.ayahs.length - 1
                            ? _goToNextAyah
                            : null,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Next'),
                            SizedBox(width: 4),
                            Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class _TafseerSourceBottomSheet extends StatelessWidget {
  final List<TafseerSource> sources;
  final int selectedId;
  final Function(int) onSourceSelected;

  const _TafseerSourceBottomSheet({
    required this.sources,
    required this.selectedId,
    required this.onSourceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkDivider : AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Select Tafseer',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Sources list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              itemCount: sources.length,
              itemBuilder: (context, index) {
                final source = sources[index];
                final isSelected = source.id == selectedId;
                
                return ListTile(
                  onTap: () => onSourceSelected(source.id),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${source.id}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    source.nameArabic,
                    style: AppTypography.arabicCaption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.text,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  subtitle: Text(
                    source.author ?? source.nameEnglish,
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
