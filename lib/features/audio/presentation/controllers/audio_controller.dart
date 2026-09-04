import 'package:get/get.dart';

import '../../data/repositories/just_audio_repository.dart';
import '../../domain/repositories/audio_repository.dart';

class AudioController extends GetxController {
  AudioController({AudioRepository? repository})
    : _repository = repository ?? JustAudioRepository();

  final AudioRepository _repository;
  final RxBool isPlaying = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    await _repository.initialize();
    isPlaying.value = _repository.isPlaying;
  }

  Future<void> toggleMusic() async {
    await _repository.togglePlayback();
    isPlaying.value = _repository.isPlaying;
  }

  Future<void> pauseMusic() async {
    await _repository.pausePlayback();
    isPlaying.value = false;
  }

  Future<void> resumeMusic() async {
    await _repository.resumePlayback();
    isPlaying.value = true;
  }

  @override
  void onClose() {
    _repository.dispose();
    super.onClose();
  }
}
