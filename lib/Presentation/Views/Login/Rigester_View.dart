// ignore_for_file: use_build_context_synchronously

import 'package:aner_astaner/features/auth/data/services/auth_service.dart';
import 'package:aner_astaner/Presentation/widgets/Custem_text.dart';
import 'package:aner_astaner/Presentation/widgets/NextButton.dart';
import 'package:aner_astaner/Presentation/widgets/custom_buttions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class RigesterView extends StatefulWidget {
  @override
  State<RigesterView> createState() => _RigesterViewState();
}

class _RigesterViewState extends State<RigesterView> {
  final TextEditingController newEmail = TextEditingController();
  final TextEditingController newPassword = TextEditingController();
  final GlobalKey<FormState> formstate = GlobalKey<FormState>();
  AuthService get authService => Get.find<AuthService>();
  bool isLoading = false;

  @override
  void dispose() {
    newEmail.dispose();
    newPassword.dispose();
    super.dispose();
  }

  void _dismissLoading() {
    if (Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<void> _showMessage({
    required String title,
    required String message,
    bool isError = false,
    VoidCallback? onOk,
  }) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onOk != null) onOk();
            },
            child: Text(
              "حسنًا",
              style: TextStyle(color: isError ? Colors.red : Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF75EFFF).withOpacity(0.5),
              const Color(0xFFFFBC75).withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          children: [
            Form(
              key: formstate,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: 40.h),
                  Center(
                    child: CircleAvatar(
                      radius: 75.r,
                      backgroundImage: AssetImage("assets/logo.png"),
                    ),
                  ),
                  SizedBox(height: 25.h),
                  Text(
                    "انشاء حساب جديد",
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 25.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "ادخل البيانات الاتيه",
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 15.sp, color: Colors.grey),
                  ),
                  SizedBox(height: 20.h),

                  _buildLabel("الأيميل"),
                  CustomTextField(
                    obscureText: false,
                    textAlign: TextAlign.end,
                    controller: newEmail,
                    hintText: "ادخل ايميل جديد",
                    inputType: TextInputType.emailAddress,
                    validator: (val) =>
                        val!.isEmpty ? "لا يمكن أن يكون فارغًا" : null,
                  ),

                  SizedBox(height: 12.h),
                  _buildLabel("الباسورد"),
                  CustomTextField(
                    textAlign: TextAlign.end,
                    controller: newPassword,
                    hintText: "ادخل الباسورد الجديد",
                    inputType: TextInputType.visiblePassword,
                    obscureText: true,
                    validator: (val) =>
                        val!.isEmpty ? "لا يمكن أن يكون فارغًا" : null,
                  ),

                  SizedBox(height: 25.h),
                  Center(
                    child: NextButton(
                      iconData: Icons.arrow_back_ios,
                      text: "تسجيل",
                      nextQuestion: () async {
                        if (isLoading || !formstate.currentState!.validate())
                          return;

                        setState(() => isLoading = true);

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Dialog(
                            backgroundColor: Colors.transparent,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        );

                        try {
                          List<String> methods = await FirebaseAuth.instance
                              .fetchSignInMethodsForEmail(newEmail.text.trim());

                          if (methods.isNotEmpty) {
                            _dismissLoading();
                            await _showMessage(
                              title: "الإيميل مستخدم بالفعل",
                              message: methods.contains('google.com')
                                  ? 'الإيميل مرتبط بجوجل، سجل باستخدامه.'
                                  : 'الإيميل مسجل مسبقًا، قم بتسجيل الدخول.',
                            );
                            return;
                          }

                          final user = await authService.registerWithEmail(
                            newEmail.text.trim(),
                            newPassword.text.trim(),
                          );

                          if (user != null) {
                            await user.sendEmailVerification();
                            _dismissLoading();
                            await _showMessage(
                              title: "تأكيد البريد",
                              message:
                                  "تم إرسال رابط تأكيد إلى بريدك الإلكتروني. من فضلك قم بتأكيده أولاً.",
                              onOk: () async {
                                Navigator.pushReplacementNamed(
                                  context,
                                  'comLogin',
                                );
                              },
                            );
                          }
                        } on FirebaseAuthException catch (e) {
                          _dismissLoading();
                          String message;
                          if (e.code == 'weak-password') {
                            message =
                                'كلمة المرور ضعيفة جدًا. اختر كلمة مرور أقوى.';
                          } else {
                            message = e.message ?? 'حدث خطأ أثناء التسجيل.';
                          }
                          await _showMessage(
                            title: "خطأ",
                            message: message,
                            isError: true,
                          );
                        } catch (e) {
                          _dismissLoading();
                          await _showMessage(
                            title: "خطأ غير متوقع",
                            message: "حدث خطأ غير متوقع. حاول لاحقًا.",
                            isError: true,
                          );
                        } finally {
                          setState(() => isLoading = false);
                        }
                      },
                    ),
                  ),

                  _buildDivider("او"),
                  _buildLoginLink(context),
                  _buildDivider("او"),
                  _buildGoogleLoginButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      textAlign: TextAlign.end,
      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDivider(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Divider(color: Colors.grey[300])),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(text, style: TextStyle(fontSize: 15.sp)),
          ),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushReplacementNamed("loginPage"),
      child: Center(
        child: Text(
          "معايا ايميل و باسورد اسجل الدخول",
          style: TextStyle(fontSize: 15.sp, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildGoogleLoginButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.h),
      child: CustomButtonWithIcon(
        text: "         +         login With google",
        colorButon: Colors.green,
        color: Colors.white,
        iconData: Icons.g_mobiledata,
        onTap: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Dialog(
              backgroundColor: Colors.transparent,
              child: Center(child: CircularProgressIndicator()),
            ),
          );

          User? user = await authService.signInWithGoogle();

          Navigator.pop(context); // Close loading

          if (user != null) {
            final userDoc = FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid);
            final snapshot = await userDoc.get();

            if (snapshot.exists) {
              Navigator.pushReplacementNamed(context, 'MasterHome');
            } else {
              await userDoc.set({
                'email': user.email,
                'createdAt': FieldValue.serverTimestamp(),
              });
              Navigator.pushReplacementNamed(context, 'comLogin');
            }
          }
        },
      ),
    );
  }
}
