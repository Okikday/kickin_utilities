// lib/smart_isolate_web.dart
import 'dart:async';
import 'dart:collection';
import 'package:flutter/services.dart';

enum KWorkPriority { low, medium, high }

const int kDefaultMaxQueueSize = 512;

class KIsolate<TArg, TProgress, TResult> {
  static Future<TResult> run<TArg, TProgress, TResult>(
    Future<TResult> Function(TArg arg, void Function(TProgress) emit) task,
    TArg arg, {
    void Function(TProgress)? onProgress,
  }) async {
    // Runs on the main browser thread asynchronously
    return await task(arg, (progress) {
      if (onProgress != null) onProgress(progress);
    });
  }
}

class KIsolateContinuous<TArg, TResult> {
  KIsolateContinuous._({
    required this.maxQueueSize,
    required this.agingThreshold,
  });

  final int maxQueueSize;
  final int agingThreshold;
  bool _running = false;
  bool get isRunning => _running;

  void Function(TArg, void Function(TResult))? _handler;
  final Queue<_Queued<TArg>> _high = Queue();
  final Queue<_Queued<TArg>> _med = Queue();
  final Queue<_Queued<TArg>> _low = Queue();
  bool _dispatching = false;
  int _nonLowSincePromotion = 0;
  int _nextId = 0;
  static const int _maxId = 0x1FFFFFFFFFFFFF;

  int get pendingCount => _high.length + _med.length + _low.length;

  static Future<KIsolateContinuous<TArg, TResult>> spawn<TArg, TResult>(
    Future<void> Function(
      void Function(void Function(TArg arg, void Function(TResult) respond))
      registerHandler,
    )
    initialize, {
    RootIsolateToken? rootIsolateToken,
    int maxQueueSize = kDefaultMaxQueueSize,
    int agingThreshold = 10,
  }) async {
    final inst = KIsolateContinuous<TArg, TResult>._(
      maxQueueSize: maxQueueSize,
      agingThreshold: agingThreshold,
    );
    await initialize((handler) => inst._handler = handler);
    inst._running = true;
    return inst;
  }

  Future<TResult> execute(
    TArg arg, {
    KWorkPriority priority = KWorkPriority.medium,
  }) {
    if (!_running) throw const KIsolateException('Isolate is not running.');
    if (pendingCount >= maxQueueSize) {
      throw KIsolateException('Task queue is full.');
    }

    final completer = Completer<TResult>();
    final task = _Queued<TArg>(_nextId++, arg, completer);
    if (_nextId >= _maxId) _nextId = 0;

    switch (priority) {
      case KWorkPriority.high:
        _high.add(task);
        break;
      case KWorkPriority.medium:
        _med.add(task);
        break;
      case KWorkPriority.low:
        _low.add(task);
        break;
    }

    scheduleMicrotask(_next);
    return completer.future;
  }

  void _next() {
    if (_dispatching || _handler == null) return;
    _Queued<TArg>? task;

    if (_low.isNotEmpty && _nonLowSincePromotion >= agingThreshold) {
      task = _low.removeFirst();
      _nonLowSincePromotion = 0;
    } else if (_high.isNotEmpty) {
      task = _high.removeFirst();
      _nonLowSincePromotion++;
    } else if (_med.isNotEmpty) {
      task = _med.removeFirst();
      _nonLowSincePromotion++;
    } else if (_low.isNotEmpty) {
      task = _low.removeFirst();
      _nonLowSincePromotion = 0;
    }

    if (task == null) return;
    _dispatching = true;

    try {
      _handler!(task.arg, (result) {
        if (!task!.completer.isCompleted) task.completer.complete(result);
        _dispatching = false;
        _next();
      });
    } catch (e, st) {
      if (!task.completer.isCompleted) task.completer.completeError(e, st);
      _dispatching = false;
      _next();
    }
  }

  void dispose() {
    _running = false;
    _high.clear();
    _med.clear();
    _low.clear();
  }
}

mixin KIsolateAccess {
  Future<TResult> isolateRun<TArg, TProgress, TResult>(
    Future<TResult> Function(TArg arg, void Function(TProgress) emit) task,
    TArg arg, {
    void Function(TProgress)? onProgress,
  }) =>
      KIsolate.run<TArg, TProgress, TResult>(task, arg, onProgress: onProgress);

  Future<KIsolateContinuous<TArg, TResult>> isolateSpawn<TArg, TResult>(
    Future<void> Function(
      void Function(void Function(TArg, void Function(TResult)))
      registerHandler,
    )
    initialize, {
    RootIsolateToken? rootIsolateToken,
    int maxQueueSize = kDefaultMaxQueueSize,
    int agingThreshold = 10,
  }) => KIsolateContinuous.spawn<TArg, TResult>(
    initialize,
    rootIsolateToken: rootIsolateToken,
    maxQueueSize: maxQueueSize,
    agingThreshold: agingThreshold,
  );
}

class KIsolateException implements Exception {
  final String message;
  final StackTrace? stackTrace;
  const KIsolateException(this.message, [this.stackTrace]);
  @override
  String toString() => 'SmartIsolateException: $message';
}

class _Queued<TArg> {
  final int id;
  final TArg arg;
  final Completer completer;
  const _Queued(this.id, this.arg, this.completer);
}
