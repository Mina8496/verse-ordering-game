import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/bible_verse.dart';
import '../../domain/repositories/bible_verse_repository.dart';

class FirestoreBibleVerseRepository implements BibleVerseRepository {
  FirestoreBibleVerseRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const examId = 'nFL11C4v8fPRqIgG0ZAe';
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _verses({
    required String churchId,
    required String chapterId,
  }) => _firestore
      .collection('Churches')
      .doc(churchId)
      .collection('Chapters')
      .doc(chapterId)
      .collection('Exames')
      .doc(examId)
      .collection('AyatQuiz');

  @override
  Future<bool> verseExists({
    required String churchId,
    required String chapterId,
    required List<String> words,
  }) async {
    final snapshot = await _verses(
      churchId: churchId,
      chapterId: chapterId,
    ).where('words', isEqualTo: words).limit(1).get();
    return snapshot.docs.isNotEmpty;
  }

  @override
  Future<void> addVerse({
    required String churchId,
    required String chapterId,
    required List<String> words,
  }) => _verses(
    churchId: churchId,
    chapterId: chapterId,
  ).add({'words': words, 'timestamp': FieldValue.serverTimestamp()});

  @override
  Stream<List<BibleVerse>> watchVerses({
    required String churchId,
    required String chapterId,
  }) => _verses(churchId: churchId, chapterId: chapterId)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (document) => BibleVerse(
                id: document.id,
                words: (document.data()['words'] as List<dynamic>? ?? [])
                    .map((word) => word.toString())
                    .toList(),
              ),
            )
            .toList(),
      );

  @override
  Future<void> updateVerse({
    required String churchId,
    required String chapterId,
    required String verseId,
    required List<String> words,
  }) => _verses(churchId: churchId, chapterId: chapterId).doc(verseId).update({
    'words': words,
    'timestamp': FieldValue.serverTimestamp(),
  });

  @override
  Future<void> deleteVerse({
    required String churchId,
    required String chapterId,
    required String verseId,
  }) => _verses(churchId: churchId, chapterId: chapterId).doc(verseId).delete();
}
