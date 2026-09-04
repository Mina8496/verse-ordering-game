import 'package:aner_astaner/features/exam_catalog/presentation/controllers/exam_catalog_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("يرجى إدخال اسم السفر")));
      return;
    }

    setState(() => isLoading = true);

    try {
      await Get.find<ExamCatalogController>().addCategory(
        churchId: widget.ChurchID!,
        chapterId: widget.ChaptersID!,
        title: season,
      );

      widget.onExameAdded?.call();
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("حدث خطأ أثناء الإضافة: $e")));
    }
  }

  @override
  void dispose() {
    seasonController.dispose();
    super.dispose();
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
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(),
                )
              : const Text("إضافة"),
        ),
      ],
    );
  }
}
