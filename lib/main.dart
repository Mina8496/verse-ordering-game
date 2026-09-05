import 'package:aner_astaner/core/di/app_bindings.dart';
import 'package:aner_astaner/core/routes/app_routes.dart';
import 'package:aner_astaner/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:upgrader/upgrader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
              initialBinding: AppBindings(),
              theme: ThemeData(fontFamily: 'Tajawal'),
              home: AppRoutes.pages[AppRoutes.splash]!(context),
              routes: AppRoutes.pages,
            );
          },
        ),
      ),
    );
  }
}
