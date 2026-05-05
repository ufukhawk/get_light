import 'dart:async';
/// The reactive interface that all Rx types implement.
abstract class RxInterface<T> {
  /// Current value.
  T get value;

  /// Set the current value.
  set value(T val);

  /// Stream of value changes.
  Stream<T> get stream;

  /// Listen to value changes.
  StreamSubscription<T> listen(
    void Function(T)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  });

  /// Close the reactive variable.
  void close();

  /// Bind a stream to this Rx variable.
  void bindStream(Stream<T> stream) {
    stream.listen((val) => value = val);
  }
}

