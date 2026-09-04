import '../../data/repositories/firestore_question_repository.dart';
import '../../domain/entities/question_model.dart';
import '../../domain/repositories/question_repository.dart';

class QuestionController {
  QuestionController({QuestionRepository? repository})
    : _repository = repository ?? FirestoreQuestionRepository();

  final QuestionRepository _repository;

  Future<QuestionModel?> fetchQuestion({
    required String? churchId,
    required String? chapterId,
    required String? categoryId,
    required String? sectionId,
    required String questionId,
  }) => _repository.fetchQuestion(
    churchId: churchId,
    chapterId: chapterId,
    categoryId: categoryId,
    sectionId: sectionId,
    questionId: questionId,
  );

  Stream<List<QuestionModel>> watchQuestions({
    required String? churchId,
    required String? chapterId,
    required String? categoryId,
    required String? sectionId,
  }) => _repository.watchQuestions(
    churchId: churchId,
    chapterId: chapterId,
    categoryId: categoryId,
    sectionId: sectionId,
  );

  Future<void> addQuestion({
    required String? churchId,
    required String? chapterId,
    required String? categoryId,
    required String? sectionId,
    required String quiz,
    required Map<String, bool> options,
  }) => _repository.addQuestion(
    churchId: churchId,
    chapterId: chapterId,
    categoryId: categoryId,
    sectionId: sectionId,
    quiz: quiz,
    options: options,
  );

  Future<void> deleteQuestion({
    required String? churchId,
    required String? chapterId,
    required String? categoryId,
    required String? sectionId,
    required String questionId,
  }) => _repository.deleteQuestion(
    churchId: churchId,
    chapterId: chapterId,
    categoryId: categoryId,
    sectionId: sectionId,
    questionId: questionId,
  );

  Future<void> updateQuestion({
    required String? churchId,
    required String? chapterId,
    required String? categoryId,
    required String? sectionId,
    required String questionId,
    required String quiz,
    required Map<String, bool> options,
  }) => _repository.updateQuestion(
    churchId: churchId,
    chapterId: chapterId,
    categoryId: categoryId,
    sectionId: sectionId,
    questionId: questionId,
    quiz: quiz,
    options: options,
  );
}
