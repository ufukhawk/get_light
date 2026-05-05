import 'package:getx_lite/src/di/dependency_injection.dart';

void main() {
  final di = GetContainer();
  print('Before: isRegistered=${di.isRegistered<String>()}');
  final result = di.put<String>('hello');
  print('After put: result=$result');
  print('After: isRegistered=${di.isRegistered<String>()}');
  print('Find: ${di.find<String>()}');
}
