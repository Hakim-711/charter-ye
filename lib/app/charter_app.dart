import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/config/app_runtime_config.dart';
import '../core/theme/app_theme.dart';
import '../features/admin/domain/admin_auth_controller.dart';
import '../features/admin/presentation/admin_panel_page.dart';
import '../features/landing/data/app_content.dart';
import '../features/landing/domain/landing_models.dart';
import '../features/landing/sections/contact_section.dart';
import '../features/landing/sections/credentials_section.dart';
import '../features/landing/sections/footer_section.dart';
import '../features/landing/sections/hero_section.dart';
import '../features/landing/sections/locations_section.dart';
import '../features/landing/sections/profile_section.dart';
import '../features/landing/sections/projects_section.dart';
import '../features/landing/sections/services_section.dart';
import '../features/landing/widgets/top_nav.dart';
import 'app_state_controller.dart';

class CharterApp extends StatefulWidget {
  const CharterApp({super.key, this.appStateController});

  final AppStateController? appStateController;

  @override
  State<CharterApp> createState() => _CharterAppState();
}

class _CharterAppState extends State<CharterApp> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ValueNotifier<double> _scrollProgress = ValueNotifier<double>(0);
  final AdminAuthController _adminAuth = AdminAuthController();

  late final AppStateController _appState;
  late final bool _ownsAppState;

  late final Map<LandingSection, GlobalKey> _sectionKeys = {
    LandingSection.home: GlobalKey(),
    LandingSection.profile: GlobalKey(),
    LandingSection.services: GlobalKey(),
    LandingSection.projects: GlobalKey(),
    LandingSection.credentials: GlobalKey(),
    LandingSection.locations: GlobalKey(),
    LandingSection.contact: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _ownsAppState = widget.appStateController == null;
    _appState = widget.appStateController ?? AppStateController();
    _scrollController.addListener(_updateScrollProgress);
    _appState.bootstrap();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.dispose();
    _scrollProgress.dispose();
    if (_ownsAppState) {
      _appState.dispose();
    }
    super.dispose();
  }

  void _updateScrollProgress() {
    if (!_scrollController.hasClients) {
      return;
    }

    final max = _scrollController.position.maxScrollExtent;
    final progress = max <= 0
        ? 0.0
        : (_scrollController.offset / max).clamp(0.0, 1.0);
    if (progress != _scrollProgress.value) {
      _scrollProgress.value = progress;
    }
  }

  void _scrollTo(LandingSection section) {
    final key = _sectionKeys[section];
    final context = key?.currentContext;
    if (context == null) {
      return;
    }

    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
      alignment: 0.08,
    );
  }

  Future<void> _scrollToTop() async {
    if (!_scrollController.hasClients) {
      return;
    }
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  bool _canAccessAdminRoute() {
    if (AppRuntimeConfig.hasRemoteSync) {
      // With backend auth enabled, access is enforced by server-side login.
      return true;
    }

    if (!kReleaseMode) {
      return true;
    }

    final expectedKey = AppRuntimeConfig.adminAccessKey;
    if (expectedKey.isEmpty) {
      return false;
    }

    final providedKey = _readAdminAccessFromUrl();
    return providedKey == expectedKey;
  }

  String? _readAdminAccessFromUrl() {
    final queryValue =
        Uri.base.queryParameters['admin_access'] ??
        Uri.base.queryParameters['admin'];
    if (queryValue != null && queryValue.trim().isNotEmpty) {
      return queryValue.trim();
    }

    final fragment = Uri.base.fragment;
    final separator = fragment.indexOf('?');
    if (separator < 0 || separator == fragment.length - 1) {
      return null;
    }

    final queryPart = fragment.substring(separator + 1);
    try {
      final params = Uri.splitQueryString(queryPart);
      final hashValue = params['admin_access'] ?? params['admin'];
      return hashValue?.trim().isEmpty ?? true ? null : hashValue?.trim();
    } catch (_) {
      return null;
    }
  }

  bool _isAdminIntentFromUrl() {
    final rootParams = Uri.base.queryParameters;
    if (_hasAdminIntentInMap(rootParams)) {
      return true;
    }

    if (Uri.base.path == '/admin') {
      return true;
    }

    final fragment = Uri.base.fragment.trim();
    if (fragment.isEmpty) {
      return false;
    }

    final routePart = fragment.split('?').first;
    final normalized = routePart.startsWith('/') ? routePart : '/$routePart';
    if (normalized == '/admin') {
      return true;
    }

    final separator = fragment.indexOf('?');
    if (separator >= 0 && separator < fragment.length - 1) {
      final queryPart = fragment.substring(separator + 1);
      try {
        final params = Uri.splitQueryString(queryPart);
        return _hasAdminIntentInMap(params);
      } catch (_) {
        return false;
      }
    }

    return false;
  }

  bool _hasAdminIntentInMap(Map<String, String> params) {
    final hasKey =
        params.containsKey('admin_access') || params.containsKey('admin');
    if (hasKey) {
      return true;
    }

    final panel = params['panel']?.trim().toLowerCase();
    if (panel == 'admin') {
      return true;
    }

    final mode = params['mode']?.trim().toLowerCase();
    return mode == 'admin';
  }

  Widget _buildAdminPanelOrDenied() {
    if (!_canAccessAdminRoute()) {
      return _AdminAccessDeniedPage(language: _appState.language);
    }
    return AdminPanelPage(
      initialSettings: _appState.adminSettings,
      leads: _appState.leads,
      language: _appState.language,
      onLanguageChanged: _appState.setLanguage,
      authController: _adminAuth,
      onSaveSettings: _appState.saveAdminSettings,
      onResetSettings: _appState.resetAdminSettings,
      onLoginSuccess: _appState.refreshAdminData,
      onUpdateLeadStatus: _appState.updateLeadStatus,
      onDeleteLead: _appState.deleteLead,
      onClearLeads: _appState.clearLeads,
    );
  }

  Route<dynamic>? _buildRoute(RouteSettings settings) {
    if (settings.name == '/admin') {
      if (!_canAccessAdminRoute()) {
        return MaterialPageRoute<void>(
          builder: (_) => _AdminAccessDeniedPage(language: _appState.language),
          settings: settings,
        );
      }

      return MaterialPageRoute<void>(
        builder: (_) => AdminPanelPage(
          initialSettings: _appState.adminSettings,
          leads: _appState.leads,
          language: _appState.language,
          onLanguageChanged: _appState.setLanguage,
          authController: _adminAuth,
          onSaveSettings: _appState.saveAdminSettings,
          onResetSettings: _appState.resetAdminSettings,
          onLoginSuccess: _appState.refreshAdminData,
          onUpdateLeadStatus: _appState.updateLeadStatus,
          onDeleteLead: _appState.deleteLead,
          onClearLeads: _appState.clearLeads,
        ),
        settings: settings,
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, _) {
        final content = AppContent.of(
          _appState.language,
          overrides: _appState.adminSettings,
        );
        if (_appState.isLoading) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: content.companyName,
            theme: buildAppTheme(isArabic: _appState.language == Language.ar),
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: content.companyName,
          theme: buildAppTheme(isArabic: _appState.language == Language.ar),
          onGenerateRoute: _buildRoute,
          home: _isAdminIntentFromUrl()
              ? _buildAdminPanelOrDenied()
              : Directionality(
                  textDirection: _appState.language == Language.ar
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: Scaffold(
                    key: _scaffoldKey,
                    drawer: LandingDrawer(
                      content: content,
                      language: _appState.language,
                      onLanguageChanged: _appState.setLanguage,
                      onNavigate: _scrollTo,
                    ),
                    floatingActionButton: ValueListenableBuilder<double>(
                      valueListenable: _scrollProgress,
                      builder: (context, progress, _) => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: progress > 0.2
                            ? FloatingActionButton.extended(
                                key: const ValueKey('to_top'),
                                heroTag: 'fab_top',
                                onPressed: _scrollToTop,
                                icon: const Icon(
                                  Icons.keyboard_double_arrow_up_rounded,
                                ),
                                label: Text(
                                  content.isArabic ? 'للأعلى' : 'Top',
                                ),
                              )
                            : FloatingActionButton.extended(
                                key: const ValueKey('to_contact'),
                                heroTag: 'fab_contact',
                                onPressed: () =>
                                    _scrollTo(LandingSection.contact),
                                icon: const Icon(Icons.support_agent_rounded),
                                label: Text(
                                  content.isArabic ? 'تواصل' : 'Contact',
                                ),
                              ),
                      ),
                    ),
                    body: SafeArea(
                      child: Column(
                        children: [
                          TopNav(
                            content: content,
                            language: _appState.language,
                            onLanguageChanged: _appState.setLanguage,
                            onMenuTap: () =>
                                _scaffoldKey.currentState?.openDrawer(),
                            onNavigate: _scrollTo,
                          ),
                          ValueListenableBuilder<double>(
                            valueListenable: _scrollProgress,
                            builder: (context, progress, _) => SizedBox(
                              height: 3,
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.transparent,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: Column(
                                children: [
                                  HeroSection(
                                    key: _sectionKeys[LandingSection.home],
                                    content: content,
                                    onPrimaryTap: () =>
                                        _scrollTo(LandingSection.services),
                                    onSecondaryTap: () =>
                                        _scrollTo(LandingSection.contact),
                                  ),
                                  ProfileSection(
                                    key: _sectionKeys[LandingSection.profile],
                                    content: content,
                                  ),
                                  ServicesSection(
                                    key: _sectionKeys[LandingSection.services],
                                    content: content,
                                  ),
                                  ProjectsSection(
                                    key: _sectionKeys[LandingSection.projects],
                                    content: content,
                                  ),
                                  CredentialsSection(
                                    key:
                                        _sectionKeys[LandingSection
                                            .credentials],
                                    content: content,
                                  ),
                                  LocationsSection(
                                    key: _sectionKeys[LandingSection.locations],
                                    content: content,
                                  ),
                                  ContactSection(
                                    key: _sectionKeys[LandingSection.contact],
                                    content: content,
                                    onSubmitLead: _appState.submitLead,
                                  ),
                                  FooterSection(content: content),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _AdminAccessDeniedPage extends StatelessWidget {
  const _AdminAccessDeniedPage({required this.language});

  final Language language;

  @override
  Widget build(BuildContext context) {
    final isArabic = language == Language.ar;
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isArabic ? 'وصول مقيّد' : 'Restricted Access'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              isArabic
                  ? 'هذه الصفحة داخلية. تم تعطيل الوصول العام للوحة الإدارة.'
                  : 'This page is internal. Public access to admin panel is disabled.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
