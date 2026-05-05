import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_light/get_light.dart';

void main() {
  test('di debug', () {
    debugPrint('Before put: isRegistered=${Get.isRegistered<String>()}');
    Get.put('hello');
    debugPrint('After put: isRegistered=${Get.isRegistered<String>()}');
    expect(Get.isRegistered<String>(), isTrue);
    debugPrint('After put: value=${Get.find<String>()}');
  });
}
