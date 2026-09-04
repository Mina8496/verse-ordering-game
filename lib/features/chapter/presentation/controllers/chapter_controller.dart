import 'package:get/get.dart';

import '../../data/repositories/firestore_chapter_repository.dart';
import '../../domain/entities/chapter_model.dart';
import '../../domain/repositories/chapter_repository.dart';

class ChapterController extends GetxController {
  ChapterController({required this.categoryId, ChapterRepository? repository})
    : _repository = repository ?? FirestoreChapterRepository();

  final String categoryId;
  final ChapterRepository _repository;
  final RxList<ChapterModel> chapters = <ChapterModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadChapters();
  }

  Future<void> loadChapters() async {
    isLoading.value = true;
    chapters.assignAll(await _repository.fetchChapters(categoryId));
    isLoading.value = false;
  }

  Future<void> addChapter(String title) async {
    await _repository.addChapter(categoryId, title);
    await loadChapters();
  }

  Future<void> deleteChapter(String chapterId) async {
    await _repository.deleteChapter(categoryId, chapterId);
    chapters.removeWhere((chapter) => chapter.id == chapterId);
  }
}
