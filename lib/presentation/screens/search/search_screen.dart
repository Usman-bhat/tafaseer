import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/providers.dart';
import '../../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchProvider>().loadRecentSearches();
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    context.read<SearchProvider>().search(query);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final searchProvider = context.watch<SearchProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'ابحث في التفاسير...',
                hintTextDirection: TextDirection.rtl,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close_rounded),
                      )
                    : null,
              ),
              onChanged: (value) => setState(() {}),
              onSubmitted: _performSearch,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: searchProvider.filterSourceId == null,
                    onTap: () => searchProvider.setFilterSource(null),
                  ),
                  ...TafseerSource.allSources.take(5).map((source) => _FilterChip(
                    label: source.nameArabic,
                    isSelected: searchProvider.filterSourceId == source.id,
                    onTap: () => searchProvider.setFilterSource(source.id),
                  )),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: searchProvider.isSearching
                ? const Center(child: CircularProgressIndicator())
                : searchProvider.results.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        itemCount: searchProvider.results.length,
                        itemBuilder: (context, index) {
                          final result = searchProvider.results[index];
                          return _SearchResultTile(entry: result)
                              .animate()
                              .fadeIn(delay: (index * 30).ms)
                              .slideX(begin: 0.05);
                        },
                      )
                    : searchProvider.query.isNotEmpty
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
                                  'No results found',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try different keywords',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          )
                        : _RecentSearches(
                            searches: searchProvider.recentSearches,
                            onSearchTap: (query) {
                              _searchController.text = query;
                              _performSearch(query);
                            },
                            onClear: () => searchProvider.clearHistory(),
                          ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontFamily: 'Amiri',
            color: isSelected ? Colors.white : AppColors.text,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary,
        showCheckmark: false,
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final TafseerEntry entry;

  const _SearchResultTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: () {
            if (entry.surahNumber > 0) {
              context.push('/surah/${entry.surahNumber}/ayah/${entry.ayahNumber}');
            }
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
              children: [
                // Source info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        entry.source?.nameArabic ?? 'Unknown',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (entry.surahNumber > 0)
                      Text(
                        'سورة ${entry.surahNumber} - آية ${entry.ayahNumber}',
                        style: AppTypography.arabicCaption.copyWith(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                // Content preview
                Text(
                  entry.text.length > 200 
                      ? '${entry.text.substring(0, 200)}...'
                      : entry.text,
                  style: AppTypography.arabicCaption.copyWith(
                    color: isDark ? AppColors.darkText : AppColors.text,
                    height: 1.8,
                  ),
                  textDirection: TextDirection.rtl,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  final List<String> searches;
  final Function(String) onSearchTap;
  final VoidCallback onClear;

  const _RecentSearches({
    required this.searches,
    required this.onSearchTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (searches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Search the Tafseer',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter keywords to search across all tafseer sources',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: onClear,
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: searches.map((query) => ActionChip(
              label: Text(
                query,
                style: const TextStyle(fontFamily: 'Amiri'),
              ),
              onPressed: () => onSearchTap(query),
              avatar: const Icon(Icons.history_rounded, size: 16),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
