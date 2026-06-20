import 'dart:async';
import 'dart:developer';

sealed class _ResultStatus {
  final Object? err;
  final StackTrace? stackTrace;
  static const loading = _Loading();
  static const success = _Success();

  const _ResultStatus(this.err, this.stackTrace);
  static _Error error(Object? err, StackTrace? st) => _Error(err, st);
}

class _Loading extends _ResultStatus {
  const _Loading() : super('', null);
}

class _Success extends _ResultStatus {
  const _Success() : super('', null);
}

class _Error extends _ResultStatus {
  _Error(super.message, super.stackTrace);
}

/// A simple wrapper for async operations that can be in loading, success, or error states.
/// status: The current status of the operation (loading, success, or error).
/// data: The data returned from a successful operation (if any). It can be null.
/// message: An error message if the operation failed. It can be null.
/// stackTrace: The stack trace of the error if the operation failed. It can be null.
class KResult<T> {
  // ignore: library_private_types_in_public_api
  final _ResultStatus status;
  final T? data;

  const KResult._({required this.status, this.data});

  T get value => data as T;

  const KResult.loading() : this._(status: _ResultStatus.loading);

  static KResult<T> success<T>(T value, {String? logMsg}) {
    if (logMsg != null) log("success: $logMsg", name: "KResult.success");
    return KResult._(status: _ResultStatus.success, data: value);
  }

  static KResult<T> error<T>(
    Object? error, [
    StackTrace? st,
    bool logError = true,
  ]) {
    if (logError) {
      log("error", error: error, stackTrace: st, name: "KResult.error");
    }
    return KResult._(status: _ResultStatus.error(error, st));
  }

  bool get isLoading => status == _ResultStatus.loading;
  bool get isSuccess => status == _ResultStatus.success;
  bool get isError => status is _Error;

  String get message => status.err.toString();
  StackTrace? get stackTrace => status.stackTrace;

  @override
  String toString() => switch (status) {
    _Loading() => 'Result<$T>: Loading',
    _Success() => 'Result<$T>: Success(data=$data)',
    _ => 'Result<$T>: Error(message=$message)',
  };

  /// Runs [operation] asynchronously and wraps the result in a [KResult.success] or [KResult.error] if it throws.
  static Future<KResult<T?>> tryRunAsync<T>(
    Future<T?> Function() operation, {
    bool logError = true,
  }) async {
    try {
      return KResult.success(await operation());
    } catch (e, st) {
      if (logError) {
        log(
          "Result tryRunAsync error: ${e.toString()}",
          error: e,
          stackTrace: st,
          name: "KResult.tryRunAsync",
        );
      }
      return KResult.error(e, st, logError);
    }
  }

  /// Runs [operation] synchronously and wraps the result in a [KResult.success] or [KResult.error] if it throws.
  static KResult<T?> tryRun<T>(
    T? Function() operation, {
    bool logError = true,
  }) {
    try {
      return KResult.success(operation());
    } catch (e, st) {
      return KResult.error(e, st, logError);
    }
  }

  /// Runs [operation] as FutureOr and wraps the result in a [KResult.success] or [KResult.error] if it throws.
  static FutureOr<KResult<T>> tryRunEither<T>(
    FutureOr<T?> Function() operation, {
    bool logError = true,
  }) async {
    try {
      return KResult.success((await operation()) as T);
    } catch (e, st) {
      if (logError) {
        log(
          "Result tryRunEither error: ${e.toString()}",
          error: e,
          stackTrace: st,
          name: "KResult.tryRunEither",
        );
      }
      return KResult.error(e, st, logError);
    }
  }

  /// Runs [transform] only if this is a success. Otherwise propagates loading/error.
  KResult<U?> doNext<U>(
    U? Function(T? data) transform, {
    bool failSilently = true,
  }) {
    if (!failSilently) {
      return isSuccess
          ? KResult.success(transform(data))
          : KResult.error(error);
    }
    return tryRun<U>(() => transform(data));
  }

  /// Runs [operation] only if this is a success; otherwise propagates loading/error.
  Future<KResult<U?>> then<U>(
    Future<U?> Function(T? data) operation, {
    bool failSilently = true,
  }) async {
    if (!failSilently) {
      return isSuccess
          ? KResult.success(await operation(data))
          : KResult.error(error);
    }
    return tryRunAsync(() async => operation(data));
  }

  KResult<T> onError(void Function(Object? error, [StackTrace? st]) handler) {
    if (isError) handler(status.err, stackTrace);
    return this;
  }
}
