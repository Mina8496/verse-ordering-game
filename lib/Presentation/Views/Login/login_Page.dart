// ignore_for_file: unused_local_variable, use_build_context_synchronously, body_might_complete_normally_nullable, avoid_print

import 'package:aner_astaner/Presentation/widgets/Custem_text.dart';
import 'package:aner_astaner/Presentation/widgets/NextButton.dart';
import 'package:aner_astaner/Presentation/widgets/custom_buttions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';

class loginPage extends StatefulWidget {
  loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  TextEditingController newEmail = TextEditingController();
  TextEditingController newPassword = TextEditingController();

  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  Future<void> signInWithGoogle(BuildContext context) async {
    // عرض اللودر
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        Navigator.pop(context); // إغلاق اللودر
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        // لو المستخدم جديد
        if (!userDoc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'email': user.email,
            'name': user.displayName ?? '',
            'role': 'User',
            'status': 'pending',
          });

          Navigator.pop(context); // إغلاق اللودر
          Navigator.pushReplacementNamed(context, 'comLogin');
          return;
        }

        // لو المستخدم قديم → التحقق من role
        final data = userDoc.data();
        final role = data != null && data.containsKey('role')
            ? data['role']
            : 'User';

        Navigator.pop(context); // إغلاق اللودر

        if (role == 'Admin' || role == 'SuperAdmin') {
          Navigator.pushReplacementNamed(context, 'MasterHome');
        }
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context); // إغلاق اللودر
      print('Google Sign-In error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل تسجيل الدخول بحساب Google')),
      );
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void loginUser() async {
    if (!formstate.currentState!.validate()) return;

    final email = newEmail.text.trim();
    final password = newPassword.text.trim();

    // عرض لودر
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        // ********** السماح لحساب Demo بالدخول بدون تحقق بريد **********
        if (email.toLowerCase() == "demo@test.com") {
          final userDoc = await _firestore
              .collection('users')
              .doc(user.uid)
              .get();

          Navigator.pop(context); // إغلاق اللودر

          if (!userDoc.exists) {
            await _firestore.collection('users').doc(user.uid).set({
              'email': user.email,
              'name': user.displayName ?? '',
              'role': 'User',
            });
          }

          Navigator.pushReplacementNamed(context, 'MasterHome');
          return;
        }
        // ****************************************************************

        // تحقق البريد للمستخدمين العاديين
        if (!user.emailVerified) {
          await user.sendEmailVerification();
          Navigator.pop(context);

          showDialog(
            context: context,
            builder: (context) => const AlertDialog(
              title: Text('تأكيد البريد'),
              content: Text('تم إرسال رابط التحقق. قم بتأكيد بريدك أولاً.'),
            ),
          );

          return;
        }

        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        Navigator.pop(context); // إغلاق اللودر

        // مستخدم جديد
        if (!userDoc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'email': user.email,
            'name': user.displayName ?? '',
            'role': 'User',
          });

          Navigator.pushReplacementNamed(context, 'comLogin');
          return;
        }

        // مستخدم قديم + role
        final data = userDoc.data();
        final role = data != null && data.containsKey('role')
            ? data['role']
            : 'User';

        Navigator.pushReplacementNamed(context, 'MasterHome');
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      String message;
      if (e.code == 'user-not-found') {
        message = 'لا يوجد مستخدم بهذا البريد الإلكتروني';
      } else if (e.code == 'wrong-password') {
        message = 'كلمة المرور غير صحيحة';
      } else {
        message = e.message ?? 'حدث خطأ غير متوقع';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('خطأ'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
    }
  }

  // Future<UserCredential?> signInWithFacebook() async {
  //   try {
  //     final LoginResult result = await FacebookAuth.instance.login();

  //     if (result.status == LoginStatus.success) {
  //       final AccessToken? accessToken = result.accessToken;

  //       if (accessToken != null) {
  //         print("Access Token: ${accessToken.toJson()}"); // Debugging

  //         // Use the access token to create a Firebase credential
  //         final OAuthCredential credential =
  //             FacebookAuthProvider.credential(accessToken.tokenString);

  //         // Sign in to Firebase
  //         return await FirebaseAuth.instance.signInWithCredential(credential);
  //       }
  //     } else {
  //       print("Facebook Login Failed: ${result.message}");
  //       return null;
  //     }
  //   } catch (e) {
  //     print("Error during Facebook Login: $e");
  //     return null;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: Padding(
          padding: EdgeInsets.all(8.0.dg),
          child: ListView(
            children: [
              Form(
                key: formstate,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Center(
                      child: SizedBox(
                        width: 150.w,
                        height: 150.h,
                        child: Center(
                          child: CircleAvatar(
                            radius: 75.r,
                            backgroundImage: AssetImage("assets/logo.png"),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "تسجيل الدخول",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Text(
                    //   "ادخل الايميل  ",
                    //   textAlign: TextAlign.end,
                    //   style: TextStyle(
                    //     fontSize: 15.sp,
                    //     color: Colors.grey,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    SizedBox(height: 15.h),
                    // email
                    Text(
                      "الأيميل",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CustomTextField(
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "لا يمكن ان يكون فارغ";
                        }
                        // return "لا يمكن ان يكون فارغ";
                      },
                      inputType: TextInputType.emailAddress,
                      hintText: "ادخل الايميل ",
                      textAlign: TextAlign.end,
                      obscureText: false,
                      controller: newEmail,
                    ),
                    SizedBox(height: 10.h),
                    // password
                    Text(
                      "الباسورد",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CustomTextField(
                      obscureText: true,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "لا يمكن ان يكون فارغ";
                        }
                        // return "لا يمكن ان يكون فارغ";
                      },
                      inputType: TextInputType.visiblePassword,
                      hintText: "ادخل الباسورد ",
                      textAlign: TextAlign.end,
                      controller: newPassword,
                    ),
                    MaterialButton(
                      onPressed: () async {
                        if (newEmail.text.trim().isEmpty ||
                            !newEmail.text.contains('@')) {
                          showDialog(
                            context: context,
                            builder: (context) => const AlertDialog(
                              title: Text('ادخل البريد'),
                              content: Text('ادخل البريد اولاً فى الاعلى.'),
                            ),
                          );

                          return;
                        }

                        await FirebaseAuth.instance.sendPasswordResetEmail(
                          email: newEmail.text.trim(),
                        );
                        showDialog(
                          context: context,
                          builder: (context) => const AlertDialog(
                            title: Text('فحص البريد'),
                            content: Text(
                              'تم إرسال رسالة لإعادة تعيين كلمة المرور.',
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "هل نسيت الباسورد ....؟",
                        textAlign: TextAlign.end,
                        style: TextStyle(fontSize: 15.sp, color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Center(
                      child: NextButton(
                        iconData: Icons.arrow_back_ios,
                        nextQuestion: loginUser,
                        text: "تسجيل الدخول ",
                        width: 165.0.w,
                      ),
                    ),

                    SizedBox(height: 15.h),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 30.h,
                            width: 120.w,
                            child: Divider(
                              height: 30.h,
                              color: Colors.grey[100],
                            ),
                          ),
                          Text("  او  ", style: TextStyle(fontSize: 15.sp)),
                          SizedBox(
                            height: 30.h,
                            width: 120.w,
                            child: Divider(
                              height: 30.h,
                              color: Colors.grey[100],
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed("Regist");
                      },
                      child: Center(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "           اول مره معانا فى الابلكشن\n ",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15.sp,
                                ),
                              ),
                              TextSpan(
                                text: "او عايز ايميل و باسورد تسجل بيهم ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.h),
                      child: CustomButtonWithIcon(
                        onTap: () {
                          signInWithGoogle(context);
                        },
                        colorButon: Colors.green,
                        color: Colors.white,
                        iconData: Icons.g_mobiledata,
                        text: "         +         login With Email google",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
