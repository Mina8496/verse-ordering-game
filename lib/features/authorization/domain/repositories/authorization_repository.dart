enum AccessStatus { allowed, noSignedInUser, disabled, incomplete }

abstract interface class AuthorizationRepository {
  Future<AccessStatus> checkCurrentUserAccess();
}
