import 'package:aner_astaner/features/bible_verses/presentation/controllers/bible_verse_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

      if (widget.churchID == null || widget.chapterID == null) return;
      final controller = Get.find<BibleVerseController>();
      if (await controller.verseExists(
        churchId: widget.churchID!,
        chapterId: widget.chapterID!,
        words: words,
      )) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❗️هذه الآية موجودة بالفعل")),
        );
        return;
      }

      await controller.addVerse(
        churchId: widget.churchID!,
        chapterId: widget.chapterID!,
        words: words,
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ تم إضافة الآية بنجاح")));
    }
  }

  @override
  void dispose() {
    _ayahController.dispose();
    super.dispose();
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
