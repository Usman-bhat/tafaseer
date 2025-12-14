import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الشروط والأحكام',
          style: AppTypography.arabicCaption.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionCard(
              title: 'مقدمة',
              content: '''
باستخدامك لتطبيق التفاسير، فإنك توافق على الالتزام بهذه الشروط والأحكام. يرجى قراءتها بعناية قبل استخدام التطبيق.
              ''',
              isDark: isDark,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            _SectionCard(
              title: 'استخدام التطبيق',
              content: '''
• التطبيق مخصص للاستخدام الشخصي والتعليمي فقط.
• يجب استخدام التطبيق بطريقة تحترم القرآن الكريم وتفاسيره.
• لا يجوز استخدام التطبيق لأي أغراض تجارية دون إذن مسبق.
• يجب عدم محاولة اختراق أو تعديل التطبيق بأي شكل من الأشكال.
              ''',
              isDark: isDark,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            _SectionCard(
              title: 'المحتوى',
              content: '''
• جميع التفاسير مأخوذة من مصادر إسلامية موثوقة.
• نحن نبذل قصارى جهدنا لضمان دقة المحتوى، لكننا لا نتحمل مسؤولية أي أخطاء قد تكون موجودة.
• للتحقق من أي معلومة، يرجى الرجوع إلى المصادر الأصلية أو استشارة أهل العلم.
              ''',
              isDark: isDark,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            _SectionCard(
              title: 'الخصوصية',
              content: '''
• نحن نحترم خصوصيتك ولا نجمع أي بيانات شخصية.
• جميع البيانات (المحفوظات، الإعدادات) تُحفظ محلياً على جهازك فقط.
• لا نشارك أي معلومات مع أطراف ثالثة.
              ''',
              isDark: isDark,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            _SectionCard(
              title: 'حقوق الملكية الفكرية',
              content: '''
• التفاسير المضمنة في التطبيق هي ملك لمؤلفيها الأصليين.
• تصميم التطبيق وكوده البرمجي محميان بموجب حقوق الملكية الفكرية.
              ''',
              isDark: isDark,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            _SectionCard(
              title: 'إخلاء المسؤولية',
              content: '''
• التطبيق مقدم "كما هو" دون أي ضمانات من أي نوع.
• لا نتحمل مسؤولية أي أضرار قد تنتج عن استخدام التطبيق.
• نحتفظ بالحق في تعديل هذه الشروط في أي وقت.
              ''',
              isDark: isDark,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            _SectionCard(
              title: 'التواصل',
              content: '''
للاستفسارات أو الشكاوى المتعلقة بهذه الشروط، يرجى التواصل معنا عبر:
bhattusman39@gmail.com
              ''',
              isDark: isDark,
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            Center(
              child: Text(
                'آخر تحديث: ديسمبر 2024',
                style: AppTypography.arabicCaption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String content;
  final bool isDark;

  const _SectionCard({
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
          Text(
            title,
            style: AppTypography.arabicCaption.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            content.trim(),
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
