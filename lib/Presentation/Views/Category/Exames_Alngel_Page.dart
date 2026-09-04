import 'package:aner_astaner/Presentation/Views/Adds_Category/Add_Exames_Alngel_Box.dart';
import 'package:aner_astaner/Presentation/Views/Category/Exames_Alshahat_Page.dart';
import 'package:aner_astaner/features/exam_catalog/domain/entities/catalog_item.dart';
import 'package:aner_astaner/features/exam_catalog/presentation/controllers/exam_catalog_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ExamesAlngelPage extends StatefulWidget {
  static const String kFixedExameID = "nFL11C4v8fPRqIgG0ZAe";

  const ExamesAlngelPage({Key? key, this.ChurchID, this.ChapterID})
    : super(key: key);
  final String? ChurchID;
  final String? ChapterID;

  @override
  State<ExamesAlngelPage> createState() => _ExamesAlngelPageState();
}

class _ExamesAlngelPageState extends State<ExamesAlngelPage> {
  List<CatalogItem> dataExames = [];
  bool isLoading = true;
  final controller = Get.find<ExamCatalogController>();

  getDataExames() async {
    if (widget.ChurchID == null || widget.ChapterID == null) return;
    dataExames = await controller.fetchCategories(
      churchId: widget.ChurchID!,
      chapterId: widget.ChapterID!,
    );

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.ChurchID != null && widget.ChapterID != null) {
      getDataExames();
    } else {
      debugPrint("ChurchID or ChapterID is null!");
    }
  }

  // 🟠 تعديل اسم السؤال
  void editExamName(String docId, String currentTitle) {
    TextEditingController titleController = TextEditingController(
      text: currentTitle,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تعديل اسم السؤال"),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: "الاسم الجديد"),
        ),
        actions: [
          TextButton(
            child: const Text("إلغاء"),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            child: const Text("حفظ"),
            onPressed: () async {
              if (titleController.text.trim().isNotEmpty) {
                await controller.updateCategory(
                  churchId: widget.ChurchID!,
                  chapterId: widget.ChapterID!,
                  categoryId: docId,
                  title: titleController.text.trim(),
                );
                Navigator.pop(ctx);
                getDataExames();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اسئلة الاسفار'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0.h),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                itemCount: dataExames.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2.bitLength,
                  mainAxisExtent: 160.spMax,
                ),
                itemBuilder: (context, i) {
                  final exam = dataExames[i];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ExamesAlshahatPage(
                            AlngelID: exam.id,
                            ChapterID: widget.ChapterID,
                            ChurchID: widget.ChurchID,
                          ),
                        ),
                      );
                    },
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('اختر إجراء'),
                          content: const Text(
                            'هل تريد تعديل الاسم أم حذف السؤال؟',
                          ),
                          actions: [
                            TextButton(
                              child: const Text(
                                'حذف',
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () async {
                                Navigator.pop(ctx);
                                await controller.deleteCategory(
                                  churchId: widget.ChurchID!,
                                  chapterId: widget.ChapterID!,
                                  categoryId: exam.id,
                                );
                                await getDataExames();
                              },
                            ),
                            TextButton(
                              child: const Text(
                                'تعديل',
                                style: TextStyle(color: Colors.blue),
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                editExamName(exam.id, exam.title);
                              },
                            ),
                          ],
                        ),
                      );
                    },

                    child: Card(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            child: Image.asset(
                              "assets/images/Splash_View2.png",
                              height: 100,
                            ),
                          ),
                          Text(exam.title),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AddExamesAlngelBox(
              ChaptersID: widget.ChapterID,
              ChurchID: widget.ChurchID,
              onExameAdded: () {
                getDataExames();
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
