import 'package:aner_astaner/Presentation/Views/Adds_Category/addAlshahatPage.dart';
import 'package:aner_astaner/features/chapter/presentation/controllers/chapter_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';

class AlshahatPage extends StatefulWidget {
  final String AlshahatID;

  const AlshahatPage({super.key, required this.AlshahatID});

  @override
  State<AlshahatPage> createState() => _AlshahatPageState();
}

class _AlshahatPageState extends State<AlshahatPage> {
  late final ChapterController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      ChapterController(categoryId: widget.AlshahatID),
      tag: widget.AlshahatID,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأصحاحات'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => ZoomDrawer.of(context)!.toggle(),
          icon: const Icon(Icons.menu),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Obx(
          () => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  itemCount: controller.chapters.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    // mainAxisExtent: 160,
                  ),
                  itemBuilder: (context, i) {
                    final chapter = controller.chapters[i];
                    return InkWell(
                      onTap: () {
                        // Navigator.of(context).push(MaterialPageRoute(
                        //     builder: (context) => QusstionPage(
                        //           AlshahatID: widget.AlshahatID,
                        //           QusstionID: data[i].id,
                        //         ))); //QuestionsPage

                        // ViewQuizPage(
                        //       categoryid: data[i].id,
                        //     )));
                      },
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('تأكيد الحذف'),
                            content: const Text(
                              'هل أنت متأكد من حذف هذا الأصحاح؟',
                            ),
                            actions: [
                              TextButton(
                                child: const Text('إلغاء'),
                                onPressed: () => Navigator.pop(context),
                              ),
                              TextButton(
                                child: const Text('حذف'),
                                onPressed: () async {
                                  await controller.deleteChapter(chapter.id);
                                  Navigator.pop(context);
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
                                "assets/images/alshat.jpeg",
                                height: 100,
                              ),
                            ),
                            Text(chapter.title),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  addAlshahatPage(addAlshahat: widget.AlshahatID),
            ),
          ); //addAlshahatPage
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
