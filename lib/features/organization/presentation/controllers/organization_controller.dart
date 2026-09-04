import '../../data/repositories/firestore_organization_repository.dart';
import '../../domain/entities/organization_item.dart';
import '../../domain/repositories/organization_repository.dart';

class OrganizationController {
  OrganizationController({OrganizationRepository? repository})
    : _repository = repository ?? FirestoreOrganizationRepository();

  final OrganizationRepository _repository;

  Future<List<OrganizationItem>> fetchAllChurches() =>
      _repository.fetchAllChurches();

  Future<List<OrganizationItem>> fetchAllChapters(String churchId) =>
      _repository.fetchAllChapters(churchId);

  Future<List<OrganizationItem>> fetchChurches({
    required String? role,
    required String? churchId,
  }) => _repository.fetchChurches(role: role, churchId: churchId);

  Future<List<OrganizationItem>> fetchChapters({
    required String? churchId,
    required String? role,
    required String? selectedChapterId,
  }) => _repository.fetchChapters(
    churchId: churchId,
    role: role,
    selectedChapterId: selectedChapterId,
  );

  Future<void> addChurch(String title) => _repository.addChurch(title);

  Future<void> addChapter({required String churchId, required String season}) =>
      _repository.addChapter(churchId: churchId, season: season);

  Future<void> updateChurch(String churchId, String title) =>
      _repository.updateChurch(churchId, title);

  Future<void> deleteChurch(String churchId) =>
      _repository.deleteChurch(churchId);

  Future<void> updateChapter({
    required String churchId,
    required String chapterId,
    required String season,
  }) => _repository.updateChapter(
    churchId: churchId,
    chapterId: chapterId,
    season: season,
  );

  Future<void> deleteChapter({
    required String churchId,
    required String chapterId,
  }) => _repository.deleteChapter(churchId: churchId, chapterId: chapterId);
}
