import 'package:aner_astaner/Presentation/Views/Adds_Category/Add_Qusstion_page.dart';
import 'package:aner_astaner/Presentation/Views/Category/Exames_Edit_Questions_Page.dart';
import 'package:flutter/material.dart';
import 'package:aner_astaner/features/question/presentation/controllers/question_controller.dart';
import 'package:get/get.dart';

class ExamesQuestionsPage extends StatefulWidget {
  const ExamesQuestionsPage({
    Key? key,
    this.ChurchID,
    this.ChapterID,
    this.AlngelID,
    this.AlshahatID,
  }) : super(key: key);

  static const String kFixedExameID = "nFL11C4v8fPRqIgG0ZAe";
  final String? ChurchID;
  final String? ChapterID;
  final String? AlngelID;
  final String? AlshahatID;

  @override
  State<ExamesQuestionsPage> createState() => _ExamesQuestionsPageState();
}

class _ExamesQuestionsPageState extends State<ExamesQuestionsPage> {
  void _deleteQuestion(BuildContext context, String docId) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا السؤال؟'),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed) {
      await Get.find<QuestionController>().deleteQuestion(
        churchId: widget.ChurchID,
        chapterId: widget.ChapterID,
        categoryId: widget.AlngelID,
        sectionId: widget.AlshahatID,
        questionId: docId,
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حذف السؤال')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الأسئلة')),
      body: StreamBuilder(
        stream: Get.find<QuestionController>().watchQuestions(
          churchId: widget.ChurchID,
          chapterId: widget.ChapterID,
          categoryId: widget.AlngelID,
          sectionId: widget.AlshahatID,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text('حدث خطأ أثناء التحميل'));
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          final questions = snapshot.data!;

          if (questions.isEmpty) {
            return const Center(child: Text('لا توجد أسئلة حتى الآن'));
          }

          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final doc = questions[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(doc.quiz),
                  subtitle: Text('عدد الخيارات: ${doc.optionsCount}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'تعديل',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExamesEditQuestionsPage(
                                questionId: doc.id,
                                AlngelID: widget.AlngelID,
                                AlshahatID: widget.AlshahatID,
                                ChapterID: widget.ChapterID,
                                ChurchID: widget.ChurchID,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'حذف',
                        onPressed: () => _deleteQuestion(context, doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => addQusstionPage(
                AlngelID: widget.AlngelID,
                AlshahatID: widget.AlshahatID,
                ChapterID: widget.ChapterID,
                ChurchID: widget.ChurchID,
              ),
            ),
          );
        },
        tooltip: 'إضافة سؤال جديد',
        child: const Icon(Icons.add),
      ),
    );
  }
}
