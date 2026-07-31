import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      blurRadius: 12,
      offset: Offset(0, 4),
      color: Color(0x14000000),
    ),
  ];

  static const List<BoxShadow> button = [
    BoxShadow(
      blurRadius: 8,
      offset: Offset(0, 3),
      color: Color(0x22000000),
    ),
  ];
}
