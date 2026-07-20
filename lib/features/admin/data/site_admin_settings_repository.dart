import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/app_runtime_config.dart';
import '../domain/site_admin_settings.dart';
import 'admin_session_repository.dart';

abstract class SiteAdminSettingsRepository {
  Future<SiteAdminSettings?> load();
  Future<void> save(SiteAdminSettings settings);
  Future<void> clear();
}

class SiteAdminSettingsRepositoryFactory {
  const SiteAdminSettingsRepositoryFactory._();

  static SiteAdminSettingsRepository create({
    AdminSessionRepository? sessionRepository,
    http.Client? client,
  }) {
    final cache = SecureStorageSiteAdminSettingsRepository();
    if (!AppRuntimeConfig.hasRemoteSync) {
      return cache;
    }
    return RemoteSiteAdminSettingsRepository(
      baseUrl: AppRuntimeConfig.apiBaseUrl,
      sessionRepository:
          sessionRepository ?? SecureStorageAdminSessionRepository(),
      cache: cache,
      client: client,
    );
  }
}

class SecureStorageSiteAdminSettingsRepository
    implements SiteAdminSettingsRepository {
  SecureStorageSiteAdminSettingsRepository({FlutterSecureStorage? storage})
    : _storage = storage ?? FlutterSecureStorage();

  static const String _storageKey = 'charter_site_admin_settings';
  final FlutterSecureStorage _storage;

  @override
  Future<SiteAdminSettings?> load() async {
    final raw = await _readSafely();
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final data = jsonDecode(raw);
      if (data is! Map) {
        return null;
      }
      return SiteAdminSettings.fromJson(data.cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(SiteAdminSettings settings) async {
    try {
      await _storage.write(
        key: _storageKey,
        value: jsonEncode(settings.toJson()),
      );
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

  Future<String?> _readSafely() async {
    try {
      return await _storage.read(key: _storageKey);
    } catch (_) {
      return null;
    }
  }
}

class RemoteSiteAdminSettingsRepository implements SiteAdminSettingsRepository {
  RemoteSiteAdminSettingsRepository({
    required String baseUrl,
    required AdminSessionRepository sessionRepository,
    required SiteAdminSettingsRepository cache,
    http.Client? client,
  }) : _baseUrl = baseUrl.endsWith('/')
           ? baseUrl.substring(0, baseUrl.length - 1)
           : baseUrl,
       _sessionRepository = sessionRepository,
       _cache = cache,
       _client = client ?? http.Client();

  final String _baseUrl;
  final AdminSessionRepository _sessionRepository;
  final SiteAdminSettingsRepository _cache;
  final http.Client _client;

  Uri get _publicSettingsUri => Uri.parse('$_baseUrl/api/public/settings');
  Uri get _adminSettingsUri => Uri.parse('$_baseUrl/api/admin/settings');

  Map<String, String> get _jsonHeaders => const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  @override
  Future<SiteAdminSettings?> load() async {
    try {
      final response = await _client.get(
        _publicSettingsUri,
        headers: _jsonHeaders,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = _extractDataMap(response.body);
        final settings = SiteAdminSettings.fromJson(data);
        await _cache.save(settings);
        return settings;
      }
    } catch (_) {
      // Fall back to secure local cache.
    }
    return _cache.load();
  }

  @override
  Future<void> save(SiteAdminSettings settings) async {
    final token = await _sessionRepository.loadAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Admin session is required.');
    }

    final headers = {..._jsonHeaders, 'Authorization': 'Bearer $token'};
    final response = await _client.put(
      _adminSettingsUri,
      headers: headers,
      body: jsonEncode(settings.toJson()),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to save settings (${response.statusCode})');
    }
    await _cache.save(settings);
  }

  @override
  Future<void> clear() async {
    final token = await _sessionRepository.loadAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Admin session is required.');
    }

    final headers = {..._jsonHeaders, 'Authorization': 'Bearer $token'};
    final response = await _client.delete(_adminSettingsUri, headers: headers);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to clear settings (${response.statusCode})');
    }
    await _cache.clear();
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
