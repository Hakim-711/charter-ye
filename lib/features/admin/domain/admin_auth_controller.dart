import '../data/admin_auth_repository.dart';
import 'admin_auth_models.dart';

class AdminAuthController {
  AdminAuthController({AdminAuthRepository? repository})
    : _repository = repository ?? AdminAuthRepositoryFactory.create();

  final AdminAuthRepository _repository;

  Future<AdminSignInResult> signIn({
    required String username,
    required String passcode,
  }) {
    return _repository.signIn(username: username, passcode: passcode);
  }

  Future<AdminPasscodeUpdateResult> updatePasscode({
    required String currentPasscode,
    required String newPasscode,
  }) {
    return _repository.updatePasscode(
      currentPasscode: currentPasscode,
      newPasscode: newPasscode,
    );
  }

  Future<void> signOut() => _repository.signOut();

  Future<bool> hasSession() => _repository.hasSession();
}
