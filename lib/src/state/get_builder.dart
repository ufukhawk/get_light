import 'package:flutter/widgets.dart';
import '../get_instance.dart';
import 'get_controllers.dart';

// ============================================================
// GetBuilder - Simple state management widget
// ============================================================

typedef GetControllerBuilder<T> = Widget Function(T controller);

/// A widget that rebuilds when the controller calls [update].
///
/// ```dart
/// GetBuilder<MyController>(
///   init: MyController(),
///   builder: (controller) => Text('${controller.count}'),
/// );
/// ```
class GetBuilder<T extends GetxController> extends StatefulWidget {
  final GetControllerBuilder<T> builder;
  final bool global;
  final Object? id;
  final String? tag;
  final bool autoRemove;
  final bool assignId;
  final T? init;
  final void Function(GetBuilderState<T> state)? initState;
  final void Function(GetBuilderState<T> state)? dispose;
  final void Function(GetBuilderState<T> state)? didChangeDependencies;
  final void Function(GetBuilder<T> oldWidget, GetBuilderState<T> state)?
      didUpdateWidget;

  const GetBuilder({
    super.key,
    required this.builder,
    this.global = true,
    this.id,
    this.tag,
    this.autoRemove = true,
    this.assignId = false,
    this.init,
    this.initState,
    this.dispose,
    this.didChangeDependencies,
    this.didUpdateWidget,
  });

  @override
  State<GetBuilder<T>> createState() => GetBuilderState<T>();
}

class GetBuilderState<T extends GetxController> extends State<GetBuilder<T>> {
  T? _controller;
  VoidCallback? _removeListener;
  bool _isCreator = false;

  @override
  void initState() {
    super.initState();
    widget.initState?.call(this);
    _initController();
  }

  void _initController() {
    final isRegistered = Get.isRegistered<T>(tag: widget.tag);

    if (widget.global) {
      if (isRegistered) {
        _isCreator = false;
        _controller = Get.find<T>(tag: widget.tag);
      } else {
        _isCreator = true;
        if (widget.init != null) {
          _controller = widget.init;
          Get.put(_controller!, tag: widget.tag);
        } else {
          _controller = Get.find<T>(tag: widget.tag);
        }
      }
    } else {
      _controller = widget.init ?? Get.find<T>(tag: widget.tag);
      _isCreator = true;
    }

    _subscribeToController();
  }

  void _subscribeToController() {
    _removeListener?.call();
    if (_controller != null) {
      if (widget.id == null) {
        _removeListener = _controller!.addListener(_update);
      } else {
        _removeListener =
            _controller!.addListenerId(widget.id!, _update);
      }
    }
  }

  void _update() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.didChangeDependencies?.call(this);
  }

  @override
  void didUpdateWidget(GetBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id || oldWidget.tag != widget.tag) {
      _subscribeToController();
    }
    widget.didUpdateWidget?.call(oldWidget, this);
  }

  @override
  void dispose() {
    widget.dispose?.call(this);
    _removeListener?.call();

    if (_isCreator || widget.assignId) {
      if (widget.autoRemove && Get.isRegistered<T>(tag: widget.tag)) {
        Get.delete<T>(tag: widget.tag);
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_controller as T);
  }
}

// ============================================================
// Context extensions for quick controller access
// ============================================================

/// Extension on BuildContext to easily find controllers.
extension GetXContextExt on BuildContext {
  /// Finds a registered controller of type [T].
  T find<T>({String? tag}) => Get.find<T>(tag: tag);
}
