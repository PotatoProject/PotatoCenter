import 'package:flutter/material.dart';

class Themes {
  static ThemeData get light => ThemeData.light().copyWith(
    bottomAppBarColor: Colors.white,
    cardColor: Colors.white,
    scaffoldBackgroundColor: Colors.grey[50],
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.white,
    ),
  );

  static ThemeData get dark => ThemeData.dark().copyWith(
    bottomAppBarColor: Colors.grey[900],
    cardColor: Colors.grey[900],
    scaffoldBackgroundColor: Color(0xFF151618),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.grey[900],
    ),
  );
}