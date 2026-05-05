import 'dart:async';
import 'dart:math' as math;
import '../state/rx_notifier.dart';
import 'rx_interface.dart';

// ============================================================
// Rx<T> - The main reactive wrapper
// ============================================================

class Rx<T> extends GetListenable<T> implements RxInterface<T> {
  Rx(T initial) : super(initial);

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

  RxInt operator +(int other) { value = value + other; return this; }
  RxInt operator -(int other) { value = value - other; return this; }
  RxInt operator *(int other) { value = value * other; return this; }
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

  RxDouble operator +(double other) { value = value + other; return this; }
  RxDouble operator -(double other) { value = value - other; return this; }
  RxDouble operator *(double other) { value = value * other; return this; }
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
// RxList<E>
// ============================================================

class RxList<E> extends Rx<List<E>> implements List<E> {
  RxList([List<E>? initial]) : super(initial ?? <E>[]);

  @override E get first => value.first;
  @override set first(E val) { value.first = val; refresh(); }
  @override E get last => value.last;
  @override set last(E val) { value.last = val; refresh(); }
  @override int get length => value.length;
  @override set length(int newLength) { value.length = newLength; refresh(); }
  @override List<E> operator +(List<E> other) => value + other;
  @override E operator [](int index) => value[index];
  @override void operator []=(int index, E val) { value[index] = val; refresh(); }
  @override void add(E element) { value.add(element); refresh(); }
  @override void addAll(Iterable<E> iterable) { value.addAll(iterable); refresh(); }
  @override bool any(bool Function(E) test) => value.any(test);
  @override Map<int, E> asMap() => value.asMap();
  @override List<R> cast<R>() => value.cast<R>();
  @override void clear() { value.clear(); refresh(); }
  @override bool contains(Object? element) => value.contains(element);
  @override E elementAt(int index) => value.elementAt(index);
  @override bool every(bool Function(E) test) => value.every(test);
  @override Iterable<T> expand<T>(Iterable<T> Function(E) toElements) => value.expand(toElements);
  @override void fillRange(int start, int end, [E? fillValue]) { value.fillRange(start, end, fillValue); refresh(); }
  @override E firstWhere(bool Function(E) test, {E Function()? orElse}) => value.firstWhere(test, orElse: orElse);
  @override T fold<T>(T initialValue, T Function(T, E) combine) => value.fold(initialValue, combine);
  @override Iterable<E> followedBy(Iterable<E> other) => value.followedBy(other);
  @override void forEach(void Function(E) action) => value.forEach(action);
  @override Iterable<E> getRange(int start, int end) => value.getRange(start, end);
  @override int indexOf(E element, [int start = 0]) => value.indexOf(element, start);
  @override int indexWhere(bool Function(E) test, [int start = 0]) => value.indexWhere(test, start);
  @override void insert(int index, E element) { value.insert(index, element); refresh(); }
  @override void insertAll(int index, Iterable<E> iterable) { value.insertAll(index, iterable); refresh(); }
  @override bool get isEmpty => value.isEmpty;
  @override bool get isNotEmpty => value.isNotEmpty;
  @override Iterator<E> get iterator => value.iterator;
  @override String join([String separator = '']) => value.join(separator);
  @override int lastIndexOf(E element, [int? start]) => value.lastIndexOf(element, start);
  @override int lastIndexWhere(bool Function(E) test, [int? start]) => value.lastIndexWhere(test, start);
  @override E lastWhere(bool Function(E) test, {E Function()? orElse}) => value.lastWhere(test, orElse: orElse);
  @override Iterable<T> map<T>(T Function(E) toElement) => value.map(toElement);
  @override E reduce(E Function(E, E) combine) => value.reduce(combine);
  @override List<E> get reversed => value.reversed.toList();
  @override bool remove(Object? element) { final r = value.remove(element); if (r) refresh(); return r; }
  @override E removeAt(int index) { final r = value.removeAt(index); refresh(); return r; }
  @override E removeLast() { final r = value.removeLast(); refresh(); return r; }
  @override void removeRange(int start, int end) { value.removeRange(start, end); refresh(); }
  @override void removeWhere(bool Function(E) test) { value.removeWhere(test); refresh(); }
  @override void replaceRange(int start, int end, Iterable<E> replacements) { value.replaceRange(start, end, replacements); refresh(); }
  @override void retainWhere(bool Function(E) test) { value.retainWhere(test); refresh(); }
  @override void setAll(int index, Iterable<E> iterable) { value.setAll(index, iterable); refresh(); }
  @override void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) { value.setRange(start, end, iterable, skipCount); refresh(); }
  @override void shuffle([math.Random? random]) { value.shuffle(random); refresh(); }
  @override E get single => value.single;
  @override E singleWhere(bool Function(E) test, {E Function()? orElse}) => value.singleWhere(test, orElse: orElse);
  @override Iterable<E> skip(int count) => value.skip(count);
  @override Iterable<E> skipWhile(bool Function(E) test) => value.skipWhile(test);
  @override void sort([int Function(E, E)? compare]) { value.sort(compare); refresh(); }
  @override List<E> sublist(int start, [int? end]) => value.sublist(start, end);
  @override Iterable<E> take(int count) => value.take(count);
  @override Iterable<E> takeWhile(bool Function(E) test) => value.takeWhile(test);
  @override List<E> toList({bool growable = true}) => value.toList(growable: growable);
  @override Set<E> toSet() => value.toSet();
  @override Iterable<E> where(bool Function(E) test) => value.where(test);
  @override Iterable<T> whereType<T>() => value.whereType<T>();
}

// ============================================================
// RxMap<K, V>
// ============================================================

