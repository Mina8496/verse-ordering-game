// ignore_for_file: unused_element

import 'package:aner_astaner/Presentation/Views/Category/Exames_Quiz_Page.dart';
import 'package:aner_astaner/Presentation/Views/Login/Edit_User_Page.dart';
import 'package:aner_astaner/features/user/domain/repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide Rx;
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';

class ChurchUsersResultsPage extends StatefulWidget {
  const ChurchUsersResultsPage({super.key});

  @override
  State<ChurchUsersResultsPage> createState() => _ChurchUsersResultsPageState();
}

class _ChurchUsersResultsPageState extends State<ChurchUsersResultsPage> {
  String? selectedBookTitle;
  String? currentUserChurchID;
  String? currentUserClassID;
  String? currentExamChapterTitle;
  String? ChurchName;
  String? SeasonName;
  String? currentUserRole;

  Future<void> fetchCurrentUserData() async {
    final profile = await Get.find<UserRepository>().fetchCurrentUserProfile();
    if (profile == null) return;

    currentUserChurchID = profile.churchId;
    currentUserClassID = profile.chapterId;
    ChurchName = profile.church;
    SeasonName = profile.season;
    currentUserRole = profile.role;
  }

  Future<void> refreshData() async {
    await fetchCurrentUserData();
    setState(() {});
  }

  /// stream لعناوين الأسفار
  Stream<List<String>> getBookTitles() {
    if (currentUserChurchID == null) return const Stream.empty();
    print("👀 churchId=$currentUserChurchID, chapterId=$currentUserClassID");

    return FirebaseFirestore.instance
        .collectionGroup("Results")
        .where("examChurchID", isEqualTo: currentUserChurchID)
        .where("chapterID", isEqualTo: currentUserClassID)
        .snapshots()
        .map((snapshot) {
          final titles = <String>{};
          for (var doc in snapshot.docs) {
            final data = doc.data();
            if (data.containsKey('bookTitle')) {
              titles.add(data['bookTitle']);
            }
          }
          return titles.toList();
        });
  }

  Stream<bool> hasExamSettingsStream({
    required String churchId,
    required String chapterId,
  }) {
    return FirebaseFirestore.instance
        .collection("Churches")
        .doc(churchId)
        .collection("Chapters")
        .doc(chapterId)
        .collection("Exames")
        .doc(ExamesQuizPage.kFixedExameID)
        .collection("Settings")
        .snapshots()
        .map((snap) => snap.docs.isNotEmpty);
  }

