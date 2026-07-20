import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../leads/domain/contact_lead.dart';
import '../data/app_content.dart';
import '../domain/landing_models.dart';
import '../widgets/shared_widgets.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key, required this.content, this.onSubmitLead});

  final AppContent content;
  final Future<void> Function(ContactLeadDraft lead)? onSubmitLead;

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
  const _ContactForm({required this.content, this.onSubmitLead});

  final AppContent content;
  final Future<void> Function(ContactLeadDraft lead)? onSubmitLead;

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _companyController = TextEditingController();
  late final TextEditingController _serviceController = TextEditingController();
  late final TextEditingController _messageController = TextEditingController();
  late final TextEditingController _honeypotController =
      TextEditingController();

  DateTime? _lastSubmittedAt;
  bool _isSubmitting = false;

  AppContent get content => widget.content;

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _serviceController.dispose();
    _messageController.dispose();
    _honeypotController.dispose();
    super.dispose();
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
      service: _serviceController.text.trim(),
      message: _messageController.text.trim(),
    );

    setState(() => _isSubmitting = true);
    try {
      if (widget.onSubmitLead != null) {
        await widget.onSubmitLead!(lead);
      }
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
    final service = _serviceController.text.trim();
    final message = _messageController.text.trim();

    final subject = content.isArabic
        ? 'طلب خدمة - شركة تشارتر'
        : 'Service Request - Charter';

    final body = content.isArabic
        ? '''
الاسم: ${name.isEmpty ? '-' : name}
الجهة / الشركة: ${company.isEmpty ? '-' : company}
الخدمة المطلوبة: ${service.isEmpty ? '-' : service}
تفاصيل الطلب:
${message.isEmpty ? '-' : message}
'''
        : '''
Name: ${name.isEmpty ? '-' : name}
Organization / Company: ${company.isEmpty ? '-' : company}
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    key: const Key('contact_submit'),
                    onPressed: _isSubmitting ? null : _submitLead,
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