class RxMap<K, V> extends Rx<Map<K, V>> implements Map<K, V> {
  RxMap([Map<K, V>? initial]) : super(initial ?? <K, V>{});

  @override void addAll(Map<K, V> other) { value.addAll(other); refresh(); }
  @override void addEntries(Iterable<MapEntry<K, V>> entries) { value.addEntries(entries); refresh(); }
  @override Map<RK, RV> cast<RK, RV>() => value.cast<RK, RV>();
  @override void clear() { value.clear(); refresh(); }
  @override bool containsKey(Object? key) => value.containsKey(key);
  @override bool containsValue(Object? v) => value.containsValue(v);
  @override Iterable<MapEntry<K, V>> get entries => value.entries;
  @override void forEach(void Function(K, V) action) => value.forEach(action);
  @override bool get isEmpty => value.isEmpty;
  @override bool get isNotEmpty => value.isNotEmpty;
  @override Iterable<K> get keys => value.keys;
  @override int get length => value.length;
  @override Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K, V) transform) => value.map(transform);
  @override V putIfAbsent(K key, V Function() ifAbsent) { final r = value.putIfAbsent(key, ifAbsent); refresh(); return r; }
  @override V? remove(Object? key) { final r = value.remove(key); if (r != null) refresh(); return r; }
  @override void removeWhere(bool Function(K, V) predicate) { value.removeWhere(predicate); refresh(); }
  @override V update(K key, V Function(V) update, {V Function()? ifAbsent}) { final r = value.update(key, update, ifAbsent: ifAbsent); refresh(); return r; }
  @override void updateAll(V Function(K, V) update) { value.updateAll(update); refresh(); }
  @override Iterable<V> get values => value.values;
  @override V operator [](Object? key) => value[key] as V;
  @override void operator []=(K key, V v) { value[key] = v; refresh(); }
}

// ============================================================
// RxSet<E>
// ============================================================

class RxSet<E> extends Rx<Set<E>> implements Set<E> {
  RxSet([Set<E>? initial]) : super(initial ?? <E>{});

  @override bool add(E element) { final r = value.add(element); if (r) refresh(); return r; }
  @override void addAll(Iterable<E> elements) { value.addAll(elements); refresh(); }
  @override bool contains(Object? element) => value.contains(element);
  @override bool containsAll(Iterable<Object?> other) => value.containsAll(other);
  @override Set<E> difference(Set<Object?> other) => value.difference(other);
  @override Set<E> intersection(Set<Object?> other) => value.intersection(other);
  @override E? lookup(Object? object) => value.lookup(object);
  @override bool remove(Object? element) { final r = value.remove(element); if (r) refresh(); return r; }
  @override void removeAll(Iterable<Object?> elements) { value.removeAll(elements); refresh(); }
  @override void removeWhere(bool Function(E) test) { value.removeWhere(test); refresh(); }
  @override void retainAll(Iterable<Object?> elements) { value.retainAll(elements); refresh(); }
  @override void retainWhere(bool Function(E) test) { value.retainWhere(test); refresh(); }
  @override Set<E> union(Set<E> other) => value.union(other);
  @override Iterator<E> get iterator => value.iterator;
  @override int get length => value.length;
  @override bool get isEmpty => value.isEmpty;
  @override bool get isNotEmpty => value.isNotEmpty;
  @override E get first => value.first;
  @override E get last => value.last;
  @override E get single => value.single;
  @override E elementAt(int index) => value.elementAt(index);
  @override void clear() { value.clear(); refresh(); }
  @override void forEach(void Function(E) action) => value.forEach(action);
  @override Set<R> cast<R>() => value.cast<R>();
  @override bool any(bool Function(E) test) => value.any(test);
  @override bool every(bool Function(E) test) => value.every(test);
  @override Set<E> toSet() => value.toSet();
  @override List<E> toList({bool growable = true}) => value.toList(growable: growable);
  @override Iterable<T> map<T>(T Function(E) toElement) => value.map(toElement);
  @override E reduce(E Function(E, E) combine) => value.reduce(combine);
  @override Iterable<T> expand<T>(Iterable<T> Function(E) toElements) => value.expand(toElements);
  @override E firstWhere(bool Function(E) test, {E Function()? orElse}) => value.firstWhere(test, orElse: orElse);
  @override T fold<T>(T initialValue, T Function(T, E) combine) => value.fold(initialValue, combine);
  @override Iterable<E> followedBy(Iterable<E> other) => value.followedBy(other);
  @override Iterable<E> skip(int count) => value.skip(count);
  @override Iterable<E> skipWhile(bool Function(E) test) => value.skipWhile(test);
  @override Iterable<E> take(int count) => value.take(count);
  @override Iterable<E> takeWhile(bool Function(E) test) => value.takeWhile(test);
  @override Iterable<E> where(bool Function(E) test) => value.where(test);
  @override Iterable<T> whereType<T>() => value.whereType<T>();
  @override String join([String separator = '']) => value.join(separator);
  @override E lastWhere(bool Function(E) test, {E Function()? orElse}) => value.lastWhere(test, orElse: orElse);
  @override E singleWhere(bool Function(E) test, {E Function()? orElse}) => value.singleWhere(test, orElse: orElse);
}

// ============================================================
// .obs extension
// ============================================================

extension ReactiveExt<T> on T {
  Rx<T> get obs {
    if (this is Rx) return this as Rx<T>;
    if (T == int) return RxInt(this as int) as Rx<T>;
    if (T == double) return RxDouble(this as double) as Rx<T>;
    if (T == String) return RxString(this as String) as Rx<T>;
    if (T == bool) return RxBool(this as bool) as Rx<T>;
    return Rx<T>(this);
  }
}
