import 'package:flutter/material.dart';

import '../domain/course.dart';

const List<Color> _coursePalette = <Color>[
  Color(0xFF3B63C4),
  Color(0xFF0F766E),
  Color(0xFF9A3412),
  Color(0xFF6D28D9),
  Color(0xFF9D174D),
  Color(0xFF0E7490),
  Color(0xFF4D7C0F),
  Color(0xFF7E22CE),
  Color(0xFF1D4ED8),
  Color(0xFFB45309),
  Color(0xFF047857),
  Color(0xFFBE123C),
];

Color courseColorFor(Course course) {
  final seed = '${course.name}|${course.code ?? ''}';
  var hash = 0;
  for (final codeUnit in seed.codeUnits) {
    hash = (hash * 31 + codeUnit) & 0x7fffffff;
  }
  return _coursePalette[hash % _coursePalette.length];
}

Color foregroundForCourse(Color background) {
  return background.computeLuminance() > 0.52
      ? const Color(0xFF13202B)
      : Colors.white;
}
