import '../../../chapter/domain/entities/chapter_model.dart';
import '../../data/repositories/firestore_exam_chapter_repository.dart';
import '../../domain/repositories/exam_chapter_repository.dart';

class ExamChapterController {
  ExamChapterController({
    required this.churchId,
    required this.chapterId,
    required this.categoryId,
    ExamChapterRepository? repository,
  }) : _repository = repository ?? FirestoreExamChapterRepository();

  final String? churchId;
  final String? chapterId;
  final String? categoryId;
  final ExamChapterRepository _repository;

  Stream<List<ChapterModel>> watchChapters() => _repository.watchChapters(
    churchId: churchId,
    chapterId: chapterId,
    categoryId: categoryId,
  );

  Future<void> addChapter(String title) => _repository.addChapter(
    churchId: churchId,
    chapterId: chapterId,
    categoryId: categoryId,
    title: title,
  );

  Future<void> deleteChapter(String sectionId) => _repository.deleteChapter(
    churchId: churchId,
    chapterId: chapterId,
    categoryId: categoryId,
    sectionId: sectionId,
  );
}
