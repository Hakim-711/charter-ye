import 'package:flutter/foundation.dart';

import '../features/admin/data/site_admin_settings_repository.dart';
import '../features/admin/domain/site_admin_settings.dart';
import '../features/landing/domain/landing_models.dart';
import '../features/leads/data/lead_inbox_repository.dart';
import '../features/leads/domain/contact_lead.dart';

class AppStateController extends ChangeNotifier {
  AppStateController({
    SiteAdminSettingsRepository? settingsRepository,
    LeadInboxRepository? leadInboxRepository,
    Language initialLanguage = Language.ar,
  }) : _settingsRepository =
           settingsRepository ?? SiteAdminSettingsRepositoryFactory.create(),
       _leadInboxRepository =
           leadInboxRepository ?? LeadInboxRepositoryFactory.create(),
       _language = initialLanguage;

  final SiteAdminSettingsRepository _settingsRepository;
  final LeadInboxRepository _leadInboxRepository;

  bool _isLoading = true;
  Language _language;
  SiteAdminSettings? _adminSettings;
  List<ContactLead> _leads = const [];

  bool get isLoading => _isLoading;
  Language get language => _language;
  SiteAdminSettings? get adminSettings => _adminSettings;
  List<ContactLead> get leads => _leads;

  Future<void> bootstrap() async {
    _isLoading = true;
    notifyListeners();

    final settingsFuture = _settingsRepository.load();
    final leadsFuture = _leadInboxRepository.load();

    final settings = await settingsFuture;
    final leads = await leadsFuture;

    _adminSettings = settings;
    _leads = _sortLeads(leads);
    _isLoading = false;
    notifyListeners();
  }

  void setLanguage(Language language) {
    if (_language == language) {
      return;
    }
    _language = language;
    notifyListeners();
  }

  Future<void> saveAdminSettings(SiteAdminSettings settings) async {
    await _settingsRepository.save(settings);
    _adminSettings = settings;
    notifyListeners();
  }

  Future<void> resetAdminSettings() async {
    await _settingsRepository.clear();
    _adminSettings = null;
    notifyListeners();
  }

  Future<void> submitLead(ContactLeadDraft draft) async {
    final lead = await _leadInboxRepository.submitDraft(draft);
    final updated = _sortLeads([lead, ..._leads]);
    _leads = updated;
    notifyListeners();
  }

  Future<void> refreshAdminData() async {
    final settings = await _settingsRepository.load();
    final leads = await _leadInboxRepository.load();
    _adminSettings = settings;
    _leads = _sortLeads(leads);
    notifyListeners();
  }

  Future<void> updateLeadStatus(String leadId, LeadStatus status) async {
    final updated = _sortLeads(
      _leads
          .map(
            (lead) => lead.id == leadId ? lead.copyWith(status: status) : lead,
          )
          .toList(),
    );
    await _leadInboxRepository.saveAll(updated);
    _leads = updated;
    notifyListeners();
  }

  Future<void> deleteLead(String leadId) async {
    final updated = _sortLeads(
      _leads.where((lead) => lead.id != leadId).toList(),
    );
    await _leadInboxRepository.saveAll(updated);
    _leads = updated;
    notifyListeners();
  }

  Future<void> clearLeads() async {
    await _leadInboxRepository.clear();
    _leads = [];
    notifyListeners();
  }

  List<ContactLead> _sortLeads(List<ContactLead> leads) {
    final sorted = [...leads];
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }
}
