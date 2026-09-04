import 'package:aner_astaner/Presentation/Views/Category/All_Exames_page.dart';
import 'package:aner_astaner/Presentation/Views/Category/Ayat_Admin_Page.dart';
import 'package:aner_astaner/Presentation/Views/Category/Data_Admain_churches_Page.dart';
import 'package:aner_astaner/Presentation/Views/Category/ExamVersesSettingsDialog.dart';
import 'package:aner_astaner/Presentation/Views/Category/Exam_Settings_Dialog.dart';
import 'package:aner_astaner/Presentation/Views/Category/Exames_Alngel_Page.dart';
import 'package:aner_astaner/Presentation/Views/Category/Manage_Users_Tabs_Page.dart';
import 'package:aner_astaner/features/user/presentation/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({Key? key, this.ChapterID, this.ChurchID, this.examId})
    : super(key: key);
  final String? ChapterID;
  final String? ChurchID;
  final String? examId;

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  bool isSuperAdmin = false;

  Future<void> checkIfSuperAdmin() async {
    final userData = await Get.find<UserController>().fetchCurrentUserData();
    if (userData != null) {
      setState(() {
        isSuperAdmin = userData['role'] == 'SuperAdmin';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfSuperAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('غرفة البيانات'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0.h),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          padding: EdgeInsets.all(8.dg),
          children: [
            if (isSuperAdmin)
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DataAdmainChurchesPage(
                        chapter: widget.ChapterID,
                        church: widget.ChurchID,
                      ),
                    ),
                  );
                },
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          "اختيار امين الفصل",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ///// sub ///
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ManageUsersPage(
                      churchId: widget.ChurchID!,
                      chapterId: widget.ChapterID!,
                    ),
                  ),
                );
              },
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "ادارة وقبول المخدومين",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// Exames////
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ExamesAlngelPage(
                      ChurchID: widget.ChurchID,
                      ChapterID: widget.ChapterID,
                    ),
                  ),
                );
              },
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "اضافة اسئلة من سيربح الملكوت",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AllExamsPage(
                    chapterId: widget.ChapterID,
                    churchId: widget.ChurchID,
                  ),
                );
              },
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "كل الامتحانات اللي تمت إضافتها",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //صفحة كل الامتحانات
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => ExamSettingsDialog(
                    chapter: widget.ChapterID,
                    church: widget.ChurchID,
                  ),
                );
              },
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "إضافة مسابقة من سربح الملكوت",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// Exames////
            // InkWell(
            //   onTap: () {
            //     Navigator.of(context).push(
            //       MaterialPageRoute(
            //         builder: (context) => ExamesAlngelPage(
            //           ChurchID: widget.ChurchID,
            //           ChapterID: widget.ChapterID,
            //         ),
            //       ),
            //     );
            //   },
            //   child: Card(
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Center(
            //           child: Text(
            //             "اضافة اسئلة من سيربح الملكوت",
            //             textAlign: TextAlign.center,
            //             style: TextStyle(
            //               fontSize: 15.sp,
            //               fontWeight: FontWeight.bold,
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            // ترتيب الايات
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AyatQuizAdminPage(
                    churchID: widget.ChurchID,
                    chapterID: widget.ChapterID,
                  ),
                );
              },
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "اضافة ايات",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // اضافة مسابفة ايات
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => ExamVersesSettingsDialog(
                    // churchID: widget.ChurchID,
                    // chapterID: widget.ChapterID,
                  ),
                );
              },
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "اضافة مسابفة ترتيب الايات",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // اضافة مستخدم
            // InkWell(
            //   onTap: () {
            //     showDialog(
            //       context: context,
            //       builder: (context) => AddDataAdmainChurchesPage(),
            //     );
            //   },
            //   child: Card(
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Center(
            //           child: Text(
            //             "اضافه مستخدم جديد",
            //             textAlign: TextAlign.center,
            //             style: TextStyle(
            //               fontSize: 15.sp,
            //               fontWeight: FontWeight.bold,
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
