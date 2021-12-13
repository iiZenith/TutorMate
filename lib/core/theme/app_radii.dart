import 'package:flutter/material.dart';

class AppRadii {
  AppRadii._();

  static const double small = 4.0;
  static const double medium = 8.0;
  static const double large = 16.0;
  static const double extraLarge = 24.0;

  static const BorderRadius borderRadiusSmall = BorderRadius.all(Radius.circular(small));
  static const BorderRadius borderRadiusMedium = BorderRadius.all(Radius.circular(medium));
  static const BorderRadius borderRadiusLarge = BorderRadius.all(Radius.circular(large));
  static const BorderRadius borderRadiusExtraLarge = BorderRadius.all(Radius.circular(extraLarge));
}
