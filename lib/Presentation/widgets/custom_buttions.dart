import 'package:aner_astaner/Domain/Repos/sized_config.dart';
import 'package:aner_astaner/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomGeneralButton extends StatelessWidget {
  const CustomGeneralButton({
    super.key,
    @required this.text,
    @required this.onPressed,
  });
  final String? text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      child: Container(
        height: 60,
        width: SizedConfig.screenwidth,
        decoration: BoxDecoration(
          color: kMaincolor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text!,
            style: const TextStyle(
              fontSize: 14,
              color: kGencolor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ),
    );
  }
}

class CustomButtonWithIcon extends StatelessWidget {
  const CustomButtonWithIcon({
    super.key,
    this.text,
    this.onTap,
    this.iconData,
    this.color,
    this.colorButon,
  });
  final String? text;
  final IconData? iconData;
  final VoidCallback? onTap;
  final Color? colorButon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: SizedConfig.screenwidth,
        decoration: BoxDecoration(
          color: colorButon,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.red),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, color: color),
            const SizedBox(height: 20),
            Text(
              text!,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
                color: const Color(0xff000000),
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}
