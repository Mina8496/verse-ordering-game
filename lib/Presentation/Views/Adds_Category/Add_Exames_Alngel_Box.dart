import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddExamesAlngelBox extends StatefulWidget {
  static const String kFixedExameID = "nFL11C4v8fPRqIgG0ZAe";

  final String? ChaptersID;
  final String? ChurchID;
  final VoidCallback? onExameAdded;

  const AddExamesAlngelBox({
    Key? key,
    this.onExameAdded,
    this.ChaptersID,
    this.ChurchID,
  }) : super(key: key);

  @override
  State<AddExamesAlngelBox> createState() => _AddExamesAlngelBoxState();
}

class _AddExamesAlngelBoxState extends State<AddExamesAlngelBox> {
  final TextEditingController seasonController = TextEditingController();
  bool isLoading = false;

  Future<void> addData() async {
    final season = seasonController.text.trim();

    if (season.isEmpty ||
        widget.ChaptersID == null ||
        widget.ChurchID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى إدخال اسم السفر")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection("Churches")
          .doc(widget.ChurchID)
          .collection("Chapters")
          .doc(widget.ChaptersID)
          .collection("Exames")
          .doc(AddExamesAlngelBox.kFixedExameID)
          .collection("Alangel")
          .add({
        "title": season,
        "created_at": FieldValue.serverTimestamp(),
      });

      widget.onExameAdded?.call();
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ أثناء الإضافة: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة سفر جديد'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: seasonController,
            decoration: const InputDecoration(
              labelText: 'اسم السفر',
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
          onPressed: isLoading ? null : addData,
          child: isLoading
              ? const SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator())
              : const Text("إضافة"),
        ),
      ],
    );
  }
}
