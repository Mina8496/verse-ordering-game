import '../entities/question_model.dart';

abstract interface class QuestionRepository {
  Future<QuestionModel?> fetchQuestion({
    required String? churchId,
    required String? chapterId,
    required String? categoryId,
    required String? sectionId,
    required String questionId,
  });

  Stream<List<QuestionModel>> watchQuestions({
    required String? churchId,
    required String? chapterId,
    required String? categoryId,
    required String? sectionId,
  });

  Future<void> addQuestion({
    required String? churchId,
    required String? chapterId,
    required String? categoryId,
    required String? sectionId,
    required String quiz,
    required Map<String, bool> options,
  });

  Future<void> deleteQuestion({
    required String? churchId,
    required String? chapterId,
    required String? categoryId,
    required String? sectionId,
    required String questionId,
  });

  Future<void> updateQuestion({
    required String? churchId,
    required String? chapterId,
    required String? categoryId,
    required String? sectionId,
    required String questionId,
    required String quiz,
    required Map<String, bool> options,
  });
}
