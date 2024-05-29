import 'package:flutter/material.dart';

class AppTextStyles {
  final BuildContext context;

  AppTextStyles(this.context);

  TextStyle get title {
    return TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  static const subtitle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: Colors.grey,
  );

  static const cardHeader = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );
}
