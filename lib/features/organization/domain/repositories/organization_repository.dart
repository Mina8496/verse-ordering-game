import '../entities/organization_item.dart';

abstract interface class OrganizationRepository {
  Future<List<OrganizationItem>> fetchAllChurches();

  Future<List<OrganizationItem>> fetchAllChapters(String churchId);

  Future<List<OrganizationItem>> fetchChurches({
    required String? role,
    required String? churchId,
  });

  Future<List<OrganizationItem>> fetchChapters({
    required String? churchId,
    required String? role,
    required String? selectedChapterId,
  });

  Future<void> addChurch(String title);

  Future<void> addChapter({required String churchId, required String season});

  Future<void> updateChurch(String churchId, String title);

  Future<void> deleteChurch(String churchId);

  Future<void> updateChapter({
    required String churchId,
    required String chapterId,
    required String season,
  });

  Future<void> deleteChapter({
    required String churchId,
    required String chapterId,
  });
}
