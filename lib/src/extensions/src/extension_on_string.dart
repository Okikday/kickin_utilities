part of '../extensions.dart';

extension KStringExtension on String {
  Map get decodeJson => jsonDecode(this);
}
