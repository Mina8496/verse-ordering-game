import 'package:aner_astaner/features/bible_verses/domain/entities/bible_verse.dart';
import 'package:aner_astaner/features/bible_verses/presentation/controllers/bible_verse_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_ayah_dialog.dart'; // استورد الملف السابق

class AyatQuizAdminPage extends StatelessWidget {
  static const String kFixedExameID = "nFL11C4v8fPRqIgG0ZAe";
  final String? churchID;
  final String? chapterID;

  const AyatQuizAdminPage({
    super.key,
    required this.churchID,
    required this.chapterID,
  });

  BibleVerseController get controller => Get.find<BibleVerseController>();

  void _showEditDialog(
    BuildContext context,
    String churchID,
    String chapterID,
    String docId,
    List<String> words,
  ) {
    final TextEditingController textController = TextEditingController(
      text: words.join(' '),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تعديل الآية'),
          content: TextFormField(
            controller: textController,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "أدخل الآية الجديدة",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newWords = textController.text.trim().split(
                  RegExp(r'\s+'),
                );
                if (newWords.length < 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('يجب إدخال آية صحيحة')),
                  );
                  return;
                }

                await this.controller.updateVerse(
                  churchId: churchID,
                  chapterId: chapterID,
                  verseId: docId,
                  words: newWords,
                );

                Navigator.pop(context);
              },
              child: Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  void showAyatDialog(BuildContext context, String churchID, String chapterID) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('الآيات المضافة'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<List<BibleVerse>>(
              stream: controller.watchVerses(
                churchId: churchID,
                chapterId: chapterID,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("حدث خطأ");
                }
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!;
                if (docs.isEmpty) {
                  return Text("لا توجد آيات مضافة بعد.");
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final verse = docs[index];
                    final words = verse.text;
                    return ListTile(
                      title: Text(words, textDirection: TextDirection.rtl),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.orange),
                            onPressed: () {
                              Navigator.pop(context);
                              _showEditDialog(
                                context,
                                churchID,
                                chapterID,
                                verse.id,
                                verse.words,
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await controller.deleteVerse(
                                churchId: churchID,
                                chapterId: chapterID,
                                verseId: verse.id,
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text("إغلاق"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة آيات"),
        // backgroundColor: Colors.teal,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) =>
                AddAyahDialog(churchID: churchID, chapterID: chapterID),
          );
        },
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<BibleVerse>>(
        stream: churchID == null || chapterID == null
            ? const Stream.empty()
            : controller.watchVerses(
                churchId: churchID!,
                chapterId: chapterID!,
              ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("لا توجد آيات مضافة بعد"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final verse = snapshot.data![index];
              final words = verse.text;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(words, textDirection: TextDirection.rtl),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.orange),
                        onPressed: () {
                          _showEditDialog(
                            context,
                            churchID!,
                            chapterID!,
                            verse.id,
                            verse.words,
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("تأكيد الحذف"),
                              content: Text("هل تريد حذف هذه الآية؟"),
                              actions: [
                                TextButton(
                                  child: Text("إلغاء"),
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                ),
                                TextButton(
                                  child: Text(
                                    "حذف",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await controller.deleteVerse(
                              churchId: churchID!,
                              chapterId: chapterID!,
                              verseId: verse.id,
                            );
                          }
                        },
                      ),
                    ],
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
