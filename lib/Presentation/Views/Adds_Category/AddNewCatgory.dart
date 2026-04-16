
// ignore_for_file: unused_local_variable
import 'package:aner_astaner/Presentation/widgets/Custem_text.dart';
import 'package:aner_astaner/Presentation/widgets/custom_buttions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddNewCatgory extends StatefulWidget {
  const AddNewCatgory({super.key});

  @override
  State<AddNewCatgory> createState() => _AddNewCatgoryState();
}

class _AddNewCatgoryState extends State<AddNewCatgory> {
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();

  TextEditingController title = TextEditingController();

  

  bool isLoading = false;
  Future<void> addCategory() async {
    CollectionReference Alangel =
      FirebaseFirestore.instance.collection('Alangel');
    if (globalKey.currentState!.validate()) {
      try {
        isLoading = true;
        setState(() {});
        DocumentReference response = await Alangel.add({
          'title': title.text,
        });
        isLoading = false;
        setState(() {});
        Navigator.of(context).pushReplacementNamed("AddNewCatgory");
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
        title: const Text('اضافة الاسفار والانجيل'),
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
                      obscureText: false,
                      hintText: "ادخل اسم الاسفار والانجيل",
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomGeneralButton(
                    onPressed: () {
                      addCategory();
                    },
                    text: "أضــافـة",
                  )
                ],
              ),
      ),
    );
  }
}
