part of '../extensions.dart';

/// Extension on num to convert to Duration and SizedBox
/// Example: 500.inMs will return Duration of 500 milliseconds
extension KNumDurationExtension on num {
  Duration get inMicroseconds => Duration(microseconds: round());
  Duration get inMs => (this * 1000).inMicroseconds;
  Duration get inMilliseconds => (this * 1000).inMicroseconds;
  Duration get inSeconds => (this * 1000 * 1000).inMicroseconds;
  Duration get inMinutes => (this * 1000 * 1000 * 60).inMicroseconds;
  Duration get inHours => (this * 1000 * 1000 * 60 * 60).inMicroseconds;
  Duration get inDays => (this * 1000 * 1000 * 60 * 60 * 24).inMicroseconds;
}

extension KWidgetExtension on num {
  SizedBox get toHBox => SizedBox(width: toDouble());
  SizedBox get toVBox => SizedBox(height: toDouble());
  SliverToBoxAdapter get toHSliverBox => SliverToBoxAdapter(child: toHBox);
  SliverToBoxAdapter get toVSliverBox => SliverToBoxAdapter(child: toVBox);
}
