import 'package:aner_astaner/Presentation/Views/Adds_Category/Add_Exames_Alshahat_Box.dart';
import 'package:aner_astaner/Presentation/Views/Category/Exames_Questions_Page.dart';
import 'package:aner_astaner/features/exam_chapter/presentation/controllers/exam_chapter_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ExamesAlshahatPage extends StatefulWidget {
  static const String kFixedExameID = "nFL11C4v8fPRqIgG0ZAe";

  const ExamesAlshahatPage({
    Key? key,
    this.ChurchID,
    this.ChapterID,
    this.AlngelID,
  }) : super(key: key);
  final String? ChurchID;
  final String? ChapterID;
  final String? AlngelID;
  // final String ExameID = "nFL11C4v8fPRqIgG0ZAe";

  @override
  State<ExamesAlshahatPage> createState() => _ExamesAlshahatPageState();
}

class _ExamesAlshahatPageState extends State<ExamesAlshahatPage> {
  late final ExamChapterController controller;
  late final String controllerTag;

  @override
  void initState() {
    super.initState();
    controllerTag = '${widget.ChurchID}_${widget.ChapterID}_${widget.AlngelID}';
    controller = Get.put(
      ExamChapterController(
        churchId: widget.ChurchID,
        chapterId: widget.ChapterID,
        categoryId: widget.AlngelID,
      ),
      tag: controllerTag,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اسئلة الإصحاحات'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0.h),
        child: StreamBuilder(
          stream: controller.watchChapters(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('حدث خطأ أثناء التحميل'));
            }

            final chapters = snapshot.data ?? const [];
            return GridView.builder(
              itemCount: chapters.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2.bitLength,
                mainAxisExtent: 160.spMax,
              ),
              itemBuilder: (context, i) {
                final chapter = chapters[i];
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ExamesQuestionsPage(
                          AlshahatID: chapter.id,
                          AlngelID: widget.AlngelID,
                          ChapterID: widget.ChapterID,
                          ChurchID: widget.ChurchID,
                        ),
                      ),
                    );

                    // ViewQuizPage(
                    //       categoryid: data[i].id,
                    //     )));
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('تأكيد الحذف'),
                        content: const Text('هل أنت متأكد من حذف هذا الإصحاح؟'),
                        actions: [
                          TextButton(
                            child: const Text('إلغاء'),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                          TextButton(
                            child: const Text(
                              'حذف',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await controller.deleteChapter(chapter.id);
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
                          padding: EdgeInsets.all(15.dg),
                          child: Image.asset(
                            "assets/images/Splash_View2.png",
                            height: 100.h,
                          ),
                        ),
                        Text(chapter.title),
                      ],
                    ),
                  ),
                );
              },
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
            builder: (ctx) => AddExamesAlshahatBox(
              ChaptersID: widget.ChapterID,
              ChurchID: widget.ChurchID,
              AlngelID: widget.AlngelID,
              controllerTag: controllerTag,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
