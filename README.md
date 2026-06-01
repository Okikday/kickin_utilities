# kickin_utilities

Kickin Utilities is a modular Flutter toolkit for common app code: constants, extensions, helpers, mixins, and Riverpod utilities.

It is organized by folder, and each folder represents a feature area. Nested folders are treated as subfeatures, so the docs below follow the source tree.

---

## ✨ What's in the box

| Feature | Description |
|---|---|
| `constants/` | Shared UI values such as `KSpacing` and `KCurves` |
| `extensions/` | Flutter and Dart extensions for strings, numbers, colors, context, duration, and Riverpod providers |
| `helpers/` | Reusable helper types like `KResult`, isolate utilities, and logger starter code |
| `mixins/` | Stateful mixins for scrolling, paging, and provider warm-up behavior |
| `state_mgmt/` | State-management helpers organized by subfeature folders such as `riverpod/` |

---

## Constants

Shared values for motion and layout.

### `src/constants/src/spacing.dart`

`KSpacing` provides common spacing tokens for Flutter layouts.

```dart
Container(padding: const EdgeInsets.all(KSpacing.md));
```

Available sizes: `xxs`, `xs`, `sm`, `md`, `lg`, `xl`, `xxl`, `xxxl`, `huge`, and `massive`.

### `src/constants/src/curves.dart`

`KCurves` provides a set of spring-based and easing curves for consistent motion.

Examples include:

- `instantSpring`
- `defaultIosSpring`
- `bouncySpring`
- `snappySpring`
- `interactiveSpring`
- `fastInSlowOut`
- `linear`, `ease`, `decelerate`, `fastSlowInOut`
- `bounceOut`, `bounceIn`
- `easeOutSine`, `easeInOutSine`, `easeOutCirc`, `easeInOutCirc`

---

## Extensions

Small convenience extensions for Flutter and Dart APIs.

### `src/extensions/src/extension_on_string.dart`

`String.decodeJson` decodes a JSON string into a `Map` or list-like structure.

```dart
final data = '{"name":"Ada"}'.decodeJson;
```

### `src/extensions/src/extension_on_num.dart`

Numeric helpers for durations and widget gaps.

- `inMicroseconds`
- `inMs`
- `inMilliseconds`
- `inSeconds`
- `inMinutes`
- `inHours`
- `inDays`
- `toHBox`
- `toVBox`
- `toHSliverBox`
- `toVSliverBox`

```dart
await 500.inMs.delay();
final gap = 16.toVBox;
```

### `src/extensions/src/extension_on_color.dart`

`Color.lightenColor()` returns a lighter color using HSL lightness.

### `src/extensions/src/extension_on_context.dart`

`BuildContext` helpers for theme, media query, and layout values.

- `theme`
- `scaffoldBackgroundColor`
- `platformBrightness`
- `isDarkMode`
- `mediaQuery`
- `screenSize`
- `deviceWidth`
- `deviceHeight`
- `viewInsets`
- `padding`
- `topPadding`
- `bottomPadding`

### `src/extensions/src/extension_on_duration.dart`

`Duration.delay()` is a small wrapper over `Future.delayed`.

### `src/extensions/src/extension_on_providers.dart`

Riverpod provider shortcuts for `ProviderListenable`, `AsyncProviderListenable`, `Ref`, `WidgetRef`, `NotifierProvider`, and `AsyncNotifierProvider`.

- `read` / `watch` / `readX` / `watchX`
- `emptyListenMany`
- `keepAliveFor`
- `not`, `notX`, `watchNot`, `watchNotX`
- `expand`, `expandX`

---

## Helpers

Utility types for results and isolate execution.

### `src/helpers/src/result.dart`

`KResult<T>` wraps loading, success, and error states.

Use it when you want to avoid repeating `try/catch` blocks around asynchronous work.

```dart
final result = await KResult.tryRunAsync(() async => fetchUser());
if (result.isSuccess) {
  print(result.value);
}
```

