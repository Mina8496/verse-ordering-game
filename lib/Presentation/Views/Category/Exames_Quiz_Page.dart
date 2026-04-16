// ignore_for_file: unnecessary_cast, non_constant_identifier_names
import 'dart:async';
import 'package:aner_astaner/Presentation/Controller/AudioController.dart';
import 'package:aner_astaner/Presentation/Controller/ExamController.dart';
import 'package:aner_astaner/Presentation/Controller/constants.dart';
import 'package:aner_astaner/Presentation/Views/MasterHome_Page.dart';
import 'package:aner_astaner/Presentation/widgets/ProgressTimer.dart';
import 'package:aner_astaner/Presentation/widgets/option_card.dart';
import 'package:aner_astaner/Presentation/widgets/result_Box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';

class ExamesQuizPage extends StatefulWidget {
  final String churchID;
  final String chapterID;
  final String alngelID;
  final String alshahatID;
  //   final int durationDays;
  // final bool hasTimer;
  // final bool isRepeatable;

  static const String kFixedExameID = "nFL11C4v8fPRqIgG0ZAe";
  static Map<String, QueryDocumentSnapshot> dataToApp = {};

  const ExamesQuizPage({
    super.key,
    required this.churchID,
    required this.chapterID,
    required this.alngelID,
    required this.alshahatID,
  });

  @override
  State<ExamesQuizPage> createState() => _ExamesQuizPageState();
}

