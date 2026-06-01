import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// Use [ref.context] to access the [BuildContext] from a [WidgetRef].
typedef KAbsorberBuilder<OutT> = Widget Function(WidgetRef ref, OutT value, Widget? _);

/// Helper API for embedding provider `watch` and `read` builders inline.
///
/// The static methods return lightweight widgets that expose a [WidgetRef] and
/// the current provider value to a builder.
class KAbsorber {
  /// Returns a widget that rebuilds when [listenable] changes.
  static Widget watch<OutT>(
    ProviderListenable<OutT> listenable, {
    Key? key,
    required KAbsorberBuilder<OutT> builder,
    Widget? child,
  }) => KAbsorbWatch(key: key, listenable: listenable, builder: builder, child: child);

  /// Returns a widget that reads [listenable] once during build.
  static Widget read<OutT>(
    ProviderListenable<OutT> listenable, {
    Key? key,
    required KAbsorberBuilder<OutT> builder,
    Widget? child,
  }) => KAbsorbRead(key: key, listenable: listenable, builder: builder, child: child);
}

/// Watches the supplied provider and rebuilds when its value changes.
class KAbsorbWatch<OutT> extends ConsumerWidget {
  /// The provider to watch.
  final ProviderListenable<OutT> listenable;

  /// Builder used to render the watched value.
  final KAbsorberBuilder<OutT> builder;

  /// Optional child passed through to the builder.
  final Widget? child;

  /// Creates a widget that watches [listenable].
  const KAbsorbWatch({super.key, required this.listenable, required this.builder, this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) => builder(ref, ref.watch(listenable), child);
}

/// Reads the supplied provider once during build.
class KAbsorbRead<OutT> extends ConsumerWidget {
  /// The provider to read.
  final ProviderListenable<OutT> listenable;

  /// Builder used to render the read value.
  final KAbsorberBuilder<OutT> builder;

  /// Optional child passed through to the builder.
  final Widget? child;

  /// Creates a widget that reads [listenable] during build.
  const KAbsorbRead({super.key, required this.listenable, required this.builder, this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) => builder(ref, ref.read(listenable), child);
}
