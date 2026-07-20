import 'package:charter_company/app/app_state_controller.dart';
import 'package:charter_company/features/admin/data/site_admin_settings_repository.dart';
import 'package:charter_company/features/admin/domain/site_admin_settings.dart';
import 'package:charter_company/features/leads/data/lead_inbox_repository.dart';
import 'package:charter_company/features/leads/domain/contact_lead.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:charter_company/main.dart';

class _MemorySettingsRepository implements SiteAdminSettingsRepository {
  @override
  Future<void> clear() async {}

  @override
  Future<SiteAdminSettings?> load() async => null;

  @override
  Future<void> save(SiteAdminSettings settings) async {}
}

class _MemoryLeadRepository implements LeadInboxRepository {
  @override
  Future<void> clear() async {}

  @override
  Future<List<ContactLead>> load() async => const [];

  @override
  Future<void> saveAll(List<ContactLead> leads) async {}

  @override
  Future<ContactLead> submitDraft(ContactLeadDraft draft) {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('renders charter landing page main sections', (
    WidgetTester tester,
  ) async {
    final appState = AppStateController(
      settingsRepository: _MemorySettingsRepository(),
      leadInboxRepository: _MemoryLeadRepository(),
    );
    addTearDown(appState.dispose);

    await tester.pumpWidget(CharterApp(appStateController: appState));
    await tester.pump(const Duration(seconds: 2));

    expect(
      find.text('تشارتر للمقاولات العامة والخدمات والتوريدات'),
      findsWidgets,
    );
    expect(
      find.text('نبني البنية التحتية ونُدير الإمداد من خلال شريك واحد'),
      findsOneWidget,
    );
    expect(find.text('قطاعات أعمالنا'), findsOneWidget);
    expect(find.text('القدرات والأهداف الاستراتيجية'), findsOneWidget);
    expect(find.text('نماذج نطاقات التنفيذ'), findsOneWidget);
    expect(find.text('تشارتر للمقاولات العامة'), findsOneWidget);
    expect(find.text('تشارتر للخدمات العامة والتوريدات'), findsOneWidget);
  });
}
