import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/app_content.dart';
import '../domain/landing_models.dart';
import '../widgets/shared_widgets.dart';

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key, required this.content});

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
              title: content.servicesTitle.of(content.language),
              subtitle: content.servicesSubtitle.of(content.language),
            ),
          ),
          const SizedBox(height: 30),
          ...content.businessDivisions.asMap().entries.map(
            (entry) => Padding(
              padding: EdgeInsets.only(
                bottom: entry.key == content.businessDivisions.length - 1
                    ? 0
                    : 28,
              ),
              child: FadeSlideIn(
                delay: Duration(milliseconds: 80 + (entry.key * 120)),
                child: _DivisionBlock(
                  content: content,
                  division: entry.value,
                  number: entry.key + 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DivisionBlock extends StatelessWidget {
  const _DivisionBlock({
    required this.content,
    required this.division,
    required this.number,
  });

  final AppContent content;
  final BusinessDivision division;
  final int number;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D111318),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [
                  AppColors.obsidian,
                  AppColors.graphite,
                  AppColors.gold.withValues(alpha: 0.88),
                ],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(division.icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        division.title.of(content.language),
                        style: textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        division.description.of(content.language),
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          height: 1.65,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  number.toString().padLeft(2, '0'),
                  style: textTheme.headlineMedium?.copyWith(
                    color: Colors.white24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final isMedium = constraints.maxWidth >= 620;
              final columns = isWide ? 2 : (isMedium ? 2 : 1);

              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: division.services
                    .asMap()
                    .entries
                    .map(
                      (entry) => SizedBox(
                        width: _cardWidth(constraints.maxWidth, columns, 14),
                        child: FadeSlideIn(
                          delay: Duration(milliseconds: 60 + (entry.key * 60)),
                          child: HoverCard(
                            child: _ServiceCard(
                              content: content,
                              service: entry.value,
                            ),
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

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.content, required this.service});

  final AppContent content;
  final ServiceItem service;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final points = service.description
        .of(content.language)
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(service.icon, color: AppColors.gold),
          ),
          const SizedBox(height: 16),
          Text(
            service.title.of(content.language),
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DotBullet(
                child: Text(
                  point,
                  style: textTheme.bodyMedium?.copyWith(
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

double _cardWidth(double maxWidth, int columns, double spacing) {
  if (columns <= 1) {
    return maxWidth;
  }

  final totalSpacing = spacing * (columns - 1);
  return (maxWidth - totalSpacing) / columns;
}
