import '../entities/chapter_model.dart';

abstract interface class ChapterRepository {
  Future<List<ChapterModel>> fetchChapters(String categoryId);

  Future<void> addChapter(String categoryId, String title);

  Future<void> deleteChapter(String categoryId, String chapterId);
}
