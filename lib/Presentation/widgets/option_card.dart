import 'package:aner_astaner/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OptionCard extends StatelessWidget {
  const OptionCard({required this.option, required this.color, Key? key})
    : super(key: key);

  final String option;
  final Color color;

  Color getTextColor(Color bgColor) {
    if (bgColor == correct) return Colors.green[900]!;
    if (bgColor == incorrect) return Colors.red[900]!;
    return const Color.fromARGB(197, 11, 181, 233); // neutral
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(color: const Color(0xFFB2DFDB), width: 2.w),
      ),
      color: color,
      child: ListTile(
        title: Text(
          option,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.0.sp,
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
            color: getTextColor(color),
          ),
        ),
      ),
    );
  }
}
