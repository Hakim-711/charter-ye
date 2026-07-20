import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../data/app_content.dart';
import '../widgets/shared_widgets.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key, required this.content});

  final AppContent content;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: AppColors.obsidian,
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: ContentWrap(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 860;
            final brand = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LogoMark(size: 52),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.companyName,
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        content.footerTagline.of(content.language),
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white60,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            final meta = Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _FooterBadge(
                  label: content.isArabic
                      ? 'مقاولات وبنية تحتية'
                      : 'Contracting & Infrastructure',
                ),
                TextButton(
                  onPressed: () => launchUrl(
                    Uri.base.resolve('privacy.html'),
                    mode: LaunchMode.platformDefault,
                  ),
                  child: Text(
                    content.isArabic ? 'سياسة الخصوصية' : 'Privacy Policy',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                TextButton(
                  onPressed: () => launchUrl(
                    Uri.base.resolve('terms.html'),
                    mode: LaunchMode.platformDefault,
                  ),
                  child: Text(
                    content.isArabic ? 'شروط الاستخدام' : 'Terms of Use',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                _FooterBadge(
                  label: content.isArabic
                      ? 'خدمات وتوريدات'
                      : 'Services & Supplies',
                ),
              ],
            );

            if (isWide) {
              return Row(
                children: [
                  Expanded(flex: 2, child: brand),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Align(alignment: Alignment.centerRight, child: meta),
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [brand, const SizedBox(height: 14), meta],
            );
          },
        ),
      ),
    );
  }
}

class _FooterBadge extends StatelessWidget {
  const _FooterBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white70,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
