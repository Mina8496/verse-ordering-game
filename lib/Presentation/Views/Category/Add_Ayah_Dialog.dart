import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddAyahDialog extends StatefulWidget {
  final String? churchID;
  final String? chapterID;

  const AddAyahDialog({
    super.key,
    required this.churchID,
    required this.chapterID,
  });

  @override
  State<AddAyahDialog> createState() => _AddAyahDialogState();
}

class _AddAyahDialogState extends State<AddAyahDialog> {
  final TextEditingController _ayahController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final words = _ayahController.text.trim().split(RegExp(r'\s+'));

      final existingDocs = await FirebaseFirestore.instance
          .collection("Churches")
          .doc(widget.churchID)
          .collection("Chapters")
          .doc(widget.chapterID)
          .collection("Exames")
          .doc("nFL11C4v8fPRqIgG0ZAe")
          .collection("AyatQuiz")
          .where('words', isEqualTo: words)
          .get();

      if (existingDocs.docs.isNotEmpty) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❗️هذه الآية موجودة بالفعل")),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection("Churches")
          .doc(widget.churchID)
          .collection("Chapters")
          .doc(widget.chapterID)
          .collection("Exames")
          .doc("nFL11C4v8fPRqIgG0ZAe")
          .collection("AyatQuiz")
          .add({'words': words, 'timestamp': FieldValue.serverTimestamp()});

      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ تم إضافة الآية بنجاح")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("إضافة آية جديدة"),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _ayahController,
          maxLines: 3,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(
            hintText: "مثال: الرب راعى فلا يعوزنى شى",
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "الرجاء إدخال الآية";
            }
            if (value.trim().split(RegExp(r'\s+')).length < 2) {
              return "يجب أن تتكون الآية من كلمتين على الأقل";
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          child: const Text("إلغاء"),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(child: const Text("إضافة"), onPressed: _submit),
      ],
    );
  }
}
