import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/organization_item.dart';
import '../../domain/repositories/organization_repository.dart';

class FirestoreOrganizationRepository implements OrganizationRepository {
  FirestoreOrganizationRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<OrganizationItem>> fetchAllChurches() async {
    final snapshot = await _firestore.collection('Churches').get();
    return _items(snapshot);
  }

  @override
  Future<List<OrganizationItem>> fetchAllChapters(String churchId) async {
    final snapshot = await _firestore
        .collection('Churches')
        .doc(churchId)
        .collection('Chapters')
        .get();
    return _items(snapshot, field: 'season');
  }

  @override
  Future<List<OrganizationItem>> fetchChurches({
    required String? role,
    required String? churchId,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection('Churches');
    if (role == 'SuperAdmin') {
      query = query.orderBy('title');
    } else if (role == 'Admin' && churchId != null) {
      query = query.where(FieldPath.documentId, isEqualTo: churchId);
    } else {
      return const [];
    }
    return _items(await query.get());
  }

  @override
  Future<List<OrganizationItem>> fetchChapters({
    required String? churchId,
    required String? role,
    required String? selectedChapterId,
  }) async {
    if (churchId == null) return const [];
    Query<Map<String, dynamic>> query = _firestore
        .collection('Churches')
        .doc(churchId)
        .collection('Chapters');
    if (role == 'Admin' && selectedChapterId != null) {
      query = query.where(FieldPath.documentId, isEqualTo: selectedChapterId);
    } else if (role != 'SuperAdmin') {
      return const [];
    }
    return _items(await query.get(), field: 'season');
  }

  List<OrganizationItem> _items(
    QuerySnapshot<Map<String, dynamic>> snapshot, {
    String field = 'title',
  }) => snapshot.docs
      .map(
        (document) => OrganizationItem(
          id: document.id,
          title: document.data()[field] as String? ?? 'بدون عنوان',
        ),
      )
      .toList();

  @override
  Future<void> addChurch(String title) {
    return _firestore.collection('Churches').add({'title': title});
  }

  @override
  Future<void> addChapter({required String churchId, required String season}) {
    return _firestore
        .collection('Churches')
        .doc(churchId)
        .collection('Chapters')
        .add({'season': season, 'created_at': FieldValue.serverTimestamp()});
  }

  @override
  Future<void> updateChurch(String churchId, String title) =>
      _firestore.collection('Churches').doc(churchId).update({'title': title});

  @override
  Future<void> deleteChurch(String churchId) =>
      _firestore.collection('Churches').doc(churchId).delete();

  @override
  Future<void> updateChapter({
    required String churchId,
    required String chapterId,
    required String season,
  }) => _firestore
      .collection('Churches')
      .doc(churchId)
      .collection('Chapters')
      .doc(chapterId)
      .update({'season': season});

  @override
  Future<void> deleteChapter({
    required String churchId,
    required String chapterId,
  }) => _firestore
      .collection('Churches')
      .doc(churchId)
      .collection('Chapters')
      .doc(chapterId)
      .delete();
}
