import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../data/app_content.dart';
import '../domain/landing_models.dart';
import '../widgets/shared_widgets.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key, required this.content});

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
              title: content.projectsTitle.of(content.language),
              subtitle: content.projectsSubtitle.of(content.language),
            ),
          ),
          const SizedBox(height: 24),
          _ShowcaseGrid(content: content),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final capabilitiesCard = FadeSlideIn(
                delay: const Duration(milliseconds: 90),
                child: _InfoCard(
                  title: content.capabilitiesTitle.of(content.language),
                  body: content.capabilitiesBody.of(content.language),
                  icon: Icons.precision_manufacturing_rounded,
                ),
              );
              final sectorsCard = FadeSlideIn(
                delay: const Duration(milliseconds: 180),
                child: _SectorsCard(content: content),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: capabilitiesCard),
                    const SizedBox(width: 16),
                    Expanded(child: sectorsCard),
                  ],
                );
              }

              return Column(
                children: [
                  capabilitiesCard,
                  const SizedBox(height: 14),
                  sectorsCard,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ShowcaseGrid extends StatelessWidget {
  const _ShowcaseGrid({required this.content});

  final AppContent content;

  Future<void> _downloadProfile() async {
    final uri = Uri.base.resolve(
      'assets/assets/documents/charter-company-profile.pdf',
    );
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          content.showcaseTitle.of(content.language),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          content.showcaseSubtitle.of(content.language),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.muted, height: 1.6),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1000
                ? 3
                : constraints.maxWidth >= 620
                ? 2
                : 1;
            final spacing = 14.0;
            final width =
                (constraints.maxWidth - (spacing * (columns - 1))) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: content.deliveryShowcases
                  .map(
                    (item) => SizedBox(
                      width: width,
                      child: _ShowcaseCard(item: item, content: content),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: _downloadProfile,
          icon: const Icon(Icons.picture_as_pdf_rounded),
          label: Text(content.downloadProfileLabel.of(content.language)),
        ),
      ],
    );
  }
}

class _ShowcaseCard extends StatelessWidget {
  const _ShowcaseCard({required this.item, required this.content});

  final DeliveryShowcase item;
  final AppContent content;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      child: SurfaceCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconBadge(icon: item.icon),
            const SizedBox(height: 14),
            Text(
              item.title.of(content.language),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              item.summary.of(content.language),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.muted,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: item.tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        tag.of(content.language),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.obsidian,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconBadge(icon: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectorsCard extends StatelessWidget {
  const _SectorsCard({required this.content});

  final AppContent content;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      child: SurfaceCard(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _IconBadge(icon: Icons.groups_rounded),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    content.sectorsTitle.of(content.language),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...content.sectorsPoints.map(
              (point) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: DotBullet(
                  child: Text(
                    point.of(content.language),
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
