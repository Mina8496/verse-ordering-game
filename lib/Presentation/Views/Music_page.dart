import 'package:aner_astaner/features/audio/presentation/controllers/audio_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MusicPage extends StatelessWidget {
  const MusicPage({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioController>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Album Art
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  "assets/images/image.jpg",
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(height: 20.h),

            Text(
              "Awesome Song",
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            Text(
              "Artist Name",
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),

            SizedBox(height: 40.h),

            // الأزرار
            Obx(
              () => IconButton(
                icon: Icon(
                  audio.isPlaying.value
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  size: 60,
                  color: Colors.blue,
                ),
                onPressed: audio.toggleMusic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
