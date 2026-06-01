import 'package:flutter/material.dart';

const _scrollThreshold = kToolbarHeight;

mixin KIsScrolledNotifierMixin<T extends StatefulWidget> on State<T> {
  final scrollController = ScrollController();
  final isScrolledNotifier = ValueNotifier<bool>(false);

  double get scrollThreshold => _scrollThreshold;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    final current = scrollController.offset;
    if (current < scrollThreshold && isScrolledNotifier.value) {
      isScrolledNotifier.value = false;
    } else if (current >= scrollThreshold && !isScrolledNotifier.value) {
      isScrolledNotifier.value = true;
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    isScrolledNotifier.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
