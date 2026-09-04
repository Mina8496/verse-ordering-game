import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aner_astaner/features/exam_settings/domain/entities/exam_setting.dart';
import 'package:aner_astaner/features/exam_settings/presentation/controllers/exam_settings_controller.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get/get.dart';

class AllExamsPage extends StatefulWidget {
  final String? churchId;
  final String? chapterId;

  const AllExamsPage({
    Key? key,
    required this.churchId,
    required this.chapterId,
  }) : super(key: key);

  @override
  State<AllExamsPage> createState() => _AllExamsPageState();
}

class _AllExamsPageState extends State<AllExamsPage> {
  late Future<List<ExamSetting>> _examsFuture;
  final controller = Get.find<ExamSettingsController>();

  @override
  void initState() {
    super.initState();
    _examsFuture = _initAndFetch();
  }

  Future<List<ExamSetting>> _initAndFetch() async {
    await initializeDateFormatting('ar', null);
    return await fetchAllExams();
  }

  Future<List<ExamSetting>> fetchAllExams() {
    if (widget.churchId == null || widget.chapterId == null) {
      return Future.value(const <ExamSetting>[]);
    }
    return controller.fetchAllSettings(
      churchId: widget.churchId!,
      chapterId: widget.chapterId!,
    );
  }

  // ✅ دالة آمنة لتحويل أي قيمة إلى DateTime
  DateTime? toDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is Map && value.containsKey('_seconds')) {
      // في حال كان Timestamp محفوظ كـ Map
      return DateTime.fromMillisecondsSinceEpoch(
        (value['_seconds'] as int) * 1000,
      );
    }
    return null;
  }

  Future<void> deleteExam(
    BuildContext context,
    String examId,
    String settingId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل تريد حذف هذا الامتحان؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (widget.churchId != null && widget.chapterId != null) {
        await controller.deleteSetting(
          churchId: widget.churchId!,
          chapterId: widget.chapterId!,
          settingId: settingId,
        );
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حذف الامتحان بنجاح')));

      setState(() {
        _examsFuture = fetchAllExams();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMMd('ar').add_jm(); // ✅ تنسيق عربي جميل

    return Scaffold(
      backgroundColor: const Color(0xfff4f6f9),
      appBar: AppBar(
        title: const Text(
          '📚 كل الامتحانات',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey.shade600,
        elevation: 3,
      ),
      body: FutureBuilder<List<ExamSetting>>(
        future: _examsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد امتحانات مضافة بعد 🕊️',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final exams = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: exams.length,
            itemBuilder: (context, index) {
              final exam = exams[index];
              final book = exam.bookTitle;
              final chapter = exam.chapterTitle;
              final duration = exam.durationDays.toString();
              final hasTimer = exam.hasTimer;
              final isRepeatable = exam.isRepeatable;

              final createdAt = toDate(exam.createdAt);
              final startDate = toDate(exam.examStart);
              final endDate = toDate(exam.examEnd);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade50, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: const Offset(2, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.indigo.shade100,
                    child: const Icon(Icons.menu_book, color: Colors.indigo),
                  ),
                  title: Text(
                    "$book - $chapter",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("⏳ المدة: $duration يوم"),
                        Text("🔁 قابل للإعادة: ${isRepeatable ? 'نعم' : 'لا'}"),
                        Text("⏱️ مؤقت: ${hasTimer ? 'مفعل' : 'غير مفعل'}"),
                        if (startDate != null)
                          Text(
                            "🚀 بداية الامتحان: ${dateFormat.format(startDate)}",
                            style: const TextStyle(fontSize: 13),
                          ),
                        if (endDate != null)
                          Text(
                            "🏁 نهاية الامتحان: ${dateFormat.format(endDate)}",
                            style: const TextStyle(fontSize: 13),
                          ),
                        if (createdAt != null)
                          Text(
                            "📅 تم الإضافة: ${dateFormat.format(createdAt)}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    tooltip: "حذف الامتحان",
                    onPressed: () =>
                        deleteExam(context, 'nFL11C4v8fPRqIgG0ZAe', exam.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
