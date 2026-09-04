import 'package:flutter/material.dart';

import '../../Presentation/Views/Adds_Category/AddNewCatgory.dart';
import '../../Presentation/Views/Adds_Category/Add_churches_Box.dart';
import '../../Presentation/Views/Category/Category_Page.dart';
import '../../Presentation/Views/Category/Chapters_Page.dart';
import '../../Presentation/Views/Category/Churches_Page.dart';
import '../../Presentation/Views/Home_page.dart';
import '../../Presentation/Views/Login/Completw_information_body.dart';
import '../../Presentation/Views/Login/Inital_Login.dart';
import '../../Presentation/Views/Login/Rigester_View.dart';
import '../../Presentation/Views/Login/login_Page.dart';
import '../../Presentation/Views/MasterHome_Page.dart';
import '../../Presentation/on Bording/splash_body.dart';
import '../../Presentation/widgets/BottomNavBar.dart';

abstract final class AppRoutes {
  static const splash = 'splashPage';
  static const initialLogin = 'InitalPage';
  static const login = 'loginPage';
  static const register = 'Regist';
  static const home = 'HomePage';
  static const masterHome = 'MasterHome';
  static const completeLogin = 'comLogin';
  static const category = 'CategoryPage';
  static const churches = 'Churchespage';
  static const chapters = 'ChaptersPage';
  static const addCategory = 'AddNewCatgory';
  static const addChurches = 'AddChurchesBox';
  static const bottomNavigation = 'CusBottomNavBar';

  static final Map<String, WidgetBuilder> pages = {
    splash: (_) => const SplashViewBody(),
    initialLogin: (_) => const InitalLogin(),
    login: (_) => loginPage(),
    register: (_) => RigesterView(),
    home: (_) => const HomePage(),
    masterHome: (_) => const MasterHome(),
    completeLogin: (_) => const CompleteInformationBody(),
    category: (_) => const CategoryPage(),
    churches: (_) => const ChurchesPage(),
    chapters: (_) => const ChaptersPage(),
    addCategory: (_) => const AddNewCatgory(),
    addChurches: (_) => const AddChurchesBox(),
    bottomNavigation: (_) => const CusBottomNavBar(),
  };
}
