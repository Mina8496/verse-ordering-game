import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/question_model.dart';
import '../../domain/repositories/question_repository.dart';

class FirestoreQuestionRepository implements QuestionRepository {
  FirestoreQuestionRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const examId = 'nFL11C4v8fPRqIgG0ZAe';
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>? _questions({
    required String? churchId,
    required String? chapterId,
    required String? categoryId,
    required String? sectionId,
  }) {
    if ([churchId, chapterId, categoryId, sectionId].any((id) => id == null)) {
      return null;
    }

    return _firestore
        .collection('Churches')
        .doc(churchId)
        .collection('Chapters')
        .doc(chapterId)
        .collection('Exames')
        .doc(examId)
        .collection('Alangel')
        .doc(categoryId)
        .collection('Alshahat')
        .doc(sectionId)
        .collection('Qusstions');
  }

  @override
  Future<QuestionModel?> fetchQuestion({
    required String? churchId,
    required String? chapterId,
    required String? categoryId,
    required String? sectionId,
    required String questionId,
  }) async {
    final questions = _questions(
      churchId: churchId,
      chapterId: chapterId,
      categoryId: categoryId,
      sectionId: sectionId,
    );
    if (questions == null) return null;

    final document = await questions.doc(questionId).get();
    if (!document.exists) return null;
    final data = document.data()!;
    final options = (data['options'] as Map<String, dynamic>? ?? {}).map(
      (key, value) => MapEntry(key, value == true),
    );
    return QuestionModel(
      id: document.id,
      quiz: data['Quiz'] as String? ?? '',
      optionsCount: options.length,
      options: options,
    );
  }

  @override
  Stream<List<QuestionModel>> watchQuestions({
    required String? churchId,
    required String? chapterId,
    required String? categoryId,
    required String? sectionId,
  }) {
    final questions = _questions(
      churchId: churchId,
      chapterId: chapterId,
      categoryId: categoryId,
      sectionId: sectionId,
    );
    if (questions == null) return Stream.value(const <QuestionModel>[]);

    return questions.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (document) => QuestionModel(
              id: document.id,
              quiz: document.data()['Quiz'] as String? ?? 'بدون عنوان',
              optionsCount:
                  (document.data()['options'] as Map<String, dynamic>?)
                      ?.length ??
                  0,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<void> addQuestion({
    required String? churchId,
    required String? chapterId,
    required String? categoryId,
    required String? sectionId,
    required String quiz,
    required Map<String, bool> options,
  }) async {
    final questions = _questions(
      churchId: churchId,
      chapterId: chapterId,
      categoryId: categoryId,
      sectionId: sectionId,
    );
    if (questions == null) throw StateError('بيانات مسار السؤال غير مكتملة');

    await questions.add({'Quiz': quiz, 'options': options});
  }

  @override
  Future<void> deleteQuestion({
    required String? churchId,
    required String? chapterId,
    required String? categoryId,
    required String? sectionId,
    required String questionId,
  }) async {
    final questions = _questions(
      churchId: churchId,
      chapterId: chapterId,
      categoryId: categoryId,
      sectionId: sectionId,
    );
    if (questions == null) throw StateError('بيانات مسار السؤال غير مكتملة');

    await questions.doc(questionId).delete();
  }

  @override
  Future<void> updateQuestion({
    required String? churchId,
    required String? chapterId,
    required String? categoryId,
    required String? sectionId,
    required String questionId,
    required String quiz,
    required Map<String, bool> options,
  }) async {
    final questions = _questions(
      churchId: churchId,
      chapterId: chapterId,
      categoryId: categoryId,
      sectionId: sectionId,
    );
    if (questions == null) throw StateError('بيانات مسار السؤال غير مكتملة');

    await questions.doc(questionId).update({'Quiz': quiz, 'options': options});
  }
}
