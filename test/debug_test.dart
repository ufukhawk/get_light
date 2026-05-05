import 'package:flutter_test/flutter_test.dart';
import 'package:get_light/getx_lite.dart';

void main() {
  test('debug', () {
    final rx = 0.obs;
    print('rx type: ${rx.runtimeType}');
    print('rx.value = ${rx.value}');

    rx.listen((value) {
      print('Listener notified with: $value');
    });

    rx.value = 1;
    print('rx.value after set: ${rx.value}');
  });
}
