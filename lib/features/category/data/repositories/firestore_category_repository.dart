import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/category_model.dart';
import '../../domain/repositories/category_repository.dart';

class FirestoreCategoryRepository implements CategoryRepository {
  FirestoreCategoryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _categories =>
      _firestore.collection('Alangel');

  @override
  Future<void> addCategory(String title) {
    return _categories.add({'title': title});
  }

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    final snapshot = await _categories.get();
    return snapshot.docs
        .map(
          (document) => CategoryModel(
            id: document.id,
            title: document.data()['title'] as String? ?? '',
          ),
        )
        .toList();
  }

  @override
  Future<void> deleteCategory(String categoryId) {
    return _categories.doc(categoryId).delete();
  }
}
