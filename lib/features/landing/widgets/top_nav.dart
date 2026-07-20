import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/app_content.dart';
import '../domain/landing_models.dart';
import 'shared_widgets.dart';

class TopNav extends StatelessWidget {
  const TopNav({
    super.key,
    required this.content,
    required this.language,
    required this.onLanguageChanged,
    required this.onMenuTap,
    required this.onNavigate,
  });

  final AppContent content;
  final Language language;
  final ValueChanged<Language> onLanguageChanged;
  final VoidCallback onMenuTap;
  final ValueChanged<LandingSection> onNavigate;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1240;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: AppColors.obsidian,
      padding: EdgeInsets.fromLTRB(isWide ? 24 : 14, 12, isWide ? 24 : 14, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 18 : 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.09),
                  Colors.white.withValues(alpha: 0.03),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                const LogoMark(size: 44),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.companyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        content.companySubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isWide)
                  ...content.navItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _NavPill(
                        label: item.label,
                        onTap: () => onNavigate(item.section),
                      ),
                    ),
                  ),
                if (isWide)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8),
                    child: LanguageToggle(
                      language: language,
                      onChanged: onLanguageChanged,
                      dark: true,
                    ),
                  )
                else
                  IconButton(
                    onPressed: onMenuTap,
                    icon: const Icon(Icons.menu_rounded, color: Colors.white),
                  ),
                if (isWide)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8),
                    child: ElevatedButton.icon(
                      onPressed: () => onNavigate(LandingSection.contact),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.call_made_rounded, size: 18),
                      label: Text(
                        content.isArabic ? 'تواصل سريع' : 'Quick Contact',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavPill extends StatelessWidget {
  const _NavPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          color: Colors.white.withValues(alpha: 0.06),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class LandingDrawer extends StatelessWidget {
  const LandingDrawer({
    super.key,
    required this.content,
    required this.language,
    required this.onLanguageChanged,
    required this.onNavigate,
  });

  final AppContent content;
  final Language language;
  final ValueChanged<Language> onLanguageChanged;
  final ValueChanged<LandingSection> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const LogoMark(size: 54),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.companyName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        content.companySubtitle,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final item in content.navItems)
            ListTile(
              title: Text(item.label),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                Navigator.of(context).pop();
                onNavigate(item.section);
              },
            ),
          const Divider(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: LanguageToggle(
              language: language,
              dark: false,
              onChanged: (lang) {
                onLanguageChanged(lang);
                Navigator.of(context).pop();
              },
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onNavigate(LandingSection.contact);
              },
              icon: const Icon(Icons.call_made_rounded, size: 18),
              label: Text(content.isArabic ? 'تواصل معنا' : 'Contact Us'),
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({
    super.key,
    required this.language,
    required this.onChanged,
    this.dark = true,
  });

  final Language language;
  final ValueChanged<Language> onChanged;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? Colors.white70 : AppColors.obsidian;
    final selected = dark ? Colors.white : AppColors.obsidian;
    final border = dark ? Colors.white30 : AppColors.border;
    final selectedBorder = dark ? Colors.white : AppColors.obsidian;
    final fill = dark ? Colors.white12 : AppColors.gold.withValues(alpha: 0.12);

    return ToggleButtons(
      isSelected: [language == Language.ar, language == Language.en],
      borderRadius: BorderRadius.circular(20),
      constraints: const BoxConstraints(minHeight: 36, minWidth: 66),
      color: foreground,
      selectedColor: selected,
      borderColor: border,
      selectedBorderColor: selectedBorder,
      fillColor: fill,
      onPressed: (index) => onChanged(index == 0 ? Language.ar : Language.en),
      children: const [Text('عربي'), Text('EN')],
    );
  }
}
