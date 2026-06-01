part of '../extensions.dart';

extension KColorsExtension on Color {
  Color lightenColor([double? value]) => HSLColor.fromColor(this).withLightness((value ?? 0.9)).toColor();
}
