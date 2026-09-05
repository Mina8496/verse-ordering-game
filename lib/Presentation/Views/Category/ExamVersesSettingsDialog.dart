import 'package:aner_astaner/features/user/domain/repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ExamVersesSettingsDialog extends StatefulWidget {
  const ExamVersesSettingsDialog({super.key});

  static const String kFixedExameID = "nFL11C4v8fPRqIgG0ZAe";

  @override
  State<ExamVersesSettingsDialog> createState() =>
      _ExamVersesSettingsDialogState();
}

class _ExamVersesSettingsDialogState extends State<ExamVersesSettingsDialog> {
  bool isRepeatable = false;
  bool hasTimer = false;
  bool isLoading = true;

  String? churchId;
  String? chapterId;
  String? fullName;
  String? season;

  List<Map<String, dynamic>> versesList = [];
  List<String> selectedVerses = [];

  // التاريخ
  DateTime? examStartDate;
  DateTime? examEndDate;
  int durationDays = 1;

  // التايمر
  double timerDuration = 30;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    final profile = await Get.find<UserRepository>().fetchCurrentUserProfile();

    if (profile != null) {
      churchId = profile.churchId;
      chapterId = profile.chapterId;
      fullName = profile.fullName;
      season = profile.season;

      await fetchVerses();
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchVerses() async {
    versesList.clear();
    print("Fetching verses for ChurchID: $churchId, ChapterID: $chapterId");
    final snapshot = await FirebaseFirestore.instance
        .collection("Churches")
        .doc(churchId)
        .collection("Chapters")
        .doc(chapterId)
        .collection("Exames")
        .doc(ExamVersesSettingsDialog.kFixedExameID)
        .collection("AyatQuiz")
        .get();

    if (snapshot.docs.isEmpty) {
      versesList.add({"id": "none", "title": "لا توجد آيات متاحة"});
    } else {
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>? ?? {};

        // لو فيه words، ناخد أول كلمة أو نكوّن منها جملة بسيطة
        String verseTitle = "آية غير مسماة";
        if (data.containsKey("words") && data["words"] is List) {
          final words = List<String>.from(data["words"]);
          verseTitle =
              words.take(4).join(" ") + (words.length > 4 ? "..." : "");
        }

        versesList.add({"id": doc.id, "title": verseTitle});
      }
    }

    setState(() {});
  }

  void showMultiVerseDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
            return AlertDialog(
              title: const Text("اختيار الآيات"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: versesList.length,
                  itemBuilder: (context, index) {
                    final verse = versesList[index];
                    final verseId = verse["id"];
                    final verseTitle = verse["title"];

                    return CheckboxListTile(
                      value: selectedVerses.contains(verseId),
                      title: Text(verseTitle),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            selectedVerses.add(verseId);
                          } else {
                            selectedVerses.remove(verseId);
                          }
                        });
                        // عشان يحدّث الواجهة داخل الـDialog نفسه
                        setInnerState(() {});
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("تم"),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("إعدادات امتحان الآيات"),
      content: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // اختيار متعدد للآيات
                  InkWell(
                    onTap: showMultiVerseDialog,
                    child: Container(
                      width: 200.w,
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
                        selectedVerses.isEmpty
                            ? "اختيار الآيات"
                            : "عدد الآيات المحددة: ${selectedVerses.length}",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  SizedBox(height: 15.h),

                  // اختيار التواريخ
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("تاريخ البداية:"),
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
                                    examEndDate ??= pickedDate.add(
                                      const Duration(days: 1),
                                    );
                                    durationDays =
                                        examEndDate!
                                            .difference(examStartDate!)
                                            .inDays +
                                        1;
                                  });
                                }
                              },
                              child: _dateBox(
                                examStartDate != null
                                    ? "${examStartDate!.day}/${examStartDate!.month}/${examStartDate!.year}"
                                    : "اختر التاريخ",
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
                            const Text("تاريخ النهاية:"),
                            const SizedBox(height: 5),
                            InkWell(
                              onTap: () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      examEndDate ??
                                      (examStartDate ?? DateTime.now()).add(
                                        const Duration(days: 1),
                                      ),
                                  firstDate: examStartDate ?? DateTime.now(),
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
                              child: _dateBox(
                                examEndDate != null
                                    ? "${examEndDate!.day}/${examEndDate!.month}/${examEndDate!.year}"
                                    : "اختر التاريخ",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (examStartDate != null && examEndDate != null)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        "مدة الامتحان: $durationDays يوم",
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
                      onChanged: (value) =>
                          setState(() => timerDuration = value),
                    ),
                  ],
                ],
              ),
            ),
      actions: [TextButton(onPressed: saveSettings, child: const Text("تم"))],
    );
  }

  Widget _dateBox(String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5),
        ],
      ),
      child: Text(text),
    );
  }

  Future<void> saveSettings() async {
    if (selectedVerses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يجب اختيار آية واحدة على الأقل")),
      );
      return;
    }

    if (examStartDate == null || examEndDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("يجب تحديد التواريخ")));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final selectedTitles = versesList
        .where((v) => selectedVerses.contains(v["id"]))
        .map((v) => v["title"])
        .toList();

    final dataToSave = {
      'versesIds': selectedVerses,
      'versesTitles': selectedTitles,
      'durationDays': durationDays,
      'examStart': Timestamp.fromDate(examStartDate!),
      'examEnd': Timestamp.fromDate(examEndDate!),
      'isRepeatable': isRepeatable,
      'hasTimer': hasTimer,
      'timerDuration': hasTimer ? timerDuration.toInt() : null,
      'timestamp': FieldValue.serverTimestamp(),
      'userFullName': fullName,
      'userId': user.uid,
      'season': season,
    };

    try {
      await FirebaseFirestore.instance
          .collection("Churches")
          .doc(churchId)
          .collection("Chapters")
          .doc(chapterId)
          .collection("Exames")
          .doc(ExamVersesSettingsDialog.kFixedExameID)
          .collection("VersesSettings")
          .add(dataToSave);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم حفظ إعدادات امتحان الآيات ✅")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("خطأ أثناء الحفظ: $e")));
    }
  }
}
