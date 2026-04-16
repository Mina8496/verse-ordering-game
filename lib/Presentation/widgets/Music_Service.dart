import 'package:audioplayers/audioplayers.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;

  late AudioPlayer _player;
  bool _isPlaying = false;

  MusicService._internal() {
    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.loop); // loop mode
  }

  Future<void> startMusic() async {
    if (!_isPlaying) {
      await _player.play(AssetSource('background.mp3'));
      _isPlaying = true;
    }
  }

  Future<void> pauseMusic() async {
    await _player.pause();
    _isPlaying = false;
  }

  Future<void> resumeMusic() async {
    if (!_isPlaying) {
      await _player.resume();
      _isPlaying = true;
    }
  }

  Future<void> stopMusic() async {
    await _player.stop();
    _isPlaying = false;
  }
}
