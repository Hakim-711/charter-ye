class AppRuntimeConfig {
  const AppRuntimeConfig._();

  static String get adminBootstrapPasscode =>
      const String.fromEnvironment('ADMIN_BOOTSTRAP_PASSCODE').trim();

  static String get adminBootstrapUsername {
    final raw = const String.fromEnvironment('ADMIN_BOOTSTRAP_USERNAME').trim();
    if (raw.isEmpty) {
      return 'admin';
    }
    return raw;
  }

  static String get adminAccessKey =>
      const String.fromEnvironment('ADMIN_ACCESS_KEY').trim();

  static String get apiBaseUrl {
    final raw = const String.fromEnvironment('CHARTER_API_BASE_URL').trim();
    if (raw.endsWith('/')) {
      return raw.substring(0, raw.length - 1);
    }
    return raw;
  }

  static bool get hasRemoteSync => apiBaseUrl.isNotEmpty;
}
