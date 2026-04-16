import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  CustomTextField({
    super.key,
    @required this.inputType,
    this.onSaved,
    this.onchanged,
    @required this.hintText,
    @required this.textAlign,
    this.onTap,
    @required this.controller,
    @required this.validator,
    required this.obscureText,
  });

  final TextInputType? inputType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final ValueSetter? onSaved;
  final ValueSetter? onchanged;
  final dynamic onTap;
  final String? hintText;
  final TextAlign? textAlign;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText,
      validator: validator,
      keyboardType: inputType,
      controller: controller,
      // maxLength: 1,
      // minLines: 1,
      style: TextStyle(fontSize: 15.sp),
      // validator: Validator,
      onChanged: onchanged,
      onSaved: onSaved,
      onTap: onTap,
      textAlign: textAlign!,
      decoration: InputDecoration(
        filled: true,
        // contentPadding: EdgeInsets.all(5.dg),
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 15.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 184, 184, 184),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class CustomText extends StatelessWidget {
  CustomText({super.key, required this.title, this.textAlign});
  String? title;
  String? adressText;
  TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 2),
        SizedBox(
          width: 500.w,
          child: Text(
            title!,
            style: TextStyle(
              fontSize: 15.sp,
              color: Color(0xff0c0b0b),
              fontFamily: "Poppins",
              height: 1.5625.h,
            ),
            textAlign: textAlign,
          ),
        ),
      ],
    );
  }
}
