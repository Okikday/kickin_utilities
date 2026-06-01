import 'package:flutter/material.dart';

const _scrollThreshold = kToolbarHeight;

mixin KScrollOffsetNotifierMixin<T extends StatefulWidget> on State<T> {
  final ScrollController scrollController = ScrollController();
  final scrollOffsetNotifier = ValueNotifier<double>(0.0);

  double get scrollThreshold => _scrollThreshold;

  /// How much difference does the last offset have to be from the current before reflecting change
  double? get tolerance => null;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    final currOffset = scrollController.offset;
    if (tolerance != null && (currOffset - scrollOffsetNotifier.value) < 0.5) return;
    scrollOffsetNotifier.value = currOffset;
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollOffsetNotifier.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
