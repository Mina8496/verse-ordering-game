
import 'package:aner_astaner/Presentation/Views/Category/All_Users_Results_Page.dart';
import 'package:aner_astaner/Presentation/Views/Category/Church_Users_ResultsPage.dart';
import 'package:aner_astaner/Presentation/Views/Home_page.dart';
import 'package:aner_astaner/Presentation/Views/Music_page.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';


class CusBottomNavBar extends StatefulWidget {
  final String? churchID;
  final String? chapterID;

  const CusBottomNavBar({super.key, this.churchID, this.chapterID});
  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<CusBottomNavBar> {
  int page = 0;

  List<Widget> get screens => [
    const HomePage(),
    const ChurchUsersResultsPage(),
    AllUsersResultsPage(
      // churchID: widget.churchID ?? "NoChurch",
      // chapterID: widget.chapterID ?? "NoChapter",
    ),
    // const GamePage(),
    const MusicPage(),
  ];

  final GlobalKey<CurvedNavigationBarState> bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        key: bottomNavigationKey,
        index: page,
        items: const <Widget>[
          Icon(Icons.home, size: 30),
          Icon(Icons.church, size: 30),
          Icon(Icons.public, size: 30),
          // Icon(Icons.sports_esports, size: 30),
          Icon(Icons.music_note, size: 30),
        ],
        color: Colors.black12,
        buttonBackgroundColor: Colors.amber,
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) {
          if (!mounted) return;

          setState(() {
            page = index;
          });
        },
        letIndexChange: (index) => true,
      ),
      body: screens[page],
    );
  }
}
