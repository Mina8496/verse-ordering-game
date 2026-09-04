import 'package:aner_astaner/features/user/domain/entities/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user_model.dart';
import '../../domain/entities/user_summary.dart';
import '../../domain/repositories/user_repository.dart';

class FirestoreUserRepository implements UserRepository {
  FirestoreUserRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
Future<UserProfile?> fetchCurrentUserProfile() async {
  final data = await fetchCurrentUserData();
  return data != null ? UserProfile.fromMap(data) : null;
}

  @override
  Stream<List<UserSummary>> watchUsersByOrganization({
    required String churchId,
    required String chapterId,
    String? role,
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('users')
        .where('ChurchID', isEqualTo: churchId)
        .where('ChapterID', isEqualTo: chapterId)
        .where('role', isNotEqualTo: 'SuperAdmin')
        .orderBy('role');
    if (role != null) query = query.where('role', isEqualTo: role);

    return query.snapshots().map(
      (snapshot) => snapshot.docs.map((document) {
        final data = document.data();
        return UserSummary(
          id: document.id,
          name: data['full_name'] as String? ?? '',
          email: data['email'] as String? ?? '',
          phone: data['Phone_Namber'] as String? ?? '',
          role: data['role'] as String? ?? 'User',
          season: data['Season'] as String? ?? '',
          profileImageUrl: data['profileImageUrl'] as String?,
        );
      }).toList(),
    );
  }

  @override
  Stream<List<UserSummary>> watchUsers({
    required String churchId,
    required String chapterId,
    required String status,
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('users')
        .where('ChurchID', isEqualTo: churchId)
        .where('ChapterID', isEqualTo: chapterId)
        .where('role', isEqualTo: 'User')
        .where('status', isEqualTo: status)
        .orderBy('full_name');

    return query.snapshots().map(
      (snapshot) => snapshot.docs.map((document) {
        final data = document.data();
        return UserSummary(
          id: document.id,
          name: data['full_name'] as String? ?? '',
          email: data['email'] as String? ?? '',
          phone: data['Phone_Namber'] as String? ?? '',
          role: data['role'] as String? ?? 'User',
          season: data['Season'] as String? ?? '',
          profileImageUrl: data['profileImageUrl'] as String?,
        );
      }).toList(),
    );
  }

  @override
  Future<void> updateUserStatus(String userId, String status) =>
      _firestore.collection('users').doc(userId).update({'status': status});

  @override
  Stream<List<UserSummary>> watchDisabledUsers(String churchId) => _firestore
      .collection('users')
      .where('ChurchID', isEqualTo: churchId)
      .where('disabled', isEqualTo: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.map((document) {
          final data = document.data();
          return UserSummary(
            id: document.id,
            name: data['full_name'] as String? ?? 'مستخدم',
            email: data['email'] as String? ?? '',
            role: data['role'] as String? ?? 'User',
            phone: data['Phone_Namber'] as String? ?? '',
            season: data['Season'] as String? ?? '',
            profileImageUrl: data['profileImageUrl'] as String?,
          );
        }).toList(),
      );

  @override
  Future<void> enableUser(String userId) =>
      _firestore.collection('users').doc(userId).update({'disabled': false});

  @override
  Future<UserModel?> fetchCurrentUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final document = await _firestore.collection('users').doc(uid).get();
    final data = document.data();
    if (!document.exists || data == null) return null;

    return UserModel.fromMap(document.id, data);
  }

  @override
  Future<Map<String, dynamic>?> fetchUserById(String userId) async {
    final document = await _firestore.collection('users').doc(userId).get();
    return document.exists ? document.data() : null;
  }

  @override
  Future<Map<String, dynamic>?> fetchCurrentUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final document = await _firestore.collection('users').doc(uid).get();
    return document.exists ? document.data() : null;
  }

  @override
  Future<void> updateCurrentUser(Map<String, dynamic> data) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).update(data);
  }

  @override
  Future<void> updateUser(String userId, Map<String, dynamic> data) {
    return _firestore.collection('users').doc(userId).update(data);
  }

  @override
  Future<void> updateProfileImage(String url) =>
      updateCurrentUser({'profileImageUrl': url});

  @override
  Future<void> deleteProfileImage() =>
      updateCurrentUser({'profileImageUrl': FieldValue.delete()});

  @override
  Future<void> completeUserProfile({
    required String uid,
    required Map<String, dynamic> data,
    required String churchId,
    required String chapterId,
  }) async {
    final batch = _firestore.batch();
    batch.set(_firestore.collection('users').doc(uid), data);
    batch.set(
      _firestore
          .collection('Churches')
          .doc(churchId)
          .collection('Chapters')
          .doc(chapterId)
          .collection('Approved')
          .doc(uid),
      data,
    );
    await batch.commit();
  }
}
