import 'package:get/get.dart';

import '../../data/repositories/firestore_category_repository.dart';
import '../../domain/entities/category_model.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryController extends GetxController {
  CategoryController({CategoryRepository? repository})
    : _repository = repository ?? FirestoreCategoryRepository();

  final CategoryRepository _repository;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    isLoading.value = true;
    categories.assignAll(await _repository.fetchCategories());
    isLoading.value = false;
  }

  Future<void> addCategory(String title) => _repository.addCategory(title);

  Future<void> deleteCategory(String categoryId) async {
    await _repository.deleteCategory(categoryId);
    categories.removeWhere((category) => category.id == categoryId);
  }
}
