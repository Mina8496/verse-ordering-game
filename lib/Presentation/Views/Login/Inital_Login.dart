// ignore_for_file: unused_local_variable, use_build_context_synchronously, body_might_complete_normally_nullable, avoid_print
import 'package:aner_astaner/Presentation/widgets/custom_buttions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InitalLogin extends StatefulWidget {
  const InitalLogin({super.key});

  @override
  State<InitalLogin> createState() => _InitalLoginState();
}

class _InitalLoginState extends State<InitalLogin> {
  TextEditingController newEmail = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> signInWithGoogle(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() {
          isLoading = false;
        });
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

        if (!userDoc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'email': user.email,
            'name': user.displayName,
            'role': 'User',
            'status': 'pending',
          });

          Navigator.pushReplacementNamed(context, 'comLogin');
        } else {
          String role = userDoc['role'];
          if (role == 'Admin') {
            Navigator.pushReplacementNamed(context, 'MasterHome');
          } else {
            Navigator.pushReplacementNamed(context, 'MasterHome');
          }
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
