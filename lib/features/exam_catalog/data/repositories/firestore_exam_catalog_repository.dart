import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/catalog_item.dart';
import '../../domain/repositories/exam_catalog_repository.dart';

class FirestoreExamCatalogRepository implements ExamCatalogRepository {
  FirestoreExamCatalogRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const examId = 'nFL11C4v8fPRqIgG0ZAe';
  final FirebaseFirestore _firestore;

  @override
  Future<List<CatalogItem>> fetchChaptersByChurch({
    required String churchId,
  }) async {
    final snapshot = await _firestore
        .collection('Churches')
        .doc(churchId)
        .collection('Chapters')
        .get();
    return _items(snapshot, (data) => data['season']);
  }

  @override
  Future<List<CatalogItem>> fetchCategories({
    required String churchId,
    required String chapterId,
  }) async {
    final snapshot = await _firestore
        .collection('Churches')
        .doc(churchId)
        .collection('Chapters')
        .doc(chapterId)
        .collection('Exames')
        .doc(examId)
        .collection('Alangel')
        .get();
    return _items(snapshot, (data) => data['title']);
  }

  @override
  Future<List<CatalogItem>> fetchChapters({
    required String churchId,
    required String chapterId,
    required String categoryId,
  }) async {
    final snapshot = await _firestore
        .collection('Churches')
        .doc(churchId)
        .collection('Chapters')
        .doc(chapterId)
        .collection('Exames')
        .doc(examId)
        .collection('Alangel')
        .doc(categoryId)
        .collection('Alshahat')
        .get();
    return _items(snapshot, (data) => data['title']);
  }

  List<CatalogItem> _items(
    QuerySnapshot<Map<String, dynamic>> snapshot,
    Object? Function(Map<String, dynamic>) titleSelector,
  ) {
    return snapshot.docs
        .map(
          (document) => CatalogItem(
            id: document.id,
            title: titleSelector(document.data()) as String? ?? 'بدون عنوان',
          ),
        )
        .toList();
  }

  CollectionReference<Map<String, dynamic>> _categories({
    required String churchId,
    required String chapterId,
  }) => _firestore
      .collection('Churches')
      .doc(churchId)
      .collection('Chapters')
      .doc(chapterId)
      .collection('Exames')
      .doc(examId)
      .collection('Alangel');

  @override
  Future<void> addCategory({
    required String churchId,
    required String chapterId,
    required String title,
  }) => _categories(
    churchId: churchId,
    chapterId: chapterId,
  ).add({'title': title, 'created_at': FieldValue.serverTimestamp()});

  @override
  Future<void> updateCategory({
    required String churchId,
    required String chapterId,
    required String categoryId,
    required String title,
  }) => _categories(
    churchId: churchId,
    chapterId: chapterId,
  ).doc(categoryId).update({'title': title});

  @override
  Future<void> deleteCategory({
    required String churchId,
    required String chapterId,
    required String categoryId,
  }) => _categories(
    churchId: churchId,
    chapterId: chapterId,
  ).doc(categoryId).delete();
}
