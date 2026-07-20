import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/app_content.dart';
import '../widgets/shared_widgets.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key, required this.content});

  final AppContent content;

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      background: AppColors.ivory,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeSlideIn(
            child: SectionHeader(
              title: content.profileTitle.of(content.language),
              subtitle: content.profileDescription.of(content.language),
            ),
          ),
          const SizedBox(height: 14),
          FadeSlideIn(
            delay: const Duration(milliseconds: 40),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.gold,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    content.establishedSince.of(content.language),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 930;
              final cards = [
                FadeSlideIn(
                  delay: const Duration(milliseconds: 80),
                  child: _InfoCard(
                    title: content.visionTitle.of(content.language),
                    body: content.visionBody.of(content.language),
                    icon: Icons.visibility_rounded,
                  ),
                ),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 160),
                  child: _InfoCard(
                    title: content.missionTitle.of(content.language),
                    body: content.missionBody.of(content.language),
                    icon: Icons.flag_rounded,
                  ),
                ),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 240),
                  child: _ValuesCard(content: content),
                ),
              ];

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: 18),
                    Expanded(child: cards[1]),
                    const SizedBox(width: 18),
                    Expanded(child: cards[2]),
                  ],
                );
              }

              return Column(
                children: [
                  cards[0],
                  const SizedBox(height: 14),
                  cards[1],
                  const SizedBox(height: 14),
                  cards[2],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      child: SurfaceCard(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconBadge(icon: icon),
            const SizedBox(height: 15),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.muted,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValuesCard extends StatelessWidget {
  const _ValuesCard({required this.content});

  final AppContent content;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      child: SurfaceCard(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _IconBadge(icon: Icons.workspace_premium_rounded),
            const SizedBox(height: 15),
            Text(
              content.valuesTitle.of(content.language),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ...content.values.map(
              (value) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DotBullet(
                  child: Text(
                    value.of(content.language),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.gold),
    );
  }
}
