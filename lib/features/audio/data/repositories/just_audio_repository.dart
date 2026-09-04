import 'package:just_audio/just_audio.dart';

import '../../domain/repositories/audio_repository.dart';

class JustAudioRepository implements AudioRepository {
  JustAudioRepository({AudioPlayer? player})
    : _player = player ?? AudioPlayer();

  final AudioPlayer _player;
  bool _isPlaying = false;

  @override
  bool get isPlaying => _isPlaying;

  @override
  Future<void> initialize() async {
    await _player.setAsset('assets/audio/background.mp3');
    await _player.setLoopMode(LoopMode.one);
    await _player.setVolume(0.5);
  }

  @override
  Future<void> togglePlayback() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
    _isPlaying = !_isPlaying;
  }

  @override
  Future<void> pausePlayback() async {
    await _player.pause();
    _isPlaying = false;
  }

  @override
  Future<void> resumePlayback() async {
    await _player.play();
    _isPlaying = true;
  }

  @override
  Future<void> dispose() => _player.dispose();
}
