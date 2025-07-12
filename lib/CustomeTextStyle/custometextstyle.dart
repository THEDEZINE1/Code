import 'package:flutter/painting.dart';

class CustomTextStyle {
  // Font style for CustomFont1 Regular with font size and color
  static TextStyle? GraphikBold(double fontSize, Color color) {
    return TextStyle(
      fontFamily: 'GraphikBold',
      fontSize: fontSize, // Font size
      color: color, // Text color
    );
  }

  // Font style for CustomFont2 Regular with font size and color
  static TextStyle? GraphikMedium(double fontSize, Color color) {
    return TextStyle(
      decoration: TextDecoration.none,
      decorationThickness: 0,
      fontFamily:
          'GraphikMedium', // Ensure this is correct in your pubspec.yaml
      fontSize: fontSize,
      color: color,
    );
  }

  static TextStyle? GraphikRegular(double fontSize, Color color) {
    return TextStyle(
        fontFamily: 'GraphikRegular', // Your font family
        fontSize: fontSize, // Font size
        color: color, // Text color
        decoration: TextDecoration.none,
        decorationThickness: 0);
  }

  static TextStyle? GraphikSemibold(double fontSize, Color color) {
    return TextStyle(
      fontFamily: 'GraphikSemibold', // Your font family
      fontSize: fontSize, // Font size
      color: color, // Text color
    );
  }
}
