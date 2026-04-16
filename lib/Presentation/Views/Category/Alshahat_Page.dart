import 'package:aner_astaner/Presentation/Views/Adds_Category/addAlshahatPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  List<QueryDocumentSnapshot> data = [];
  RxList<String> savedCategories = <String>[].obs; ///////
  bool isLoading = true;

  getDataAlshahat() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Alangel")
        .doc(widget.AlshahatID)
        .collection("Alshahat")
        .get();
    data.addAll(querySnapshot.docs);

    isLoading = false;

    setState(() {});
  }

  @override
  void initState() {
    getDataAlshahat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأصحاحات'),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => ZoomDrawer.of(context)!.toggle(),
            icon: const Icon(Icons.menu)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isLoading == true
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : GridView.builder(
                itemCount: data.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  // mainAxisExtent: 160,
                ),
                itemBuilder: (context, i) {
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
                          content: const Text('هل أنت متأكد من حذف هذا الأصحاح؟'),
                          actions: [
                            TextButton(
                              child: const Text('إلغاء'),
                              onPressed: () => Navigator.pop(context),
                            ),
                            TextButton(
                              child: const Text('حذف'),
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection("Alangel")
                                    .doc(widget.AlshahatID)
                                    .collection("Alshahat")
                                    .doc(data[i].id)
                                    .delete();
                                Navigator.pop(context);
                                setState(() {
                                  data.removeAt(i);
                                });
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
                              )),
                          Text("${data[i]["title"]}"),
                        ],
                      ),
                    ),
                  );
                }),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => addAlshahatPage(
                  addAlshahat: widget.AlshahatID))); //addAlshahatPage
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
