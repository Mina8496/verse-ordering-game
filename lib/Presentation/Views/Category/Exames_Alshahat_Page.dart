

import 'package:aner_astaner/Presentation/Views/Adds_Category/Add_Exames_Alngel_Box.dart';
import 'package:aner_astaner/Presentation/Views/Adds_Category/Add_Exames_Alshahat_Box.dart';
import 'package:aner_astaner/Presentation/Views/Category/Exames_Questions_Page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  // List<QueryDocumentSnapshot> dataAdmin = [];
  List<QueryDocumentSnapshot> dataAlshahat = [];
  // List<QueryDocumentSnapshot> dataSubscribe = [];
  bool isLoading = true;

  getDataAlshahat() async {
    dataAlshahat.clear(); // تجنب التكرار

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Churches")
        .doc(widget.ChurchID) // ← اسم الوثيقة في Churches
        .collection("Chapters")
        .doc(widget.ChapterID) // ← اسم الوثيقة في Chapters
        .collection("Exames")
        .doc(AddExamesAlngelBox.kFixedExameID) // ← اسم الوثيقة في Exames
        .collection("Alangel")
        .doc(widget.AlngelID)
        .collection("Alshahat")
        .get();

    dataAlshahat.addAll(querySnapshot.docs);

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.ChurchID != null && widget.ChapterID != null) {
      getDataAlshahat();
    } else {
      debugPrint("ChurchID or ChapterID is null!");
    }
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
        child: isLoading == true
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : GridView.builder(
                itemCount: dataAlshahat.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2.bitLength,
                  mainAxisExtent: 160.spMax,
                ),
                itemBuilder: (context, i) {
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ExamesQuestionsPage(
                                AlshahatID: dataAlshahat[i].id,
                                AlngelID: widget.AlngelID,
                                ChapterID: widget.ChapterID,
                                ChurchID: widget.ChurchID,
                              )));

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
                              child: const Text('حذف', style: TextStyle(color: Colors.red)),
                              onPressed: () async {
                                Navigator.pop(ctx);
                                await FirebaseFirestore.instance
                                    .collection("Churches")
                                    .doc(widget.ChurchID)
                                    .collection("Chapters")
                                    .doc(widget.ChapterID)
                                    .collection("Exames")
                                    .doc(AddExamesAlngelBox.kFixedExameID)
                                    .collection("Alangel")
                                    .doc(widget.AlngelID)
                                    .collection("Alshahat")
                                    .doc(dataAlshahat[i].id)
                                    .delete();
                                await getDataAlshahat();
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
                              )),
                          Text("${dataAlshahat[i]["title"] ?? "بدون عنوان"}"),
                        ],
                      ),
                    ),
                  );
                }),
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
              onExameAdded: () {
                getDataAlshahat(); // يحدث القائمة تلقائيًا بعد الإضافة
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
