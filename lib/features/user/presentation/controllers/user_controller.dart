import 'package:aner_astaner/features/user/domain/entities/user_profile.dart';

import '../../domain/entities/user_model.dart';
import '../../domain/entities/user_summary.dart';
import '../../domain/repositories/user_repository.dart';

class UserController {
  UserController({required UserRepository repository})
    : _repository = repository;

  final UserRepository _repository;

  Future<UserProfile?> fetchCurrentUserProfile() =>
    _repository.fetchCurrentUserProfile();

  Stream<List<UserSummary>> watchUsersByOrganization({
    required String churchId,
    required String chapterId,
    String? role,
  }) => _repository.watchUsersByOrganization(
    churchId: churchId,
    chapterId: chapterId,
    role: role,
  );

  Stream<List<UserSummary>> watchUsers({
    required String churchId,
    required String chapterId,
    required String status,
  }) => _repository.watchUsers(
    churchId: churchId,
    chapterId: chapterId,
    status: status,
  );

  Future<void> updateUserStatus(String userId, String status) =>
      _repository.updateUserStatus(userId, status);

  Stream<List<UserSummary>> watchDisabledUsers(String churchId) =>
      _repository.watchDisabledUsers(churchId);

  Future<void> enableUser(String userId) => _repository.enableUser(userId);

  Future<UserModel?> fetchUserData() => _repository.fetchCurrentUser();

  Future<Map<String, dynamic>?> fetchUserById(String userId) =>
      _repository.fetchUserById(userId);

  Future<Map<String, dynamic>?> fetchCurrentUserData() =>
      _repository.fetchCurrentUserData();

  Future<void> updateCurrentUser(Map<String, dynamic> data) =>
      _repository.updateCurrentUser(data);

  Future<void> updateUser(String userId, Map<String, dynamic> data) =>
      _repository.updateUser(userId, data);

  Future<void> updateProfileImage(String url) =>
      _repository.updateProfileImage(url);

  Future<void> deleteProfileImage() => _repository.deleteProfileImage();

  Future<void> completeUserProfile({
    required String uid,
    required Map<String, dynamic> data,
    required String churchId,
    required String chapterId,
  }) => _repository.completeUserProfile(
    uid: uid,
    data: data,
    churchId: churchId,
    chapterId: chapterId,
  );
}
