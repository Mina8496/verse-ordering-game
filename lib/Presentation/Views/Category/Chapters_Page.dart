import 'package:aner_astaner/Presentation/Views/Adds_Category/Add_Chapters_Box.dart';
import 'package:aner_astaner/Presentation/Views/Category/Room_Page.dart';
import 'package:aner_astaner/features/organization/domain/entities/organization_item.dart';
import 'package:aner_astaner/features/organization/presentation/controllers/organization_controller.dart';
import 'package:aner_astaner/features/user/presentation/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChaptersPage extends StatefulWidget {
  final String? ChurchID;

  const ChaptersPage({super.key, this.ChurchID});

  @override
  State<ChaptersPage> createState() => _ChaptersPageState();
}

class _ChaptersPageState extends State<ChaptersPage> {
  List<OrganizationItem> chapters = [];
  bool isLoading = true;
  String role = '';
  String? selectedChapterId;

  final organizationController = Get.find<OrganizationController>();
  final userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    fetchChapters();
  }

  Future<void> fetchChapters() async {
    setState(() => isLoading = true);
    final userData = await userController.fetchCurrentUserData();
    if (userData == null) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    role = userData['role'] as String? ?? '';
    selectedChapterId = userData['ChapterID'] as String?;
    chapters = await organizationController.fetchChapters(
      churchId: widget.ChurchID,
      role: role,
      selectedChapterId: selectedChapterId,
    );
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> deleteChapter(String chapterId) async {
    final churchId = widget.ChurchID;
    if (churchId == null) return;
    await organizationController.deleteChapter(
      churchId: churchId,
      chapterId: chapterId,
    );
    await fetchChapters();
  }

  Future<void> editChapterName(String id, String currentName) async {
    final controller = TextEditingController(text: currentName);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تعديل اسم الفصل'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'اسم الفصل الجديد'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final churchId = widget.ChurchID;
              final name = controller.text.trim();
              if (churchId == null || name.isEmpty) return;
              await organizationController.updateChapter(
                churchId: churchId,
                chapterId: id,
                season: name,
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              await fetchChapters();
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> showDeleteDialog(String chapterId) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذا الفصل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await deleteChapter(chapterId);
            },
            child: const Text('نعم'),
          ),
        ],
      ),
    );
  }

  void showChapterActions(OrganizationItem chapter) {
    if (role == 'Admin') {
      editChapterName(chapter.id, chapter.title);
      return;
    }
    if (role != 'SuperAdmin') return;

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text('تعديل'),
            onTap: () {
              Navigator.pop(sheetContext);
              editChapterName(chapter.id, chapter.title);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('حذف'),
            onTap: () {
              Navigator.pop(sheetContext);
              showDeleteDialog(chapter.id);
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
        title: const Text('الفصول'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0.h),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : chapters.isEmpty
            ? const Center(child: Text('لا توجد فصول حالياً'))
            : GridView.builder(
                itemCount: chapters.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final chapter = chapters[index];
                  return InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RoomPage(
                          ChurchID: widget.ChurchID,
                          ChapterID: chapter.id,
                        ),
                      ),
                    ),
                    onLongPress: () => showChapterActions(chapter),
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Splash_View2.png',
                            height: 100.h,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            chapter.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
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
                builder: (_) => AddChaptersBox(churchID: widget.ChurchID),
              ).then((_) => fetchChapters()),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
