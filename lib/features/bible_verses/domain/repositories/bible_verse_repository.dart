import '../entities/bible_verse.dart';

abstract interface class BibleVerseRepository {
  Future<bool> verseExists({
    required String churchId,
    required String chapterId,
    required List<String> words,
  });

  Future<void> addVerse({
    required String churchId,
    required String chapterId,
    required List<String> words,
  });

  Stream<List<BibleVerse>> watchVerses({
    required String churchId,
    required String chapterId,
  });

  Future<void> updateVerse({
    required String churchId,
    required String chapterId,
    required String verseId,
    required List<String> words,
  });

  Future<void> deleteVerse({
    required String churchId,
    required String chapterId,
    required String verseId,
  });
}
