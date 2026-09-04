import 'package:aner_astaner/features/category/presentation/controllers/category_controller.dart';
import 'package:aner_astaner/Presentation/widgets/Custem_text.dart';
import 'package:aner_astaner/Presentation/widgets/custom_buttions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddNewCatgory extends StatefulWidget {
  const AddNewCatgory({super.key});

  @override
  State<AddNewCatgory> createState() => _AddNewCatgoryState();
}

class _AddNewCatgoryState extends State<AddNewCatgory> {
  final GlobalKey<FormState> globalKey = GlobalKey<FormState>();

  final TextEditingController title = TextEditingController();

  bool isLoading = false;
  Future<void> addCategory() async {
    if (globalKey.currentState!.validate()) {
      try {
        setState(() => isLoading = true);
        await Get.find<CategoryController>().addCategory(title.text.trim());
        Navigator.of(context).pushReplacementNamed("AddNewCatgory");
      } catch (e) {
        print("Erorrrrrror : $e");
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    title.dispose();
    super.dispose();
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
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 20,
                    ),
                    child: CustomTextField(
                      validator: (val) {
                        return val == null || val.trim().isEmpty
                            ? "لا يمكن ان يكون فارغ"
                            : null;
                      },
                      controller: title,
                      inputType: TextInputType.text,
                      obscureText: false,
                      hintText: "ادخل اسم الاسفار والانجيل",
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomGeneralButton(
                    onPressed: () {
                      addCategory();
                    },
                    text: "أضــافـة",
                  ),
                ],
              ),
      ),
    );
  }
}
