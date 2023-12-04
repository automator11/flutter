import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class AppTheme {
  static ThemeData get light {
    var baseTheme = ThemeData(
        fontFamily: 'Poppins',
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: kPrimaryBackground,
        textTheme: const TextTheme(bodyLarge: TextStyle(fontSize: 11)),
        inputDecorationTheme: const InputDecorationTheme(
          isDense: true,
          border: OutlineInputBorder(
            borderSide: BorderSide(
                color: kInputDefaultBorderColor,
                style: BorderStyle.solid,
                width: 1.0),
            borderRadius: BorderRadius.all(
              Radius.circular(9),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: kInputDefaultBorderColor,
                style: BorderStyle.solid,
                width: 1.0),
            borderRadius: BorderRadius.all(
              Radius.circular(9),
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: kInputErrorBorderColor,
                style: BorderStyle.solid,
                width: 1.0),
            borderRadius: BorderRadius.all(
              Radius.circular(9),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: kPrimaryColor, style: BorderStyle.solid, width: 1.0),
            borderRadius: BorderRadius.all(
              Radius.circular(9),
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: kInputErrorBorderColor,
                style: BorderStyle.solid,
                width: 1.0),
            borderRadius: BorderRadius.all(
              Radius.circular(9),
            ),
          ),
          outlineBorder: BorderSide(
            color: kInputDefaultBorderColor,
            style: BorderStyle.solid,
            width: 1.0,
          ),
        ),
        cardTheme: CardTheme(
          color: kPrimaryBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                disabledBackgroundColor: kSecondaryBackground,
                textStyle: const TextStyle(color: kSecondaryColor))),
        buttonTheme: ButtonThemeData(
          buttonColor: kPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          disabledColor: kSecondaryBackground,
        ));
    return baseTheme.copyWith(
      primaryTextTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
        textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme));
  }
}
