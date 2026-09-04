class BibleVerse {
  const BibleVerse({required this.id, required this.words});

  final String id;
  final List<String> words;

  String get text => words.join(' ');
}
