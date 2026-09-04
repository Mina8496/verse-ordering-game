import '../../data/repositories/firestore_exam_settings_repository.dart';
import '../../domain/entities/exam_selection.dart';
import '../../domain/entities/exam_setting.dart';
import '../../domain/repositories/exam_settings_repository.dart';

class ExamSettingsController {
  ExamSettingsController({ExamSettingsRepository? repository})
    : _repository = repository ?? FirestoreExamSettingsRepository();

  final ExamSettingsRepository _repository;

  Future<ExamSelection?> fetchCurrentSelection() =>
      _repository.fetchCurrentSelection();

  Future<List<ExamSetting>> fetchSettings(String chapterId) =>
      _repository.fetchSettings(chapterId: chapterId);

  Future<List<ExamSetting>> fetchAllSettings({
    required String churchId,
    required String chapterId,
  }) => _repository.fetchAllSettings(churchId: churchId, chapterId: chapterId);

  Future<void> deleteSetting({
    required String churchId,
    required String chapterId,
    required String settingId,
  }) => _repository.deleteSetting(
    churchId: churchId,
    chapterId: chapterId,
    settingId: settingId,
  );
}
