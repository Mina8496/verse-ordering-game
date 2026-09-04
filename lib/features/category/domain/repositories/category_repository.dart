import '../entities/category_model.dart';

abstract interface class CategoryRepository {
  Future<void> addCategory(String title);

  Future<List<CategoryModel>> fetchCategories();

  Future<void> deleteCategory(String categoryId);
}
