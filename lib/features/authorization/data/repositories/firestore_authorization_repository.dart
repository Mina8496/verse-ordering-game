import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repositories/authorization_repository.dart';

class FirestoreAuthorizationRepository implements AuthorizationRepository {
  FirestoreAuthorizationRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<AccessStatus> checkCurrentUserAccess() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return AccessStatus.noSignedInUser;

    final userDocument = await _firestore.collection('users').doc(uid).get();
    final userData = userDocument.data();
    if (!userDocument.exists || userData == null) {
      return AccessStatus.incomplete;
    }
    if (userData['disabled'] == true) return AccessStatus.disabled;

    final role = userData['role'];
    final isAdmin =
        role == 'DataAdmin' || role == 'Admin' || role == 'SuperAdmin';
    if (isAdmin) return AccessStatus.allowed;

    final churchId = userData['ChurchID'];
    final chapterId = userData['ChapterID'];
    if (churchId is! String ||
        chapterId is! String ||
        churchId.isEmpty ||
        chapterId.isEmpty) {
      return AccessStatus.incomplete;
    }

    final approvalDocument = await _firestore
        .collection('Churches')
        .doc(churchId)
        .collection('Chapters')
        .doc(chapterId)
        .collection('Approved')
        .doc(uid)
        .get();

    return approvalDocument.exists
        ? AccessStatus.allowed
        : AccessStatus.incomplete;
  }
}
