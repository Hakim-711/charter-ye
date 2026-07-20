import 'package:charter_company/features/landing/data/app_content.dart';
import 'package:charter_company/features/landing/domain/landing_models.dart';
import 'package:charter_company/features/landing/sections/contact_section.dart';
import 'package:charter_company/features/leads/domain/contact_lead.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildContact({
    required Future<void> Function(ContactLeadDraft lead) onSubmitLead,
    bool submissionEnabled = true,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ContactSection(
            content: AppContent.of(Language.ar),
            onSubmitLead: onSubmitLead,
            submissionEnabled: submissionEnabled,
          ),
        ),
      ),
    );
  }

  testWidgets('shows validation errors when required fields are empty', (
    tester,
  ) async {
    await tester.pumpWidget(buildContact(onSubmitLead: (_) async {}));

    final submit = find.byKey(const Key('contact_submit'));
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(find.text('هذا الحقل مطلوب.'), findsWidgets);
  });

  testWidgets('submits lead when required fields are valid', (tester) async {
    var submissions = 0;
    await tester.pumpWidget(
      buildContact(
        onSubmitLead: (_) async {
          submissions += 1;
        },
      ),
    );

    await tester.enterText(find.byKey(const Key('contact_name')), 'أحمد');
    await tester.enterText(
      find.byKey(const Key('contact_phone')),
      '+967 774 863 677',
    );
    await tester.enterText(
      find.byKey(const Key('contact_email_address')),
      'ahmed@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('contact_service')),
      'الخدمات اللوجستية',
    );
    await tester.enterText(
      find.byKey(const Key('contact_message')),
      'نحتاج عرض سعر وتفاصيل نطاق العمل خلال هذا الأسبوع.',
    );
    await tester.ensureVisible(find.byKey(const Key('contact_privacy')));
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    final submit = find.byKey(const Key('contact_submit'));
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(submissions, 1);
  });

  testWidgets('disables online submission when backend is unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildContact(onSubmitLead: (_) async {}, submissionEnabled: false),
    );

    final button = tester.widget<ElevatedButton>(
      find.byKey(const Key('contact_submit')),
    );
    expect(button.onPressed, isNull);
    expect(find.textContaining('الإرسال الإلكتروني غير متاح'), findsOneWidget);
  });
}
