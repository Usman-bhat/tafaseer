import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سياسة الخصوصية',
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
نحن نقدر خصوصيتك ونلتزم بحمايتها. توضح سياسة الخصوصية هذه كيفية تعاملنا مع المعلومات عند استخدامك لتطبيق التفاسير.
              ''',
              isDark: isDark,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            _SectionCard(
              title: 'البيانات التي نجمعها',
              content: '''
• لا نجمع أي بيانات شخصية.
• لا نتتبع موقعك الجغرافي.
• لا نصل إلى جهات الاتصال أو الصور أو أي ملفات على جهازك.
• جميع إعداداتك وبياناتك تُحفظ محلياً على جهازك فقط.
              ''',
              isDark: isDark,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            _SectionCard(
              title: 'التخزين المحلي',
              content: '''
يحفظ التطبيق البيانات التالية محلياً على جهازك:
• الآيات المحفوظة والمفضلة
• آخر موضع قراءة
• إعدادات التطبيق (المظهر، حجم الخط، إلخ)
• سجل البحث

هذه البيانات لا تُرسل إلى أي خادم خارجي.
              ''',
              isDark: isDark,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            _SectionCard(
              title: 'الأذونات',
              content: '''
التطبيق لا يطلب أي أذونات خاصة. يعمل بشكل كامل دون الحاجة للوصول إلى:
• الكاميرا
• الميكروفون
• جهات الاتصال
• الموقع الجغرافي
• التخزين الخارجي
              ''',
              isDark: isDark,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            _SectionCard(
              title: 'الإعلانات والتحليلات',
              content: '''
• التطبيق لا يحتوي على أي إعلانات.
• لا نستخدم أي أدوات تحليلية لتتبع استخدامك.
• لا نبيع أو نشارك أي بيانات مع أطراف ثالثة.
              ''',
              isDark: isDark,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            _SectionCard(
              title: 'حقوقك',
              content: '''
• يمكنك حذف جميع بياناتك بإلغاء تثبيت التطبيق.
• يمكنك مسح المحفوظات وسجل البحث من داخل التطبيق.
• لديك السيطرة الكاملة على بياناتك.
              ''',
              isDark: isDark,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            _SectionCard(
              title: 'التحديثات',
              content: '''
قد نقوم بتحديث سياسة الخصوصية هذه من وقت لآخر. سنقوم بإعلامك بأي تغييرات عن طريق نشر السياسة الجديدة في التطبيق.
              ''',
              isDark: isDark,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            _SectionCard(
              title: 'التواصل',
              content: '''
إذا كان لديك أي أسئلة حول سياسة الخصوصية هذه، يرجى التواصل معنا عبر:
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
