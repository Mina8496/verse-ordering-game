import 'package:aner_astaner/features/chapter/presentation/controllers/chapter_controller.dart';
import 'package:aner_astaner/Presentation/widgets/Custem_text.dart';
import 'package:aner_astaner/Presentation/widgets/custom_buttions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class addAlshahatPage extends StatefulWidget {
  const addAlshahatPage({required this.addAlshahat});

  final String addAlshahat;

  @override
  State<addAlshahatPage> createState() => _addAlshahatPageState();
}

class _addAlshahatPageState extends State<addAlshahatPage> {
  final GlobalKey<FormState> globalKey = GlobalKey<FormState>();

  final TextEditingController title = TextEditingController();

  bool isLoading = false;
  Future<void> addNewAlshahat() async {
    if (globalKey.currentState!.validate()) {
      try {
        setState(() => isLoading = true);
        await Get.find<ChapterController>(
          tag: widget.addAlshahat,
        ).addChapter(title.text.trim());
        if (mounted) Navigator.of(context).pop();
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
      appBar: AppBar(title: const Text('اضافة الأصحاحات'), centerTitle: true),
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
                      hintText: "ادخل اسم الأصحاح",
                      textAlign: TextAlign.right,
                      obscureText: false,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomGeneralButton(
                    onPressed: () {
                      addNewAlshahat();
                    },
                    text: "أضــافـة",
                  ),
                ],
              ),
      ),
    );
  }
}
