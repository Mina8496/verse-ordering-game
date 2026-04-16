// ignore_for_file: unused_local_variable
import 'package:aner_astaner/Presentation/widgets/Custem_text.dart';
import 'package:aner_astaner/Presentation/widgets/custom_buttions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class addAlshahatPage extends StatefulWidget {
  const addAlshahatPage({required this.addAlshahat});

  final String addAlshahat;

  @override
  State<addAlshahatPage> createState() => _addAlshahatPageState();
}

class _addAlshahatPageState extends State<addAlshahatPage> {
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();

  TextEditingController title = TextEditingController();

  bool isLoading = false;
  Future<void> addNewAlshahat() async {
    CollectionReference Alshahat = FirebaseFirestore.instance
        .collection('Alangel')
        .doc(widget.addAlshahat)
        .collection("Alshahat");
    if (globalKey.currentState!.validate()) {
      try {
        isLoading = true;
        setState(() {});
        DocumentReference response = await Alshahat.add({
          'title': title.text,
        });
        isLoading = false;
        setState(() {});
        Navigator.of(context).pushReplacementNamed("addAlshahatPage");

        ///
      } catch (e) {
        print("Erorrrrrror : $e");
      }
    }
    // Call the user's CollectionReference to add a new use
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اضافة الأصحاحات'),
        centerTitle: true,
      ),
      body: Form(
        key: globalKey,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 20),
                    child: CustomTextField(
                      validator: (val) {
                        if (val == null) {
                          return "لا يمكن ان يكون فارغ";
                        }
                        return "لا يمكن ان يكون فارغ";
                      },
                      controller: title,
                      inputType: TextInputType.text,
                      hintText: "ادخل اسم الأصحاح",
                      textAlign: TextAlign.right,
                      obscureText: false,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomGeneralButton(
                    onPressed: () {
                      addNewAlshahat();
                    },
                    text: "أضــافـة",
                  )
                ],
              ),
      ),
    );
  }
}
