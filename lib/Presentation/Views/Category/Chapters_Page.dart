import 'package:aner_astaner/Presentation/Views/Adds_Category/Add_Chapters_Box.dart';
import 'package:aner_astaner/Presentation/Views/Category/Room_Page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChaptersPage extends StatefulWidget {
  final String? ChurchID;

  const ChaptersPage({Key? key, this.ChurchID}) : super(key: key);

  @override
  State<ChaptersPage> createState() => _ChaptersPageState();
}

class _ChaptersPageState extends State<ChaptersPage> {
  List<QueryDocumentSnapshot> chapters = [];
  bool isLoading = true;
  String role = "";
  String? chapterId;

  @override
  void initState() {
    super.initState();
    fetchChapters();
  }

  Future<void> fetchChapters() async {
    setState(() => isLoading = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final userDoc =
    await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (!userDoc.exists) {
      setState(() => isLoading = false);
      return;
    }

    final userData = userDoc.data()!;
    role = userData['role'];
    chapterId = userData['ChapterID'];

    QuerySnapshot snapshot;

    if (role == 'SuperAdmin') {
      snapshot = await FirebaseFirestore.instance
          .collection("Churches")
          .doc(widget.ChurchID)
          .collection("Chapters")
          .get();
    } else if (role == 'Admin' && chapterId != null) {
      snapshot = await FirebaseFirestore.instance
          .collection("Churches")
          .doc(widget.ChurchID)
          .collection("Chapters")
          .where(FieldPath.documentId, isEqualTo: chapterId)
          .get();
    } else {
      snapshot = await FirebaseFirestore.instance
          .collection("Churches")
          .doc(widget.ChurchID)
          .collection("Chapters")
          .limit(0)
          .get();
    }

    setState(() {
      chapters = snapshot.docs;
      isLoading = false;
    });
  }

  Future<void> deleteChapter(String chapterId) async {
    await FirebaseFirestore.instance
        .collection("Churches")
        .doc(widget.ChurchID)
        .collection("Chapters")
        .doc(chapterId)
        .delete();

    fetchChapters();
  }

  void editChapterName(String docId, String currentName) {
    TextEditingController nameController = TextEditingController(
      text: currentName,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تعديل اسم الفصل"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "اسم الفصل الجديد"),
        ),
        actions: [
          TextButton(
            child: const Text("إلغاء"),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            child: const Text("حفظ"),
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection("Churches")
                    .doc(widget.ChurchID)
                    .collection("Chapters")
                    .doc(docId)
                    .update({"season": nameController.text.trim()});
                Navigator.pop(ctx);
                fetchChapters();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> showDeleteDialog(String chapterId) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذا الفصل؟'),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            child: const Text('نعم'),
            onPressed: () async {
              Navigator.pop(ctx);
              await deleteChapter(chapterId);
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
        title: const Text('الفصول'),
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
            : chapters.isEmpty
            ? const Center(child: Text("لا توجد فصول حالياً"))
            : GridView.builder(
          itemCount: chapters.length,
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            final chapter = chapters[index];
            return InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RoomPage(
                      ChurchID: widget.ChurchID,
                      ChapterID: chapter.id,
                    ),
                  ),
                );
              },
              onLongPress: () {
                if (role == 'SuperAdmin') {
                  showModalBottomSheet(
                    context: context,
                    builder: (ctx) => Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                          title: const Text("تعديل"),
                          onTap: () {
                            Navigator.pop(ctx);
                            editChapterName(
                              chapter.id,
                              chapter["season"].toString(),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          title: const Text("حذف"),
                          onTap: () {
                            Navigator.pop(ctx);
                            showDeleteDialog(chapter.id);
                          },
                        ),
                      ],
                    ),
                  );
                } else if (role == 'Admin') {
                  editChapterName(
                    chapter.id,
                    chapter["season"].toString(),
                  );
                }
              },
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/Splash_View2.png",
                      height: 100.h,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "${chapter["season"]}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: role == 'SuperAdmin'
          ? FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AddChaptersBox(churchID: widget.ChurchID),
          ).then((_) => fetchChapters());
        },
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
