import 'package:flutter/widgets.dart';
import '../get_instance.dart';
import 'get_controllers.dart';

/// A StatelessWidget that has a controller of type [T] accessible via
/// the [controller] getter.
///
/// ```dart
/// class HomePage extends GetView<HomeController> {
///   @override
///   Widget build(BuildContext context) {
///     return Text(controller.title);
///   }
/// }
/// ```
abstract class GetView<T extends GetxController> extends StatelessWidget {
  const GetView({super.key});

  /// The controller instance. Uses [tag] if provided.
  T get controller => Get.find<T>(tag: tag);

  /// Optional tag to differentiate controllers of the same type.
  String? get tag => null;
}

/// A StatefulWidget version of [GetView].
abstract class GetWidget<T extends GetxController> extends StatefulWidget {
  const GetWidget({super.key});

  T get controller => Get.find<T>(tag: tag);

  String? get tag => null;
}
