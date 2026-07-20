import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/app_content.dart';
import '../domain/landing_models.dart';
import '../widgets/shared_widgets.dart';

class LocationsSection extends StatelessWidget {
  const LocationsSection({super.key, required this.content});

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
              title: content.locationsTitle.of(content.language),
              subtitle: content.locationsSubtitle.of(content.language),
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 980
                  ? 3
                  : (constraints.maxWidth >= 640 ? 2 : 1);
              final width = columns == 1
                  ? constraints.maxWidth
                  : (constraints.maxWidth - (16 * (columns - 1))) / columns;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: content.locations
                    .asMap()
                    .entries
                    .map(
                      (entry) => SizedBox(
                        width: width,
                        child: FadeSlideIn(
                          delay: Duration(milliseconds: 80 + (entry.key * 80)),
                          child: _LocationCard(
                            content: content,
                            location: entry.value,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.content, required this.location});

  final AppContent content;
  final LocationItem location;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      child: SurfaceCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(location.icon, color: AppColors.gold),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.title.of(content.language),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    location.address.of(content.language),
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
