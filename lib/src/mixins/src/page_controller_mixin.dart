import 'package:flutter/widgets.dart';

mixin KPageControllerMixin<T extends StatefulWidget> on State<T> {
  final pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
