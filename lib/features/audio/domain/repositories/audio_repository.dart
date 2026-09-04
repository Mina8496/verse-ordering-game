abstract interface class AudioRepository {
  bool get isPlaying;

  Future<void> initialize();

  Future<void> togglePlayback();

  Future<void> pausePlayback();

  Future<void> resumePlayback();

  Future<void> dispose();
}
