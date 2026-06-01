import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickin_storage/kickin_storage.dart';
import 'package:kickin_utilities/src/helpers/helpers.dart';
import 'package:kickin_utilities/src/state_mgmt/riverpod/riverpod.dart';

// export 'package:flutter_riverpod/flutter_riverpod.dart';

//=============================================
// BASE NOTIFIER
//=============================================
abstract class _BaseNotifier<T> extends Notifier<T> {
  final T _defaultKey;
  _BaseNotifier(this._defaultKey);
  @override
  T build() => _defaultKey;

  void update(T Function(T) cb) {
    final next = cb(state);
    if (next != state) state = next;
  }

  void set(T value) => state = value;
}

//=============================================
// PRIMITIVE TYPE NOTIFIERS
//=============================================
/// A simple `int` notifier with convenience defaults.
class KIntNotifier extends _BaseNotifier<int> {
  KIntNotifier([super._defaultKey = 0]);
}

/// A simple `double` notifier with convenience defaults.
class KDoubleNotifier extends _BaseNotifier<double> {
  KDoubleNotifier([super._defaultKey = 0.0]);
}

/// A simple `String` notifier with convenience defaults.
class KStringNotifier extends _BaseNotifier<String> {
  KStringNotifier([super._defaultKey = '']);
}

/// A boolean notifier with a `toggle()` helper.
class KBoolNotifier extends _BaseNotifier<bool> {
  KBoolNotifier([super._defaultKey = false]);
  void toggle() => state = !state;
}

/// Generic notifier for arbitrary types with simple `set`/`update` helpers.
class KSomeNotifier<T> extends _BaseNotifier<T> {
  KSomeNotifier(super._defaultKey);
}

//=============================================
// ASYNC* BASE NOTIFIER
//=============================================
/// A notifier backed by a [Stream].
class KWatchNotifier<T> extends StreamNotifier<T> {
  final Stream<T> Function() _streamFactory;
  KWatchNotifier(this._streamFactory);
  @override
  Stream<T> build() => _streamFactory();
}

//=============================================
// ASYNC BASE NOTIFIER
//=============================================

abstract class _AsyncBaseNotifier<T> extends AsyncNotifier<T> {
  final T _defaultKey;
  _AsyncBaseNotifier(this._defaultKey);

  @override
  FutureOr<T> build() => _defaultKey;

  void set(T value) => state = AsyncData(value);
}

/// Async notifier that exposes an initial default value and can be set later.
class KSomeAsyncNotifier<T> extends _AsyncBaseNotifier<T> {
  KSomeAsyncNotifier(super._defaultKey);
}

// ============================================================================
// PersistentNotifier - With Hive persistence
// ============================================================================

/// [In] is how the data get's stored
/// [Out] is how the data is output
class KCachedNotifier<In, Out> extends AsyncNotifier<Out> {
  static final _hive = AppHive(boxName: kRiverpodCacheBoxName);
  final String _key;
  final Out _defaultValue;
  final bool? isUpdateNotifying;
  final FutureOr<Out> Function(In? data)? decode;
  final FutureOr<In> Function(Out raw)? encode;

  String get key => _key;
  Out get defaultValue => _defaultValue;

  Future<void> _writeLock = Future.value();

  KCachedNotifier(this._key, this._defaultValue, {this.isUpdateNotifying, this.decode, this.encode});

  @override
  Future<Out> build() async {
    return (await KResult.tryRunAsync<Out>(() async {
              if (!_hive.isInitialized) await _hive.initialize();
              final data = await _hive.getData(key: _key);
              return decode?.call(data) ?? data as Out?;
            }))
            .onError((e, [st]) => KResult.error<Out>("Try using decode params to properly decode data from storage"))
            .data ??
        _defaultValue;
  }

  Future<void> set(Out value) async {
    state = AsyncData(value);
    if (!_hive.isInitialized) await _hive.initialize();
    await _scheduleWrite(value);
  }

  Future<void> updateIfNotEqual(Out value) async {
    if (value == state.value) return;
    await set(value);
  }

  Future<void> _scheduleWrite(Out value) async => await KResult.tryRunAsync(
    () async => _writeLock = _writeLock.then((_) {
      final encoded = encode?.call(value) ?? value as In;
      return _hive.setData(key: _key, value: encoded);
    }),
  ).onError((e, st) => KResult.error("Try using the encode params: $e"));

  @override
  bool updateShouldNotify(AsyncValue<Out> previous, AsyncValue<Out> next) =>
      isUpdateNotifying ?? super.updateShouldNotify(previous, next);
}
