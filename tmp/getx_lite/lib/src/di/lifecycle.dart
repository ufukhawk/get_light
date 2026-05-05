import 'package:flutter/foundation.dart';

/// Lifecycle management for controllers.
///
/// Extend [GetxController] to get lifecycle methods:
/// - [onInit]: Called when the controller is created.
/// - [onReady]: Called one frame after [onInit].
/// - [onClose]: Called before the controller is disposed.
mixin GetLifeCycleMixin {
  /// Called immediately after the widget is allocated in memory.
  @protected
  @mustCallSuper
  void onInit() {
    // Schedule onReady for next frame
    WidgetsBinding.instance.addPostFrameCallback((_) => onReady());
  }

  /// Called 1 frame after onInit(). Perfect for navigation or async requests.
  void onReady() {}

  /// Called before [onDelete]. Use to dispose resources (TextEditingControllers,
  /// AnimationControllers, etc.).
  void onClose() {}

  bool _initialized = false;

  /// Whether the controller has been initialized.
  bool get initialized => _initialized;

  /// Called at the exact moment the widget is allocated in memory.
  @protected
  @mustCallSuper
  @nonVirtual
  void onStart() {
    if (_initialized) return;
    onInit();
    _initialized = true;
  }

  bool _isClosed = false;

  /// Whether the controller has been closed.
  bool get isClosed => _isClosed;

  /// Called when the controller is removed from memory.
  @mustCallSuper
  @nonVirtual
  void onDelete() {
    if (_isClosed) return;
    _isClosed = true;
    onClose();
  }
}

/// Marks a service that should not be auto-disposed.
mixin GetxServiceMixin {}

/// A service that persists in memory (never auto-disposed).
/// Ideal for auth, API services, etc.
abstract class GetxService with GetLifeCycleMixin, GetxServiceMixin {}
