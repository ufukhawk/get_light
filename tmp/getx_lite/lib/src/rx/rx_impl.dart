import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../state/rx_notifier.dart';
import 'rx_interface.dart';
import 'rx_typedefs.dart';

// ============================================================
// Rx<T> - The main reactive wrapper (used with .obs extension)
// ============================================================

/// A reactive variable that notifies listeners when its value changes.
///
/// Use `.obs` extension on any value to create an Rx variable:
/// ```dart
/// final count = 0.obs;
/// final name = 'John'.obs;
/// ```
class Rx<T> extends GetListenable<T> implements RxInterface<T> {
  Rx(T initial) : super(initial);

  @override
  T get value => super.value;

  @override
  set value(T val) {
    super.value = val;
  }

  @override
  Stream<T> get stream => super.stream;

  @override
  void bindStream(Stream<T> stream) {
    stream.listen((val) => value = val);
  }

  dynamic toJson() => (value as dynamic)?.toJson();
}

// ============================================================
// RxBool
// ============================================================

class RxBool extends Rx<bool> {
  RxBool(super.initial);

  void toggle() => value = !value;
}

// ============================================================
// RxInt
// ============================================================

class RxInt extends Rx<int> {
  RxInt(super.initial);

  RxInt operator +(int other) {
    value = value + other;
    return this;
  }

  RxInt operator -(int other) {
    value = value - other;
    return this;
  }

  RxInt operator *(int other) {
    value = value * other;
    return this;
  }

  double operator /(int other) => value / other;

  int operator ~/(int other) => value ~/ other;

  int operator %(int other) => value % other;

  bool operator >(int other) => value > other;
  bool operator <(int other) => value < other;
  bool operator >=(int other) => value >= other;
  bool operator <=(int other) => value <= other;
}

// ============================================================
// RxDouble
// ============================================================

class RxDouble extends Rx<double> {
  RxDouble(super.initial);

  RxDouble operator +(double other) {
    value = value + other;
    return this;
  }

  RxDouble operator -(double other) {
    value = value - other;
    return this;
  }

  RxDouble operator *(double other) {
    value = value * other;
    return this;
  }

  double operator /(double other) => value / other;

  bool operator >(double other) => value > other;
  bool operator <(double other) => value < other;
  bool operator >=(double other) => value >= other;
  bool operator <=(double other) => value <= other;
}

// ============================================================
// RxString
// ============================================================

class RxString extends Rx<String> {
  RxString(super.initial);

  bool get isBlank => value.trim().isEmpty;
  bool get isNotBlank => value.trim().isNotEmpty;
  bool get isNum => num.tryParse(value) != null;
  bool get isAlphabetOnly => RegExp(r'^[a-zA-Z]+$').hasMatch(value);
  bool get isDateTime => DateTime.tryParse(value) != null;
}

// ============================================================
// RxList<T>
// ============================================================

class RxList<E> extends Rx<List<E>> implements List<E> {
  RxList([List<E> initial = const []]) : super(initial);

  @override
  E get first => value.first;
  @override
  set first(E val) {
    value.first = val;
    refresh();
  }

  @override
  E get last => value.last;
  @override
  set last(E val) {
    value.last = val;
    refresh();
  }

  @override
  int get length => value.length;
  @override
  set length(int newLength) {
    value.length = newLength;
    refresh();
  }

  @override
  List<E> operator +(List<E> other) => value + other;

  @override
  E operator [](int index) => value[index];

  @override
  void operator []=(int index, E val) {
    value[index] = val;
    refresh();
  }

  @override
  void add(E element) {
    value.add(element);
    refresh();
  }

  @override
  void addAll(Iterable<E> iterable) {
    value.addAll(iterable);
    refresh();
  }

  @override
  bool any(bool Function(E) test) => value.any(test);

  @override
  Map<int, E> asMap() => value.asMap();

  @override
  List<R> cast<R>() => value.cast<R>();

  @override
  void clear() {
    value.clear();
    refresh();
  }

  @override
  bool contains(Object? element) => value.contains(element);

  @override
  E elementAt(int index) => value.elementAt(index);

  @override
  bool every(bool Function(E) test) => value.every(test);

  @override
  Iterable<T> expand<T>(Iterable<T> Function(E) toElements) =>
      value.expand(toElements);

  @override
  void fillRange(int start, int end, [E? fillValue]) {
    value.fillRange(start, end, fillValue);
    refresh();
  }

  @override
  E firstWhere(bool Function(E) test, {E Function()? orElse}) =>
      value.firstWhere(test, orElse: orElse);

