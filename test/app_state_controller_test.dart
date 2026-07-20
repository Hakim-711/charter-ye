import 'package:charter_company/app/app_state_controller.dart';
import 'package:charter_company/features/admin/data/site_admin_settings_repository.dart';
import 'package:charter_company/features/admin/domain/site_admin_settings.dart';
import 'package:charter_company/features/leads/data/lead_inbox_repository.dart';
import 'package:charter_company/features/leads/domain/contact_lead.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSettingsRepository implements SiteAdminSettingsRepository {
  SiteAdminSettings? _value;

  @override
  Future<void> clear() async {
    _value = null;
  }

  @override
  Future<SiteAdminSettings?> load() async => _value;

  @override
  Future<void> save(SiteAdminSettings settings) async {
    _value = settings;
  }
}

class _FakeLeadRepository implements LeadInboxRepository {
  List<ContactLead> _leads;

  _FakeLeadRepository({List<ContactLead>? initial})
    : _leads = initial ?? const [];

  @override
  Future<void> clear() async {
    _leads = [];
  }

  @override
  Future<List<ContactLead>> load() async => _leads;

  @override
  Future<void> saveAll(List<ContactLead> leads) async {
    _leads = leads;
  }

  @override
  Future<ContactLead> submitDraft(ContactLeadDraft draft) async {
    final lead = ContactLead(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      createdAtIso: DateTime.now().toUtc().toIso8601String(),
      name: draft.name,
      company: draft.company,
      service: draft.service,
      message: draft.message,
      status: LeadStatus.newLead,
    );
    _leads = [lead, ..._leads];
    return lead;
  }
}

void main() {
  test('loads and sorts leads by date desc', () async {
    final settings = _FakeSettingsRepository();
    final leads = _FakeLeadRepository(
      initial: const [
        ContactLead(
          id: 'old',
          createdAtIso: '2025-01-01T00:00:00.000Z',
          name: 'A',
          company: '',
          service: '',
          message: '',
          status: LeadStatus.newLead,
        ),
        ContactLead(
          id: 'new',
          createdAtIso: '2026-01-01T00:00:00.000Z',
          name: 'B',
          company: '',
          service: '',
          message: '',
          status: LeadStatus.newLead,
        ),
      ],
    );

    final controller = AppStateController(
      settingsRepository: settings,
      leadInboxRepository: leads,
    );
    await controller.bootstrap();

    expect(controller.isLoading, isFalse);
    expect(controller.leads.first.id, 'new');
    expect(controller.leads.last.id, 'old');
  });

  test('submits and updates lead status', () async {
    final controller = AppStateController(
      settingsRepository: _FakeSettingsRepository(),
      leadInboxRepository: _FakeLeadRepository(),
    );
    await controller.bootstrap();
    await controller.submitLead(
      const ContactLeadDraft(
        name: 'Lead Name',
        company: 'Org',
        service: 'Logistics',
        message: 'Need urgent logistics support',
      ),
    );

    final leadId = controller.leads.first.id;
    await controller.updateLeadStatus(leadId, LeadStatus.contacted);

    expect(controller.leads.length, 1);
    expect(controller.leads.first.status, LeadStatus.contacted);
  });
}
