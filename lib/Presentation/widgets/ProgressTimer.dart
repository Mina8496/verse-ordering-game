import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ProgressTimer extends StatelessWidget {
  const ProgressTimer({Key? key, required this.maxSec, required this.sec})
      : super(key: key);

  final int maxSec;
  final RxInt sec;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        height: 50.h,
        width: 50.w,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: 1 - (sec.value / maxSec),
              color: Colors.amber,
              backgroundColor: Colors.grey.shade300,
              strokeWidth: 8.w,
            ),
            Center(
              child: Text(
                '${sec.value}s',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Colors.amber, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
