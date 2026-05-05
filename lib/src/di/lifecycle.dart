import 'package:flutter/scheduler.dart';

/// Lifecycle management for controllers.
mixin GetLifeCycleMixin {
  /// Called immediately after the widget is allocated in memory.
  void onInit() {
    SchedulerBinding.instance.addPostFrameCallback((_) => onReady());
  }

  /// Called 1 frame after onInit().
  void onReady() {}

  /// Called before [onDelete]. Use to dispose resources.
  void onClose() {}

  bool _initialized = false;

  /// Whether the controller has been initialized.
  bool get initialized => _initialized;

  /// Called at the exact moment the widget is allocated in memory.
  void onStart() {
    if (_initialized) return;
    onInit();
    _initialized = true;
  }

  bool _isClosed = false;

  /// Whether the controller has been closed.
  bool get isClosed => _isClosed;

  /// Called when the controller is removed from memory.
  void onDelete() {
    if (_isClosed) return;
    _isClosed = true;
    onClose();
  }
}

/// Marks a service that should not be auto-disposed.
mixin GetxServiceMixin {}

/// A service that persists in memory (never auto-disposed).
abstract class GetxService with GetLifeCycleMixin, GetxServiceMixin {}
