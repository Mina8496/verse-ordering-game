import 'package:cloud_firestore/cloud_firestore.dart';

class ExamSetting {
  const ExamSetting({
    this.id = '',
    required this.bookTitle,
    required this.chapterTitle,
    required this.durationDays,
    required this.isRepeatable,
    required this.hasTimer,
    required this.examStart,
    required this.examEnd,
    this.createdAt,
  });

  final String id;
  final String bookTitle;
  final String chapterTitle;
  final int durationDays;
  final bool isRepeatable;
  final bool hasTimer;
  final Timestamp? examStart;
  final Timestamp? examEnd;
  final Timestamp? createdAt;

  factory ExamSetting.fromMap(Map<String, dynamic> data) {
    return ExamSetting(
      id: data['id'] as String? ?? '',
      bookTitle: data['bookTitle'] as String? ?? 'غير محدد',
      chapterTitle: data['chapterTitle'] as String? ?? 'غير محدد',
      durationDays: (data['durationDays'] as num?)?.toInt() ?? 0,
      isRepeatable: data['isRepeatable'] == true,
      hasTimer: data['hasTimer'] == true,
      examStart: data['examStart'] as Timestamp?,
      examEnd: data['examEnd'] as Timestamp?,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  bool isAvailableOn(DateTime date) {
    if (examStart == null || examEnd == null) return false;

    final start = examStart!.toDate();
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = startDate.add(Duration(days: durationDays));
    final dateOnly = DateTime(date.year, date.month, date.day);

    return !dateOnly.isBefore(startDate) && dateOnly.isBefore(endDate);
  }
}
