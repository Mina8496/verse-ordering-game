// ignore_for_file: unused_local_variable, use_build_context_synchronously, body_might_complete_normally_nullable, avoid_print
import 'package:aner_astaner/Presentation/widgets/custom_buttions.dart';
import 'package:aner_astaner/features/auth/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class InitalLogin extends StatefulWidget {
  const InitalLogin({super.key});

  @override
  State<InitalLogin> createState() => _InitalLoginState();
}

class _InitalLoginState extends State<InitalLogin> {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  bool isLoading = false;
  final AuthService authService = Get.find<AuthService>();

  Future<void> signInWithGoogle(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = await authService.signInWithGoogle(ensureProfile: false);

      if (user != null) {
        final userProfile = await authService.getUserProfile(user);

        if (userProfile == null) {
          await authService.ensureUserProfile(user);

          Navigator.pushReplacementNamed(context, 'comLogin');
        } else {
          Navigator.pushReplacementNamed(context, 'MasterHome');
        }
      }
    } catch (e) {
      print('Google Sign-In error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل تسجيل الدخول بحساب Google')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الشاشة الأصلية
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(117, 239, 255, 1).withOpacity(0.5),
                  const Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 1],
              ),
            ),
            child: ListView(
              children: [
                Form(
                  key: formstate,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20.h),
                      CircleAvatar(
                        radius: 60.r,
                        backgroundImage: AssetImage(
                          "assets/logo.png",
                          // width: 800.w,
                          // height: 150.h,
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Text(
                        "انر واستنر",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18.sp),
                      ),
                      SizedBox(height: 30.h),
                      Text(
                        "تسجيل الدخول",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 50.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.h),
                        child: CustomButtonWithIcon(
                          onTap: () => signInWithGoogle(context),
                          colorButon: Colors.green,
                          color: Colors.white,
                          iconData: Icons.g_mobiledata,
                          text: "         +         login With Email google",
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 30.h,
                              width: 150.w,
                              child: Divider(
                                height: 30.h,
                                color: Colors.grey[100],
                              ),
                            ),
                            Text("  او  ", style: TextStyle(fontSize: 15.sp)),
                            SizedBox(
                              height: 30.h,
                              width: 150.w,
                              child: Divider(
                                height: 30.h,
                                color: Colors.grey[100],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.h),
                        child: CustomButtonWithIcon(
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushReplacementNamed("Regist");
                          },
                          color: Colors.white,
                          iconData: Icons.login,
                          text:
                              "               التسجيل باستخدام البريد الألكترونى",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Overlay loading indicator
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
