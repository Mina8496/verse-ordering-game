import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddChaptersBox extends StatefulWidget {
  final String? churchID;

  const AddChaptersBox({Key? key, this.churchID}) : super(key: key);

  @override
  State<AddChaptersBox> createState() => _AddChaptersBoxState();
}

class _AddChaptersBoxState extends State<AddChaptersBox> {
  final TextEditingController seasonController = TextEditingController();
  bool isLoading = false;

  Future<void> addChapter() async {
    if (seasonController.text.trim().isEmpty || widget.churchID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى إدخال الفصل")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection("Churches")
          .doc(widget.churchID)
          .collection("Chapters")
          .add({
        "season": seasonController.text.trim(),
        "created_at": FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pop(); // إغلاق الصندوق بعد الإضافة
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة فصل جديد'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: seasonController,
            decoration: const InputDecoration(
              labelText: 'اسم الفصل',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("إلغاء"),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : addChapter,
          child: isLoading
              ? const SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator())
              : const Text("إضافة"),
        ),
      ],
    );
  }
}
