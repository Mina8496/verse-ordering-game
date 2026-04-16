import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NextButton extends StatelessWidget {
  const NextButton({
    Key? key,
    required this.nextQuestion,
    required this.text,
    this.width = 145,
    required this.iconData,
  }) : super(key: key);
  final VoidCallback nextQuestion;
  final String text;
  final double width;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0.dg),
      ),
      child: FloatingActionButton.extended(
        backgroundColor: Colors.amber,
        icon: Icon(iconData),
        onPressed: nextQuestion,
        label: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
