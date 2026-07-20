import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/app_runtime_config.dart';
import '../../admin/data/admin_session_repository.dart';
import '../domain/contact_lead.dart';

abstract class LeadInboxRepository {
  Future<List<ContactLead>> load();
  Future<void> saveAll(List<ContactLead> leads);
  Future<void> clear();
  Future<ContactLead> submitDraft(ContactLeadDraft draft);
}

class LeadInboxRepositoryFactory {
  const LeadInboxRepositoryFactory._();

  static LeadInboxRepository create({
    AdminSessionRepository? sessionRepository,
    http.Client? client,
  }) {
    final cache = SecureStorageLeadInboxRepository();
    if (!AppRuntimeConfig.hasRemoteSync) {
      return cache;
    }
    return RemoteLeadInboxRepository(
      baseUrl: AppRuntimeConfig.apiBaseUrl,
      sessionRepository:
          sessionRepository ?? SecureStorageAdminSessionRepository(),
      cache: cache,
      client: client,
    );
  }
}

class SecureStorageLeadInboxRepository implements LeadInboxRepository {
  SecureStorageLeadInboxRepository({FlutterSecureStorage? storage})
    : _storage = storage ?? FlutterSecureStorage();

  static const String _storageKey = 'charter_lead_inbox';
  final FlutterSecureStorage _storage;

  @override
  Future<List<ContactLead>> load() async {
    final raw = await _readSafely();
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }

      final leads = <ContactLead>[];
      for (final item in decoded) {
        if (item is Map) {
          leads.add(ContactLead.fromJson(item.cast<String, dynamic>()));
        }
      }
      return leads;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> saveAll(List<ContactLead> leads) async {
    final payload = leads.map((lead) => lead.toJson()).toList();
    try {
      await _storage.write(key: _storageKey, value: jsonEncode(payload));
    } catch (_) {
      // Ignore local write errors.
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.delete(key: _storageKey);
    } catch (_) {
      // Ignore local clear errors.
    }
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

    final current = await load();
    await saveAll([lead, ...current]);
    return lead;
  }

  Future<String?> _readSafely() async {
    try {
      return await _storage.read(key: _storageKey);
    } catch (_) {
      return null;
    }
  }
}

class RemoteLeadInboxRepository implements LeadInboxRepository {
  RemoteLeadInboxRepository({
    required String baseUrl,
    required AdminSessionRepository sessionRepository,
    required LeadInboxRepository cache,
    http.Client? client,
  }) : _baseUrl = baseUrl.endsWith('/')
           ? baseUrl.substring(0, baseUrl.length - 1)
           : baseUrl,
       _sessionRepository = sessionRepository,
       _cache = cache,
       _client = client ?? http.Client();

  final String _baseUrl;
  final AdminSessionRepository _sessionRepository;
  final LeadInboxRepository _cache;
  final http.Client _client;

  Uri get _adminLeadsUri => Uri.parse('$_baseUrl/api/admin/leads');
  Uri get _publicLeadsUri => Uri.parse('$_baseUrl/api/public/leads');

  Map<String, String> get _jsonHeaders => const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, String>> _buildAuthHeaders() async {
    final token = await _sessionRepository.loadAccessToken();
    if (token == null || token.isEmpty) {
      return _jsonHeaders;
    }
    return {..._jsonHeaders, 'Authorization': 'Bearer $token'};
  }

  @override
  Future<List<ContactLead>> load() async {
    final token = await _sessionRepository.loadAccessToken();
    if (token == null || token.isEmpty) {
      return _cache.load();
    }

    try {
      final headers = {..._jsonHeaders, 'Authorization': 'Bearer $token'};
      final response = await _client.get(_adminLeadsUri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = _extractDataList(response.body);
        final leads = data
            .whereType<Map>()
            .map((item) => ContactLead.fromJson(item.cast<String, dynamic>()))
            .toList();
        await _cache.saveAll(leads);
        return leads;
      }
    } catch (_) {
      // Fall back to cache.
    }

    return _cache.load();
  }

  @override
  Future<void> saveAll(List<ContactLead> leads) async {
    final token = await _sessionRepository.loadAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Admin session is required.');
    }

    final headers = await _buildAuthHeaders();
    final response = await _client.put(
      _adminLeadsUri,
      headers: headers,
      body: jsonEncode(leads.map((lead) => lead.toJson()).toList()),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to save leads (${response.statusCode})');
    }
    await _cache.saveAll(leads);
  }

  @override
  Future<void> clear() async {
    final token = await _sessionRepository.loadAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Admin session is required.');
    }

    final headers = await _buildAuthHeaders();
    final response = await _client.delete(_adminLeadsUri, headers: headers);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to clear leads (${response.statusCode})');
    }
    await _cache.clear();
  }

  @override
  Future<ContactLead> submitDraft(ContactLeadDraft draft) async {
    try {
      final response = await _client.post(
        _publicLeadsUri,
        headers: _jsonHeaders,
        body: jsonEncode({
          'name': draft.name,
          'company': draft.company,
          'service': draft.service,
          'message': draft.message,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final map = _extractDataMap(response.body);
        final lead = ContactLead.fromJson(map);
        return lead;
      }
    } catch (_) {
      // Fall back to local cache.
    }

    return _cache.submitDraft(draft);
  }

  List<dynamic> _extractDataList(String rawBody) {
    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map) {
        final data = decoded['data'];
        if (data is List) {
          return data;
        }
      }
      if (decoded is List) {
        return decoded;
      }
    } catch (_) {
      // Ignore malformed JSON.
    }
    return const [];
  }

  Map<String, dynamic> _extractDataMap(String rawBody) {
    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map) {
        final data = decoded['data'];
        if (data is Map) {
          return data.cast<String, dynamic>();
        }
        return decoded.cast<String, dynamic>();
      }
    } catch (_) {
      // Ignore malformed JSON.
    }
    return const {};
  }
}
