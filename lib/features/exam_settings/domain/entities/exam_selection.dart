class ExamSelection {
  const ExamSelection({
    this.bookId,
    this.chapterId,
    this.durationDays,
    this.isRepeatable,
    this.hasTimer,
    this.bookTitle,
    this.chapterTitle,
  });

  final String? bookId;
  final String? chapterId;
  final int? durationDays;
  final bool? isRepeatable;
  final bool? hasTimer;
  final String? bookTitle;
  final String? chapterTitle;

  factory ExamSelection.fromMap(Map<String, dynamic> data) {
    return ExamSelection(
      bookId: data['bookId'] as String?,
      chapterId: data['chapterId'] as String?,
      durationDays: (data['durationDays'] as num?)?.toInt(),
      isRepeatable: data['isRepeatable'] as bool?,
      hasTimer: data['hasTimer'] as bool?,
      bookTitle: data['bookTitle'] as String?,
      chapterTitle: data['chapterTitle'] as String?,
    );
  }
}
