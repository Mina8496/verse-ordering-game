import '../../data/repositories/firestore_bible_verse_repository.dart';
import '../../domain/entities/bible_verse.dart';
import '../../domain/repositories/bible_verse_repository.dart';

class BibleVerseController {
  BibleVerseController({BibleVerseRepository? repository})
    : _repository = repository ?? FirestoreBibleVerseRepository();

  final BibleVerseRepository _repository;

  Future<bool> verseExists({
    required String churchId,
    required String chapterId,
    required List<String> words,
  }) => _repository.verseExists(
    churchId: churchId,
    chapterId: chapterId,
    words: words,
  );

  Future<void> addVerse({
    required String churchId,
    required String chapterId,
    required List<String> words,
  }) => _repository.addVerse(
    churchId: churchId,
    chapterId: chapterId,
    words: words,
  );

  Stream<List<BibleVerse>> watchVerses({
    required String churchId,
    required String chapterId,
  }) => _repository.watchVerses(churchId: churchId, chapterId: chapterId);

  Future<void> updateVerse({
    required String churchId,
    required String chapterId,
    required String verseId,
    required List<String> words,
  }) => _repository.updateVerse(
    churchId: churchId,
    chapterId: chapterId,
    verseId: verseId,
    words: words,
  );

  Future<void> deleteVerse({
    required String churchId,
    required String chapterId,
    required String verseId,
  }) => _repository.deleteVerse(
    churchId: churchId,
    chapterId: chapterId,
    verseId: verseId,
  );
}
