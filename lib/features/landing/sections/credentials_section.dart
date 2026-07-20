import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/app_content.dart';
import '../domain/landing_models.dart';
import '../widgets/shared_widgets.dart';

class CredentialsSection extends StatelessWidget {
  const CredentialsSection({super.key, required this.content});

  final AppContent content;

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      background: AppColors.pearl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeSlideIn(
            child: SectionHeader(
              title: content.credentialsTitle.of(content.language),
              subtitle: content.credentialsSubtitle.of(content.language),
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900 ? 2 : 1;
              final width = columns == 1
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 16) / 2;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: content.portfolioGroups
                    .asMap()
                    .entries
                    .map(
                      (entry) => SizedBox(
                        width: width,
                        child: FadeSlideIn(
                          delay: Duration(milliseconds: 80 + (entry.key * 90)),
                          child: HoverCard(
                            child: _PortfolioGroupCard(
                              content: content,
                              group: entry.value,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 18),
          FadeSlideIn(
            delay: const Duration(milliseconds: 420),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.obsidian,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    color: AppColors.goldSoft,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      content.isArabic
                          ? 'تتوفر وثائق التسجيل والترخيص المهنية للشركة للتحقق ضمن إجراءات التأهيل والتعاقد الرسمية.'
                          : 'Company registration and professional licensing documents are available for verification during formal prequalification and contracting.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        height: 1.65,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioGroupCard extends StatelessWidget {
  const _PortfolioGroupCard({required this.content, required this.group});

  final AppContent content;
  final PortfolioGroup group;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(group.icon, color: AppColors.gold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  group.title.of(content.language),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...group.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: DotBullet(
                child: Text(
                  item.of(content.language),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                    height: 1.55,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