Key helpers:

- `KResult.loading()`
- `KResult.success()`
- `KResult.error()`
- `tryRunAsync()`
- `tryRun()`
- `tryRunEither()`
- `doNext()`
- `then()`
- `onError()`

### `src/helpers/src/isolate.dart`

Isolate utilities for one-shot work and persistent workers.

#### `KIsolate<TArg, TProgress, TResult>`

Runs a single task in a dedicated isolate and supports progress callbacks.

#### `KIsolateContinuous<TArg, TResult>`

Runs sequential tasks inside one long-lived isolate with priority queueing and backpressure.

#### `KIsolateAccess` mixin

Convenience mixin that exposes `isolateRun()` and `isolateSpawn()`.

#### `KIsolateException`

Exception type thrown when isolate spawn or execution fails.

### `src/helpers/src/logger.dart`

This file currently contains commented-out logger starter code. It is part of the source tree, but it does not currently contribute active exported behavior.

---

## Mixins

State helpers that wire controllers and provider warm-up behavior.

### `src/mixins/src/is_scrolled_notifier_mixin.dart`

`KIsScrolledNotifierMixin` gives a `ScrollController` and a `ValueNotifier<bool>` that flips when the scroll offset passes the toolbar-height threshold.

### `src/mixins/src/scroll_offset_notifier_mixin.dart`

`KScrollOffsetNotifierMixin` exposes the current scroll offset in a `ValueNotifier<double>`.

### `src/mixins/src/page_controller_mixin.dart`

`KPageControllerMixin` owns and disposes a `PageController`.

### `src/mixins/src/provider_warmup_mixin.dart`

`KProviderWarmupMixin` keeps Riverpod providers alive for a duration and can clear them individually or in bulk.

---

## State Management

This folder is reserved for state-management helpers. Each subfolder under `state_mgmt/` is a separate subfeature, so if another state-management approach is added later it can live beside `riverpod/` without changing the documentation structure.

### Riverpod

Riverpod-specific helpers live here.

#### `src/state_mgmt/riverpod/src/absorber.dart`

`KAbsorber.watch()` and `KAbsorber.read()` wrap Riverpod access in lightweight widgets.

Use them when you want to pass both the `WidgetRef` and the provider value into a builder.

```dart
KAbsorber.watch(myProvider, builder: (ref, value, child) {
  return Text('$value');
});
```

#### `src/state_mgmt/riverpod/src/custom_notifiers.dart`

Custom notifiers for Riverpod apps.

##### Primitive notifiers

- `KIntNotifier`
- `KDoubleNotifier`
- `KStringNotifier`
- `KBoolNotifier`
- `KSomeNotifier<T>`

##### Async notifiers

- `KWatchNotifier<T>`
- `KSomeAsyncNotifier<T>`

##### Cached notifier

- `KCachedNotifier<In, Out>` stores state in `kickin_storage` / Hive using the shared `kRiverpodCacheBoxName`.

---

## Usage

Import the package from one place:

```dart
import 'package:kickin_utilities/kickin_utilities.dart';
```

Minimal example:

```dart
final Map profile = '{"name":"Alice"}'.decodeJson;
final wait = 500.inMs;

final result = await KResult.tryRunAsync(() async => profile['name']);

class Example extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KAbsorber.watch(counterProvider, builder: (r, count, _) {
      return Text('Count: $count');
    });
  }
}
```

---

## Tests & Example App

The repository includes:

- `test/kickin_utilities_test.dart` for core package validation
- `example/` for a minimal Flutter app that uses `KSpacing` and Riverpod notifiers

Run tests:

```bash
flutter test
```

Run the example app:

```bash
cd example
flutter pub get
flutter run
```

---

## Installation

Add the package to your app:

```yaml
dependencies:
  kickin_utilities:
    ^0.0.1-dev.2
```

Or install it with the standard command:

```bash
flutter pub add kickin_utilities
```

---

## License

See the repository `LICENSE` file.
