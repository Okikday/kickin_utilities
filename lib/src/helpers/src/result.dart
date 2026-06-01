import 'dart:async';
import 'dart:developer';

sealed class _ResultStatus {
  final String message;
  final StackTrace? stackTrace;
  static const loading = _Loading();
  static const success = _Success();

  const _ResultStatus(this.message, this.stackTrace);
  static _Error error(String message, StackTrace? st) => _Error(message, st);
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
    if (logMsg != null) log("success: $logMsg");
    return KResult._(status: _ResultStatus.success, data: value);
  }

  static KResult<T> error<T>(String message, [StackTrace? st, bool logError = true]) {
    if (logError) log("error: $message", error: message, stackTrace: st);
    return KResult._(status: _ResultStatus.error(message, st));
  }

  bool get isLoading => status == _ResultStatus.loading;
  bool get isSuccess => status == _ResultStatus.success;
  bool get isError => status is _Error;

  String get message => status.message;
  StackTrace? get stackTrace => status.stackTrace;

  @override
  String toString() => switch (status) {
    _Loading() => 'Result<$T>: Loading',
    _Success() => 'Result<$T>: Success(data=$data)',
    _ => 'Result<$T>: Error(message=$message)',
  };

  /// Runs [operation] and wraps the result in a [KResult.success] or [KResult.error] if it throws.
  static Future<KResult<T?>> tryRunAsync<T>(Future<T?> Function() operation, {bool logError = true}) async {
    try {
      return KResult.success(await operation());
    } catch (e, st) {
      if (logError) {
        log("Result tryRunAsync error: ${e.toString()}", error: e, stackTrace: st);
      }
      return KResult.error(e.toString(), st, logError);
    }
  }

  static KResult<T?> tryRun<T>(T? Function() operation, {bool logError = true}) {
    try {
      return KResult.success(operation());
    } catch (e, st) {
      return KResult.error(e.toString(), st, logError);
    }
  }

  static FutureOr<KResult<T>> tryRunEither<T>(FutureOr<T?> Function() operation, {bool logError = true}) async {
    try {
      return KResult.success((await operation()) as T);
    } catch (e, st) {
      if (logError) {
        log("Result tryRunEither error: ${e.toString()}", error: e, stackTrace: st);
      }
      return KResult.error(e.toString(), st, logError);
    }
  }

  /// Runs [transform] only if this is a success. Otherwise propagates loading/error.
  KResult<U?> doNext<U>(U? Function(T? data) transform, {bool failSilently = true}) {
    if (!failSilently) {
      return isSuccess ? KResult.success(transform(data)) : KResult.error(message);
    }
    return tryRun<U>(() => transform(data));
  }

  /// Runs [operation] only if this is a success; otherwise propagates loading/error.
  Future<KResult<U?>> then<U>(Future<U?> Function(T? data) operation, {bool failSilently = true}) async {
    if (!failSilently) {
      return isSuccess ? KResult.success(await operation(data)) : KResult.error(message);
    }
    return tryRunAsync(() async => operation(data));
  }

  KResult<T> onError(void Function(String message, [StackTrace? st]) handler) {
    if (isError) handler(message, stackTrace);
    return this;
  }
}
