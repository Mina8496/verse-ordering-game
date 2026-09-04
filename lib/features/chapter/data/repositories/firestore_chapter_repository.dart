import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/chapter_model.dart';
import '../../domain/repositories/chapter_repository.dart';

class FirestoreChapterRepository implements ChapterRepository {
  FirestoreChapterRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _chapters(String categoryId) =>
      _firestore.collection('Alangel').doc(categoryId).collection('Alshahat');

  @override
  Future<List<ChapterModel>> fetchChapters(String categoryId) async {
    final snapshot = await _chapters(categoryId).get();
    return snapshot.docs
        .map(
          (document) => ChapterModel(
            id: document.id,
            title: document.data()['title'] as String? ?? '',
          ),
        )
        .toList();
  }

  @override
  Future<void> addChapter(String categoryId, String title) {
    return _chapters(categoryId).add({'title': title});
  }

  @override
  Future<void> deleteChapter(String categoryId, String chapterId) {
    return _chapters(categoryId).doc(chapterId).delete();
  }
}
