import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ContentWrap extends StatelessWidget {
  const ContentWrap({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontal = width < 640
        ? 20.0
        : width < 1100
        ? 38.0
        : 68.0;

    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontal),
          child: child,
        ),
      ),
    );
  }
}

class SectionContainer extends StatelessWidget {
  const SectionContainer({
    super.key,
    required this.child,
    required this.background,
    this.verticalPadding = 72,
    this.decorative = true,
  });

  final Widget child;
  final Color background;
  final double verticalPadding;
  final bool decorative;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      child: Stack(
        children: [
          if (decorative) ...[
            Positioned(
              top: -80,
              right: -70,
              child: _GlowBlob(
                size: 220,
                color: AppColors.gold.withValues(alpha: 0.08),
              ),
            ),
            Positioned(
              left: -80,
              bottom: -90,
              child: _GlowBlob(
                size: 210,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ],
          Padding(
            padding: EdgeInsets.symmetric(vertical: verticalPadding),
            child: ContentWrap(child: child),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.24)),
          ),
          child: Text(
            isRtl ? 'تشارتر' : 'CHARTER',
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w800,
              letterSpacing: isRtl ? 0.1 : 0.9,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Text(
            subtitle,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.muted,
              height: 1.7,
            ),
          ),
        ),
      ],
    );
  }
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 18,
    this.outlined = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: outlined ? Border.all(color: AppColors.border) : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.obsidian.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.04),
  });

  final Widget child;
  final Duration delay;
  final Offset offset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  Timer? _delayTimer;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  late final Animation<Offset> _position = Tween<Offset>(
    begin: widget.offset,
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
      return;
    }
    _delayTimer = Timer(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _position, child: widget.child),
    );
  }
}

class HoverCard extends StatefulWidget {
  const HoverCard({super.key, required this.child});

  final Widget child;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translateByDouble(0.0, _hovered ? -5.0 : 0.0, 0.0, 1.0)
          ..scaleByDouble(
            _hovered ? 1.01 : 1.0,
            _hovered ? 1.01 : 1.0,
            1.0,
            1.0,
          ),
        child: widget.child,
      ),
    );
  }
}

class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 62, this.elevated = false});

  final double size;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.18),
        border: Border.all(color: AppColors.border),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          Positioned(
            left: size * 0.13,
            top: size * 0.12,
            child: Container(
              width: size * 0.34,
              height: size * 0.72,
              decoration: BoxDecoration(
                color: AppColors.obsidian,
                borderRadius: BorderRadius.circular(size * 0.08),
              ),
            ),
          ),
          Positioned(
            right: size * 0.16,
            top: size * 0.13,
            child: Container(
              width: size * 0.31,
              height: size * 0.31,
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(size * 0.08),
              ),
              child: Center(
                child: Container(
                  width: size * 0.08,
                  height: size * 0.12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(size * 0.04),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: size * 0.19,
            bottom: size * 0.14,
            child: Container(
              width: size * 0.31,
              height: size * 0.31,
              decoration: BoxDecoration(
                color: AppColors.obsidian,
                borderRadius: BorderRadius.circular(size * 0.08),
              ),
              child: Center(
                child: Container(
                  width: size * 0.14,
                  height: size * 0.2,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(size * 0.07),
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

class DotBullet extends StatelessWidget {
  const DotBullet({super.key, required this.child, this.spacing = 10});

  final Widget child;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.only(top: 8),
          decoration: const BoxDecoration(
            color: AppColors.gold,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(child: child),
      ],
    );
  }
}