  Stream<Map<String, dynamic>?> latestExamSettingsStream({
    required String churchId,
    required String chapterId,
  }) {
    return FirebaseFirestore.instance
        .collection("Churches")
        .doc(churchId)
        .collection("Chapters")
        .doc(chapterId)
        .collection("Exames")
        .doc(ExamesQuizPage.kFixedExameID)
        .collection("Settings")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return null;
          return snap.docs.first.data();
        });
  }

  /// ✅ يجمع نتائج الامتحانات + الآيات + المستخدمين
  Stream<List<Map<String, dynamic>>> getCombinedResults() {
    if (currentUserChurchID == null || currentUserClassID == null) {
      return const Stream.empty();
    }

    final resultsStream = FirebaseFirestore.instance
        .collectionGroup("Results")
        .where("examChurchID", isEqualTo: currentUserChurchID)
        .where("chapterID", isEqualTo: currentUserClassID)
        .orderBy("date", descending: true)
        .snapshots();

    final ayatStream = FirebaseFirestore.instance
        .collection("ExamesAyat")
        .where("examChurchID", isEqualTo: currentUserChurchID)
        .where("ChapterID", isEqualTo: currentUserClassID)
        .snapshots();

    final usersStream = FirebaseFirestore.instance
        .collection("users")
        .where("ChurchID", isEqualTo: currentUserChurchID)
        .where("ChapterID", isEqualTo: currentUserClassID)
        .snapshots();

    final settingsStream = latestExamSettingsStream(
      churchId: currentUserChurchID!,
      chapterId: currentUserClassID!,
    );

    return Rx.combineLatest4(
      resultsStream,
      ayatStream,
      usersStream,
      settingsStream,
      (
        QuerySnapshot resultsSnap,
        QuerySnapshot ayatSnap,
        QuerySnapshot usersSnap,
        Map<String, dynamic>? settings,
      ) {
        final examChapterID = settings?['chapterID'];

        // print("🎯 Active exam chapter = $examChapterTitle");

        /// 🔹 1. users map
        final usersMap = <String, Map<String, dynamic>>{};
        for (var doc in usersSnap.docs) {
          usersMap[doc.id] = doc.data() as Map<String, dynamic>;
        }

        /// 🔹 2. exams results
        final Map<String, Map<String, dynamic>> grouped = {};

        for (var doc in resultsSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final uid = data['userId'];
          if (uid == null) continue;

          final ts = data['date'] is Timestamp
              ? (data['date'] as Timestamp).toDate()
              : DateTime.now();

          final existing = grouped[uid];

          // ✅ احتفظ فقط بأحدث نتيجة
          if (existing == null ||
              ts.isAfter(existing['timestamp'] as DateTime)) {
            grouped[uid] = {
              "userId": uid,
              "full_name": data['full_name'] ?? "مستخدم",
              "score": data['score'] ?? 0,
              "total": data['totalQuestions'] ?? 0,
              "percentage":
                  double.tryParse(data['percentage']?.toString() ?? "0") ?? 0,
              "bookTitle": data['bookTitle'] ?? "",
              "chapterTitle": data['chapterTitle'] ?? "",
              "chapterID": data['chapterID'],
              "timestamp": ts,
            };
          }
        }

        /// 🔹 3. ayat results
        for (var doc in ayatSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final uid = data['userId'];
          if (uid == null) continue;

          grouped.putIfAbsent(uid, () {
            return {
              "userId": uid,
              "full_name": data['full_name'] ?? "مستخدم",
              "score": 0,
              "total": 0,
              "percentage": 0,
              "bookTitle": "—",
              "chapterTitle": "—",
              "timestamp": DateTime.now(),
            };
          });

          grouped[uid]!['scoreAyat'] = data['scoreAyat'] ?? 0;
          grouped[uid]!['totalQuestionsAyat'] = data['totalQuestionsAyat'] ?? 0;
        }

        /// 🔹 4. merge users + filter
        final List<Map<String, dynamic>> finalList = [];

        for (var e in grouped.values) {
          final uid = e['userId'];
          final user = usersMap[uid];
          if (user == null) continue;
          if (user['disabled'] == true) continue;

          /// ⭐ فلترة حسب إصحاح الامتحان الحالي
          if (examChapterID != null && e['chapterID'] != examChapterID) {
            continue;
          }

          e['profileImageUrl'] = user['profileImageUrl'];
          e['Church'] = user['Church'] ?? "كنيسة";

          finalList.add(e);
        }

        /// 🔹 5. sort
        finalList.sort((a, b) {
          final t = (b['timestamp'] as DateTime).compareTo(
            a['timestamp'] as DateTime,
          );
          if (t != 0) return t;
          return (b['score'] as num).compareTo(a['score'] as num);
        });

        print("📊 Final Results = ${finalList.length}");
        return finalList;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchCurrentUserData(),
      builder: (context, snapshot) {
        if (currentUserChurchID == null || currentUserClassID == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return StreamBuilder<Map<String, dynamic>?>(
          stream: latestExamSettingsStream(
            churchId: currentUserChurchID!,
            chapterId: currentUserClassID!,
          ),
          builder: (context, settingsSnap) {
            if (!settingsSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final settings = settingsSnap.data!;
            currentExamChapterTitle = settings['chapterTitle'];

            return Scaffold(
              appBar: AppBar(
                title: Text(
                  "⛪ نتائج كنيستى فى $SeasonName",
                  style: TextStyle(fontSize: 15.sp),
                ),
              ),
              body: Column(
                children: [
                  // 📘 عنوان الامتحان

                  // 📊 النتائج
                  Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: getCombinedResults(),
                      builder: (context, snap) {
                        if (!snap.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final results = snap.data!;
                        if (results.isEmpty) {
                          return const Center(child: Text("لا توجد نتائج بعد"));
                        }

                        return RefreshIndicator(
                          onRefresh: refreshData,
                          child: ListView.builder(
                            itemCount: results.length,
                            itemBuilder: (context, index) {
                              final data = results[index];
                              final rank = index + 1;
                              final date = data['timestamp'] as DateTime;
                              final percent =
                                  (data['percentage'] ?? 0.0) as num;
                              final score = data['score'] ?? 0;
                              final total = data['total'] ?? 0;
                              final book = data['bookTitle'] ?? "سفر";
                              final chapter = data['chapterTitle'] ?? "إصحاح";
                              final name = data['full_name'] ?? "مستخدم";
                              final photoUrl = data['profileImageUrl'];
                              final church = data['Church'] ?? "كنيسة";

                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.h,
                                  vertical: 6.w,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.dg),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12.h,
                                      vertical: 8.w,
                                    ),
                                    leading: Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        CircleAvatar(
                                          radius: 28.r,
                                          backgroundImage:
                                              (photoUrl != null &&
                                                  photoUrl.isNotEmpty)
                                              ? NetworkImage(photoUrl)
                                              : const AssetImage(
                                                      "assets/images/def_prof.gif",
                                                    )
                                                    as ImageProvider,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.circular(
                                              12.dg,
                                            ),
                                          ),
                                          padding: EdgeInsets.all(4.dg),
                                          child: Text(
                                            "$rank",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    title: Text(
                                      name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          church,
                                          style: TextStyle(fontSize: 10.sp),
                                        ),
                                        Text(
                                          "📖 $book - $chapter",
                                          style: TextStyle(fontSize: 10.sp),
                                        ),
                                        Text(
                                          "⭐ $score / $total (${percent.toStringAsFixed(1)}%)",
                                        ),
                                        if (data['scoreAyat'] != null)
                                          Text(
                                            "📜 مسابقة الآيات: ${data['totalQuestionsAyat']} / ${data['scoreAyat']}",
                                          ),
                                        Text(
                                          "📅 ${DateFormat.yMd().add_jm().format(date)}",
                                        ),
                                      ],
                                    ),
                                    onLongPress:
                                        (currentUserRole == 'Admin' ||
                                            currentUserRole == 'SuperAdmin')
                                        ? () {
                                            showModalBottomSheet(
                                              context: context,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                      top: Radius.circular(
                                                        20.dg,
                                                      ),
                                                    ),
                                              ),
                                              builder: (context) => Padding(
                                                padding: EdgeInsets.all(16.dg),
                                                child: Wrap(
                                                  children: [
                                                    ListTile(
                                                      leading: const Icon(
                                                        Icons.edit,
                                                        color: Colors.blue,
                                                      ),
                                                      title: const Text(
                                                        'تعديل المستخدم',
                                                      ),
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                EditUserPage(
                                                                  userID:
                                                                      data['userId'],
                                                                ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
