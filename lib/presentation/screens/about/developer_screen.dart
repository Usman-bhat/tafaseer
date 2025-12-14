import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'عن المطور',
          style: AppTypography.arabicCaption.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Developer avatar
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Developer name
            Text(
              'محمد عثمان',
              style: AppTypography.arabicTitle.copyWith(
                color: isDark ? AppColors.darkText : AppColors.text,
              ),
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            Text(
              'Mohammad Usman',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Social links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialButton(
                  icon: Icons.language_rounded,
                  label: 'Portfolio',
                  color: AppColors.primary,
                  onTap: () => _launchUrl('https://portfolio-mohammad.web.app/'),
                ),
                const SizedBox(width: AppSpacing.md),
                _SocialButton(
                  icon: Icons.code_rounded,
                  label: 'GitHub',
                  color: isDark ? Colors.white : Colors.black87,
                  onTap: () => _launchUrl('https://github.com/Usman-bhat'),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.xxl),
            
            // About section
            _InfoCard(
              icon: Icons.info_outline_rounded,
              title: 'عن التطبيق',
              content: 'تطبيق التفاسير هو تطبيق إسلامي يهدف إلى تقديم تفاسير القرآن الكريم من مصادر موثوقة ومتعددة، بتصميم عصري وسهل الاستخدام.',
              isDark: isDark,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            _InfoCard(
              icon: Icons.auto_stories_rounded,
              title: 'المصادر',
              content: 'يحتوي التطبيق على 10 تفاسير مختلفة تشمل:\n• تفسير الطبري\n• تفسير ابن كثير\n• تفسير السعدي\n• تفسير القرطبي\n• تفسير البغوي\n• تفسير ابن عاشور\n• الكشاف للزمخشري\n• مفاتيح الغيب للرازي\n• إعراب القرآن\n• الوسيط لطنطاوي',
              isDark: isDark,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            _InfoCard(
              icon: Icons.phone_android_rounded,
              title: 'التقنيات',
              content: 'تم بناء التطبيق باستخدام:\n• Flutter - لدعم منصات متعددة\n• SQLite - لتخزين البيانات محلياً\n• Material Design 3 - لواجهة عصرية',
              isDark: isDark,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            _InfoCard(
              icon: Icons.email_outlined,
              title: 'التواصل',
              content: 'للتواصل والاقتراحات:\nbhattusman39@gmail.com',
              isDark: isDark,
            ),
            
            const SizedBox(height: AppSpacing.xxl),
            
            // Version and credits
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'التفاسير',
                    style: AppTypography.arabicTitle.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'الإصدار 1.0.0',
                    style: AppTypography.arabicCaption.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isDark ? AppColors.darkDivider : AppColors.divider,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkText : AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final bool isDark;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTypography.arabicCaption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            content,
            style: AppTypography.arabicCaption.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              height: 1.8,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}
