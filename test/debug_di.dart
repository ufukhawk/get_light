import 'package:flutter_test/flutter_test.dart';
import 'package:get_light/getx_lite.dart';

void main() {
  test('di debug', () {
    print('Before put: isRegistered=${Get.isRegistered<String>()}');
    Get.put('hello');
    print('After put: isRegistered=${Get.isRegistered<String>()}');
    expect(Get.isRegistered<String>(), isTrue);
    print('After put: value=${Get.find<String>()}');
  });
}
