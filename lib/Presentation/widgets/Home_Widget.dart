// ignore_for_file: unused_field, use_build_context_synchronously, unnecessary_cast
import 'dart:async';
import 'dart:typed_data';
import 'package:aner_astaner/features/user/domain/entities/user_model.dart';
import 'package:aner_astaner/features/user/domain/repositories/profile_image_uploader.dart';
import 'package:aner_astaner/features/user/presentation/controllers/user_controller.dart';
import 'package:aner_astaner/Presentation/Views/Category/Churches_Page.dart';
import 'package:aner_astaner/Presentation/Views/Category/Exames_Quiz_Page.dart';
import 'package:aner_astaner/Presentation/Views/Login/Completw_information_body.dart';
import 'package:aner_astaner/Presentation/Views/RewardsPage.dart';
import 'package:aner_astaner/Presentation/widgets/BibleReadButton.dart';
import 'package:aner_astaner/Presentation/widgets/BubbleTopTailPainter.dart';
import 'package:aner_astaner/Presentation/widgets/ChatBubble.dart';
import 'package:aner_astaner/Presentation/widgets/isUser_Approved_Or_Admin.dart';
import 'package:aner_astaner/Presentation/widgets/showHowTo_Qussyion_Dialog.dart';
import 'package:aner_astaner/features/exam_catalog/presentation/controllers/exam_catalog_controller.dart';
import 'package:aner_astaner/features/exam_settings/presentation/controllers/exam_settings_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key, this.alngelId}) : super(key: key);
  final String? alngelId;
  static const String kFixedExameID = "nFL11C4v8fPRqIgG0ZAe";

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> with TickerProviderStateMixin {
  final ExamCatalogController examCatalogController =
      Get.find<ExamCatalogController>();
  ProfileImageUploader get profileImageService =>
      Get.find<ProfileImageUploader>();
  final ExamSettingsController examSettingsController =
      Get.find<ExamSettingsController>();
  String? imageUrl;
  Uint8List? imageData;
  List<DropdownMenuItem<String>> alnagelList = [];
  List<DropdownMenuItem<String>> chaptersList = [];

  String? selectedBook;
  String? selectedChapter;
  String? selectedBookTitle;
  String? selectedChapterTitle;
  int? selectedDuration;
  bool? selectedRepeatable;
  bool? selectedHasTimer;

  UserModel? userModel;
  UserController get userController => Get.find<UserController>();
  bool hasUserData = false;

  bool isLoading = true;
  bool _isStartingExam = false;

  String? churchId;
  String? chapterId;
  String? fullName;
  String? season;
  String? church;
  String? role;

  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  int _currentImageIndex = 0;
  String _currentImagePath = "assets/carcter/correct.png";
  late Timer _timer;
  late AnimationController _zoomController;
  late Animation<double> _zoomAnimation;
  double _textOpacity = 1.0;

  String _welcomeText = "👋مرحبًا";

  @override
  void initState() {
    super.initState();
    getData().then((_) async {
      await fetchChaptersByChurch();
      await fetchAlnagel();
      await fetchSavedExamSettings();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAndShowHowToPlay(); // ✅ هذا السطر يشغل الدالة الصحيحة
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _offsetAnimation =
        Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();

    _zoomController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeInOut),
    );

    updateImageBasedOnTime();
    updateWelcomeText();

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      updateImageBasedOnTime();
      updateWelcomeText();
    });
  }

  Future<void> fetchChaptersByChurch() async {
    chaptersList.clear();
    if (churchId == null) return;

    final chapters = await examCatalogController.fetchChaptersByChurch(
      churchId!,
    );
    for (final chapter in chapters) {
      chaptersList.add(
        DropdownMenuItem(value: chapter.id, child: Text(chapter.title)),
      );
    }

    // ✅ لو فيه فصل محفوظ في Firestore، نخلي Dropdown يفتحه
    if (chapterId != null &&
        chaptersList.any((item) => item.value == chapterId)) {
      if (!mounted) return;
      setState(() {
        chapterId = chapterId; // يثبت القيمة
      });
    } else {
      if (!mounted) return;
      setState(() {
        chapterId = null; // لو مفيش فصل محفوظ
      });
    }
  }

  Future<void> saveSelectedChapter(
    String chapterId,
    String chapterTitle,
  ) async {
    await userController.updateCurrentUser({
      'ChapterID': chapterId,
      'Season': chapterTitle,
    });
    if (!mounted) return;
    setState(() {
      this.chapterId = chapterId;
    });
  }

  void checkAndShowHowToPlay() async {
    final prefs = await SharedPreferences.getInstance();
    bool seenTutorial = prefs.getBool('seen_tutorial') ?? false;

    if (!seenTutorial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showHowToQuizDialog(context);
      });
      prefs.setBool('seen_tutorial', true);
    }
  }

  /// ✅ انقل `selectImage` هنا داخل الكلاس وليس داخل `initState`
  Future<void> selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false, // مهم حتى لا يطلب صلاحيات
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    if (!mounted) return;
    setState(() => imageData = bytes);

    final url = await profileImageService.upload(bytes);

    if (url != null) {
      if (!mounted) return;
      setState(() => imageUrl = url);

      // حفظ URL الصورة
      await userController.updateProfileImage(url);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ تم رفع الصورة وحفظ الرابط بنجاح")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ فشل رفع الصورة")));
    }
  }

  void updateWelcomeText() {
    final hour = DateTime.now().hour;
    if (!mounted) return;
    setState(() => _textOpacity = 0.0); // يبدأ بالإخفاء

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      // setState(() {
      //   if (hour >= 5 && hour < 12) {
      //     _welcomeText = "☀️سنه جديده سعيده عليك يا بطل";
      //   } else if (hour >= 12 && hour < 16) {
      //     _welcomeText = "🕶️ سنه جديده سعيده عليك يا بطل";
      //   } else if (hour >= 16 && hour < 20) {
      //     _welcomeText = "🌇سنه جديده سعيده عليك يا بطل";
      //   } else {
      //     _welcomeText = "🌙سنه جديده سعيده عليك يا بطل";
      //   }
      //   _textOpacity = 1.0; // ثم يظهر بسلاسة
      // });
      setState(() {
        if (hour >= 5 && hour < 12) {
          _welcomeText = "☀️جاهز لانجاز جديد يا بطل";
        } else if (hour >= 12 && hour < 16) {
          _welcomeText = "🕶️ نهارك سعيد يا بطل";
        } else if (hour >= 16 && hour < 20) {
          _welcomeText = "🌇بينا نعمل شعل عالى يا بطل";
        } else {
          _welcomeText = "🌙معاك فى اى وقت يا بطل";
        }
        _textOpacity = 1.0; // ثم يظهر بسلاسة
      });
    });
  }

  void updateImageBasedOnTime() {
    final now = DateTime.now().hour;
    if (!mounted) return;
    setState(() {
      if (now >= 5 && now < 12) {
        _currentImagePath = "assets/carcter/correct.png";
      } else if (now >= 12 && now < 16) {
        _currentImagePath = "assets/carcter/pen_search.gif";
      } else if (now >= 16 && now < 19) {
        _currentImagePath = "assets/carcter/pen_persntion.png";
      } else {
        _currentImagePath = "assets/carcter/pen_idea.png";
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _zoomController.dispose();
    _timer.cancel();
    super.dispose();
  }

  Future<void> getData() async {
    final profile = await userController.fetchCurrentUserProfile();

    if (profile != null) {
      hasUserData = true;
      churchId = profile.churchId;
      chapterId = profile.chapterId;
      fullName = profile.fullName;
      season = profile.season;
      church = profile.church;
      role = profile.role;

      imageUrl = profile.profileImageUrl;
    }
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> fetchAlnagel() async {
    alnagelList.clear();
    if (churchId == null || chapterId == null) return;

    final categories = await examCatalogController.fetchCategories(
      churchId: churchId!,
      chapterId: chapterId!,
    );
    for (final category in categories) {
      alnagelList.add(
        DropdownMenuItem(value: category.id, child: Text(category.title)),
      );
    }
    if (!mounted) return;
    setState(() {});
  }

  Future<void> fetchChapters(String alngelId) async {
    chaptersList.clear();
    if (churchId == null || chapterId == null) return;

    final chapters = await examCatalogController.fetchChapters(
      churchId: churchId!,
      chapterId: chapterId!,
      categoryId: alngelId,
    );
    for (final chapter in chapters) {
      chaptersList.add(
        DropdownMenuItem(value: chapter.id, child: Text(chapter.title)),
      );
    }
    if (!mounted) return;
    setState(() {});
  }

  Future<void> fetchSavedExamSettings() async {
    final selection = await examSettingsController.fetchCurrentSelection();
    if (selection == null || !mounted) return;

    setState(() {
      selectedBook = selection.bookId;
      selectedChapter = selection.chapterId;
      selectedDuration = selection.durationDays;
      selectedRepeatable = selection.isRepeatable;
      selectedHasTimer = selection.hasTimer;
      selectedBookTitle = selection.bookTitle;
      selectedChapterTitle = selection.chapterTitle;
    });
  }

  Future<bool> isUserInfoComplete() async {
    final profile = await userController.fetchCurrentUserProfile();
    if (profile == null) return false;

    // الحقول المطلوبة
    return profile.fullName != null &&
        profile.churchId != null &&
        profile.chapterId != null &&
        profile.season != null &&
        profile.church != null;
  }

  void showCompleteInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("⚠️ البيانات غير مكتملة"),
        content: const Text("من فضلك أكمل بياناتك للمتابعة"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Get.to(() => const CompleteInformationBody());
            },
            child: const Text("إكمال البيانات"),
          ),
        ],
      ),
    );
  }

  Widget buildInfoText(String? value) {
    if (isLoading) return const CircularProgressIndicator();
    if (!hasUserData) return const Text("لا توجد بيانات متاحة");

    if (value == null || value.isEmpty) {
      return InkWell(
        onTap: showCompleteInfoDialog,
        child: Text(
          "⚠️ اضغط هنا لإكمال البيانات",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Text(
      value,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12.sp,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: 700.h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(right: 100.w, bottom: 175.h),
                child: CustomPaint(
                  size: Size(60.w, 30.h),
                  painter: BubbleTopTailPainter(
                    color: Colors.red,
                  ), //Colors.indigo
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 120.h),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50.dg),
                      topRight: Radius.circular(50.dg),
                      bottomLeft: Radius.circular(50.dg),
                      bottomRight: Radius.circular(50.dg),
                    ),
                    color: Colors.red, //Colors.indigo,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 110.h),
                      SizedBox(
                        width: double.infinity,
                        height: 15.h,
                        child: buildInfoText(fullName),
                      ),
                      SizedBox(height: 15.h),
                      SizedBox(
                        width: double.infinity,
                        height: 20.h,
                        child: buildInfoText(season),
                      ),
                      SizedBox(height: 20.h),
                      SizedBox(
                        width: double.infinity,
                        height: 40.h,
                        child: buildInfoText(church),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0.dg),
                        child: Row(
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isStartingExam
                                    ? null
                                    : () async {
                                        if (!mounted) return;
                                        setState(() => _isStartingExam = true);

                                        try {
                                          // ✅ التحقق من اعتماد المستخدم
                                          if (!(await isUserApprovedOrAdmin(
                                            context,
                                          )))
                                            return;

                                          // ✅ التحقق من اكتمال البيانات
                                          if (!(await isUserInfoComplete())) {
                                            showCompleteInfoDialog();
                                            return;
                                          }

                                          // ✅ التحقق من اختيار الخدمة
                                          if (churchId == null ||
                                              chapterId == null) {
                                            Fluttertoast.showToast(
                                              msg: "⚠️ اختر الخدمة أولًا",
                                              backgroundColor: Colors.black54,
                                              textColor: Colors.white,
                                            );
                                            return;
                                          }

                                          // ✅ البحث عن الامتحان اللي تاريخ النهارده يقع بين examStart و examEnd
                                          // ✅ البحث عن أول امتحان لتاريخ اليوم (من كل الامتحانات)
                                          print(
                                            "🧭 Church ID: $churchId | Chapter ID: $chapterId",
                                          );

                                          final settings =
                                              await examSettingsController
                                                  .fetchSettings(
                                                    churchId: churchId!,
                                                    chapterId: chapterId!,
                                                  );

                                          if (settings.isEmpty) {
                                            Fluttertoast.showToast(
                                              msg:
                                                  "❌ لا يوجد إعدادات لهذا الامتحان",
                                              backgroundColor: Colors.black54,
                                              textColor: Colors.white,
                                            );
                                            return;
                                          }

                                          final activeSetting = settings
                                              .where(
                                                (setting) =>
                                                    setting.isAvailableOn(
                                                      DateTime.now(),
                                                    ),
                                              )
                                              .firstOrNull;

                                          if (activeSetting == null) {
                                            Fluttertoast.showToast(
                                              msg:
                                                  "❌ لا يوجد امتحان متاح اليوم",
                                              backgroundColor: Colors.black54,
                                              textColor: Colors.white,
                                            );
                                            return;
                                          }

                                          // ✅ لو وجدنا الامتحان
                                          final bookTitle =
                                              activeSetting.bookTitle;
                                          final chapterTitle =
                                              activeSetting.chapterTitle;
                                          final durationDays =
                                              activeSetting.durationDays;
                                          final isRepeatable =
                                              activeSetting.isRepeatable
                                              ? "نعم"
                                              : "لا";
                                          final hasTimer =
                                              activeSetting.hasTimer
                                              ? "نعم"
                                              : "لا";
                                          final Timestamp startTimestamp =
                                              activeSetting.examStart!;
                                          final DateTime examEndDate =
                                              startTimestamp.toDate().add(
                                                Duration(days: durationDays),
                                              );

                                          // ✅ عرض نافذة التفاصيل
                                          showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      20.dg,
                                                    ),
                                              ),
                                              backgroundColor: Colors.white,
                                              child: Container(
                                                padding: EdgeInsets.all(20.h),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      "تفاصيل الامتحان",
                                                      style: TextStyle(
                                                        fontSize: 20.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.indigo,
                                                      ),
                                                    ),
                                                    SizedBox(height: 15.h),
                                                    Card(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              15.dg,
                                                            ),
                                                      ),
                                                      color:
                                                          Colors.indigo.shade50,
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                          12.h,
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "📖 السفر: $bookTitle",
                                                              style: TextStyle(
                                                                fontSize: 16.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 5.h,
                                                            ),
                                                            Text(
                                                              "🧩 الإصحاح: $chapterTitle",
                                                              style: TextStyle(
                                                                fontSize: 16.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 5.h,
                                                            ),
                                                            Text(
                                                              "⏳ المدة: $durationDays يوم",
                                                              style: TextStyle(
                                                                fontSize: 16.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 5.h,
                                                            ),
                                                            Text(
                                                              "🔁 مكرر: $isRepeatable",
                                                              style: TextStyle(
                                                                fontSize: 16.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 5.h,
                                                            ),
                                                            Text(
                                                              "⏱ تايمر: $hasTimer",
                                                              style: TextStyle(
                                                                fontSize: 16.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 20.h),
                                                    Text(
                                                      "اختر طريقة البدء",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16.sp,
                                                      ),
                                                    ),
                                                    SizedBox(height: 10.h),

                                                    // ✅ أزرار الامتحان
                                                    Column(
                                                      children: [
                                                        ElevatedButton.icon(
                                                          onPressed: () {
                                                            if (DateTime.now()
                                                                .isAfter(
                                                                  examEndDate,
                                                                )) {
                                                              Fluttertoast.showToast(
                                                                msg:
                                                                    "⏳ انتهت مدة الامتحان",
                                                              );
                                                              return;
                                                            }
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                            Get.to(
                                                              () => ExamesQuizPage(
                                                                churchID:
                                                                    churchId!,
                                                                chapterID:
                                                                    chapterId!,
                                                                alngelID:
                                                                    activeSetting
                                                                        .bookId!,
                                                                alshahatID:
                                                                    activeSetting
                                                                        .chapterId!,
                                                              ),
                                                            );
                                                          },
                                                          icon: const Icon(
                                                            Icons.quiz,
                                                            color: Colors.white,
                                                          ),
                                                          label: Text(
                                                            "من سيربح الملكوت",
                                                            style: TextStyle(
                                                              fontSize: 15.sp,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.indigo,
                                                            minimumSize: Size(
                                                              double.infinity,
                                                              50.h,
                                                            ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                        // SizedBox(height: 10.h),
                                                        SizedBox(height: 10.h),
                                                        ElevatedButton.icon(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                            Get.to(
                                                              () =>
                                                                  RewardsPage(),
                                                            );
                                                          },
                                                          icon: const Icon(
                                                            Icons.emoji_events,
                                                            color: Colors.white,
                                                          ),
                                                          label: Text(
                                                            "الجوائز",
                                                            style: TextStyle(
                                                              fontSize: 15.sp,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors
                                                                    .amber[400],
                                                            minimumSize: Size(
                                                              double.infinity,
                                                              50.h,
                                                            ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12.dg,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    SizedBox(height: 10.h),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                          ),
                                                      child: const Text(
                                                        "إلغاء",
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        } finally {
                                          if (!mounted) return;
                                          setState(
                                            () => _isStartingExam = false,
                                          );
                                        }
                                      },
                                icon: _isStartingExam
                                    ? SizedBox(
                                        width: 20.h,
                                        height: 20.h,
                                        child: const CircularProgressIndicator(
                                          color: Colors.indigo,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.play_arrow),
                                label: Text(
                                  _isStartingExam ? "...تحميل" : "ابدأ الآن",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.sp,
                                    color: Colors.indigo,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 100.h,
                                    vertical: 14.h,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.dg),
                                  ),
                                ),
                              ),
                            ),

                            if (role == 'Admin' || role == 'SuperAdmin')
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                child: IconButton(
                                  onPressed: () {
                                    Get.to(() => ChurchesPage());
                                    ScaffoldMessenger.of(
                                      context,
                                    ).hideCurrentSnackBar();
                                    Fluttertoast.showToast(
                                      msg: "أنت مسؤول ✅",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.black54,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.admin_panel_settings,
                                    color: Colors.white,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepOrange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        10.dg,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Center(child: BibleReadButton()),
                      SizedBox(height: 50.h),
                    ],
                  ),
                ),
                SlideTransition(
                  position: _offsetAnimation,
                  child: SlideTransition(
                    position: _offsetAnimation,
                    child: AnimatedBuilder(
                      animation: _zoomAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _zoomAnimation.value,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedOpacity(
                                opacity: _textOpacity,
                                duration: const Duration(milliseconds: 400),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  child: ChatBubble(
                                    text: _welcomeText,
                                    // icon: Icons
                                    //     .waving_hand_rounded, // ممكن تغيرها لأي أيقونة أو تشيلها
                                  ),
                                ),
                              ),
                              Image.asset(
                                _currentImagePath,
                                height: 100.h,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 12),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 0.h), // ممكن تزود لو عايز مسافة
                child: Container(
                  width: 200.w,
                  height: 200.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(-1, 10),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: buildProfileImage(),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(top: 130.h, right: 110.w),
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder: (context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('اختر صورة من المعرض'),
                              onTap: () {
                                Navigator.pop(context);
                                selectImage();
                              },
                            ),
                            if (imageUrl != null || imageData != null)
                              ListTile(
                                leading: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                title: const Text('حذف الصورة'),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await userController.deleteProfileImage();
                                  if (!mounted) return;
                                  setState(() {
                                    imageUrl = null;
                                    imageData = null;
                                  });
                                  Fluttertoast.showToast(
                                    msg: '✅ تم حذف الصورة',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.black54,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                },
                              ),
                          ],
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(16.0.r),
                    child: const Icon(Icons.camera_alt, color: Colors.teal),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileImage() {
    if (imageData != null) {
      return CircleAvatar(
        radius: 105.0.r,
        backgroundImage: MemoryImage(imageData!),
      );
    } else if (imageUrl != null) {
      return CircleAvatar(
        radius: 105.0.r,
        backgroundImage: NetworkImage(imageUrl!),
      );
    } else {
      return const CircleAvatar(
        radius: 105.0,
        backgroundImage: AssetImage("assets/images/def_prof.avif"),
      );
    }
  }
}
