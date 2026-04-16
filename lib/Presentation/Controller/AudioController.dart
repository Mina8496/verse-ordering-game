import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:just_audio/just_audio.dart';

class AudioController extends GetxController {
  final player = AudioPlayer();
  var isPlaying = false.obs;

  @override
  void onInit() {
    super.onInit();
    initMusic();
  }

  Future<void> initMusic() async {
    await player.setAsset('assets/audio/background.mp3');
    await player.setLoopMode(LoopMode.one); // 🔁 يلف تلقائي
    player.setVolume(0.5);
    // لا تعمل Loop هنا لو انت عايز الزر يوقف فورًا
    // player.setLoopMode(LoopMode.all);

    player.setVolume(0.5);
  }

  void toggleMusic() async {
    if (isPlaying.value) {
      await player.pause(); // مهم
      isPlaying.value = false;
    } else {
      await player.play(); // يبدأ
      isPlaying.value = true;
    }
  }
}
