part of '../extensions.dart';

extension KExtensionOnDuration on Duration {
  Future<void> delay([FutureOr<void> Function()? computation]) => Future.delayed(this, computation);
}
