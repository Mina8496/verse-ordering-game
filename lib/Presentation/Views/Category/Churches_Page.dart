import 'package:aner_astaner/Presentation/Views/Adds_Category/Add_churches_Box.dart';
import 'package:aner_astaner/Presentation/Views/Category/Chapters_Page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChurchesPage extends StatefulWidget {
  const ChurchesPage({Key? key}) : super(key: key);

  @override
  State<ChurchesPage> createState() => _ChurchesPageState();
}

class _ChurchesPageState extends State<ChurchesPage> {
  List<QueryDocumentSnapshot> data = [];
  bool isLoading = true;
  String role = "";
  String? churchId;

  Future<void> getData() async {
    setState(() => isLoading = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    if (!userDoc.exists) {
      setState(() => isLoading = false);
      return;
    }

    final userData = userDoc.data()!;
    role = userData['role'];
    churchId = userData['ChurchID'];

    QuerySnapshot querySnapshot;

    if (role == 'SuperAdmin') {
      querySnapshot = await FirebaseFirestore.instance
          .collection("Churches")
          .orderBy("title", descending: false)
          .get();
    } else if (role == 'Admin') {
      querySnapshot = await FirebaseFirestore.instance
          .collection("Churches")
          .where(FieldPath.documentId, isEqualTo: churchId)
          .get();
    } else {
      querySnapshot = await FirebaseFirestore.instance
          .collection("Churches")
          .limit(0)
          .get();
    }

    setState(() {
      data = querySnapshot.docs;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  void editChurchName(String docId, String currentName) {
    TextEditingController nameController = TextEditingController(
      text: currentName,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تعديل اسم الكنيسة"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "اسم الكنيسة الجديد"),
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
                    .doc(docId)
                    .update({"title": nameController.text.trim()});
                Navigator.pop(ctx);
                getData();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> confirmDeleteChurch(String docId) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف الكنيسة؟'),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            child: const Text('نعم'),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance
                  .collection("Churches")
                  .doc(docId)
                  .delete();
              await getData();
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
        title: const Text('المحافظات والكنائس'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0.h),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : data.isEmpty
            ? const Center(child: Text("لا توجد كنائس لعرضها"))
            : GridView.builder(
                itemCount: data.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemBuilder: (context, i) {
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ChaptersPage(ChurchID: data[i].id),
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
                                title: const Text("تعديل اسم الكنيسة"),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  editChurchName(
                                    data[i].id,
                                    data[i]["title"].toString(),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                title: const Text("حذف الكنيسة"),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  confirmDeleteChurch(data[i].id);
                                },
                              ),
                            ],
                          ),
                        );
                      } else if (role == 'Admin') {
                        editChurchName(data[i].id, data[i]["title"].toString());
                      }
                    },
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(15.dg),
                            child: Image.asset(
                              "assets/images/Splash_View2.png",
                              height: 100.h,
                            ),
                          ),
                          Center(
                            child: Text(
                              "${data[i]["title"]}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
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
                  builder: (ctx) => AddChurchesBox(onSuccess: () => getData()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
