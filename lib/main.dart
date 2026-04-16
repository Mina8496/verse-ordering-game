import 'package:aner_astaner/Presentation/Controller/AudioController.dart';
import 'package:aner_astaner/Presentation/Controller/ExamController.dart';
import 'package:aner_astaner/Presentation/Views/Adds_Category/AddNewCatgory.dart';
import 'package:aner_astaner/Presentation/Views/Adds_Category/Add_churches_Box.dart';
import 'package:aner_astaner/Presentation/Views/Category/Category_Page.dart';
import 'package:aner_astaner/Presentation/Views/Category/Chapters_Page.dart';
import 'package:aner_astaner/Presentation/Views/Category/Churches_Page.dart';
import 'package:aner_astaner/Presentation/Views/Home_page.dart';
import 'package:aner_astaner/Presentation/Views/Login/Completw_information_body.dart';
import 'package:aner_astaner/Presentation/Views/Login/Inital_Login.dart';
import 'package:aner_astaner/Presentation/Views/Login/Rigester_View.dart';
import 'package:aner_astaner/Presentation/Views/Login/login_Page.dart';
import 'package:aner_astaner/Presentation/Views/MasterHome_Page.dart';
import 'package:aner_astaner/Presentation/on%20Bording/splash_body.dart';
import 'package:aner_astaner/Presentation/widgets/BottomNavBar.dart';
import 'package:aner_astaner/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:upgrader/upgrader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await FirebaseFirestore.instance.clearPersistence();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.put(AudioController());
  Get.put(ExamController());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: UpgradeAlert(
        dialogStyle: UpgradeDialogStyle.material,
        // canDismissDialog: false, // ❌ يمنع إغلاق الديالوج
        showIgnore: false, // ❌ يمنع Ignore
        showLater: false,
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(fontFamily: 'Tajawal'),
              home: const SplashViewBody(),
              routes: {
                "splashPage": (context) => const SplashViewBody(),
                "InitalPage": (context) => const InitalLogin(),
                "loginPage": (context) => loginPage(),
                "Regist": (context) => RigesterView(),
                "HomePage": (context) => const HomePage(),
                "MasterHome": (context) => const MasterHome(),
                "comLogin": (context) => const CompleteInformationBody(),
                "CategoryPage": (context) => const CategoryPage(),
                "Churchespage": (context) => const ChurchesPage(),
                "ChaptersPage": (context) => const ChaptersPage(),
                "AddNewCatgory": (context) => const AddNewCatgory(),
                "AddChurchesBox": (context) => const AddChurchesBox(),
                "CusBottomNavBar": (context) => const CusBottomNavBar(),
              },
            );
          },
        ),
      ),
    );
  }
}
