import 'dart:ui';

import 'package:flutter/material.dart';

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
//        primaryColor: isDarkTheme ? Color(0xffE22386) : Color(0xff950952),
        primaryColor: isDarkTheme ? Colors.blue : Color(0xff1f5cfc),
        backgroundColor: isDarkTheme ? Colors.black87 : Colors.white,
        indicatorColor: isDarkTheme ? Colors.white : Colors.black87);
  }
}