  @override
  T fold<T>(T initialValue, T Function(T, E) combine) =>
      value.fold(initialValue, combine);

  @override
  Iterable<E> followedBy(Iterable<E> other) => value.followedBy(other);

  @override
  void forEach(void Function(E) action) => value.forEach(action);

  @override
  Iterable<E> getRange(int start, int end) => value.getRange(start, end);

  @override
  int indexOf(E element, [int start = 0]) => value.indexOf(element, start);

  @override
  int indexWhere(bool Function(E) test, [int start = 0]) =>
      value.indexWhere(test, start);

  @override
  void insert(int index, E element) {
    value.insert(index, element);
    refresh();
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    value.insertAll(index, iterable);
    refresh();
  }

  @override
  bool get isEmpty => value.isEmpty;
  @override
  bool get isNotEmpty => value.isNotEmpty;

  @override
  Iterator<E> get iterator => value.iterator;

  @override
  String join([String separator = '']) => value.join(separator);

  @override
  int lastIndexOf(E element, [int? start]) => value.lastIndexOf(element, start);

  @override
  int lastIndexWhere(bool Function(E) test, [int? start]) =>
      value.lastIndexWhere(test, start);

  @override
  E lastWhere(bool Function(E) test, {E Function()? orElse}) =>
      value.lastWhere(test, orElse: orElse);

  @override
  bool remove(Object? element) {
    final result = value.remove(element);
    if (result) refresh();
    return result;
  }

  @override
  E removeAt(int index) {
    final result = value.removeAt(index);
    refresh();
    return result;
  }

  @override
  E removeLast() {
    final result = value.removeLast();
    refresh();
    return result;
  }

  @override
  void removeRange(int start, int end) {
    value.removeRange(start, end);
    refresh();
  }

  @override
  void removeWhere(bool Function(E) test) {
    value.removeWhere(test);
    refresh();
  }

  @override
  void replaceRange(int start, int end, Iterable<E> replacements) {
    value.replaceRange(start, end, replacements);
    refresh();
  }

  @override
  void retainWhere(bool Function(E) test) {
    value.retainWhere(test);
    refresh();
  }

  @override
  void setAll(int index, Iterable<E> iterable) {
    value.setAll(index, iterable);
    refresh();
  }

  @override
  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    value.setRange(start, end, iterable, skipCount);
    refresh();
  }

  @override
  void shuffle([math.Random? random]) {
    value.shuffle(random);
    refresh();
  }

  @override
  E get single => value.single;

  @override
  E singleWhere(bool Function(E) test, {E Function()? orElse}) =>
      value.singleWhere(test, orElse: orElse);

  @override
  Iterable<E> skip(int count) => value.skip(count);

  @override
  Iterable<E> skipWhile(bool Function(E) test) => value.skipWhile(test);

  @override
  void sort([int Function(E, E)? compare]) {
    value.sort(compare);
    refresh();
  }

  @override
  List<E> sublist(int start, [int? end]) => value.sublist(start, end);

  @override
  Iterable<E> take(int count) => value.take(count);

  @override
  Iterable<E> takeWhile(bool Function(E) test) => value.takeWhile(test);

  @override
  List<E> toList({bool growable = true}) => value.toList(growable: growable);

  @override
  Set<E> toSet() => value.toSet();

  @override
  Iterable<E> where(bool Function(E) test) => value.where(test);

  @override
  Iterable<T> whereType<T>() => value.whereType<T>();
}

// ============================================================
// RxMap<K, V>
// ============================================================

class RxMap<K, V> extends Rx<Map<K, V>> implements Map<K, V> {
  RxMap([Map<K, V> initial = const {}]) : super(initial);

  @override
  void addAll(Map<K, V> other) {
    value.addAll(other);
    refresh();
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> entries) {
    value.addEntries(entries);
    refresh();
  }

  @override
  Map<RK, RV> cast<RK, RV>() => value.cast<RK, RV>();

  @override
  void clear() {
    value.clear();
    refresh();
  }

  @override
  bool containsKey(Object? key) => value.containsKey(key);

  @override
  bool containsValue(Object? value) => this.value.containsValue(value);

  @override
  Iterable<MapEntry<K, V>> get entries => value.entries;

  @override
  void forEach(void Function(K, V) action) => value.forEach(action);

  @override
  bool get isEmpty => value.isEmpty;

  @override
  bool get isNotEmpty => value.isNotEmpty;

  @override
  Iterable<K> get keys => value.keys;

