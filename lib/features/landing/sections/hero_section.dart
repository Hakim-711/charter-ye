import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/app_content.dart';
import '../widgets/shared_widgets.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.content,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  final AppContent content;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 940;

    return Container(
      color: AppColors.obsidian,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.obsidian, AppColors.graphite],
                ),
              ),
            ),
          ),
          Positioned(
            top: -160,
            right: -120,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            left: -120,
            bottom: -140,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          ContentWrap(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 62),
              child: FadeSlideIn(
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: _HeroTextBlock(
                              content: content,
                              onPrimaryTap: onPrimaryTap,
                              onSecondaryTap: onSecondaryTap,
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            flex: 4,
                            child: _HeroHighlightsCard(content: content),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeroTextBlock(
                            content: content,
                            onPrimaryTap: onPrimaryTap,
                            onSecondaryTap: onSecondaryTap,
                          ),
                          const SizedBox(height: 24),
                          _HeroHighlightsCard(content: content),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroTextBlock extends StatelessWidget {
  const _HeroTextBlock({
    required this.content,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  final AppContent content;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LogoMark(size: 138, elevated: true),
        const SizedBox(height: 26),
        Text(
          content.heroTitle.of(content.language),
          style: textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          content.heroDescription.of(content.language),
          style: textTheme.bodyLarge?.copyWith(
            color: Colors.white70,
            height: 1.72,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content.heroTagline.of(content.language),
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.goldSoft,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: onPrimaryTap,
              child: Text(content.ctaPrimary.of(content.language)),
            ),
            OutlinedButton(
              onPressed: onSecondaryTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
              ),
              child: Text(content.ctaSecondary.of(content.language)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _HeroPill(
              label: content.isArabic
                  ? 'المقاولات العامة'
                  : 'General Contracting',
            ),
            _HeroPill(
              label: content.isArabic
                  ? 'الخدمات والتوريدات'
                  : 'Services & Supplies',
            ),
            _HeroPill(label: content.isArabic ? 'مأرب وعدن' : 'Marib & Aden'),
            _HeroPill(
              label: content.isArabic
                  ? 'تغطية كافة المحافظات'
                  : 'Nationwide Coverage',
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroHighlightsCard extends StatelessWidget {
  const _HeroHighlightsCard({required this.content});

  final AppContent content;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SurfaceCard(
      padding: const EdgeInsets.all(22),
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content.companyName,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            content.companySubtitle,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          ...content.heroHighlights.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FadeSlideIn(
                delay: Duration(milliseconds: 80 + (index * 100)),
                offset: const Offset(0, 0.06),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: AppColors.gold, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title.of(content.language),
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.description.of(content.language),
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.muted,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
        color: Colors.white.withValues(alpha: 0.05),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.white70),
      ),
    );
  }
}
