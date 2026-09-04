import 'package:aner_astaner/features/exam_chapter/presentation/controllers/exam_chapter_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddExamesAlshahatBox extends StatefulWidget {
  static const String kFixedExameID = "nFL11C4v8fPRqIgG0ZAe";

  final String? ChaptersID;
  final String? ChurchID;
  final String? AlngelID;
  final String controllerTag;
  final VoidCallback? onExameAdded;

  const AddExamesAlshahatBox({
    Key? key,
    this.onExameAdded,
    this.ChaptersID,
    this.ChurchID,
    this.AlngelID,
    required this.controllerTag,
  }) : super(key: key);

  @override
  State<AddExamesAlshahatBox> createState() => _AddExamesAlshahatBoxState();
}

class _AddExamesAlshahatBoxState extends State<AddExamesAlshahatBox> {
  final TextEditingController seasonController = TextEditingController();
  bool isLoading = false;

  Future<void> addData() async {
    final season = seasonController.text.trim();

    if (season.isEmpty ||
        widget.ChaptersID == null ||
        widget.ChurchID == null ||
        widget.AlngelID == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("يرجى إدخال اسم الاصحاح")));
      return;
    }

    setState(() => isLoading = true);

    try {
      await Get.find<ExamChapterController>(
        tag: widget.controllerTag,
      ).addChapter(season);

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
      title: const Text('إضافة إصحاح جديد'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: seasonController,
            decoration: const InputDecoration(
              labelText: 'اسم الاصحاح',
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
