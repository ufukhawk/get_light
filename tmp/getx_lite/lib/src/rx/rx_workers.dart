import 'dart:async';
import '../state/rx_notifier.dart';

// ============================================================
// Worker callbacks: ever, once, interval, debounce
// ============================================================

bool _conditional(dynamic condition) {
  if (condition == null) return true;
  if (condition is bool) return condition;
  if (condition is bool Function()) return condition();
  return true;
}

typedef WorkerCallback<T> = Function(T callback);

/// Manages a collection of workers that can be disposed together.
class Workers {
  Workers(this.workers);
  final List<Worker> workers;

  void dispose() {
    for (final worker in workers) {
      if (!worker._disposed) {
        worker.dispose();
      }
    }
  }
}

/// Called every time [listener] changes, as long as [condition] returns true.
///
/// ```dart
/// worker = ever(count, (value) {
///   print('counter changed to: $value');
/// }, condition: () => count > 5);
/// ```
Worker ever<T>(
  GetListenable<T> listener,
  WorkerCallback<T> callback, {
  dynamic condition = true,
  Function? onError,
  void Function()? onDone,
  bool? cancelOnError,
}) {
  StreamSubscription<T> sub = listener.listen(
    (event) {
      if (_conditional(condition)) callback(event);
    },
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
  return Worker(sub.cancel, '[ever]');
}

/// Similar to [ever], but takes a list of [listeners].
Worker everAll<T>(
  List<GetListenable<T>> listeners,
  WorkerCallback<T> callback, {
  dynamic condition = true,
  Function? onError,
  void Function()? onDone,
  bool? cancelOnError,
}) {
  final evers = <StreamSubscription<T>>[];
  for (final listener in listeners) {
    final sub = listener.listen(
      (event) {
        if (_conditional(condition)) callback(event);
      },
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    evers.add(sub);
  }

  Future<void> cancel() async {
    for (final sub in evers) {
      await sub.cancel();
    }
  }
  return Worker(cancel, '[everAll]');
}

/// Executes only 1 time when [condition] is met, then cancels.
///
/// ```dart
/// worker = once(count, (value) {
///   print("counter reached $value");
/// }, condition: () => count() > 2);
/// ```
Worker once<T>(
  GetListenable<T> listener,
  WorkerCallback<T> callback, {
  dynamic condition = true,
  Function? onError,
  void Function()? onDone,
  bool? cancelOnError,
}) {
  late Worker ref;
  StreamSubscription<T>? sub;
  sub = listener.listen(
    (event) {
      if (!_conditional(condition)) return;
      ref._disposed = true;
      sub?.cancel();
      callback(event);
    },
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
  ref = Worker(sub.cancel, '[once]');
  return ref;
}

/// Ignores all changes during [time], then emits the first value after timeout.
///
/// ```dart
/// worker = interval(count, (value) => print(value),
///   time: Duration(seconds: 1),
///   condition: () => count < 20,
/// );
/// ```
Worker interval<T>(
  GetListenable<T> listener,
  WorkerCallback<T> callback, {
  Duration time = const Duration(seconds: 1),
  dynamic condition = true,
  Function? onError,
  void Function()? onDone,
  bool? cancelOnError,
}) {
  var debounceActive = false;
  StreamSubscription<T> sub = listener.listen(
    (event) async {
      if (debounceActive || !_conditional(condition)) return;
      debounceActive = true;
      await Future.delayed(time);
      debounceActive = false;
      callback(event);
    },
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
  return Worker(sub.cancel, '[interval]');
}

/// Debouncer utility for [debounce] worker.
class _Debouncer {
  _Debouncer({required this.delay});
  final Duration delay;
  Timer? _timer;

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }
}

/// Like [interval], but sends the last value after the debounce period.
/// Useful for search-as-you-type, anti-DDoS, etc.
///
/// ```dart
/// worker = debounce(searchQuery, (value) {
///   searchAPI(value);
/// }, time: Duration(milliseconds: 300));
/// ```
Worker debounce<T>(
  GetListenable<T> listener,
  WorkerCallback<T> callback, {
  Duration? time,
  Function? onError,
  void Function()? onDone,
  bool? cancelOnError,
}) {
  final debouncer = _Debouncer(
    delay: time ?? const Duration(milliseconds: 800),
  );
  StreamSubscription<T> sub = listener.listen(
    (event) {
      debouncer(() {
        callback(event);
      });
    },
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
  return Worker(sub.cancel, '[debounce]');
}

/// A single worker reference returned by [ever], [once], [interval], [debounce].
class Worker {
  Worker(this.worker, this.type);

  /// subscription.cancel() callback
  final Future<void> Function() worker;

  /// type of worker (debounce, interval, ever, once)
  final String type;

  bool _disposed = false;
  bool get disposed => _disposed;

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    worker();
  }

  void call() => dispose();
}
