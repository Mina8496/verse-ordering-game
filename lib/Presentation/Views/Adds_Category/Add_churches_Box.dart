import 'package:aner_astaner/Presentation/widgets/Custem_text.dart';
import 'package:aner_astaner/Presentation/widgets/custom_buttions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddChurchesBox extends StatefulWidget {
  final VoidCallback? onSuccess;

  const AddChurchesBox({Key? key, this.onSuccess}) : super(key: key);

  @override
  State<AddChurchesBox> createState() => _AddChurchesBoxState();
}

class _AddChurchesBoxState extends State<AddChurchesBox> {
  final GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  final TextEditingController title = TextEditingController();
  bool isLoading = false;

  Future<void> addChurch() async {
    if (!globalKey.currentState!.validate()) return;

    try {
      setState(() => isLoading = true);

      await FirebaseFirestore.instance.collection('Churches').add({
        'title': title.text.trim(),
      });

      if (widget.onSuccess != null) {
        widget.onSuccess!(); // ← يتم استدعاؤه قبل الإغلاق
      }

      Navigator.of(context).pop(); // ← يغلق نافذة الإدخال
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("حدث خطأ أثناء الإضافة")));
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: globalKey,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: title,
                    hintText: "ادخل اسم البلد - المحافظه - الكنيسة",
                    textAlign: TextAlign.start,
                    inputType: TextInputType.text,
                    obscureText: false,
                    
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "لا يمكن أن يكون الاسم فارغًا";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),
                  CustomGeneralButton(text: "أضــافـة", onPressed: addChurch),
                ],
              ),
      ),
    );
  }
}
