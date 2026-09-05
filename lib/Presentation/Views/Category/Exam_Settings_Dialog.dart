// ignore_for_file: unnecessary_cast
import 'package:aner_astaner/features/user/domain/entities/user_model.dart';
import 'package:aner_astaner/features/user/domain/repositories/user_repository.dart';
import 'package:aner_astaner/features/user/presentation/controllers/user_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ExamSettingsDialog extends StatefulWidget {
  final String? church;
  final String? chapter;
  final bool? isRepeatable;
  final bool? hasTimer;
  final String? alngelId;

  const ExamSettingsDialog({
    super.key,
    this.isRepeatable,
    this.hasTimer,
    this.church,
    this.chapter,
    this.alngelId,
  });

  static const String kFixedExameID = "nFL11C4v8fPRqIgG0ZAe";

  @override
  State<ExamSettingsDialog> createState() => _ExamSettingsDialogState();
}

class _ExamSettingsDialogState extends State<ExamSettingsDialog> {
  late bool isRepeatable;
  late bool hasTimer;
  bool isLoading = true;

  String? churchId;
  String? chapterId;
  String? fullName;
  String? season;

  List<DropdownMenuItem<String>> alnagelList = [];
  List<DropdownMenuItem<String>> chaptersList = [];

  String? selectedBook;
  String? selectedChapter;
  UserModel? userModel;
  UserController get userController => Get.find<UserController>();

  DateTime? examStartDate;
  DateTime? examEndDate;
  int durationDays = 1;
  double timerDuration = 30; // القيمة الافتراضية 30 ثانية

  @override
  void initState() {
    super.initState();
    isRepeatable = widget.isRepeatable ?? false;
    hasTimer = widget.hasTimer ?? false;

    // استخدم الكنيسة والفصل القادم من الصفحة السابقة
    churchId = widget.church;
    chapterId = widget.chapter;

    getUserData();
  }

  Future<void> getUserData() async {
    final profile = await Get.find<UserRepository>().fetchCurrentUserProfile();
    if (profile != null) {
      fullName = profile.fullName;
      season = profile.season;

      setState(() => isLoading = false);
      await fetchAlnagel();
    }
  }

  Future<void> fetchAlnagel() async {
    if (churchId == null || chapterId == null) return;

    alnagelList.clear();
    final snapshot = await FirebaseFirestore.instance
        .collection("Churches")
        .doc(churchId)
        .collection("Chapters")
        .doc(chapterId)
        .collection("Exames")
        .doc(ExamSettingsDialog.kFixedExameID)
        .collection("Alangel")
        .get();

    for (var doc in snapshot.docs) {
      alnagelList.add(
        DropdownMenuItem(value: doc.id, child: Text(doc['title'])),
      );
    }
    setState(() {});
  }

