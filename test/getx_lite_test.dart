import 'package:flutter_test/flutter_test.dart';
import 'package:get_light/get_light.dart';

// ============================================================
// Reactive Types Tests
// ============================================================

void main() {
  group('Rx types', () {
    test('.obs creates Rx values', () {
      final rxInt = 0.obs;
      expect(rxInt.value, 0);
      expect(rxInt, isA<Rx<int>>());

      final rxDouble = 3.14.obs;
      expect(rxDouble.value, 3.14);

      final rxBool = true.obs;
      expect(rxBool.value, true);

      final rxString = 'hello'.obs;
      expect(rxString.value, 'hello');
    });

    test('specialized types work', () {
      final rxBool = RxBool(false);
      expect(rxBool.value, false);
      rxBool.toggle();
      expect(rxBool.value, true);

      final rxInt = RxInt(5);
      rxInt + 3;
      expect(rxInt.value, 8);
    });

    test('Rx value changes notify listeners', () {
      final rx = 0.obs;
      var notified = false;
      rx.listen((value) {
        notified = true;
      });
      rx.value = 1;
      expect(notified, isTrue);
      expect(rx.value, 1);
    });

    test('RxList operations', () {
      final list = RxList<int>([1, 2, 3]);
      expect(list.length, 3);
      list.add(4);
      expect(list.length, 4);
      expect(list[3], 4);
      list.remove(1);
      expect(list.length, 3);
      expect(list.contains(1), isFalse);
    });

    test('RxMap operations', () {
      final map = RxMap<String, int>({'a': 1, 'b': 2});
      expect(map['a'], 1);
      map['c'] = 3;
      expect(map.length, 3);
    });

    test('RxSet operations', () {
      final set = RxSet<int>({1, 2, 3});
      expect(set.length, 3);
      set.add(4);
      expect(set.length, 4);
      set.remove(2);
      expect(set.length, 3);
    });
  });

  // ============================================================
  // DI Tests
  // ============================================================

  group('Dependency Injection', () {
    setUp(() {
      Get.deleteAll(force: true);
    });

    test('put and find', () {
      Get.put('test');
      expect(Get.find<String>(), 'test');
    });

    test('lazyPut defers creation', () {
      Get.lazyPut<String>(() => 'lazy');
      expect(Get.isRegistered<String>(), isTrue);
      expect(Get.isPrepared<String>(), isTrue);
      expect(Get.find<String>(), 'lazy');
      expect(Get.isPrepared<String>(), isFalse);
    });

    test('isRegistered', () {
      expect(Get.isRegistered<String>(), isFalse);
      Get.put('hello');
      expect(Get.isRegistered<String>(), isTrue);
    });

    test('delete removes instance', () {
      Get.put('temp');
      expect(Get.isRegistered<String>(), isTrue);
      Get.delete<String>();
      expect(Get.isRegistered<String>(), isFalse);
    });

    test('deleteAll clears all', () {
      Get.put('a');
      Get.put(42);
      expect(Get.isRegistered<String>(), isTrue);
      expect(Get.isRegistered<int>(), isTrue);
      Get.deleteAll(force: true);
      expect(Get.isRegistered<String>(), isFalse);
      expect(Get.isRegistered<int>(), isFalse);
    });

    test('findOrNull returns null for unregistered', () {
      expect(Get.findOrNull<String>(), isNull);
      Get.put('exists');
      expect(Get.findOrNull<String>(), 'exists');
    });

    test('replace swaps instance', () {
      Get.put('old');
      Get.replace<String>('new');
      expect(Get.find<String>(), 'new');
    });

    test('create returns new instance each find', () {
      var counter = 0;
      Get.create<int>(() => ++counter);
      final a = Get.find<int>();
      final b = Get.find<int>();
      expect(a, isNot(b));
    });
  });
}
