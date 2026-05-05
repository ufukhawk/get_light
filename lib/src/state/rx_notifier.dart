import 'dart:async';
import 'package:flutter/foundation.dart';

import '../rx/rx_interface.dart';
import 'list_notifier.dart';

// ============================================================
// Global Rx tracking for Obx widgets
// ============================================================

/// During an Obx build, when an Rx value is read, the Rx variable
/// passes itself to this callback so the Obx element can subscribe.
void Function(RxInterface)? _currentRxContext;

/// Call this before building an Obx widget tree.
void pushRxContext(void Function(RxInterface) onRxRead) {
  _currentRxContext = onRxRead;
}

/// Call this after building an Obx widget tree.
void popRxContext() {
  _currentRxContext = null;
}

/// Called by Rx values when their [value] is read during an Obx build.
void _reportRxRead(RxInterface rx) {
  _currentRxContext?.call(rx);
}

// ============================================================
// GetListenable<T> - The base reactive value (used by Rx<T>)
// ============================================================

class GetListenable<T> extends ListNotifierSingle<T> implements RxInterface<T> {
  GetListenable(T val) : _value = val;

  StreamController<T>? _controller;

  StreamController<T> get subject {
    if (_controller == null) {
      _controller = StreamController<T>.broadcast(sync: true);
    }
    return _controller!;
  }

  @override
  @mustCallSuper
  void close() {
    _controller?.close();
    dispose();
  }

  @override
  Stream<T> get stream => subject.stream;

  @override
  void bindStream(Stream<T> stream) {
    stream.listen((val) => value = val);
  }

  T _value;

  @override
  T get value {
    reportRead();
    _reportRxRead(this); // Auto-register with current Obx context
    return _value;
  }

  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    refresh();
    _controller?.add(_value);
  }

  T? call([T? v]) {
    if (v != null) {
      value = v;
    }
    return value;
  }

  @override
  StreamSubscription<T> listen(
    void Function(T)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final ctrl = StreamController<T>(sync: true);
    final cancel = addListener(() {
      if (!ctrl.isClosed) ctrl.add(_value);
    });
    ctrl.onCancel = () {
      cancel();
      ctrl.close();
    };
    return ctrl.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError ?? false,
    );
  }

  @override
  String toString() => value.toString();
}

// ============================================================
// Equality mixin (used by GetStatus)
// ============================================================

mixin Equality {
  List<Object?> get props;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Equality) return false;
    if (props.length != other.props.length) return false;
    for (var i = 0; i < props.length; i++) {
      if (props[i] != other.props[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(props);
}

// ============================================================
// GetStatus - Loading / Success / Error / Empty states
// ============================================================

abstract class GetStatus<T> with Equality {
  const GetStatus();

  factory GetStatus.loading() => LoadingStatus<T>();
  factory GetStatus.error(Object message) => ErrorStatus<T, Object>(message);
  factory GetStatus.empty() => EmptyStatus<T>();
  factory GetStatus.success(T data) => SuccessStatus<T>(data);
}

class LoadingStatus<T> extends GetStatus<T> {
  @override
  List<Object?> get props => [];
}

class SuccessStatus<T> extends GetStatus<T> {
  final T data;
  const SuccessStatus(this.data);

  @override
  List<Object?> get props => [data];
}

class ErrorStatus<T, S> extends GetStatus<T> {
  final S? error;
  const ErrorStatus([this.error]);

  @override
  List<Object?> get props => [error];
}

class EmptyStatus<T> extends GetStatus<T> {
  @override
  List<Object?> get props => [];
}

extension StatusDataExt<T> on GetStatus<T> {
  bool get isLoading => this is LoadingStatus;
  bool get isSuccess => this is SuccessStatus;
  bool get isError => this is ErrorStatus;
  bool get isEmpty => this is EmptyStatus;

  dynamic get error {
    if (this is ErrorStatus) {
      return (this as ErrorStatus).error;
    }
    return null;
  }

  String get errorMessage {
    if (this is ErrorStatus) {
      final err = this as ErrorStatus;
      if (err.error != null) {
        return err.error is String ? err.error as String : err.error.toString();
      }
    }
    return '';
  }

  T? get data {
    if (this is SuccessStatus) {
      return (this as SuccessStatus).data;
    }
    return null;
  }
}

// ============================================================
// StateMixin - Adds loading/error/success state handling
// ============================================================

extension _Empty on Object? {
  bool _isEmpty() {
    final val = this;
    if (val == null) return true;
    if (val is Iterable) return val.isEmpty;
    if (val is String) return val.trim().isEmpty;
    if (val is Map) return val.isEmpty;
    return false;
  }
}

mixin StateMixin<T> on ListNotifier {
  T? _value;
  GetStatus<T>? _status;

  void _fillInitialStatus() {
    _status = (_value == null || _value!._isEmpty())
        ? GetStatus.loading()
        : GetStatus.success(_value as T);
  }

  GetStatus<T> get status {
    reportRead();
    return _status ??= GetStatus.loading();
  }

  T get state => value;

  set status(GetStatus<T> newStatus) {
    if (newStatus == status) return;
    _status = newStatus;
    if (newStatus is SuccessStatus<T>) {
      _value = newStatus.data;
    }
    refresh();
  }

  T get value {
    reportRead();
    return _value as T;
  }

  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    refresh();
  }

  void change(GetStatus<T> status) {
    if (status != this.status) {
      this.status = status;
    }
  }

  void setSuccess(T data) => change(GetStatus.success(data));
  void setError(Object error) => change(GetStatus.error(error));
  void setLoading() => change(GetStatus.loading());
  void setEmpty() => change(GetStatus.empty());

  void futurize(
    Future<T> Function() body, {
    T? initialData,
    String? errorMessage,
    bool useEmpty = true,
  }) {
    final compute = body;
    _value ??= initialData;
    status = GetStatus.loading();
    compute().then((newValue) {
      if ((newValue == null || newValue._isEmpty()) && useEmpty) {
        status = GetStatus.empty();
      } else {
        status = GetStatus.success(newValue);
      }
      refresh();
    }, onError: (err) {
      status = GetStatus.error(
        err is Exception ? err : Exception(errorMessage ?? err.toString()),
      );
      refresh();
    });
  }
}

// ============================================================
// Value<T> - A non-reactive value holder with status
// ============================================================

class Value<T> extends ListNotifier with StateMixin<T>
    implements ValueListenable<T?> {
  Value(T val) {
    _value = val;
    _fillInitialStatus();
  }

  @override
  T get value {
    reportRead();
    return _value as T;
  }

  @override
  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    refresh();
  }

  T? call([T? v]) {
    if (v != null) {
      value = v;
    }
    return value;
  }

  void update(T Function(T? value) fn) {
    value = fn(value);
  }

  @override
  String toString() => value.toString();

  dynamic toJson() => (value as dynamic)?.toJson();
}
