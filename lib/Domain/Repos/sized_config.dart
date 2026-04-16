import 'package:flutter/material.dart';

class SizedConfig {
  static double? screenwidth;
  static double? screenHeigth;
  static double? defaulatsize;
  static Orientation? orientation;

  void init(BuildContext context) {
    screenwidth = MediaQuery.of(context).size.width;
    screenHeigth = MediaQuery.of(context).size.height;
    orientation = MediaQuery.of(context).orientation;

    defaulatsize = orientation == Orientation.landscape
        ? screenHeigth! * .024
        : screenwidth! * .024;

    print("this is the default size $defaulatsize");
  }
}