  @override
  int get length => value.length;

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K, V) transform) =>
      value.map(transform);

  @override
  V? putIfAbsent(K key, V Function() ifAbsent) {
    final result = value.putIfAbsent(key, ifAbsent);
    refresh();
    return result;
  }

  @override
  V? remove(Object? key) {
    final result = value.remove(key);
    if (result != null) refresh();
    return result;
  }

  @override
  void removeWhere(bool Function(K, V) predicate) {
    value.removeWhere(predicate);
    refresh();
  }

  @override
  V update(K key, V Function(V) update, {V Function()? ifAbsent}) {
    final result = value.update(key, update, ifAbsent: ifAbsent);
    refresh();
    return result;
  }

  @override
  void updateAll(V Function(K, V) update) {
    value.updateAll(update);
    refresh();
  }

  @override
  Iterable<V> get values => value.values;

  @override
  V operator [](Object? key) => value[key] as V;

  @override
  void operator []=(K key, V val) {
    value[key] = val;
    refresh();
  }
}

// ============================================================
// RxSet<E>
// ============================================================

class RxSet<E> extends Rx<Set<E>> implements Set<E> {
  RxSet([Set<E> initial = const {}]) : super(initial);

  @override
  bool add(E element) {
    final result = value.add(element);
    if (result) refresh();
    return result;
  }

  @override
  void addAll(Iterable<E> elements) {
    value.addAll(elements);
    refresh();
  }

  @override
  bool contains(Object? element) => value.contains(element);

  @override
  bool containsAll(Iterable<Object?> other) => value.containsAll(other);

  @override
  Set<E> difference(Set<Object?> other) => value.difference(other);

  @override
  Set<E> intersection(Set<Object?> other) => value.intersection(other);

  @override
  E? lookup(Object? object) => value.lookup(object);

  @override
  bool remove(Object? element) {
    final result = value.remove(element);
    if (result) refresh();
    return result;
  }

  @override
  void removeAll(Iterable<Object?> elements) {
    value.removeAll(elements);
    refresh();
  }

  @override
  void removeWhere(bool Function(E) test) {
    value.removeWhere(test);
    refresh();
  }

  @override
  void retainAll(Iterable<Object?> elements) {
    value.retainAll(elements);
    refresh();
  }

  @override
  void retainWhere(bool Function(E) test) {
    value.retainWhere(test);
    refresh();
  }

  @override
  Set<E> union(Set<E> other) => value.union(other);

  @override
  Iterator<E> get iterator => value.iterator;

  @override
  int get length => value.length;

  @override
  bool get isEmpty => value.isEmpty;

  @override
  bool get isNotEmpty => value.isNotEmpty;

  @override
  E get first => value.first;

  @override
  E get last => value.last;

  @override
  E get single => value.single;

  @override
  E elementAt(int index) => value.elementAt(index);

  @override
  void clear() {
    value.clear();
    refresh();
  }

  @override
  void forEach(void Function(E) action) => value.forEach(action);

  @override
  Set<R> cast<R>() => value.cast<R>();

  @override
  bool any(bool Function(E) test) => value.any(test);

  @override
  bool every(bool Function(E) test) => value.every(test);

  @override
  Set<E> toSet() => value.toSet();

  @override
  List<E> toList({bool growable = true}) => value.toList(growable: growable);
}

// ============================================================
// .obs extension - Makes any value reactive
// ============================================================

extension ReactiveExt<T> on T {
  /// Converts a value to a reactive Rx variable.
  ///
  /// ```dart
  /// final name = 'John'.obs;   // RxString
  /// final count = 0.obs;       // RxInt
  /// final price = 9.99.obs;    // RxDouble
  /// final flag = true.obs;     // RxBool
  /// final items = [1,2,3].obs; // RxList<int>
  /// ```
  Rx<T> get obs {
    if (this is Rx) return this as Rx<T>;

    if (T == int) return RxInt(this as int) as Rx<T>;
    if (T == double) return RxDouble(this as double) as Rx<T>;
    if (T == String) return RxString(this as String) as Rx<T>;
    if (T == bool) return RxBool(this as bool) as Rx<T>;

    if (this is List) return RxList<E>(this as List<E>) as Rx<T>;
    if (this is Map) return RxMap<K, V>(this as Map<K, V>) as Rx<T>;
    if (this is Set) return RxSet<E>(this as Set<E>) as Rx<T>;

    return Rx<T>(this);
  }
}

// Math import
import 'dart:math' as math;
