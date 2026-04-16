import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  void _showEditDialog(
    BuildContext context,
    String churchID,
    String chapterID,
    String docId,
    List words,
  ) {
    final TextEditingController controller = TextEditingController(
      text: words.join(' '),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تعديل الآية'),
          content: TextFormField(
            controller: controller,
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
                final newWords = controller.text.trim().split(RegExp(r'\s+'));
                if (newWords.length < 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('يجب إدخال آية صحيحة')),
                  );
                  return;
                }

                await FirebaseFirestore.instance
                    .collection("Churches")
                    .doc(churchID)
                    .collection("Chapters")
                    .doc(chapterID)
                    .collection("Exames")
                    .doc(kFixedExameID)
                    .collection("AyatQuiz")
                    .doc(docId)
                    .update({
                      'words': newWords,
                      'timestamp': FieldValue.serverTimestamp(),
                    });

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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("Churches")
                  .doc(churchID)
                  .collection("Chapters")
                  .doc(chapterID)
                  .collection("Exames")
                  .doc(kFixedExameID)
                  .collection("AyatQuiz")
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("حدث خطأ");
                }
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return Text("لا توجد آيات مضافة بعد.");
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final words = (doc['words'] as List).join(' ');
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
                                doc.id,
                                doc['words'],
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection("Churches")
                                  .doc(churchID)
                                  .collection("Chapters")
                                  .doc(chapterID)
                                  .collection("Exames")
                                  .doc(kFixedExameID)
                                  .collection("AyatQuiz")
                                  .doc(doc.id)
                                  .delete();
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
    final ayatRef = FirebaseFirestore.instance
        .collection("Churches")
        .doc(churchID)
        .collection("Chapters")
        .doc(chapterID)
        .collection("Exames")
        .doc("nFL11C4v8fPRqIgG0ZAe")
        .collection("AyatQuiz")
        .orderBy("timestamp", descending: true);

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
      body: StreamBuilder<QuerySnapshot>(
        stream: ayatRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("لا توجد آيات مضافة بعد"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final wordsList = doc['words'] as List<dynamic>;
              final words = wordsList.join(" ");

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
                            doc.id,
                            wordsList,
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
                            await FirebaseFirestore.instance
                                .collection("Churches")
                                .doc(churchID)
                                .collection("Chapters")
                                .doc(chapterID)
                                .collection("Exames")
                                .doc(kFixedExameID)
                                .collection("AyatQuiz")
                                .doc(doc.id)
                                .delete();
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
