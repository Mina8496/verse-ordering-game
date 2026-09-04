import '../../domain/entities/catalog_item.dart';
import '../../domain/repositories/exam_catalog_repository.dart';

class ExamCatalogController {
  ExamCatalogController({required ExamCatalogRepository repository})
    : _repository = repository;

  final ExamCatalogRepository _repository;

  Future<List<CatalogItem>> fetchChaptersByChurch(String churchId) =>
      _repository.fetchChaptersByChurch(churchId: churchId);

  Future<List<CatalogItem>> fetchCategories({
    required String churchId,
    required String chapterId,
  }) => _repository.fetchCategories(churchId: churchId, chapterId: chapterId);

  Future<List<CatalogItem>> fetchChapters({
    required String churchId,
    required String chapterId,
    required String categoryId,
  }) => _repository.fetchChapters(
    churchId: churchId,
    chapterId: chapterId,
    categoryId: categoryId,
  );

  Future<void> addCategory({
    required String churchId,
    required String chapterId,
    required String title,
  }) => _repository.addCategory(
    churchId: churchId,
    chapterId: chapterId,
    title: title,
  );

  Future<void> updateCategory({
    required String churchId,
    required String chapterId,
    required String categoryId,
    required String title,
  }) => _repository.updateCategory(
    churchId: churchId,
    chapterId: chapterId,
    categoryId: categoryId,
    title: title,
  );

  Future<void> deleteCategory({
    required String churchId,
    required String chapterId,
    required String categoryId,
  }) => _repository.deleteCategory(
    churchId: churchId,
    chapterId: chapterId,
    categoryId: categoryId,
  );
}