  Future<void> fetchChapters(String alngelId) async {
    if (churchId == null || chapterId == null) return;

    chaptersList.clear();
    final snapshot = await FirebaseFirestore.instance
        .collection("Churches")
        .doc(churchId)
        .collection("Chapters")
        .doc(chapterId)
        .collection("Exames")
        .doc(ExamSettingsDialog.kFixedExameID)
        .collection("Alangel")
        .doc(alngelId)
        .collection("Alshahat")
        .get();

    if (snapshot.docs.isEmpty) {
      chaptersList.add(
        const DropdownMenuItem(
          value: null,
          child: Text("لا توجد إصحاحات متاحة"),
        ),
      );
    } else {
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final title = data['title'] ?? 'بدون عنوان';
        chaptersList.add(DropdownMenuItem(value: doc.id, child: Text(title)));
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("إعدادات الامتحان"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // اختيار السفر
            Container(
              width: 150.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: DropdownButton<String>(
                value: selectedBook,
                isExpanded: true,
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down),
                items: alnagelList.isNotEmpty
                    ? alnagelList
                    : [
                        const DropdownMenuItem(
                          value: null,
                          child: Text("لا يوجد أسفار متاحة"),
                        ),
                      ],
                onChanged: (value) async {
                  setState(() {
                    selectedBook = value!;
                    selectedChapter = null;
                  });
                  if (value != null) await fetchChapters(value);
                },
                hint: const Center(child: Text("السفر")),
              ),
            ),
            SizedBox(height: 10.h),

            // اختيار الإصحاح
            Container(
              width: 150.w,
              padding: EdgeInsets.symmetric(horizontal: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: DropdownButton<String>(
                value: selectedChapter,
                isExpanded: true,
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down),
                items: chaptersList.isNotEmpty
                    ? chaptersList
                    : [
                        DropdownMenuItem(
                          value: null,
                          child: Text(
                            "اختار السفر أولاً",
                            style: TextStyle(fontSize: 15.sp),
                          ),
                        ),
                      ],
                onChanged: (value) {
                  setState(() {
                    selectedChapter = value!;
                  });
                },
                hint: const Center(child: Text("الإصحاح")),
              ),
            ),

            const SizedBox(height: 10),

            // التواريخ
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("تاريخ بداية الامتحان:"),
                      const SizedBox(height: 5),
                      InkWell(
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: examStartDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              examStartDate = pickedDate;
                              if (examEndDate != null) {
                                durationDays =
                                    examEndDate!
                                        .difference(examStartDate!)
                                        .inDays +
                                    1;
                              }
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 10.h,
                            horizontal: 12.w,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Text(
                            examStartDate != null
                                ? "${examStartDate!.day}/${examStartDate!.month}/${examStartDate!.year}"
                                : "اختر تاريخ البداية",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("تاريخ نهاية الامتحان:"),
                      const SizedBox(height: 5),
                      InkWell(
                        onTap: () async {
                          if (examStartDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('اختر تاريخ البداية أولاً'),
                              ),
                            );
                            return;
                          }
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate:
                                examEndDate ??
                                examStartDate!.add(const Duration(days: 1)),
                            firstDate: examStartDate!,
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              examEndDate = pickedDate;
                              durationDays =
                                  examEndDate!
                                      .difference(examStartDate!)
                                      .inDays +
                                  1;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 10.h,
                            horizontal: 12.w,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Text(
                            examEndDate != null
                                ? "${examEndDate!.day}/${examEndDate!.month}/${examEndDate!.year}"
                                : "اختر تاريخ النهاية",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            if (examStartDate != null && examEndDate != null)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  "مدة الامتحان: $durationDays يوم${durationDays > 1 ? "s" : ""}",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            SizedBox(height: 10.h),

            SwitchListTile(
              title: const Text("هل الامتحان يتكرر؟"),
              value: isRepeatable,
              onChanged: (val) => setState(() => isRepeatable = val),
            ),

            SwitchListTile(
              title: const Text("هل يحتوي على تايمر؟"),
              value: hasTimer,
              onChanged: (val) => setState(() => hasTimer = val),
            ),

            if (hasTimer) ...[
              const SizedBox(height: 10),
              Text(
                "مدة التايمر: ${timerDuration.toInt()} ثانية",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Slider(
                value: timerDuration,
                min: 20,
                max: 60,
                divisions: 8,
                label: "${timerDuration.toInt()} ثانية",
                onChanged: (value) {
                  setState(() {
                    timerDuration = value;
                  });
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (selectedBook == null || selectedChapter == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('يجب اختيار السفر والإصحاح')),
              );
              return;
            }

            if (examStartDate == null || examEndDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('يجب تحديد تواريخ الامتحان')),
              );
              return;
            }

            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser == null) return;

            final selectedBookItem = alnagelList.firstWhere(
              (item) => item.value == selectedBook,
              orElse: () =>
                  const DropdownMenuItem(value: '', child: Text("السفر")),
            );
            final selectedChapterItem = chaptersList.firstWhere(
              (item) => item.value == selectedChapter,
              orElse: () =>
                  const DropdownMenuItem(value: '', child: Text("الإصحاح")),
            );

            final selectedBookTitle =
                (selectedBookItem.child as Text).data ?? "السفر";
            final selectedChapterTitle =
                (selectedChapterItem.child as Text).data ?? "الإصحاح";

            final dataToSave = {
              'bookId': selectedBook,
              'chapterId': selectedChapter,
              'bookTitle': selectedBookTitle,
              'chapterTitle': selectedChapterTitle,
              'durationDays': durationDays,
              'examStart': Timestamp.fromDate(examStartDate!),
              'examEnd': Timestamp.fromDate(examEndDate!),
              'isRepeatable': isRepeatable,
              'hasTimer': hasTimer,
              'timerDuration': hasTimer ? timerDuration.toInt() : null,
              'timestamp': FieldValue.serverTimestamp(),
              'userFullName': fullName,
              'userId': currentUser.uid,
              'season': season,
            };

            try {
              await FirebaseFirestore.instance
                  .collection("Churches")
                  .doc(churchId)
                  .collection("Chapters")
                  .doc(chapterId)
                  .collection("Exames")
                  .doc(ExamSettingsDialog.kFixedExameID)
                  .collection("Settings")
                  .add(dataToSave);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("تم إضافة امتحان جديد بنجاح ✅")),
              );

              Navigator.pop(context);
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("خطأ أثناء الحفظ: $e")));
            }
          },
          child: const Text("تم"),
        ),
      ],
    );
  }
}
