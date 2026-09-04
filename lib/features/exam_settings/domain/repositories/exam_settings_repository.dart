import '../entities/exam_selection.dart';
import '../entities/exam_setting.dart';

abstract interface class ExamSettingsRepository {
  Future<ExamSelection?> fetchCurrentSelection();

  Future<List<ExamSetting>> fetchSettings({required String chapterId});

  Future<List<ExamSetting>> fetchAllSettings({
    required String churchId,
    required String chapterId,
  });

  Future<void> deleteSetting({
    required String churchId,
    required String chapterId,
    required String settingId,
  });
}
