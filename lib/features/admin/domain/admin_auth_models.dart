enum AdminSignInStatus { success, invalidPasscode, lockedOut, notConfigured }

class AdminSignInResult {
  const AdminSignInResult._({required this.status, this.retryAfter});

  const AdminSignInResult.success() : this._(status: AdminSignInStatus.success);

  const AdminSignInResult.invalidPasscode()
    : this._(status: AdminSignInStatus.invalidPasscode);

  const AdminSignInResult.notConfigured()
    : this._(status: AdminSignInStatus.notConfigured);

  const AdminSignInResult.lockedOut(Duration retryAfter)
    : this._(status: AdminSignInStatus.lockedOut, retryAfter: retryAfter);

  final AdminSignInStatus status;
  final Duration? retryAfter;
}

enum AdminPasscodeUpdateStatus {
  success,
  invalidCurrentPasscode,
  weakPasscode,
  notConfigured,
}

class AdminPasscodeUpdateResult {
  const AdminPasscodeUpdateResult._(this.status);

  const AdminPasscodeUpdateResult.success()
    : this._(AdminPasscodeUpdateStatus.success);

  const AdminPasscodeUpdateResult.invalidCurrentPasscode()
    : this._(AdminPasscodeUpdateStatus.invalidCurrentPasscode);

  const AdminPasscodeUpdateResult.weakPasscode()
    : this._(AdminPasscodeUpdateStatus.weakPasscode);

  const AdminPasscodeUpdateResult.notConfigured()
    : this._(AdminPasscodeUpdateStatus.notConfigured);

  final AdminPasscodeUpdateStatus status;
}
