import 'package:flutter/material.dart';

// final URL = dotenv.env['DEVELOPMENT_URL']!;
// final CLIENT_ID = dotenv.env['CLIENT_ID']!;
// final SECRET_KEY = dotenv.env['SECRET_KEY'];

const String URL = 'http://192.168.1.84:8000/api';

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

// hex to dart color
Color hexToColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll('#', '');
  if (hexColor.length == 6) {
    hexColor = 'FF$hexColor';
  }
  return Color(int.parse(hexColor, radix: 16));
}
