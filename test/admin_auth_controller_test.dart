import 'package:charter_company/features/admin/data/admin_auth_repository.dart';
import 'package:charter_company/features/admin/domain/admin_auth_controller.dart';
import 'package:charter_company/features/admin/domain/admin_auth_models.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAdminAuthRepository implements AdminAuthRepository {
  bool _session = false;
  AdminSignInResult signInResult = const AdminSignInResult.success();
  AdminPasscodeUpdateResult passcodeResult =
      const AdminPasscodeUpdateResult.success();

  @override
  Future<bool> hasSession() async => _session;

  @override
  Future<AdminSignInResult> signIn({
    required String username,
    required String passcode,
  }) async {
    if (signInResult.status == AdminSignInStatus.success) {
      _session = true;
    }
    return signInResult;
  }

  @override
  Future<void> signOut() async {
    _session = false;
  }

  @override
  Future<AdminPasscodeUpdateResult> updatePasscode({
    required String currentPasscode,
    required String newPasscode,
  }) async {
    return passcodeResult;
  }
}

void main() {
  test('signIn success sets session', () async {
    final repo = _FakeAdminAuthRepository();
    final controller = AdminAuthController(repository: repo);

    final result = await controller.signIn(
      username: 'admin',
      passcode: 'Secret@123',
    );

    expect(result.status, AdminSignInStatus.success);
    expect(await controller.hasSession(), isTrue);
  });

  test('signIn lockout status is returned', () async {
    final repo = _FakeAdminAuthRepository()
      ..signInResult = const AdminSignInResult.lockedOut(Duration(minutes: 5));
    final controller = AdminAuthController(repository: repo);

    final result = await controller.signIn(username: 'admin', passcode: 'bad');

    expect(result.status, AdminSignInStatus.lockedOut);
    expect(result.retryAfter, isNotNull);
  });

  test('updatePasscode returns repository result', () async {
    final repo = _FakeAdminAuthRepository()
      ..passcodeResult = const AdminPasscodeUpdateResult.weakPasscode();
    final controller = AdminAuthController(repository: repo);

    final result = await controller.updatePasscode(
      currentPasscode: 'Old@1234',
      newPasscode: 'weak',
    );

    expect(result.status, AdminPasscodeUpdateStatus.weakPasscode);
  });

  test('signOut clears session', () async {
    final repo = _FakeAdminAuthRepository();
    final controller = AdminAuthController(repository: repo);
    await controller.signIn(username: 'admin', passcode: 'Secret@123');
    expect(await controller.hasSession(), isTrue);

    await controller.signOut();
    expect(await controller.hasSession(), isFalse);
  });
}
