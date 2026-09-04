import 'package:aner_astaner/Presentation/Views/Adds_Category/Add_churches_Box.dart';
import 'package:aner_astaner/Presentation/Views/Category/Chapters_Page.dart';
import 'package:aner_astaner/features/organization/domain/entities/organization_item.dart';
import 'package:aner_astaner/features/organization/presentation/controllers/organization_controller.dart';
import 'package:aner_astaner/features/user/presentation/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChurchesPage extends StatefulWidget {
  const ChurchesPage({super.key});

  @override
  State<ChurchesPage> createState() => _ChurchesPageState();
}

class _ChurchesPageState extends State<ChurchesPage> {
  List<OrganizationItem> churches = [];
  bool isLoading = true;
  String role = '';
  String? churchId;

  final organizationController = Get.find<OrganizationController>();
  final userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    setState(() => isLoading = true);
    final profile = await userController.fetchCurrentUserProfile();
    if (profile == null) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    role = profile.role ?? '';
    churchId = profile.churchId;
    churches = await organizationController.fetchChurches(
      role: role,
      churchId: churchId,
    );
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> editChurchName(String id, String currentName) async {
    final controller = TextEditingController(text: currentName);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تعديل اسم الكنيسة'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'اسم الكنيسة الجديد'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              await organizationController.updateChurch(id, name);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              await getData();
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> confirmDeleteChurch(String id) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف الكنيسة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await organizationController.deleteChurch(id);
              await getData();
            },
            child: const Text('نعم'),
          ),
        ],
      ),
    );
  }

  void showChurchActions(OrganizationItem church) {
    if (role == 'Admin') {
      editChurchName(church.id, church.title);
      return;
    }
    if (role != 'SuperAdmin') return;

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text('تعديل اسم الكنيسة'),
            onTap: () {
              Navigator.pop(sheetContext);
              editChurchName(church.id, church.title);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('حذف الكنيسة'),
            onTap: () {
              Navigator.pop(sheetContext);
              confirmDeleteChurch(church.id);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحافظات والكنائس'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0.h),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : churches.isEmpty
            ? const Center(child: Text('لا توجد كنائس لعرضها'))
            : GridView.builder(
                itemCount: churches.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemBuilder: (context, index) {
                  final church = churches[index];
                  return InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChaptersPage(ChurchID: church.id),
                      ),
                    ),
                    onLongPress: () => showChurchActions(church),
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Splash_View2.png',
                            height: 100.h,
                          ),
                          Text(
                            church.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: role == 'SuperAdmin'
          ? FloatingActionButton(
              backgroundColor: Colors.amber,
              onPressed: () => showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => AddChurchesBox(onSuccess: getData),
              ),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
