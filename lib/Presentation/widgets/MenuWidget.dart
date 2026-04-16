// ignore_for_file: constant_identifier_names, depend_on_referenced_packages
import 'package:aner_astaner/Presentation/widgets/menuItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MenuItems {
  static const home = MenuItem("صفحة الرئيسية ", Icons.home);
  // static const category = MenuItem("الانجيل والأسفارات", Icons.category);
  static const Users = MenuItem("بياناتى ", Icons.person);
  static const UserPersonalResultsPage = MenuItem("نتائجى", Icons.fact_check);
  static const DisabledUsers = MenuItem(
    "المحظورين ",
    Icons.disabled_by_default,
  );
  // static const Qusstion = MenuItem(" الأسئلة", Icons.question_answer);
  // static const Churches = MenuItem("الكنائس", Icons.church);
  static const Logout = MenuItem("تسجيل الخروج", Icons.logout);

  static const all = <MenuItem>[
    home,
    // category,
    Users,
    UserPersonalResultsPage,
    DisabledUsers,
    // Qusstion,
    // Churches,
    Logout,
  ];
}

class MenuWidget extends StatelessWidget {
  final MenuItem? currentItem;
  final ValueChanged<MenuItem>? onSelectedItem;
  const MenuWidget({super.key, this.currentItem, this.onSelectedItem});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        backgroundColor: Colors.indigo,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Spacer(),
              ...MenuItems.all.map(buildMenuItem).toList(),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenuItem(MenuItem item) => ListTileTheme(
    selectedColor: Colors.white,
    child: ListTile(
      selectedTileColor: Colors.black26,
      selected: currentItem == item,
      minLeadingWidth: 15.w,
      leading: Icon(item.icon),
      title: Text(
        item.title,
        style: TextStyle(fontSize: 14.sp, color: Colors.white),
      ),
      onTap: () => onSelectedItem?.call(item),
    ),
  );
}
