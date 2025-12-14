import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/providers.dart';
import '../../theme/app_theme.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SurahProvider>();
      if (provider.surahs.isEmpty) {
        provider.loadSurahs();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Surah> _filterSurahs(List<Surah> surahs) {
    if (_searchQuery.isEmpty) return surahs;
    
    final query = _searchQuery.toLowerCase();
    return surahs.where((s) {
      return s.nameArabic.contains(_searchQuery) ||
          s.englishName.toLowerCase().contains(query) ||
          s.id.toString() == query;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surahProvider = context.watch<SurahProvider>();
    final filteredSurahs = _filterSurahs(surahProvider.surahs);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'السور',
          style: AppTypography.arabicTitle.copyWith(
            color: isDark ? AppColors.darkText : AppColors.text,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'ابحث عن سورة...',
                hintTextDirection: TextDirection.rtl,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.close_rounded),
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ).animate().fadeIn(duration: 300.ms),
          
          // Surah list
          Expanded(
            child: surahProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : surahProvider.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                            const SizedBox(height: 16),
                            Text(surahProvider.error!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => surahProvider.loadSurahs(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredSurahs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 64,
                                  color: theme.colorScheme.outline,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No results for "$_searchQuery"',
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            itemCount: filteredSurahs.length,
                            itemBuilder: (context, index) {
                              final surah = filteredSurahs[index];
                              return _SurahTile(surah: surah)
                                  .animate()
                                  .fadeIn(delay: (index * 30).ms)
                                  .slideX(begin: 0.05);
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _SurahTile extends StatelessWidget {
  final Surah surah;

  const _SurahTile({required this.surah});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMakki = surah.revelationType.contains('مكي');
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: () => context.push('/surah/${surah.id}'),
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
                      _toArabicNumber(surah.id),
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: AppSpacing.md),
                
                // Surah info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              surah.nameArabic,
                              style: AppTypography.arabicBody.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkText : AppColors.text,
                                fontSize: 18,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            surah.englishName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: (isMakki ? AppColors.makki : AppColors.madani)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isMakki ? 'Makki' : 'Madani',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isMakki ? AppColors.makki : AppColors.madani,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Ayah count
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${surah.ayahCount}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Ayaat',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
                
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _toArabicNumber(int number) {
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((d) => arabicNumerals[int.parse(d)]).join();
  }
}
