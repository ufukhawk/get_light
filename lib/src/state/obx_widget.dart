import 'package:flutter/widgets.dart';
import '../rx/rx_interface.dart';
import 'simple_builder.dart';

// ============================================================
// ObxWidget - Base class for reactive widgets
// ============================================================

typedef WidgetCallback = Widget Function();

/// Base class for all GetX reactive widgets.
abstract class ObxWidget extends ObxStatelessWidget {
  const ObxWidget({super.key});
}

// ============================================================
// Obx - The simplest reactive widget
// ============================================================

/// The simplest reactive widget in GetX.
///
/// Pass your Rx variable in the root scope of the callback to have it
/// automatically registered for changes.
///
/// ```dart
/// final name = "GetX".obs;
/// Obx(() => Text(name.value));
/// ```
class Obx extends ObxWidget {
  final WidgetCallback builder;

  const Obx(this.builder, {super.key});

  @override
  Widget build(BuildContext context) {
    return builder();
  }
}

// ============================================================
// ObxValue - Reactive widget with local state
// ============================================================

/// Similar to Obx, but manages a local Rx state.
///
/// ```dart
/// ObxValue<RxBool>(
///   (data) => Switch(
///     value: data.value,
///     onChanged: (flag) => data.value = flag,
///   ),
///   false.obs,
/// );
/// ```
class ObxValue<T extends RxInterface> extends ObxWidget {
  final Widget Function(T) builder;
  final T data;

  const ObxValue(this.builder, this.data, {super.key});

  @override
  Widget build(BuildContext context) => builder(data);
}
