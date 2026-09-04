import 'package:aner_astaner/features/user/data/repositories/firestore_user_repository.dart';
import 'package:aner_astaner/features/user/data/services/profile_image_service.dart';
import 'package:aner_astaner/features/user/domain/repositories/profile_image_uploader.dart';
import 'package:aner_astaner/features/user/domain/repositories/user_repository.dart';
import 'package:get/get.dart';

import '../../features/auth/data/services/auth_service.dart';
import '../../features/audio/presentation/controllers/audio_controller.dart';
import '../../features/bible_verses/presentation/controllers/bible_verse_controller.dart';
import '../../features/authorization/data/repositories/firestore_authorization_repository.dart';
import '../../features/authorization/domain/repositories/authorization_repository.dart';
import '../../features/category/presentation/controllers/category_controller.dart';
import '../../features/exam/presentation/controllers/exam_controller.dart';
import '../../features/exam_catalog/presentation/controllers/exam_catalog_controller.dart';
import '../../features/exam_settings/presentation/controllers/exam_settings_controller.dart';
import '../../features/question/presentation/controllers/question_controller.dart';
import '../../features/organization/presentation/controllers/organization_controller.dart';
import '../../features/user/presentation/controllers/user_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(AuthService.new, fenix: true);
    Get.lazyPut<AuthorizationRepository>(
      FirestoreAuthorizationRepository.new,
      fenix: true,
    );
    Get.lazyPut<CategoryController>(CategoryController.new, fenix: true);
    Get.lazyPut<AudioController>(AudioController.new, fenix: true);
    Get.lazyPut<BibleVerseController>(BibleVerseController.new, fenix: true);
    Get.lazyPut<ExamController>(ExamController.new, fenix: true);
    Get.lazyPut<ExamCatalogController>(ExamCatalogController.new, fenix: true);
    Get.lazyPut<ExamSettingsController>(
      ExamSettingsController.new,
      fenix: true,
    );
    Get.lazyPut<QuestionController>(QuestionController.new, fenix: true);
    Get.lazyPut<OrganizationController>(
      OrganizationController.new,
      fenix: true,
    );
    Get.lazyPut<UserRepository>(FirestoreUserRepository.new, fenix: true);
    Get.lazyPut<UserController>(
      () => UserController(repository: Get.find<UserRepository>()),
      fenix: true,
    );
    Get.lazyPut<ProfileImageUploader>(ProfileImageService.new, fenix: true);
  }
}
