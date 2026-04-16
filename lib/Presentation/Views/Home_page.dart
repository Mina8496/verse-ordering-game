
import 'package:aner_astaner/Presentation/widgets/Home_Widget.dart';
import 'package:aner_astaner/Presentation/widgets/showHowTo_Qussyion_Dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'بسم الثالوث القدوس',
          style: TextStyle(fontSize: 20.sp, color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => ZoomDrawer.of(context)!.toggle(),
          icon: const Icon(Icons.menu),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              showHowToQuizDialog(context);
            },
          ),

          // IconButton(
          //     onPressed: () async {
          //       GoogleSignIn googleSignIn = GoogleSignIn();
          //       googleSignIn.disconnect();
          //       await FirebaseAuth.instance.signOut();
          //       Get.toNamed("InitalPage");
          //     },
          //     icon: const Icon(Icons.exit_to_app))
        ],
      ),
      body: const Stack(children: [HomeWidget()]),
    );
  }
}
