import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../landing/domain/landing_models.dart';
import '../../leads/domain/contact_lead.dart';
import '../domain/admin_auth_controller.dart';
import '../domain/admin_auth_models.dart';
import '../domain/site_admin_settings.dart';

typedef SaveSiteAdminSettings =
    Future<void> Function(SiteAdminSettings settings);
typedef ResetSiteAdminSettings = Future<void> Function();
typedef UpdateLeadStatusCallback =
    Future<void> Function(String leadId, LeadStatus status);
typedef DeleteLeadCallback = Future<void> Function(String leadId);
typedef ClearLeadsCallback = Future<void> Function();

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({
    super.key,
    required this.initialSettings,
    required this.leads,
    required this.language,
    required this.onLanguageChanged,
    required this.authController,
    this.onLoginSuccess,
    required this.onSaveSettings,
    required this.onResetSettings,
    required this.onUpdateLeadStatus,
    required this.onDeleteLead,
    required this.onClearLeads,
  });

  final SiteAdminSettings? initialSettings;
  final List<ContactLead> leads;
  final Language language;
  final ValueChanged<Language> onLanguageChanged;
  final AdminAuthController authController;
  final Future<void> Function()? onLoginSuccess;
  final SaveSiteAdminSettings onSaveSettings;
  final ResetSiteAdminSettings onResetSettings;
  final UpdateLeadStatusCallback onUpdateLeadStatus;
  final DeleteLeadCallback onDeleteLead;
  final ClearLeadsCallback onClearLeads;

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final _usernameController = TextEditingController(text: 'admin');
  final _loginController = TextEditingController();

  final _companyNameArController = TextEditingController();
  final _companyNameEnController = TextEditingController();
  final _companySubtitleArController = TextEditingController();
  final _companySubtitleEnController = TextEditingController();
  final _heroTitleArController = TextEditingController();
  final _heroTitleEnController = TextEditingController();
  final _heroDescriptionArController = TextEditingController();
  final _heroDescriptionEnController = TextEditingController();
  final _officePhoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();
  final _secondaryEmailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _maribAddressArController = TextEditingController();
  final _maribAddressEnController = TextEditingController();
  final _adenAddressArController = TextEditingController();
  final _adenAddressEnController = TextEditingController();
  final _coverageArController = TextEditingController();
  final _coverageEnController = TextEditingController();
  final _currentPasscodeController = TextEditingController();
  final _newPasscodeController = TextEditingController();
  final _confirmPasscodeController = TextEditingController();

  final _settingsFormKey = GlobalKey<FormState>();

  bool _isAuthenticated = false;
  bool _isSaving = false;
  bool _isAuthenticating = false;
  bool _isCheckingSession = true;
  late SiteAdminSettings _activeSettings;
  late List<ContactLead> _leads;

  @override
  void initState() {
    super.initState();
    _activeSettings = widget.initialSettings ?? const SiteAdminSettings();
    _leads = [...widget.leads]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _applySettingsToForm(_activeSettings);
    _restoreSession();
  }

  @override
  void didUpdateWidget(covariant AdminPanelPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.initialSettings, widget.initialSettings)) {
      _activeSettings = widget.initialSettings ?? const SiteAdminSettings();
      _applySettingsToForm(_activeSettings);
    }
    if (!identical(oldWidget.leads, widget.leads)) {
      _leads = [...widget.leads]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _loginController.dispose();
    _companyNameArController.dispose();
    _companyNameEnController.dispose();
    _companySubtitleArController.dispose();
    _companySubtitleEnController.dispose();
    _heroTitleArController.dispose();
    _heroTitleEnController.dispose();
    _heroDescriptionArController.dispose();
    _heroDescriptionEnController.dispose();
    _officePhoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _secondaryEmailController.dispose();
    _websiteController.dispose();
    _maribAddressArController.dispose();
    _maribAddressEnController.dispose();
    _adenAddressArController.dispose();
    _adenAddressEnController.dispose();
    _coverageArController.dispose();
    _coverageEnController.dispose();
    _currentPasscodeController.dispose();
    _newPasscodeController.dispose();
    _confirmPasscodeController.dispose();
    super.dispose();
  }

  bool get _isArabic => widget.language == Language.ar;

  void _applySettingsToForm(SiteAdminSettings settings) {
    _companyNameArController.text = settings.companyNameAr ?? '';
    _companyNameEnController.text = settings.companyNameEn ?? '';
    _companySubtitleArController.text = settings.companySubtitleAr ?? '';
    _companySubtitleEnController.text = settings.companySubtitleEn ?? '';
    _heroTitleArController.text = settings.heroTitleAr ?? '';
    _heroTitleEnController.text = settings.heroTitleEn ?? '';
    _heroDescriptionArController.text = settings.heroDescriptionAr ?? '';
    _heroDescriptionEnController.text = settings.heroDescriptionEn ?? '';
    _officePhoneController.text = settings.officePhoneRaw ?? '';
    _whatsappController.text = settings.whatsappRaw ?? '';
    _emailController.text = settings.email ?? '';
    _secondaryEmailController.text = settings.secondaryEmail ?? '';
    _websiteController.text = settings.websiteUrl ?? '';
    _maribAddressArController.text = settings.maribAddressAr ?? '';
    _maribAddressEnController.text = settings.maribAddressEn ?? '';
    _adenAddressArController.text = settings.adenAddressAr ?? '';
    _adenAddressEnController.text = settings.adenAddressEn ?? '';
    _coverageArController.text = settings.coverageAr ?? '';
    _coverageEnController.text = settings.coverageEn ?? '';
  }

  String? _clean(TextEditingController controller) {
    final value = controller.text.trim();
    if (value.isEmpty) {
      return null;
    }
    return value;
  }

  Future<void> _restoreSession() async {
    final hasSession = await widget.authController.hasSession();
    if (!mounted) {
      return;
    }
    if (!hasSession) {
      setState(() => _isCheckingSession = false);
      return;
    }

    if (widget.onLoginSuccess != null) {
      try {
        await widget.onLoginSuccess!();
      } catch (_) {
        if (!mounted) {
          return;
        }
        setState(() => _isCheckingSession = false);
        _showSnack(
          _isArabic
              ? 'تعذر استعادة جلسة الإدارة. يرجى تسجيل الدخول مجددًا.'
              : 'Failed to restore admin session. Please sign in again.',
        );
        return;
      }
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _isAuthenticated = true;
      _isCheckingSession = false;
    });
  }

  String? _normalizeWebsite(String? input) {
    if (input == null || input.isEmpty) {
      return null;
    }
    if (input.startsWith('http://') || input.startsWith('https://')) {
      return input;
    }
    return 'https://$input';
  }

  SiteAdminSettings _buildDraftSettings() {
    return SiteAdminSettings(
      companyNameAr: _clean(_companyNameArController),
      companyNameEn: _clean(_companyNameEnController),
      companySubtitleAr: _clean(_companySubtitleArController),
      companySubtitleEn: _clean(_companySubtitleEnController),
      heroTitleAr: _clean(_heroTitleArController),
      heroTitleEn: _clean(_heroTitleEnController),
      heroDescriptionAr: _clean(_heroDescriptionArController),
      heroDescriptionEn: _clean(_heroDescriptionEnController),
      officePhoneRaw: _clean(_officePhoneController),
      whatsappRaw: _clean(_whatsappController),
      email: _clean(_emailController),
      secondaryEmail: _clean(_secondaryEmailController),
      websiteUrl: _normalizeWebsite(_clean(_websiteController)),
      maribAddressAr: _clean(_maribAddressArController),
      maribAddressEn: _clean(_maribAddressEnController),
      adenAddressAr: _clean(_adenAddressArController),
      adenAddressEn: _clean(_adenAddressEnController),
      coverageAr: _clean(_coverageArController),
      coverageEn: _clean(_coverageEnController),
    );
  }

  Future<void> _attemptLogin() async {
    final username = _usernameController.text.trim();
    final input = _loginController.text.trim();
    if (username.isEmpty || input.isEmpty || _isAuthenticating) {
      return;
    }

    setState(() => _isAuthenticating = true);
    final result = await widget.authController.signIn(
      username: username,
      passcode: input,
    );
    if (!mounted) {
      return;
    }

    if (result.status == AdminSignInStatus.success &&
        widget.onLoginSuccess != null) {
      try {
        await widget.onLoginSuccess!();
      } catch (_) {
        if (!mounted) {
          return;
        }
        setState(() => _isAuthenticating = false);
        _showSnack(
          _isArabic
              ? 'تم تسجيل الدخول ولكن تعذر تحميل بيانات الإدارة.'
              : 'Signed in, but failed to load admin data.',
        );
        return;
      }
      if (!mounted) {
        return;
      }
    }

    setState(() => _isAuthenticating = false);
    switch (result.status) {
      case AdminSignInStatus.success:
        setState(() => _isAuthenticated = true);
        return;
      case AdminSignInStatus.invalidPasscode:
        _showSnack(
          _isArabic
              ? 'رمز المرور غير صحيح. حاول مرة أخرى.'
              : 'Wrong passcode. Please try again.',
        );
        return;
      case AdminSignInStatus.lockedOut:
        final retry = result.retryAfter ?? const Duration(minutes: 10);
        _showSnack(
          _isArabic
              ? 'تم قفل الدخول مؤقتًا. حاول بعد ${_formatDuration(retry)}.'
              : 'Sign-in is temporarily locked. Retry in ${_formatDuration(retry)}.',
        );
        return;
      case AdminSignInStatus.notConfigured:
        _showSnack(
          _isArabic
              ? 'لوحة الإدارة غير مهيأة بعد. اضبط ADMIN_BOOTSTRAP_PASSCODE في إعدادات النشر.'
              : 'Admin panel is not configured. Set ADMIN_BOOTSTRAP_PASSCODE at deployment.',
        );
        return;
    }
  }

  Future<void> _saveChanges() async {
    final isValid = _settingsFormKey.currentState?.validate() ?? false;
    if (!isValid || _isSaving) {
      return;
    }

    final shouldChangePasscode =
        _currentPasscodeController.text.trim().isNotEmpty ||
        _newPasscodeController.text.trim().isNotEmpty ||
        _confirmPasscodeController.text.trim().isNotEmpty;

    if (shouldChangePasscode) {
      final current = _currentPasscodeController.text.trim();
      final next = _newPasscodeController.text.trim();
      final confirm = _confirmPasscodeController.text.trim();

      if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
        _showSnack(
          _isArabic
              ? 'للتعديل الأمني، املأ الحقول الثلاثة: الحالي والجديد والتأكيد.'
              : 'To update passcode, fill current/new/confirm fields.',
        );
        return;
      }
      if (next != confirm) {
        _showSnack(
          _isArabic
              ? 'تأكيد رمز المرور الجديد غير متطابق.'
              : 'Passcode confirmation does not match.',
        );
        return;
      }
    }

    final settings = _buildDraftSettings();
    setState(() => _isSaving = true);

    if (shouldChangePasscode) {
      final changeResult = await widget.authController.updatePasscode(
        currentPasscode: _currentPasscodeController.text.trim(),
        newPasscode: _newPasscodeController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      if (changeResult.status != AdminPasscodeUpdateStatus.success) {
        setState(() => _isSaving = false);
        switch (changeResult.status) {
          case AdminPasscodeUpdateStatus.invalidCurrentPasscode:
            _showSnack(
              _isArabic
                  ? 'رمز المرور الحالي غير صحيح.'
                  : 'Current passcode is incorrect.',
            );
            return;
          case AdminPasscodeUpdateStatus.weakPasscode:
            _showSnack(
              _isArabic
                  ? 'الرمز الجديد ضعيف. استخدم 10 أحرف على الأقل مع حروف كبيرة وصغيرة ورقم ورمز.'
                  : 'Weak passcode. Use at least 10 chars with upper/lower, number, and symbol.',
            );
            return;
          case AdminPasscodeUpdateStatus.notConfigured:
            _showSnack(
              _isArabic
                  ? 'المصادقة غير مهيأة. تحقق من إعدادات ADMIN_BOOTSTRAP_PASSCODE.'
                  : 'Auth is not configured. Check ADMIN_BOOTSTRAP_PASSCODE.',
            );
            return;
          case AdminPasscodeUpdateStatus.success:
            break;
        }
      }
    }

    try {
      await widget.onSaveSettings(settings);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
      _showSnack(
        _isArabic
            ? 'تعذر حفظ الإعدادات على الخادم. تحقق من الاتصال ثم أعد المحاولة.'
            : 'Failed to save settings to server. Check connection and try again.',
      );
      return;
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _activeSettings = settings;
      _isSaving = false;
      _currentPasscodeController.clear();
      _newPasscodeController.clear();
      _confirmPasscodeController.clear();
    });

    _showSnack(
      _isArabic
          ? 'تم حفظ الإعدادات الداخلية بنجاح.'
          : 'Internal settings saved successfully.',
    );
  }

  Future<void> _resetAll() async {
    setState(() => _isSaving = true);
    try {
      await widget.onResetSettings();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
      _showSnack(
        _isArabic
            ? 'تعذر إعادة الضبط على الخادم.'
            : 'Failed to reset settings on server.',
      );
      return;
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _activeSettings = const SiteAdminSettings();
      _applySettingsToForm(_activeSettings);
      _currentPasscodeController.clear();
      _newPasscodeController.clear();
      _confirmPasscodeController.clear();
      _isSaving = false;
    });

    _showSnack(
      _isArabic
          ? 'تمت إعادة الضبط إلى القيم الافتراضية.'
          : 'All overrides were reset to defaults.',
    );
  }

  Future<void> _copyJson() async {
    final draft = _buildDraftSettings();
    final formatted = const JsonEncoder.withIndent(
      '  ',
    ).convert(draft.toJson());
    await Clipboard.setData(ClipboardData(text: formatted));
    if (!mounted) {
      return;
    }
    _showSnack(_isArabic ? 'تم نسخ JSON.' : 'JSON copied to clipboard.');
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String _statusLabel(LeadStatus status, {required bool isArabic}) {
    switch (status) {
      case LeadStatus.newLead:
        return isArabic ? 'جديد' : 'New';
      case LeadStatus.contacted:
        return isArabic ? 'تم التواصل' : 'Contacted';
      case LeadStatus.closed:
        return isArabic ? 'مغلق' : 'Closed';
    }
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds <= 0 ? 1 : duration.inSeconds;
    final minutes = (totalSeconds / 60).ceil();
    if (_isArabic) {
      return '$minutes دقيقة';
    }
    return '$minutes minute(s)';
  }

  Future<void> _updateLeadStatus(String leadId, LeadStatus status) async {
    try {
      await widget.onUpdateLeadStatus(leadId, status);
    } catch (_) {
      if (mounted) {
        _showSnack(
          _isArabic
              ? 'تعذر تحديث حالة الطلب.'
              : 'Failed to update lead status.',
        );
      }
      return;
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _leads =
          _leads
              .map(
                (lead) =>
                    lead.id == leadId ? lead.copyWith(status: status) : lead,
              )
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  Future<void> _deleteLead(String leadId) async {
    try {
      await widget.onDeleteLead(leadId);
    } catch (_) {
      if (mounted) {
        _showSnack(_isArabic ? 'تعذر حذف الطلب.' : 'Failed to delete lead.');
      }
      return;
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _leads = _leads.where((lead) => lead.id != leadId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  Future<void> _clearLeads() async {
    try {
      await widget.onClearLeads();
    } catch (_) {
      if (mounted) {
        _showSnack(
          _isArabic ? 'تعذر مسح صندوق الوارد.' : 'Failed to clear inbox.',
        );
      }
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() => _leads = []);
  }

  Future<void> _signOut() async {
    await widget.authController.signOut();
    if (!mounted) {
      return;
    }
    setState(() => _isAuthenticated = false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isArabic ? 'لوحة التحكم الداخلية' : 'Internal Admin Panel',
          ),
          actions: [
            if (_isAuthenticated)
              IconButton(
                tooltip: _isArabic ? 'تسجيل خروج' : 'Sign Out',
                onPressed: _signOut,
                icon: const Icon(Icons.logout_rounded),
              ),
            IconButton(
              tooltip: _isArabic ? 'تبديل اللغة' : 'Toggle Language',
              onPressed: () {
                widget.onLanguageChanged(
                  widget.language == Language.ar ? Language.en : Language.ar,
                );
              },
              icon: const Icon(Icons.language_rounded),
            ),
          ],
        ),
        body: _isCheckingSession
            ? const Center(child: CircularProgressIndicator())
            : (_isAuthenticated ? _buildForm(context) : _buildLogin(context)),
      ),
    );
  }

  Widget _buildLogin(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Card(
          margin: const EdgeInsets.all(22),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isArabic ? 'تسجيل دخول المشرف' : 'Admin Sign-In',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(
                  _isArabic
                      ? 'هذه الواجهة داخلية لإدارة المحتوى. أدخل رمز المرور للمتابعة.'
                      : 'This panel is internal. Enter admin passcode to continue.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: _isArabic ? 'اسم المستخدم' : 'Username',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                  onFieldSubmitted: (_) => _attemptLogin(),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _loginController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: _isArabic ? 'كلمة المرور' : 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                  ),
                  onFieldSubmitted: (_) => _attemptLogin(),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isAuthenticating ? null : _attemptLogin,
                    icon: _isAuthenticating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.login_rounded),
                    label: Text(_isArabic ? 'دخول' : 'Sign In'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Form(
            key: _settingsFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.shield_rounded),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _isArabic
                                ? 'البيانات تُحفظ محليًا بشكل آمن، وتُزامن تلقائيًا إذا تم ربط API مركزي.'
                                : 'Data is stored securely locally, and auto-syncs when central API is configured.',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(height: 1.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _AdminSectionCard(
                  title: _isArabic
                      ? 'الهوية والواجهة الرئيسية'
                      : 'Brand and Hero',
                  child: Column(
                    children: [
                      _row2(
                        _TextFieldTile(
                          label: _isArabic
                              ? 'اسم الشركة (عربي)'
                              : 'Company Name (Arabic)',
                          controller: _companyNameArController,
                        ),
                        _TextFieldTile(
                          label: _isArabic
                              ? 'اسم الشركة (EN)'
                              : 'Company Name (EN)',
                          controller: _companyNameEnController,
                        ),
                      ),
                      _row2(
                        _TextFieldTile(
                          label: _isArabic
                              ? 'الوصف المختصر (عربي)'
                              : 'Subtitle (Arabic)',
                          controller: _companySubtitleArController,
                        ),
                        _TextFieldTile(
                          label: _isArabic
                              ? 'الوصف المختصر (EN)'
                              : 'Subtitle (EN)',
                          controller: _companySubtitleEnController,
                        ),
                      ),
                      _row2(
                        _TextFieldTile(
                          label: _isArabic
                              ? 'عنوان الهيرو (عربي)'
                              : 'Hero Title (Arabic)',
                          controller: _heroTitleArController,
                        ),
                        _TextFieldTile(
                          label: _isArabic
                              ? 'عنوان الهيرو (EN)'
                              : 'Hero Title (EN)',
                          controller: _heroTitleEnController,
                        ),
                      ),
                      _row2(
                        _TextFieldTile(
                          label: _isArabic
                              ? 'وصف الهيرو (عربي)'
                              : 'Hero Description (Arabic)',
                          controller: _heroDescriptionArController,
                          maxLines: 3,
                        ),
                        _TextFieldTile(
                          label: _isArabic
                              ? 'وصف الهيرو (EN)'
                              : 'Hero Description (EN)',
                          controller: _heroDescriptionEnController,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _AdminSectionCard(
                  title: _isArabic
                      ? 'التواصل والمواقع'
                      : 'Contact and Locations',
                  child: Column(
                    children: [
                      _row2(
                        _TextFieldTile(
                          label: _isArabic ? 'هاتف المكتب' : 'Office Phone',
                          controller: _officePhoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        _TextFieldTile(
                          label: _isArabic ? 'رقم واتساب' : 'WhatsApp Number',
                          controller: _whatsappController,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      _row2(
                        _TextFieldTile(
                          label: _isArabic ? 'البريد الإلكتروني' : 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) {
                              return null;
                            }
                            if (!v.contains('@')) {
                              return _isArabic
                                  ? 'صيغة بريد غير صحيحة'
                                  : 'Invalid email format';
                            }
                            return null;
                          },
                        ),
                        _TextFieldTile(
                          label: _isArabic
                              ? 'رابط الموقع الإلكتروني'
                              : 'Website URL',
                          controller: _websiteController,
                          hint: 'https://charter-ye.com',
                        ),
                      ),
                      _row2(
                        _TextFieldTile(
                          label: _isArabic
                              ? 'بريد العمليات'
                              : 'Operations Email',
                          controller: _secondaryEmailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) {
                              return null;
                            }
                            if (!v.contains('@')) {
                              return _isArabic
                                  ? 'صيغة بريد غير صحيحة'
                                  : 'Invalid email format';
                            }
                            return null;
                          },
                        ),
                        const SizedBox.shrink(),
                      ),
                      _row2(
                        _TextFieldTile(
                          label: _isArabic
                              ? 'عنوان مأرب (عربي)'
                              : 'Marib Address (Arabic)',
                          controller: _maribAddressArController,
                          maxLines: 2,
                        ),
                        _TextFieldTile(
                          label: _isArabic
                              ? 'عنوان مأرب (EN)'
                              : 'Marib Address (EN)',
                          controller: _maribAddressEnController,
                          maxLines: 2,
                        ),
                      ),
                      _row2(
                        _TextFieldTile(
                          label: _isArabic
                              ? 'عنوان عدن (عربي)'
                              : 'Aden Address (Arabic)',
                          controller: _adenAddressArController,
                          maxLines: 2,
                        ),
                        _TextFieldTile(
                          label: _isArabic
                              ? 'عنوان عدن (EN)'
                              : 'Aden Address (EN)',
                          controller: _adenAddressEnController,
                          maxLines: 2,
                        ),
                      ),
                      _row2(
                        _TextFieldTile(
                          label: _isArabic
                              ? 'نص التغطية (عربي)'
                              : 'Coverage Text (Arabic)',
                          controller: _coverageArController,
                          maxLines: 2,
                        ),
                        _TextFieldTile(
                          label: _isArabic
                              ? 'نص التغطية (EN)'
                              : 'Coverage Text (EN)',
                          controller: _coverageEnController,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _AdminSectionCard(
                  title: _isArabic ? 'صندوق الوارد (الطلبات)' : 'Lead Inbox',
                  child: _LeadInboxBlock(
                    leads: _leads,
                    isArabic: _isArabic,
                    statusLabelBuilder: _statusLabel,
                    onStatusChanged: _isSaving
                        ? null
                        : (leadId, status) => _updateLeadStatus(leadId, status),
                    onDeleteLead: _isSaving
                        ? null
                        : (leadId) => _deleteLead(leadId),
                    onClearLeads: _isSaving ? null : _clearLeads,
                  ),
                ),
                const SizedBox(height: 14),
                _AdminSectionCard(
                  title: _isArabic ? 'الأمان والبيانات' : 'Security and Data',
                  child: Column(
                    children: [
                      _row2(
                        _TextFieldTile(
                          label: _isArabic
                              ? 'رمز المرور الحالي'
                              : 'Current Admin Passcode',
                          controller: _currentPasscodeController,
                          obscureText: true,
                        ),
                        _TextFieldTile(
                          label: _isArabic
                              ? 'رمز مرور جديد'
                              : 'New Admin Passcode',
                          controller: _newPasscodeController,
                          obscureText: true,
                        ),
                      ),
                      _row2(
                        _TextFieldTile(
                          label: _isArabic
                              ? 'تأكيد الرمز الجديد'
                              : 'Confirm New Passcode',
                          controller: _confirmPasscodeController,
                          obscureText: true,
                        ),
                        const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: _isArabic
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Text(
                          _isArabic
                              ? 'قوة الرمز المطلوبة: 10 أحرف+ (كبير/صغير/رقم/رمز).'
                              : 'Passcode policy: 10+ chars with upper/lower/number/symbol.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.black54),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveChanges,
                            icon: const Icon(Icons.save_rounded),
                            label: Text(
                              _isArabic ? 'حفظ التغييرات' : 'Save Changes',
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: _isSaving ? null : _copyJson,
                            icon: const Icon(Icons.copy_all_rounded),
                            label: Text(_isArabic ? 'نسخ JSON' : 'Copy JSON'),
                          ),
                          OutlinedButton.icon(
                            onPressed: _isSaving ? null : _resetAll,
                            icon: const Icon(Icons.restore_rounded),
                            label: Text(
                              _isArabic
                                  ? 'إعادة الافتراضيات'
                                  : 'Reset to Defaults',
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _isSaving
                                ? null
                                : () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: Text(
                              _isArabic ? 'العودة للموقع' : 'Back to Website',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row2(Widget left, Widget right) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 860;
        if (!isWide) {
          return Column(
            children: [
              left,
              if (right is! SizedBox) ...[const SizedBox(height: 12), right],
              const SizedBox(height: 12),
            ],
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              const SizedBox(width: 12),
              Expanded(child: right),
            ],
          ),
        );
      },
    );
  }
}

class _AdminSectionCard extends StatelessWidget {
  const _AdminSectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _LeadInboxBlock extends StatelessWidget {
  const _LeadInboxBlock({
    required this.leads,
    required this.isArabic,
    required this.statusLabelBuilder,
    this.onStatusChanged,
    this.onDeleteLead,
    this.onClearLeads,
  });

  final List<ContactLead> leads;
  final bool isArabic;
  final String Function(LeadStatus status, {required bool isArabic})
  statusLabelBuilder;
  final Future<void> Function(String leadId, LeadStatus status)?
  onStatusChanged;
  final Future<void> Function(String leadId)? onDeleteLead;
  final Future<void> Function()? onClearLeads;

  @override
  Widget build(BuildContext context) {
    final newCount = leads
        .where((lead) => lead.status == LeadStatus.newLead)
        .length;
    final contactedCount = leads
        .where((lead) => lead.status == LeadStatus.contacted)
        .length;
    final closedCount = leads
        .where((lead) => lead.status == LeadStatus.closed)
        .length;

    if (leads.isEmpty) {
      return Text(
        isArabic ? 'لا توجد طلبات واردة حالياً.' : 'No leads captured yet.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _LeadCountChip(
              label: '${isArabic ? 'إجمالي' : 'Total'}: ${leads.length}',
              tone: Colors.blueGrey,
            ),
            _LeadCountChip(
              label:
                  '${statusLabelBuilder(LeadStatus.newLead, isArabic: isArabic)}: $newCount',
              tone: Colors.orange,
            ),
            _LeadCountChip(
              label:
                  '${statusLabelBuilder(LeadStatus.contacted, isArabic: isArabic)}: $contactedCount',
              tone: Colors.indigo,
            ),
            _LeadCountChip(
              label:
                  '${statusLabelBuilder(LeadStatus.closed, isArabic: isArabic)}: $closedCount',
              tone: Colors.green,
            ),
          ],
        ),
        if (onClearLeads != null) ...[
          const SizedBox(height: 10),
          Align(
            alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onClearLeads == null
                  ? null
                  : () => onClearLeads!.call(),
              icon: const Icon(Icons.delete_sweep_rounded),
              label: Text(isArabic ? 'حذف كل الوارد' : 'Clear Inbox'),
            ),
          ),
        ],
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: leads.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final lead = leads[index];
            final created = lead.createdAt.toLocal();
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lead.name.isEmpty
                                  ? (isArabic ? 'بدون اسم' : 'Unnamed Lead')
                                  : lead.name,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lead.company.isEmpty
                                  ? (isArabic ? 'الجهة: -' : 'Company: -')
                                  : '${isArabic ? 'الجهة' : 'Company'}: ${lead.company}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              lead.service.isEmpty
                                  ? (isArabic ? 'الخدمة: -' : 'Service: -')
                                  : '${isArabic ? 'الخدمة' : 'Service'}: ${lead.service}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 170,
                        child: DropdownButtonFormField<LeadStatus>(
                          initialValue: lead.status,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                          items: LeadStatus.values
                              .map(
                                (status) => DropdownMenuItem<LeadStatus>(
                                  value: status,
                                  child: Text(
                                    statusLabelBuilder(
                                      status,
                                      isArabic: isArabic,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: onStatusChanged == null
                              ? null
                              : (status) {
                                  if (status == null) {
                                    return;
                                  }
                                  onStatusChanged!(lead.id, status);
                                },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onDeleteLead == null
                            ? null
                            : () => onDeleteLead!(lead.id),
                        icon: const Icon(Icons.delete_outline_rounded),
                        tooltip: isArabic ? 'حذف الطلب' : 'Delete Lead',
                      ),
                    ],
                  ),
                  if (lead.message.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      lead.message,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '${isArabic ? 'التاريخ' : 'Date'}: ${created.year}-${created.month.toString().padLeft(2, '0')}-${created.day.toString().padLeft(2, '0')} ${created.hour.toString().padLeft(2, '0')}:${created.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _LeadCountChip extends StatelessWidget {
  const _LeadCountChip({required this.label, required this.tone});

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tone.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: tone,
        ),
      ),
    );
  }
}

class _TextFieldTile extends StatelessWidget {
  const _TextFieldTile({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.hint,
    this.obscureText = false,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final String? hint;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}
