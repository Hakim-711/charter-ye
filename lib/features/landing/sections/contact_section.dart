import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../leads/domain/contact_lead.dart';
import '../data/app_content.dart';
import '../domain/landing_models.dart';
import '../widgets/shared_widgets.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({
    super.key,
    required this.content,
    this.onSubmitLead,
    this.submissionEnabled = true,
  });

  final AppContent content;
  final Future<void> Function(ContactLeadDraft lead)? onSubmitLead;
  final bool submissionEnabled;

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      background: AppColors.pearl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeSlideIn(
            child: SectionHeader(
              title: content.contactTitle.of(content.language),
              subtitle: content.contactSubtitle.of(content.language),
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 940;
              final form = FadeSlideIn(
                delay: const Duration(milliseconds: 80),
                child: _ContactForm(
                  content: content,
                  onSubmitLead: onSubmitLead,
                  submissionEnabled: submissionEnabled,
                ),
              );
              final details = FadeSlideIn(
                delay: const Duration(milliseconds: 160),
                child: _ContactDetails(content: content),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: form),
                    const SizedBox(width: 22),
                    Expanded(child: details),
                  ],
                );
              }

              return Column(
                children: [form, const SizedBox(height: 16), details],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ContactDetails extends StatelessWidget {
  const _ContactDetails({required this.content});

  final AppContent content;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: content.contactItems
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DetailCard(content: content, item: item),
            ),
          )
          .toList(),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.content, required this.item});

  final AppContent content;
  final ContactItem item;

  Future<void> _openContactAction(BuildContext context) async {
    final actionUrl = item.actionUrl;
    if (actionUrl == null || actionUrl.isEmpty) {
      return;
    }

    final launched = await launchUrl(
      Uri.parse(actionUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(content.formOpenContactError.of(content.language)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAction = item.actionUrl?.isNotEmpty ?? false;

    return MouseRegion(
      cursor: hasAction ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: hasAction ? () => _openContactAction(context) : null,
        child: HoverCard(
          child: SurfaceCard(
            radius: 16,
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: AppColors.gold),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label.of(content.language),
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.value,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                if (hasAction)
                  Icon(
                    Icons.open_in_new_rounded,
                    color: AppColors.muted.withValues(alpha: 0.7),
                    size: 18,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactForm extends StatefulWidget {
  const _ContactForm({
    required this.content,
    required this.submissionEnabled,
    this.onSubmitLead,
  });

  final AppContent content;
  final Future<void> Function(ContactLeadDraft lead)? onSubmitLead;
  final bool submissionEnabled;

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _companyController = TextEditingController();
  late final TextEditingController _phoneController = TextEditingController();
  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _serviceController = TextEditingController();
  late final TextEditingController _messageController = TextEditingController();
  late final TextEditingController _honeypotController =
      TextEditingController();

  DateTime? _lastSubmittedAt;
  bool _isSubmitting = false;
  bool _privacyAccepted = false;

  AppContent get content => widget.content;

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _serviceController.dispose();
    _messageController.dispose();
    _honeypotController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) {
      return content.formValidationRequired.of(content.language);
    }
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7 || digits.length > 15) {
      return content.formValidationPhone.of(content.language);
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return content.formValidationRequired.of(content.language);
    }
    final valid = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
    if (!valid || email.length > 180) {
      return content.formValidationEmail.of(content.language);
    }
    return null;
  }

  String? _requiredMin(String? value, {required int minLength}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return content.formValidationRequired.of(content.language);
    }
    if (v.length < minLength) {
      return content.formValidationMinLength.of(content.language);
    }
    return null;
  }

  Future<void> _submitLead() async {
    if (_isSubmitting) {
      return;
    }
    if (_honeypotController.text.trim().isNotEmpty) {
      return;
    }
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final now = DateTime.now();
    if (_lastSubmittedAt != null &&
        now.difference(_lastSubmittedAt!) < const Duration(seconds: 20)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(content.formRateLimitMessage.of(content.language)),
        ),
      );
      return;
    }

    final lead = ContactLeadDraft(
      name: _nameController.text.trim(),
      company: _companyController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().toLowerCase(),
      service: _serviceController.text.trim(),
      message: _messageController.text.trim(),
    );

    setState(() => _isSubmitting = true);
    try {
      final submit = widget.onSubmitLead;
      if (submit == null) {
        throw StateError('No lead submission handler is configured.');
      }
      await submit(lead);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(content.formSubmitError.of(content.language))),
      );
      return;
    }

    if (!mounted) {
      return;
    }
    _lastSubmittedAt = DateTime.now();
    _nameController.clear();
    _companyController.clear();
    _phoneController.clear();
    _emailController.clear();
    _serviceController.clear();
    _messageController.clear();
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(content.formSuccess.of(content.language))),
    );
  }

  Future<void> _openEmailComposer() async {
    final name = _nameController.text.trim();
    final company = _companyController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final service = _serviceController.text.trim();
    final message = _messageController.text.trim();

    final subject = content.isArabic
        ? 'طلب خدمة - شركة تشارتر'
        : 'Service Request - Charter';

    final body = content.isArabic
        ? '''
الاسم: ${name.isEmpty ? '-' : name}
الجهة / الشركة: ${company.isEmpty ? '-' : company}
رقم الهاتف: ${phone.isEmpty ? '-' : phone}
البريد الإلكتروني: ${email.isEmpty ? '-' : email}
الخدمة المطلوبة: ${service.isEmpty ? '-' : service}
تفاصيل الطلب:
${message.isEmpty ? '-' : message}
'''
        : '''
Name: ${name.isEmpty ? '-' : name}
Organization / Company: ${company.isEmpty ? '-' : company}
Phone: ${phone.isEmpty ? '-' : phone}
Email: ${email.isEmpty ? '-' : email}
Requested Service: ${service.isEmpty ? '-' : service}
Request Details:
${message.isEmpty ? '-' : message}
''';

    final mailUri = Uri(
      scheme: 'mailto',
      path: content.contactEmail,
      queryParameters: {'subject': subject, 'body': body},
    );

    final launched = await launchUrl(
      mailUri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(content.formOpenContactError.of(content.language)),
        ),
      );
    }
  }

  Future<void> _openPrivacyPolicy() async {
    await launchUrl(
      Uri.base.resolve('privacy.html'),
      mode: LaunchMode.platformDefault,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(22),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content.formTitle.of(content.language),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (!widget.submissionEnabled) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  content.formServiceUnavailable.of(content.language),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Offstage(
              offstage: true,
              child: TextFormField(
                key: const Key('contact_honeypot'),
                controller: _honeypotController,
                decoration: const InputDecoration(labelText: 'Website'),
              ),
            ),
            TextFormField(
              key: const Key('contact_name'),
              controller: _nameController,
              validator: (value) => _requiredMin(value, minLength: 2),
              decoration: InputDecoration(
                hintText: content.formHintName.of(content.language),
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              key: const Key('contact_phone'),
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: _validatePhone,
              autofillHints: const [AutofillHints.telephoneNumber],
              decoration: InputDecoration(
                hintText: content.formHintPhone.of(content.language),
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              key: const Key('contact_email_address'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(
                hintText: content.formHintEmail.of(content.language),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              key: const Key('contact_company'),
              controller: _companyController,
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.length > 90) {
                  return content.formValidationTooLong.of(content.language);
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: content.formHintCompany.of(content.language),
                prefixIcon: const Icon(Icons.business_rounded),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              key: const Key('contact_service'),
              controller: _serviceController,
              validator: (value) => _requiredMin(value, minLength: 2),
              decoration: InputDecoration(
                hintText: content.formHintService.of(content.language),
                prefixIcon: const Icon(Icons.handyman_outlined),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              key: const Key('contact_message'),
              controller: _messageController,
              maxLines: 4,
              validator: (value) => _requiredMin(value, minLength: 10),
              decoration: InputDecoration(
                hintText: content.formHintMessage.of(content.language),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 14),
            FormField<bool>(
              initialValue: _privacyAccepted,
              validator: (_) => _privacyAccepted
                  ? null
                  : content.privacyRequired.of(content.language),
              builder: (field) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxListTile(
                    key: const Key('contact_privacy'),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _privacyAccepted,
                    onChanged: (value) {
                      setState(() => _privacyAccepted = value ?? false);
                      field.didChange(_privacyAccepted);
                    },
                    title: Text(
                      content.privacyConsent.of(content.language),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    subtitle: TextButton(
                      onPressed: _openPrivacyPolicy,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        alignment: AlignmentDirectional.centerStart,
                      ),
                      child: Text(
                        content.isArabic
                            ? 'قراءة سياسة الخصوصية'
                            : 'Read privacy policy',
                      ),
                    ),
                  ),
                  if (field.hasError)
                    Text(
                      field.errorText!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    key: const Key('contact_submit'),
                    onPressed: _isSubmitting || !widget.submissionEnabled
                        ? null
                        : _submitLead,
                    child: Text(content.formSubmit.of(content.language)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    key: const Key('contact_email'),
                    onPressed: _openEmailComposer,
                    child: Text(content.formSendByEmail.of(content.language)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
