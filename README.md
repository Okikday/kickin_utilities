# kickin_utilities

A Flutter package of common utilities: constants, extensions, helpers, and mixins. No dependencies beyond Flutter itself.

Part of the **Kickin** toolkit for Flutter.

---

## Installation

```sh
flutter pub add kickin_utilities
```

Or add it manually to your `pubspec.yaml`:

```yaml
dependencies:
  kickin_utilities: ^0.0.1
```

Then import it:

```dart
import 'package:kickin_utilities/kickin_utilities.dart';
```

---

## What's included

| Feature | What it gives you |
|---|---|
| **Constants** | Spacing tokens (`KSpacing`) and motion curves (`KCurves`) |
| **Extensions** | Shortcuts on `String`, `num`, `Color`, `BuildContext`, `Duration`, and Riverpod providers |
| **Helpers** | `KResult` for safe async operations, `KIsolate` for background tasks |
| **Mixins** | Scroll offset tracking, scroll threshold detection, and page controller ownership |

---

## Constants

### `KSpacing`

Named spacing tokens for consistent layout padding and gaps.

```dart
Container(padding: const EdgeInsets.all(KSpacing.md));
```

Available sizes: `xxs`, `xs`, `sm`, `md`, `lg`, `xl`, `xxl`, `xxxl`, `huge`, `massive`

### `KCurves`

Pre-defined animation curves for consistent motion across your app.

```dart
// Spring curves
KCurves.instantSpring
KCurves.defaultIosSpring
KCurves.bouncySpring
KCurves.snappySpring
KCurves.interactiveSpring

// Easing curves
KCurves.fastInSlowOut
KCurves.easeOutSine
KCurves.easeOutCirc
KCurves.bounceOut
```

---

## Extensions

### On `num`

Duration helpers and spacing widgets:

```dart
await 500.inMs.delay();   // wait 500 ms
await 2.inSeconds.delay();

16.toVBox    // SizedBox(height: 16)
16.toHBox    // SizedBox(width: 16)
16.toVSliverBox  // sliver version
16.toHSliverBox  // sliver version
```

### On `BuildContext`

Theme and layout shortcuts — no more deep `MediaQuery.of(context)` chains:

```dart
context.isDarkMode
context.theme
context.scaffoldBackgroundColor
context.screenSize
context.deviceWidth
context.deviceHeight
context.topPadding
context.bottomPadding
context.viewInsets
```

### On `String`

```dart
final data = '{"name":"Alice"}'.decodeJson; // Map or list
```

### On `Color`

```dart
final lighter = myColor.lightenColor(); // HSL-based lightening
```

### On `Duration`

```dart
await 1.inSeconds.delay(); // Future.delayed shorthand
```

### On Riverpod providers

Shortcuts on `ProviderListenable`, `Ref`, `WidgetRef`, and notifier providers:

```dart
// Read or watch a provider
userProvider.read(ref)
userProvider.watch(ref)

// Boolean inversion
userProvider.not(ref)       // reads the negation
userProvider.watchNot(ref)  // watches the negation

// Keep alive for a duration then auto-dispose
ref.keepAliveFor(const Duration(minutes: 5));
```

---

## Helpers

### `KResult<T>` — safe async operations

A wrapper for loading, success, and error states. Use it instead of repeating `try/catch` everywhere.

```dart
final result = await KResult.tryRunAsync(() async => fetchUser(id));

if (result.isSuccess) {
  print(result.value);
} else {
  print(result.message); // readable error
}
```

**Constructors:**

| Method | Description |
|---|---|
| `KResult.loading()` | Represents an in-progress state |
| `KResult.success(value)` | Wraps a successful result |
| `KResult.error(message)` | Wraps an error with a message |
| `KResult.tryRunAsync(fn)` | Runs async work, captures errors automatically |
| `KResult.tryRun(fn)` | Same but synchronous |

**Chaining:**

```dart
final result = await KResult.tryRunAsync(() => fetchUser(id))
    .then((r) => r.doNext(() => fetchPosts(r.value!.id)))
    .onError((r) => print('Failed: ${r.message}'));
```

---

### `KIsolate` — background tasks

Run CPU-heavy work off the main thread without managing isolates manually.

#### `KIsolate` — one-shot task

```dart
final result = await KIsolate.run(
  arg: largeDataSet,
  task: (data) => processList(data),
);
```

#### `KIsolateContinuous` — persistent worker

Runs sequential tasks in a single long-lived isolate. Good for queued background work like file processing.

```dart
final worker = KIsolateContinuous<String, String>();
await worker.spawn(task: (input) => compressString(input));
final output = await worker.run(arg: 'some large text');
```

#### `KIsolateAccess` mixin

Add isolate helpers directly to a class:

```dart
class MyService with KIsolateAccess {
  Future<String> process(String input) => isolateRun(arg: input, task: heavyFn);
}
```

---

## Mixins

Drop-in state helpers for common widget patterns.

### `KScrollOffsetNotifierMixin`

Exposes the current scroll offset as a `ValueNotifier<double>`. Automatically updates as the user scrolls.

```dart
class _MyState extends State<MyWidget> with KScrollOffsetNotifierMixin {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: scrollOffset,
      builder: (_, offset, __) => Text('Offset: $offset'),
    );
  }
}
```

### `KIsScrolledNotifierMixin`

Flips a `ValueNotifier<bool>` when scroll passes the toolbar-height threshold. Useful for showing/hiding app bar shadows or sticky headers.

### `KPageControllerMixin`

Owns and disposes a `PageController` for you — no boilerplate `initState`/`dispose` needed.

---

## Full example

```dart
import 'package:kickin_utilities/kickin_utilities.dart';

Future<void> main() async {
  // Safe async operation
  final result = await KResult.tryRunAsync(() async {
    await 1.inSeconds.delay();
    return '{"name":"Alice"}'.decodeJson;
  });

  if (result.isSuccess) {
    print(result.value); // {name: Alice}
  } else {
    print(result.message);
  }
}

// Spacing in widgets
Widget spacedColumn() => Column(
  children: [
    const Text('Hello'),
    16.toVBox,
    const Text('World'),
  ],
);

// Context shortcuts
Widget header(BuildContext context) => Container(
  width: context.deviceWidth,
  padding: EdgeInsets.only(top: context.topPadding),
  color: context.isDarkMode ? Colors.black : Colors.white,
);
```

---

## API reference summary

| Class / Extension | Purpose |
|---|---|
| `KSpacing` | Named spacing constants |
| `KCurves` | Named animation curves |
| `KResult<T>` | Safe async result wrapper |
| `KIsolate` | One-shot background isolate task |
| `KIsolateContinuous` | Persistent background worker isolate |
| `KIsolateAccess` | Mixin for easy isolate access in any class |
| `KIsolateException` | Exception thrown when isolate work fails |
| `KScrollOffsetNotifierMixin` | Tracks scroll offset in a `ValueNotifier` |
| `KIsScrolledNotifierMixin` | Detects when scroll passes a threshold |
| `KPageControllerMixin` | Owns and disposes a `PageController` |
