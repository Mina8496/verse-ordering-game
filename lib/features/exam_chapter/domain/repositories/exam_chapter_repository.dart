import '../../../chapter/domain/entities/chapter_model.dart';

abstract interface class ExamChapterRepository {
  Stream<List<ChapterModel>> watchChapters({
    required String? churchId,
    required String? chapterId,
    required String? categoryId,
  });

  Future<void> addChapter({
    required String? churchId,
    required String? chapterId,
    required String? categoryId,
    required String title,
  });

  Future<void> deleteChapter({
    required String? churchId,
    required String? chapterId,
    required String? categoryId,
    required String sectionId,
  });
}
