// ignore_for_file: unused_element

import 'dart:async';
import 'dart:math';

import 'package:aner_astaner/features/audio/presentation/controllers/audio_controller.dart';
import 'package:aner_astaner/Presentation/Views/MasterHome_Page.dart';
import 'package:aner_astaner/Presentation/widgets/ProgressTimer.dart';
import 'package:aner_astaner/Presentation/widgets/result_Box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:just_audio/just_audio.dart';

class VersesExamQuizPage extends StatefulWidget {
  final String? churchID;
  final String? chapterID;
  final String? alngelID;
  final String? alshahatID;
  static const String kFixedExameID = "nFL11C4v8fPRqIgG0ZAe";

  const VersesExamQuizPage({
    super.key,
    required this.churchID,
    required this.chapterID,
    required this.alngelID,
    required this.alshahatID,
  });

  @override
  State<VersesExamQuizPage> createState() => _VersesExamQuizPageState();
}

class _VersesExamQuizPageState extends State<VersesExamQuizPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final player = AudioPlayer();
  final backgroundPlayer = AudioPlayer();

  // data lists
  List<Map<String, dynamic>> versesDocs =
      []; // list of loaded verses data (maps)
  List<String> currentOrder = [];
  List<String> shuffledWords = [];
  late List<String> correctOrder;

  // UI / state
  bool showAnimation = false;
  String feedbackGif = "assets/carcter/pen_search.png";
  bool? wasLastAnswerCorrect;
  String feedbackText = '';
  bool showFeedbackText = false;

  bool isLoading = true;
  bool hasTimer = false;
  bool isRepeatable = false;
  int durationDays = 1;
  double timerDuration = 30; // from settings (seconds)
  int index = 0;
  int scoreAyat = 0;

  // timer
  Timer? _timer;
  late int maxSec;
  RxInt? sec;

  // animations
  late AnimationController _shakeController;
  late Animation<Offset> _shakeAnimation;
  late AnimationController _bounceController;
  late Animation<Offset> _bounceAnimation;

  // online counter (same UX)
  int onlineUsers = 100;
  Timer? _onlineTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.03, 0),
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.1),
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_bounceController);

    _prepareAudio();
    playBackgroundMusic();
    startOnlineCounter();

    // initial access check (includes loading settings -> verses)
    checkUserAccess();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => showAnimation = true);
    });
    final audio = Get.find<AudioController>();
    audio.pauseMusic();
  }

  Future<void> _prepareAudio() async {
    try {
      // we only set asset when we need to play; just prepare background
      await player.setAsset('assets/audio/correct.mp3');
      await backgroundPlayer.setAsset('assets/audio/Q_music_back.mp3');
      await backgroundPlayer.setLoopMode(LoopMode.one);
    } catch (e) {
      debugPrint("Audio prepare error: $e");
    }
  }

  Future<void> playBackgroundMusic() async {
    try {
      await backgroundPlayer.play();
    } catch (e) {
      debugPrint("Background audio play error: $e");
    }
  }

  void startOnlineCounter() {
    final random = Random();
    _onlineTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        onlineUsers = 80 + random.nextInt(120);
      });
    });
  }

  // ---------------------------
  // Access checks (same as your logic)
  // ---------------------------
  Future<void> checkUserAccess() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();
    final userData = userDoc.data() ?? {};
    if (userData["VersesExamDone"] == true) {
      // أظهر رسالة بدل التحويل المباشر
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("⚠️ انتهى الامتحان"),
            content: const Text(
              "لقد أكملت هذا الامتحان سابقًا ولا يمكنك الدخول مرة أخرى.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MasterHome()),
                  );
                },
                child: const Text("رجوع"),
              ),
            ],
          ),
        );
      }
      return;
    }

    final role = userData['role'] ?? '';
    final status = userData['status'] ?? 'pending';

    if (role == 'Admin' || role == 'SuperAdmin' || role == 'DataAdmin') {
      await loadVersesSettingsAndVerses();
      return;
    }

    if (status != "correct") {
      if (!mounted) return;
      await backgroundPlayer.stop();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("⚠️ انتظار الموافقة"),
          content: const Text(
            "لم يتم تفعيل حسابك بعد. يرجى انتظار موافقة الخادم المسئول.",
          ),
          actions: [
            TextButton(
              onPressed: () {
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

    // check Approved
    final approvedDoc = await FirebaseFirestore.instance
        .collection("Churches")
        .doc(widget.churchID)
        .collection("Chapters")
        .doc(widget.chapterID)
        .collection("Approved")
        .doc(uid)
        .get();

    if (!approvedDoc.exists) {
      if (!mounted) return;
      await backgroundPlayer.stop();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("🚫 غير مصرح لك بالدخول"),
          content: const Text(
            "لم يتم اعتمادك بعد من الخادم المسئول على هذا الفصل.",
          ),
          actions: [
            TextButton(
              onPressed: () {
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

    await loadVersesSettingsAndVerses();
  }

  // ---------------------------
  // Load VersesSettings (latest) + fetch verses by IDs
  // ---------------------------
  Future<void> loadVersesSettingsAndVerses() async {
    setState(() => isLoading = true);

    try {
      final examDocRef = FirebaseFirestore.instance
          .collection("Churches")
          .doc(widget.churchID)
          .collection("Chapters")
          .doc(widget.chapterID)
          .collection("Exames")
          .doc(VersesExamQuizPage.kFixedExameID);

      // get latest VersesSettings doc (by timestamp)
      final settingsQuery = await examDocRef
          .collection("VersesSettings")
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (settingsQuery.docs.isEmpty) {
        debugPrint("No VersesSettings found.");
        setState(() {
          isLoading = false;
        });
        return;
      }

      final settings = settingsQuery.docs.first.data();
      // read settings
      durationDays = (settings['durationDays'] ?? 1) as int;
      hasTimer = (settings['hasTimer'] ?? false) as bool;
      isRepeatable = (settings['isRepeatable'] ?? false) as bool;
      timerDuration = (settings['timerDuration'] != null)
          ? (settings['timerDuration'] as num).toDouble()
          : 30.0;

      final versesIds = List<String>.from(settings['versesIds'] ?? []);
      final versesTitles = List<String>.from(settings['versesTitles'] ?? []);

      // fetch each verse document by id (AyatQuiz/{id})
      final List<Map<String, dynamic>> loaded = [];

      for (int i = 0; i < versesIds.length; i++) {
        final id = versesIds[i];
        final doc = await examDocRef.collection("AyatQuiz").doc(id).get();
        if (!doc.exists) continue;
        // ignore: unnecessary_cast
        final d = doc.data() as Map<String, dynamic>? ?? {};

        // read words list (words)
        final words = <String>[];
        if (d.containsKey('words') && d['words'] is List) {
          try {
            words.addAll(List<String>.from(d['words']));
          } catch (_) {
            // ignore type issues
          }
        }

        loaded.add({
          'id': id,
          'words': words,
          'title': (i < versesTitles.length)
              ? versesTitles[i]
              : (d['title'] ?? words.take(6).join(' ')),
          'raw': d,
        });
      }

      if (loaded.isEmpty) {
        debugPrint("No verses loaded from VersesSettings ids.");
        setState(() {
          isLoading = false;
        });
        return;
      }

      setState(() {
        versesDocs = loaded;
        index = 0;
        scoreAyat = 0;
        isLoading = false;
      });

      // initialize first verse
      updateVerseFromData();
    } catch (e) {
      debugPrint("Error loading VersesSettings or verses: $e");
      setState(() => isLoading = false);
    }
  }

  // ---------------------------
  // Verse handling & timer
  // ---------------------------
  void updateVerseFromData() {
    if (index < 0 || index >= versesDocs.length) return;

    final wordsData = List<String>.from(versesDocs[index]['words'] ?? []);
    correctOrder = List<String>.from(wordsData);
    shuffledWords = List.from(correctOrder)..shuffle(Random());
    currentOrder = List.from(shuffledWords);

    // timer seconds come from timerDuration (if present), else default 40
    maxSec = timerDuration.toInt() > 0 ? timerDuration.toInt() : 40;
    sec = RxInt(maxSec);

    // start timer if needed
    stopTimer();
    if (hasTimer) startTimer();
  }

  void startTimer() {
    resetTimer();
    _timer?.cancel();
    if (!mounted) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (sec != null && sec!.value > 0) {
        if (sec!.value == 10) {
          // play warning
          try {
            await player.setAsset('assets/audio/warning.mp3');
            await player.play();
          } catch (e) {
            debugPrint('Warning audio error: $e');
          }
        }
        sec!.value--;
      } else {
        // time ended
        stopTimer();
        if (!mounted) return;
        setState(() {
          wasLastAnswerCorrect = false;
          feedbackGif = "assets/carcter/wrong.png";
          feedbackText = "انتهى الوقت ❌";
          showFeedbackText = true;
        });
        try {
          await player.setAsset('assets/audio/wrong.mp3');
          await player.play();
        } catch (e) {
          debugPrint("Timeout audio error: $e");
        }
        _shakeController.forward(from: 0);

        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          nextQuestion();
        });
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void resetTimer() {
    if (sec != null) sec!.value = maxSec;
  }

  // ---------------------------
  // Check answer (compare currentOrder to correctOrder)
  // ---------------------------
  void checkAnswer() {
    final isCorrect = listEquals(currentOrder, correctOrder);
    if (!mounted) return;

    setState(() {
      wasLastAnswerCorrect = isCorrect;
      feedbackGif = isCorrect
          ? "assets/carcter/correct.png"
          : "assets/carcter/wrong.png";
      feedbackText = isCorrect ? "إجابة صحيحة!" : "إجابة خاطئة!";
      showFeedbackText = true;
      showAnimation = true;
    });

    try {
      player.setAsset(
        isCorrect ? 'assets/audio/correct.mp3' : 'assets/audio/wrong.mp3',
      );
      player.play();
    } catch (e) {
      debugPrint("Audio play error: $e");
    }

    if (isCorrect) {
      _bounceController.forward(from: 0);
      scoreAyat++;
    } else {
      _shakeController.forward(from: 0);
    }

    // small delay then next
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      nextQuestion();
    });
  }

  // ---------------------------
  // Navigation between verses
  // ---------------------------
  Future<void> nextQuestion() async {
    if (!mounted) return;

    // reset UI flags
    setState(() {
      showFeedbackText = false;
      showAnimation = false;
    });

    stopTimer();

    final isLast = index >= versesDocs.length - 1;
    if (isLast) {
      await saveUserResult();
      // show result dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => ResultBox(
          onPressed: startOver,
          score: scoreAyat,
          questionLength: versesDocs.length,
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MasterHome()),
          (r) => false,
        );
      });
    } else {
      // advance
      setState(() {
        index++;
      });
      updateVerseFromData();
    }
  }

  Future<void> saveUserResult() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();
    // ignore: unnecessary_cast
    final userData = userDoc.data() as Map<String, dynamic>?;

    final total = versesDocs.length;
    final percentage = total == 0 ? 0.0 : (scoreAyat / total) * 100.0;

    final resultData = {
      'userId': uid,
      'scoreAyat': scoreAyat,
      'totalQuestionsAyat': total,
      'percentageAyat': percentage.toStringAsFixed(1),
      'full_name': userData?['full_name'],
      'Church': userData?['Church'],
      'ChurchID': userData?['ChurchID'],
      'chapterID': widget.chapterID,
      'examChurchID': widget.churchID,
      'date': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection("ExamesAyat").add(resultData);
      debugPrint("✅ Saved ExamesAyat: $resultData");
    } catch (e) {
      debugPrint("Error saving ExamesAyat: $e");
    }
  }

  void startOver() {
    if (!mounted) return;
    setState(() {
      index = 0;
      scoreAyat = 0;
      updateVerseFromData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    backgroundPlayer.stop();
    _timer?.cancel();
    _onlineTimer?.cancel();
    player.dispose();
    backgroundPlayer.dispose();
    _shakeController.dispose();
    _bounceController.dispose();
    final audio = Get.find<AudioController>();
    audio.resumeMusic();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // لو راح للهوم أو خرج:
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      // احفظ النتيجة
      await saveUserResult();

      // اعمل flag فى Firestore انه حل الامتحان
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({"VersesExamDone": true});
      // مش هننقل مباشرة هنا لأن التطبيق ممكن يرجع
      // لكن لما يرجع نمنعه من الدخول تاني (Check access)
      //////////////////////////////////////////////// ignore: unused_element///////////////////////////////////
      void handleExit() async {
        await saveUserResult();

        // ضع علامة انتهاء الامتحان
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await FirebaseFirestore.instance.collection("users").doc(uid).update({
            "VersesExamDone": true,
          });
        }

        // ارجع للصفحة الرئيسية
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MasterHome()),
            (route) => false,
          );
        }
      }
    }
  }

  // small helper for comparing lists (order matters)
  bool listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // ---------------------------
  // UI (kept same as your original with ReorderableListView)
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (versesDocs.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            "لا توجد آيات متاحة حاليًا.",
            style: TextStyle(fontSize: 18.sp),
          ),
        ),
      );
    }

    // safety
    if (index >= versesDocs.length) index = versesDocs.length - 1;
    final currentVerse = versesDocs[index];
    final title = currentVerse['title'] ?? '';
    // currentOrder / shuffledWords already set in updateVerseFromData

    return WillPopScope(
      onWillPop: () async {
        // لا تسمح بالرجوع
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.black12,
          leading: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.white),
                  SizedBox(width: 3.w),
                  Icon(
                    Icons.question_mark_sharp,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Text(
                    "    $scoreAyat",
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
                        const TextSpan(
                          text: '/',
                          style: TextStyle(fontSize: 12),
                        ),
                        TextSpan(
                          text: "${versesDocs.length}",
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
                    padding: const EdgeInsets.only(
                      right: 12.0,
                      top: 5,
                      bottom: 5,
                    ),
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
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    SizedBox(height: 100.h),
                    SizedBox(height: 20.h),
                    Container(
                      padding: EdgeInsets.all(3.dg),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.dg),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 1),
                        ],
                      ),
                      child: SizedBox(
                        height: 20.h,
                        child: Text(
                          title.isEmpty
                              ? "رتب الكلمات التالية لتكوين الآية"
                              : title,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        SizedBox(width: 10.w),
                        SlideTransition(
                          position: wasLastAnswerCorrect == true
                              ? _bounceAnimation
                              : _shakeAnimation,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 500),
                            opacity: showAnimation ? 1.0 : 0.0,
                            child: Image.asset(feedbackGif, height: 120),
                          ),
                        ),
                      ],
                    ),

                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(70.0.dg),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20.dg),
                        child: Column(
                          children: [
                            SizedBox(height: 10.h),

                            SizedBox(
                              height: 400.h,
                              child: ReorderableListView(
                                buildDefaultDragHandles: true,
                                onReorder: (oldIndex, newIndex) {
                                  if (!mounted) return;
                                  setState(() {
                                    if (newIndex > oldIndex) newIndex -= 1;
                                    final item = currentOrder.removeAt(
                                      oldIndex,
                                    );
                                    currentOrder.insert(newIndex, item);
                                  });
                                },
                                children: [
                                  for (int i = 0; i < currentOrder.length; i++)
                                    ListTile(
                                      key: ValueKey(currentOrder[i]),
                                      title: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            15.dg,
                                          ),
                                        ),
                                        child: Text(
                                          currentOrder[i],
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyan[700],
                                foregroundColor: Colors.white,
                              ),
                              onPressed: checkAnswer,
                              child: Text(
                                "تحقق من الترتيب",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          color: Colors.black54,
          padding: EdgeInsets.all(9.dg),
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
