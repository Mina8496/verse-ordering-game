// ignore_for_file: sort_child_properties_last
import 'package:aner_astaner/core/constants/app_colors.dart';
import 'package:aner_astaner/Presentation/widgets/BottomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResultBox extends StatelessWidget {
  const ResultBox({
    required this.score,
    required this.questionLength,
    required this.onPressed,
  });

  final int score;
  final int questionLength;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // backgroundColor: Colors.amber,
      content: Padding(
        padding: EdgeInsets.all(30.0.dg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "النقاط",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0.sp),
            ),
            SizedBox(height: 20.0.h),
            CircleAvatar(
              child: Text(
                "$score / $questionLength",
                style: TextStyle(fontSize: 30.sp),
              ),
              radius: 70.r,
              backgroundColor: score == questionLength / 2
                  ? Colors.yellow
                  : score < questionLength / 2
                  ? incorrect
                  : correct,
            ),
            SizedBox(height: 20.0.h),
            Text(
              score == questionLength / 2
                  ? "!عظيم"
                  : score < questionLength / 2
                  ? "فى افضل من كدا"
                  : "عاش يا بطل .. ممتاذ",
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30.0.h),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: ((context) => const CusBottomNavBar()),
                  ),
                );
                onPressed;
              },
              child: Text(
                "صفحة الرئيسة",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 15.0.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
