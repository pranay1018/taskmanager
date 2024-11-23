import 'package:flutter/material.dart';

import '../../utils/color_constants.dart';

class ScreenTitle extends StatelessWidget {
  final String title;

  const ScreenTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: ColorConstants.primary,
      ),
      textAlign: TextAlign.center,
    );
  }
}
