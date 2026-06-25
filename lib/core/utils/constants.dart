// import 'package:flutter/material.dart';

// const String URL = 'https://np.baltra.in/api';

// extension StringCasingExtension on String {
//   String toCapitalized() =>
//       length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
//   String toTitleCase() => replaceAll(RegExp(' +'), ' ')
//       .split(' ')
//       .map((str) => str.toCapitalized())
//       .join(' ');
// }

// // hex to dart color
// Color hexToColor(String hexColor) {
//   hexColor = hexColor.toUpperCase().replaceAll('#', '');
//   if (hexColor.length == 6) {
//     hexColor = 'FF$hexColor';
//   }
//   return Color(int.parse(hexColor, radix: 16));
// }
import 'package:flutter/material.dart';

const String URL = 'https://np.baltra.in/api';
// const String URL = 'http://192.168.1.123:8000/api';

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

// Safe hex color parser
Color hexToColor(String? hexColor) {
  if (hexColor == null || hexColor.trim().isEmpty) {
    return Colors.grey; // fallback
  }

  String color = hexColor.trim().toUpperCase().replaceAll('#', '');

  // Handle named colors or invalid input
  if (color == 'GREEN') return Colors.green;
  if (color == 'RED') return Colors.red;
  if (color == 'BLUE') return Colors.blue;
  if (color == 'BLACK') return Colors.black;
  if (color == 'WHITE') return Colors.white;

  // Handle hex codes
  if (color.length == 6) {
    color = 'FF$color';
  } else if (color.length != 8) {
    return Colors.grey; // invalid hex → fallback
  }

  try {
    return Color(int.parse(color, radix: 16));
  } catch (e) {
    return Colors.grey; // fallback on parse error
  }
}
