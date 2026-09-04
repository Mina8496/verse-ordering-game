import '../entities/catalog_item.dart';

abstract interface class ExamCatalogRepository {
  Future<List<CatalogItem>> fetchChaptersByChurch({required String churchId});

  Future<List<CatalogItem>> fetchCategories({
    required String churchId,
    required String chapterId,
  });

  Future<List<CatalogItem>> fetchChapters({
    required String churchId,
    required String chapterId,
    required String categoryId,
  });

  Future<void> addCategory({
    required String churchId,
    required String chapterId,
    required String title,
  });

  Future<void> updateCategory({
    required String churchId,
    required String chapterId,
    required String categoryId,
    required String title,
  });

  Future<void> deleteCategory({
    required String churchId,
    required String chapterId,
    required String categoryId,
  });
}
