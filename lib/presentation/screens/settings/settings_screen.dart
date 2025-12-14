import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/providers.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appState = context.watch<AppStateProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الإعدادات',
          style: AppTypography.arabicCaption.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Appearance section
          _SectionHeader(title: 'المظهر', isDark: isDark),
          _SettingsCard(
            isDark: isDark,
            children: [
              _ThemeSelector(
                currentMode: appState.themeMode,
                onChanged: appState.setThemeMode,
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Reading section
          _SectionHeader(title: 'القراءة', isDark: isDark),
          _SettingsCard(
            isDark: isDark,
            children: [
              _FontSizeSlider(
                value: appState.arabicFontSize,
                onChanged: appState.setArabicFontSize,
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Default Tafseer section
          _SectionHeader(title: 'التفسير الافتراضي', isDark: isDark),
          _SettingsCard(
            isDark: isDark,
            children: [
              _TafseerSelector(
                selectedId: appState.selectedTafseerSourceId,
                onChanged: appState.setSelectedTafseerSource,
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Language section
          _SectionHeader(title: appState.isArabic ? 'اللغة' : 'Language', isDark: isDark),
          _SettingsCard(
            isDark: isDark,
            children: [
              _LanguageSelector(
                isArabic: appState.isArabic,
                onChanged: appState.setLanguage,
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // About section
          _SectionHeader(title: appState.isArabic ? 'حول التطبيق' : 'About', isDark: isDark),
          _SettingsCard(
            isDark: isDark,
            children: [
              _SettingsTile(
                icon: Icons.person_outline_rounded,
                title: appState.isArabic ? 'عن المطور' : 'Developer',
                onTap: () => context.push('/developer'),
                isDark: isDark,
              ),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: appState.isArabic ? 'الشروط والأحكام' : 'Terms & Conditions',
                onTap: () => context.push('/terms'),
                isDark: isDark,
              ),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: appState.isArabic ? 'سياسة الخصوصية' : 'Privacy Policy',
                onTap: () => context.push('/privacy'),
                isDark: isDark,
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Icons.info_outline_rounded,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
                title: Text(
                  appState.isArabic ? 'الإصدار' : 'Version',
                  style: AppTypography.arabicCaption.copyWith(
                    color: isDark ? AppColors.darkText : AppColors.text,
                  ),
                  textDirection: appState.isArabic ? TextDirection.rtl : TextDirection.ltr,
                ),
                trailing: Text(
                  '1.0.0',
                  style: AppTypography.arabicCaption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Icons.library_books_rounded,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
                title: Text(
                  appState.isArabic ? 'التفاسير المتاحة' : 'Available Tafseer',
                  style: AppTypography.arabicCaption.copyWith(
                    color: isDark ? AppColors.darkText : AppColors.text,
                  ),
                  textDirection: appState.isArabic ? TextDirection.rtl : TextDirection.ltr,
                ),
                trailing: Text(
                  appState.isArabic ? '10 تفاسير' : '10 sources',
                  style: AppTypography.arabicCaption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDark;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: AppTypography.arabicCaption.copyWith(
          color: isDark ? AppColors.darkText : AppColors.text,
        ),
        textDirection: TextDirection.rtl,
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.sm,
        right: AppSpacing.sm,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: AppTypography.arabicCaption.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;

  const _SettingsCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.divider,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final Function(ThemeMode) onChanged;

  const _ThemeSelector({
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المظهر',
            style: AppTypography.arabicCaption.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _ThemeOption(
                icon: Icons.brightness_auto_rounded,
                label: 'تلقائي',
                isSelected: currentMode == ThemeMode.system,
                onTap: () => onChanged(ThemeMode.system),
              ),
              const SizedBox(width: AppSpacing.sm),
              _ThemeOption(
                icon: Icons.light_mode_rounded,
                label: 'فاتح',
                isSelected: currentMode == ThemeMode.light,
                onTap: () => onChanged(ThemeMode.light),
              ),
              const SizedBox(width: AppSpacing.sm),
              _ThemeOption(
                icon: Icons.dark_mode_rounded,
                label: 'داكن',
                isSelected: currentMode == ThemeMode.dark,
                onTap: () => onChanged(ThemeMode.dark),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Expanded(
      child: Material(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.primary : null,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: AppTypography.arabicCaption.copyWith(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? AppColors.primary : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FontSizeSlider extends StatelessWidget {
  final double value;
  final Function(double) onChanged;

  const _FontSizeSlider({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'حجم الخط العربي',
                style: AppTypography.arabicCaption.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textDirection: TextDirection.rtl,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${value.round()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Text('أ', style: TextStyle(fontFamily: 'Amiri', fontSize: 14)),
              Expanded(
                child: Slider(
                  value: value,
                  min: 14,
                  max: 32,
                  divisions: 18,
                  activeColor: AppColors.primary,
                  onChanged: onChanged,
                ),
              ),
              const Text('أ', style: TextStyle(fontFamily: 'Amiri', fontSize: 28)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
              style: AppTypography.quranVerse.copyWith(
                fontSize: value,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}

class _TafseerSelector extends StatelessWidget {
  final int selectedId;
  final Function(int) onChanged;

  const _TafseerSelector({
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sources = context.read<TafseerProvider>().availableSources;
    final selected = sources.firstWhere(
      (s) => s.id == selectedId,
      orElse: () => sources.first,
    );
    
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            '${selected.id}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      title: Text(
        selected.nameArabic,
        style: AppTypography.arabicCaption.copyWith(
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkText : AppColors.text,
        ),
        textDirection: TextDirection.rtl,
      ),
      subtitle: Text(
        selected.author ?? selected.nameEnglish,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => _showSourcePicker(context, sources),
    );
  }

  void _showSourcePicker(BuildContext context, List<dynamic> sources) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkDivider : AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'اختر التفسير الافتراضي',
                style: AppTypography.arabicTitle.copyWith(
                  color: isDark ? AppColors.darkText : AppColors.text,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: sources.length,
                itemBuilder: (context, index) {
                  final source = sources[index];
                  final isSelected = source.id == selectedId;
                  
                  return ListTile(
                    onTap: () {
                      onChanged(source.id);
                      Navigator.pop(context);
                    },
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.1),
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
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
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
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final bool isArabic;
  final Function(String) onChanged;

  const _LanguageSelector({
    required this.isArabic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'لغة التطبيق' : 'App Language',
            style: AppTypography.arabicCaption.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Material(
                  color: isArabic
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: InkWell(
                    onTap: () => onChanged('ar'),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isArabic ? AppColors.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '🇸🇦',
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'العربية',
                            style: AppTypography.arabicCaption.copyWith(
                              fontSize: 12,
                              fontWeight: isArabic ? FontWeight.w600 : FontWeight.normal,
                              color: isArabic ? AppColors.primary : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Material(
                  color: !isArabic
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: InkWell(
                    onTap: () => onChanged('en'),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: !isArabic ? AppColors.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '🇺🇸',
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'English',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: !isArabic ? FontWeight.w600 : FontWeight.normal,
                              color: !isArabic ? AppColors.primary : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