class _ExamesQuizPageState extends State<ExamesQuizPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  List<QueryDocumentSnapshot> data = [];
  String feedbackGif = "assets/carcter/pen_search.gif";
  bool showAnimation = false;
  late AnimationController _shakeController;
  late Animation<Offset> _shakeAnimation;
  late AnimationController _bounceController;
  late Animation<Offset> _bounceAnimation;
  bool? wasLastAnswerCorrect;
  String feedbackText = '';
  bool showFeedbackText = false;

  final correctPlayer = AudioPlayer();
  final wrongPlayer = AudioPlayer();
  final warningPlayer = AudioPlayer();
  final backgroundPlayer = AudioPlayer();

  int durationDays = 1;
  int? selectedOptionIndex;

  bool hasTimer = false;
  bool isRepeatable = false;

  bool isLoading = true;

  int onlineUsers = 123;
  Timer? _onlineTimer;
  // Timer related variables
  Timer? _timer;
  late int maxSec;
  RxInt? sec;

  // final RxInt sec = 60.obs;

  int index = 0;
  int score = 0;
  bool isPressed = false;
  bool isAlreadySelected = false;
  String? bookTitle;
  String? chapterTitle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    backgroundPlayer.pause();
    final audio = Get.find<AudioController>();

    audio.isPlaying.value = false;
    audio.player.pause();

    _initPlayers();
    WidgetsBinding.instance.addObserver(this);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.05, 0), // هزة صغيرة أفقية
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.1),
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_bounceController);

    _bounceAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.1), // يتحرك لأعلى قليلاً
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_bounceController);

    checkUserAccess();
    playBackgroundMusic();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => showAnimation = true);
    });
    startOnlineCounter();
  }

  void startOnlineCounter() {
    final random = Random();
    _onlineTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        // يولد رقم عشوائي بين 80 و 200 مثلا
        onlineUsers = 80 + random.nextInt(120);
      });
    });
  }

  Future<void> _initPlayers() async {
    try {
      await correctPlayer.setAsset('assets/audio/correct.mp3');
      await wrongPlayer.setAsset('assets/audio/wrong.mp3');
      await warningPlayer.setAsset('assets/audio/warning.mp3');
      await backgroundPlayer.setAsset('assets/audio/Q_music_back.mp3');
      await backgroundPlayer.setLoopMode(LoopMode.one);
    } catch (e) {
      debugPrint("⚠️ خطأ في تحميل الملفات الصوتية: $e");
    }
  }

  Future<void> playBackgroundMusic() async {
    try {
      await backgroundPlayer.setAsset('assets/audio/Q_music_back.mp3');
      await backgroundPlayer.setLoopMode(LoopMode.one);
      await backgroundPlayer.play();
    } catch (e) {
      debugPrint("⚠️ خطأ عند تشغيل الموسيقى الخلفية: $e");
    }
  }

  Future<void> checkUserAccess() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // 1️⃣ تحقق من بيانات المستخدم
    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    final userData = userDoc.data() ?? {};
    final role = userData['role'] ?? '';
    final status = userData['status'] ?? 'pending'; // 👈 نضيفها هنا

    // 2️⃣ لو المستخدم Admin أو DataAdmin يدخل عادي
    if (role == 'DataAdmin' || role == 'Admin' || role == 'SuperAdmin') {
      initQuiz();
      return;
    }

    // 3️⃣ لو status مش "correct" نمنع الدخول
    if (status != "correct") {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("غير مسموح بالدخول"),
          content: Text(
            "حالتك الحالية: $status\nيرجى انتظار الموافقة قبل دخول الامتحان.",
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await backgroundPlayer.stop();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MasterHome()),
                  );
                }
              },
              child: const Text("رجوع"),
            ),
          ],
        ),
      );
      return;
    }

    // 4️⃣ لو المستخدم عنده status = correct، نكمل التحقق من Approved
    final approvedDoc = await FirebaseFirestore.instance
        .collection("Churches")
        .doc(widget.churchID)
        .collection("Chapters")
        .doc(widget.chapterID)
        .collection("Approved")
        .doc(uid)
        .get();

    if (approvedDoc.exists) {
      initQuiz();
      return;
    }

    // 5️⃣ المستخدم مش في Approved
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("انتظار الموافقة"),
        content: const Text(
          "انتظر الموافقة من الخادم المسئول. جرب في وقت لاحق.",
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await backgroundPlayer.stop();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MasterHome()),
                );
              }
            },
            child: const Text("رجوع"),
          ),
        ],
      ),
    );
  }

  Future<void> initQuiz() async {
    await fetchExamSettings();

    if (!isRepeatable) {
      final alreadySubmitted = await hasUserSubmittedBefore();
      if (alreadySubmitted) {
        // المستخدم حل قبل كده، نمنعه
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("تم حل الامتحان من قبل"),
            content: const Text("لا يمكنك دخول هذا الامتحان مرة أخرى."),
            actions: [
              TextButton(
                onPressed: () async {
                  await backgroundPlayer.stop();
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MasterHome()),
                    );
                  }
                },
                child: const Text("رجوع"),
              ),
            ],
          ),
        );

        return;
      }
    }

    await getQuestions();
    print("عدد الأسئلة المحمّلة: ${data.length}");
    final examController = Get.find<ExamController>();
    examController.isExamRunning.value = true; // الامتحان شغال

    // ✅ تأكد أن القيم جاهزة تمامًا قبل تشغيل التايمر
    if (hasTimer) {
      await Future.delayed(
        const Duration(milliseconds: 200),
      ); // تأخير بسيط للتأكيد
      print("🎯 بدء التايمر بقيمة: $maxSec ثانية من الإعدادات");
      sec = RxInt(maxSec);
      startTimer();
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _handleExitBeforeFinish() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();
    final userData = userDoc.data() ?? {};

    final full_name = userData['full_name'];
    final Church = userData['Church'];
    final userChurchID = userData['ChurchID'];

    final resultId = "${widget.alngelID}_${widget.alshahatID}";
    final resultRef = FirebaseFirestore.instance
        .collection("Exames")
        .doc(uid)
        .collection("Results")
        .doc(resultId);

    final percentage = data.isEmpty ? 0 : ((score / data.length) * 100);

    await resultRef.set({
      'score': score,
      'totalQuestions': data.length,
      'percentage': percentage.toStringAsFixed(1),
      'date': FieldValue.serverTimestamp(),
      'alngelID': widget.alngelID,
      'alshahatID': widget.alshahatID,
      'bookTitle': bookTitle,
      'chapterTitle': chapterTitle,
      'full_name': full_name,
      'Church': Church,
      'userChurchID': userChurchID,
      'examChurchID': widget.churchID,
      'chapterID': widget.chapterID,
      'userId': uid,
      'attempts': 1,
      'status': 'left_exam',
    });

    await backgroundPlayer.stop();

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text("تم حفظ النتيجة"),
          content: const Text("تم حفظ نتيجتك الحالية قبل الخروج من الامتحان."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MasterHome()),
                  (route) => false,
                );
              },
              child: const Text("رجوع"),
            ),
          ],
        ),
      );
    }
  }

  Future<void> fetchExamSettings() async {
    try {
      final now = DateTime.now(); // 🕒 استخدم التوقيت المحلي
      bool foundValidSettings = false;

      final settingsCollection = await FirebaseFirestore.instance
          .collection('Churches')
          .doc(widget.churchID)
          .collection('Chapters')
          .doc(widget.chapterID)
          .collection('Exames')
          .doc(ExamesQuizPage.kFixedExameID)
          .collection('Settings')
          .get();

      for (var doc in settingsCollection.docs) {
        final data = doc.data();
        final Timestamp? startTimestamp = data['examStart'] as Timestamp?;
        final Timestamp? endTimestamp = data['examEnd'] as Timestamp?;

        if (startTimestamp != null && endTimestamp != null) {
          final startDate = startTimestamp.toDate();
          final endDate = endTimestamp.toDate();

          // 🧾 طباعة التواريخ للتأكد
          print("🔍 الآن: $now");
          print("📅 start: $startDate | end: $endDate");

          // ✅ لو start == end، خليه مفتوح لنفس اليوم كامل
          final effectiveEnd = endDate.isAtSameMomentAs(startDate)
              ? endDate.add(const Duration(hours: 23, minutes: 59, seconds: 59))
              : endDate;

          // ✅ الشرط النهائي لفحص صلاحية الامتحان
          if (now.isAfter(startDate) && now.isBefore(effectiveEnd)) {
            print("✅ تم العثور على إعداد امتحان صالح الآن");

            durationDays = data['durationDays'] ?? 1;
            hasTimer = data['hasTimer'] ?? false;
            isRepeatable = data['isRepeatable'] ?? false;
            bookTitle = data['bookTitle'] ?? 'غير محدد';
            chapterTitle = data['chapterTitle'] ?? 'غير محدد';

            // ⏱️ قراءة زمن التايمر من الإعدادات
            int timerFromSettings = data['timerDuration'] ?? 40;
            maxSec = timerFromSettings;
            sec = RxInt(maxSec);
            print(
              "✅ تم تحميل إعدادات الامتحان: hasTimer=$hasTimer | maxSec=$maxSec",
            );

            print("⏱️ وقت السؤال من الإعدادات: $maxSec ثانية");

            foundValidSettings = true;
            break;
          }
        }
      }

      if (!foundValidSettings) {
        print("⚠️ لا يوجد امتحان متاح حاليًا");
        Get.snackbar(
          'تنبيه',
          'لا يوجد امتحان متاح في الوقت الحالي',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("❌ خطأ أثناء تحميل إعدادات الامتحان: $e");
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل الإعدادات: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> getQuestions() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("Churches")
        .doc(widget.churchID)
        .collection("Chapters")
        .doc(widget.chapterID)
        .collection("Exames")
        .doc(ExamesQuizPage.kFixedExameID)
        .collection("Alangel")
        .doc(widget.alngelID)
        .collection("Alshahat")
        .doc(widget.alshahatID)
        .collection("Qusstions")
        .get();

    data = querySnapshot.docs;
    print("✅ عدد الأسئلة المحملة: ${data.length}");
    for (var doc in data) {
      print("📄 سؤال: ${doc.data()}");
    }

    isLoading = false;
    setState(() {});
  }

  Future<void> saveUserResult() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();
    final userData = userDoc.data() as Map<String, dynamic>?;

    final full_name = userData?['full_name'];
    final Church = userData?['Church'];
    final userChurchID = userData?['ChurchID'];

    final resultId = "${widget.alngelID}_${widget.alshahatID}";
    final resultRef = FirebaseFirestore.instance
        .collection("Exames")
        .doc(uid)
        .collection("Results")
        .doc(resultId);

    final snapshot = await resultRef.get();

    // ⚡ استخدم null-aware operator للتأكد من وجود الحقل
    int attempts = snapshot.exists
        ? (snapshot.data()?['attempts'] as int? ?? 0)
        : 0;

    final resultData = {
      'score': score,
      'totalQuestions': data.length,
      'percentage': ((score / data.length) * 100).toStringAsFixed(1),
      'date': FieldValue.serverTimestamp(),
      'alngelID': widget.alngelID,
      'alshahatID': widget.alshahatID,
      'bookTitle': bookTitle,
      'chapterTitle': chapterTitle,
      'full_name': full_name,
      'Church': Church,
      'userChurchID': userChurchID,
      'examChurchID': widget.churchID,
      'chapterID': widget.chapterID,
      'userId': uid,
      'attempts': attempts + 1, // ⬅️ نخزن عدد المحاولات
    };

    await resultRef.set(resultData);
    print("✅ Result saved with attempt ${attempts + 1}");
  }

  Future<bool> hasUserSubmittedBefore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    final resultId = "${widget.alngelID}_${widget.alshahatID}";
    final docRef = FirebaseFirestore.instance
        .collection('Exames')
        .doc(uid)
        .collection('Results')
        .doc(resultId);

    final snapshot = await docRef.get();

    // ⚡ تحديد نوع الحقل صراحة
    final attempts = snapshot.exists
        ? (snapshot.data()?['attempts'] as int? ?? 0)
        : 0;

    if (isRepeatable) {
      return false;
    } else {
      return attempts >= 1;
    }
  }

  void startTimer() {
    stopTimer(); // ⬅️ تأكد مفيش تايمر قديم شغال
    resetTimer(); // رجّع العداد لـ maxSec
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (sec != null && sec!.value > 0) {
        if (sec!.value == 10) {
          // تحذير آخر 10 ثواني (اختياري)
          try {
            await warningPlayer.seek(Duration.zero);
            await warningPlayer.play();
          } catch (e) {
            debugPrint('Error playing warning sound: $e');
          }
        }
        sec!.value--;
      } else {
        stopTimer();
        // خلص الوقت: اعتبر السؤال خاطئ وامشي للسؤال اللي بعده
        setState(() {
          wasLastAnswerCorrect = false;
          feedbackText = 'انتهى الوقت ⏰';
          showFeedbackText = true;
          feedbackGif = "assets/carcter/wrong.png";
        });
        _shakeController.forward(from: 0);
        try {
          await wrongPlayer.seek(Duration.zero);
          await wrongPlayer.play();
        } catch (e) {
          debugPrint("Error playing wrong sound: $e");
        }
        await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
        nextQuestion();
      }
    });
  }

  void stopTimer() => _timer?.cancel();

  void resetTimer() {
    if (sec == null) {
      sec = RxInt(maxSec);
    } else {
      sec!.value = maxSec;
    }
  }

  ///////////
  // void stopTimer() => _timer?.cancel();
  // void resetTimer() => sec?.value = maxSec;

  void chackAnserAndUpdate(bool value, int selectedIndex) async {
    if (isAlreadySelected) return;

    try {
      if (value == true) {
        // ✅ إجابة صحيحة
        setState(() {
          wasLastAnswerCorrect = true;
          feedbackText = 'إجابة صحيحة ✔️';
          showFeedbackText = true;
          feedbackGif = "assets/carcter/correct.png";
        });

        _bounceController.forward(from: 0);

        await correctPlayer.seek(Duration.zero);
        await correctPlayer.play();
      } else {
        // ❌ إجابة خاطئة
        setState(() {
          wasLastAnswerCorrect = false;
          feedbackText = 'إجابة خاطئة ❌';
          showFeedbackText = true;
          feedbackGif = "assets/carcter/wrong.png";
        });

        _shakeController.forward(from: 0);

        await wrongPlayer.seek(Duration.zero);
        await wrongPlayer.play();
      }
    } catch (e) {
      debugPrint("Error playing answer sound: $e");
    }

    if (value) score++;

    setState(() {
      selectedOptionIndex = selectedIndex;
      isPressed = true;
      isAlreadySelected = true;
    });

    // ⏳ إخفاء النص بعد 1.5 ثانية
    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      if (mounted) {
        setState(() {
          showFeedbackText = false;
        });
      }
    });
  }

  Future<void> nextQuestion() async {
    // 🛠️ أعد ضبط كل القيم أولاً
    setState(() {
      isPressed = false;
      isAlreadySelected = false;
      selectedOptionIndex = null;
      showFeedbackText = false;
      showAnimation = false;
    });

    await Future.delayed(const Duration(milliseconds: 200));

    final isLastQuestion = index == data.length - 1;

    if (isLastQuestion) {
      stopTimer();
      if (bookTitle == null ||
          chapterTitle == null ||
          bookTitle == 'غير محدد' ||
          chapterTitle == 'غير محدد') {
        await fetchExamSettings();
      }
      await saveUserResult();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => ResultBox(
          onPressed: startOver,
          score: score,
          questionLength: data.length,
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MasterHome()),
          (route) => false,
        );
      });
    } else {
      setState(() {
        index++;
        showAnimation = true;
      });

      if (hasTimer) {
        startTimer(); // ⬅️ startTimer نفسه بيعمل cancel + reset + start
      }
    }
  }

  void startOver() {
    setState(() {
      index = 0;
      score = 0;
      isPressed = false;
      isAlreadySelected = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _onlineTimer?.cancel();
    correctPlayer.dispose();
    wrongPlayer.dispose();
    warningPlayer.dispose();
    backgroundPlayer.dispose();
    _shakeController.dispose();
    _bounceController.dispose();
    final audio = Get.find<AudioController>();
    audio.player.play();
    super.dispose();
    // ✅ حفظ النتيجة عند الخروج فقط إن كان الامتحان غير منتهي
    if (data.isNotEmpty && index < data.length - 1) {
      _handleExitBeforeFinish();
    }
    final examController = Get.find<ExamController>();

    examController.isExamRunning.value = false; // الامتحان انتهى

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _handleExitBeforeFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (index >= data.length || data.isEmpty || data[index].data() == null) {
      return Scaffold(
        body: Center(
          child: Text("جارى تحميل الاسئله", style: TextStyle(fontSize: 18.sp)),
        ),
      );
    }

    if (isLoading || data.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("جارى تجميع الأسئلة... تأكد من الاتصال بالإنترنت")],
          ),
        ),
      );
    } else if (data.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            "لا توجد أسئلة متاحة حاليًا لهذا الامتحان.",
            style: TextStyle(fontSize: 18.sp),
          ),
        ),
      );
    }

    // ✅ استخدم WillPopScope هنا
    return WillPopScope(
      onWillPop: () async {
        // المستخدم مش هيقدر يرجع
        await _handleExitBeforeFinish();

        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.black12,
          automaticallyImplyLeading: false, // ⬅️ يخفي زر الرجوع
          leading: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.white),
                  SizedBox(width: 3.w),
                  const Icon(
                    Icons.question_mark_sharp,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Text(
                    "    $score",
                    style: TextStyle(fontSize: 8.sp, color: Colors.white),
                  ),
                  const Spacer(),
                  RichText(
                    text: TextSpan(
                      text: '${index + 1}',
                      style: Theme.of(context).textTheme.headlineMedium!
                          .copyWith(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Tajawal',
                          ),
                      children: [
                        TextSpan(
                          text: '/',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        TextSpan(
                          text: "${data.length}",
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: hasTimer && sec != null
              ? [
                  Padding(
                    padding: EdgeInsets.only(right: 12.0, top: 5, bottom: 5),
                    child: ProgressTimer(maxSec: maxSec, sec: sec!),
                  ),
                ]
              : [],
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/Backgrounds/background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 100.h),
                SizedBox(height: 20.h),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 1),
                    ],
                  ),
                  child: Text(
                    "أختر اجابة واحدة",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                AnimatedSlide(
                  duration: const Duration(milliseconds: 500),
                  offset: showAnimation ? Offset.zero : const Offset(1, 0),
                  curve: Curves.easeOut,
                  child: Text(
                    data[index]["Quiz"],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                      color: Colors.white,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (showFeedbackText)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          feedbackText,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: wasLastAnswerCorrect == true
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    SlideTransition(
                      position: wasLastAnswerCorrect == true
                          ? _bounceAnimation
                          : _shakeAnimation,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: showAnimation ? 1.0 : 0.0,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Image.asset(feedbackGif, height: 120),
                        ),
                      ),
                    ),
                  ],
                ),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  height: BouncingScrollSimulation.maxSpringTransferVelocity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(70.0.dg),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.dg),
                    child: Column(
                      children: [
                        SizedBox(height: 50.h),
                        for (int i = 0; i < data[index]["options"].length; i++)
                          GestureDetector(
                            onTap: () async {
                              chackAnserAndUpdate(
                                data[index]["options"].values.toList()[i],
                                i,
                              );
                              await Future.delayed(
                                const Duration(seconds: 1, milliseconds: 500),
                              );
                              nextQuestion(); // ⬅️ و nextQuestion هتعمل startTimer لو مطلوب
                            },

                            child: AnimatedSlide(
                              duration: Duration(milliseconds: 500 + i * 100),
                              offset: showAnimation
                                  ? Offset.zero
                                  : const Offset(0, 1),
                              curve: Curves.easeOut,
                              child: OptionCard(
                                option: data[index]["options"].keys.toList()[i],
                                color: isPressed
                                    ? i == selectedOptionIndex
                                          ? data[index]["options"].values
                                                        .toList()[i] ==
                                                    true
                                                ? correct
                                                : incorrect
                                          : neutral
                                    : neutral,
                              ),
                            ),
                          ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        /// 👇 هنا أضفنا العداد الوهمي في الأسفل
        bottomNavigationBar: Container(
          color: Colors.black54,
          padding: EdgeInsets.all(12.dg),
          child: Text(
            "عدد المشتركين الاونلاين الان : $onlineUsers",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
