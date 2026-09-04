import 'package:aner_astaner/features/organization/presentation/controllers/organization_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("يرجى إدخال الفصل")));
      return;
    }

    setState(() => isLoading = true);

    try {
      await Get.find<OrganizationController>().addChapter(
        churchId: widget.churchID!,
        season: seasonController.text.trim(),
      );

      Navigator.of(context).pop(); // إغلاق الصندوق بعد الإضافة
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("حدث خطأ: $e")));
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
