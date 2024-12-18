import 'package:flutter/material.dart';
import 'package:taskmanager/src/utils/color_constants.dart';


class AppTheme {
  // Rooms Controls Text Style
  static TextStyle header = const TextStyle(
    color: ColorConstants.text,
    fontSize: 18,
    fontWeight: FontWeight.bold
  );

  static TextStyle body = const TextStyle(
      color: ColorConstants.text,
      fontSize: 14,
  );
  static TextStyle bodyBold = const TextStyle(
    color: ColorConstants.text,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  static TextStyle caption = const TextStyle(
      color: ColorConstants.text,
      fontSize: 12,
  );

  static TextStyle captionWhite = const TextStyle(
    color: ColorConstants.background,
    fontSize: 12,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );

  static const TextStyle timestamp = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );

  static const TextStyle chip = TextStyle(
    fontSize: 12,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}


//
// Typography
// Primary Font: System default (San Francisco for iOS, Roboto for Android)
// Header Size: 18sp/pt
// Body Text: 14sp/pt
// Caption Text: 12sp/pt