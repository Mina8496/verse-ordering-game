import 'package:aner_astaner/features/user/domain/entities/user_profile.dart';

import '../entities/user_model.dart';
import '../entities/user_summary.dart';

abstract interface class UserRepository {
  Stream<List<UserSummary>> watchUsersByOrganization({
    required String churchId,
    required String chapterId,
    String? role,
  });

  Stream<List<UserSummary>> watchUsers({
    required String churchId,
    required String chapterId,
    required String status,
  });

  Future<void> updateUserStatus(String userId, String status);

  Future<UserProfile?> fetchCurrentUserProfile();

  Stream<List<UserSummary>> watchDisabledUsers(String churchId);

  Future<void> enableUser(String userId);

  Future<UserModel?> fetchCurrentUser();

  Future<Map<String, dynamic>?> fetchUserById(String userId);

  Future<Map<String, dynamic>?> fetchCurrentUserData();

  Future<void> updateCurrentUser(Map<String, dynamic> data);

  Future<void> updateUser(String userId, Map<String, dynamic> data);

  Future<void> updateProfileImage(String url);

  Future<void> deleteProfileImage();

  Future<void> completeUserProfile({
    required String uid,
    required Map<String, dynamic> data,
    required String churchId,
    required String chapterId,
  });
}
