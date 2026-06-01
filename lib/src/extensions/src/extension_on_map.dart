import 'dart:convert';

extension KMapExtension<T> on Map<T, T?> {
  String get encodeToJson => jsonEncode(this);
}
