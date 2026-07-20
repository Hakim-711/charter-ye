import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_runtime_config.dart';
import '../domain/admin_auth_models.dart';
import 'admin_session_repository.dart';

abstract class AdminAuthRepository {
  Future<AdminSignInResult> signIn({
    required String username,
    required String passcode,
  });

  Future<AdminPasscodeUpdateResult> updatePasscode({
    required String currentPasscode,
    required String newPasscode,
  });

  Future<void> signOut();
  Future<bool> hasSession();
}

class AdminAuthRepositoryFactory {
  const AdminAuthRepositoryFactory._();

  static AdminAuthRepository create({
    AdminSessionRepository? sessionRepository,
    http.Client? client,
  }) {
    final session = sessionRepository ?? SecureStorageAdminSessionRepository();
    if (AppRuntimeConfig.hasRemoteSync) {
      return RemoteAdminAuthRepository(
        baseUrl: AppRuntimeConfig.apiBaseUrl,
        sessionRepository: session,
        client: client,
      );
    }

    return LocalBootstrapAdminAuthRepository(
      bootstrapUsername: AppRuntimeConfig.adminBootstrapUsername,
      bootstrapPasscode: AppRuntimeConfig.adminBootstrapPasscode,
      sessionRepository: session,
    );
  }
}

class LocalBootstrapAdminAuthRepository implements AdminAuthRepository {
  LocalBootstrapAdminAuthRepository({
    required String bootstrapUsername,
    required String bootstrapPasscode,
    required AdminSessionRepository sessionRepository,
  }) : _bootstrapUsername =
           (bootstrapUsername.isEmpty ? 'admin' : bootstrapUsername).trim(),
       _bootstrapPasscode = bootstrapPasscode.trim(),
       _sessionRepository = sessionRepository;

  final String _bootstrapUsername;
  final String _bootstrapPasscode;
  final AdminSessionRepository _sessionRepository;

  @override
  Future<AdminSignInResult> signIn({
    required String username,
    required String passcode,
  }) async {
    final user = username.trim();
    final pwd = passcode.trim();
    if (_bootstrapPasscode.isEmpty) {
      return const AdminSignInResult.notConfigured();
    }

    if (user == _bootstrapUsername && pwd == _bootstrapPasscode) {
      await _sessionRepository.saveAccessToken('local_bootstrap_session');
      return const AdminSignInResult.success();
    }

    return const AdminSignInResult.invalidPasscode();
  }

  @override
  Future<AdminPasscodeUpdateResult> updatePasscode({
    required String currentPasscode,
    required String newPasscode,
  }) async {
    return const AdminPasscodeUpdateResult.notConfigured();
  }

  @override
  Future<void> signOut() async {
    await _sessionRepository.clear();
  }

  @override
  Future<bool> hasSession() async {
    final token = await _sessionRepository.loadAccessToken();
    return token != null && token.isNotEmpty;
  }
}

class RemoteAdminAuthRepository implements AdminAuthRepository {
  RemoteAdminAuthRepository({
    required String baseUrl,
    required AdminSessionRepository sessionRepository,
    http.Client? client,
  }) : _baseUrl = baseUrl.endsWith('/')
           ? baseUrl.substring(0, baseUrl.length - 1)
           : baseUrl,
       _sessionRepository = sessionRepository,
       _client = client ?? http.Client();

  final String _baseUrl;
  final AdminSessionRepository _sessionRepository;
  final http.Client _client;

  Uri get _loginUri => Uri.parse('$_baseUrl/api/auth/login');
  Uri get _changePasswordUri => Uri.parse('$_baseUrl/api/auth/change-password');

  Map<String, String> get _jsonHeaders => const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  @override
  Future<AdminSignInResult> signIn({
    required String username,
    required String passcode,
  }) async {
    final payload = {'username': username.trim(), 'password': passcode.trim()};

    try {
      final response = await _client.post(
        _loginUri,
        headers: _jsonHeaders,
        body: jsonEncode(payload),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = _extractDataMap(response.body);
        final token = (data['token'] as String?)?.trim();
        if (token == null || token.isEmpty) {
          return const AdminSignInResult.invalidPasscode();
        }
        await _sessionRepository.saveAccessToken(token);
        return const AdminSignInResult.success();
      }

      if (response.statusCode == 423) {
        final retrySeconds = _extractRetrySeconds(response.body);
        return AdminSignInResult.lockedOut(Duration(seconds: retrySeconds));
      }
      if (response.statusCode == 503) {
        return const AdminSignInResult.notConfigured();
      }
      return const AdminSignInResult.invalidPasscode();
    } catch (_) {
      return const AdminSignInResult.invalidPasscode();
    }
  }

  @override
  Future<AdminPasscodeUpdateResult> updatePasscode({
    required String currentPasscode,
    required String newPasscode,
  }) async {
    final token = await _sessionRepository.loadAccessToken();
    if (token == null || token.isEmpty) {
      return const AdminPasscodeUpdateResult.notConfigured();
    }

    try {
      final response = await _client.post(
        _changePasswordUri,
        headers: {..._jsonHeaders, 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'currentPassword': currentPasscode.trim(),
          'newPassword': newPasscode.trim(),
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const AdminPasscodeUpdateResult.success();
      }
      if (response.statusCode == 401) {
        return const AdminPasscodeUpdateResult.invalidCurrentPasscode();
      }
      if (response.statusCode == 400) {
        return const AdminPasscodeUpdateResult.weakPasscode();
      }
      return const AdminPasscodeUpdateResult.notConfigured();
    } catch (_) {
      return const AdminPasscodeUpdateResult.notConfigured();
    }
  }

  @override
  Future<void> signOut() async {
    await _sessionRepository.clear();
  }

  @override
  Future<bool> hasSession() async {
    final token = await _sessionRepository.loadAccessToken();
    return token != null && token.isNotEmpty;
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

  int _extractRetrySeconds(String rawBody) {
    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map) {
        final retry = decoded['retrySeconds'];
        if (retry is int && retry > 0) {
          return retry;
        }
      }
    } catch (_) {
      // Ignore malformed JSON.
    }
    return 600;
  }
}
