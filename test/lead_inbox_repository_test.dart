import 'dart:convert';

import 'package:charter_company/features/admin/data/admin_session_repository.dart';
import 'package:charter_company/features/leads/data/lead_inbox_repository.dart';
import 'package:charter_company/features/leads/domain/contact_lead.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _MemorySessionRepository implements AdminSessionRepository {
  @override
  Future<void> clear() async {}

  @override
  Future<String?> loadAccessToken() async => null;

  @override
  Future<void> saveAccessToken(String token) async {}
}

class _TrackingCache implements LeadInboxRepository {
  int submissions = 0;

  @override
  Future<void> clear() async {}

  @override
  Future<List<ContactLead>> load() async => const [];

  @override
  Future<void> saveAll(List<ContactLead> leads) async {}

  @override
  Future<ContactLead> submitDraft(ContactLeadDraft draft) async {
    submissions += 1;
    throw StateError('The remote repository must not report local delivery.');
  }
}

const _draft = ContactLeadDraft(
  name: 'Client',
  company: 'Example',
  phone: '+967774863677',
  email: 'client@example.com',
  service: 'Logistics',
  message: 'We need a complete logistics proposal.',
);

void main() {
  test('remote failure never falls back to a false local success', () async {
    final cache = _TrackingCache();
    final repository = RemoteLeadInboxRepository(
      baseUrl: 'https://api.example.com',
      sessionRepository: _MemorySessionRepository(),
      cache: cache,
      client: MockClient((_) async => http.Response('unavailable', 503)),
    );

    await expectLater(
      repository.submitDraft(_draft),
      throwsA(isA<LeadSubmissionException>()),
    );
    expect(cache.submissions, 0);
  });

  test('successful remote submission returns server-confirmed lead', () async {
    final repository = RemoteLeadInboxRepository(
      baseUrl: 'https://api.example.com',
      sessionRepository: _MemorySessionRepository(),
      cache: _TrackingCache(),
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'data': {
              'id': 'lead-1',
              'createdAtIso': '2026-07-20T10:00:00.000Z',
              'name': _draft.name,
              'company': _draft.company,
              'phone': _draft.phone,
              'email': _draft.email,
              'service': _draft.service,
              'message': _draft.message,
              'status': 'newLead',
            },
          }),
          201,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );

    final lead = await repository.submitDraft(_draft);
    expect(lead.id, 'lead-1');
    expect(lead.phone, _draft.phone);
    expect(lead.email, _draft.email);
  });
}
