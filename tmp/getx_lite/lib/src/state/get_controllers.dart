import 'package:flutter/widgets.dart';
import '../di/dependency_injection.dart';
import '../di/lifecycle.dart';
import 'list_notifier.dart';
import 'rx_notifier.dart';

// ============================================================
// GetxController - Base controller with state management
// ============================================================

/// A base controller class that provides state management functionality.
///
/// Extend this class to create a controller with lifecycle methods
/// ([onInit], [onReady], [onClose]) and the ability to update UI.
///
/// ```dart
/// class CounterController extends GetxController {
///   var count = 0;
///
///   void increment() {
///     count++;
///     update(); // Triggers UI update for GetBuilder widgets
///   }
/// }
/// ```
abstract class GetxController extends ListNotifier with GetLifeCycleMixin {
  /// Notifies listeners to update the UI.
  ///
  /// - [ids]: Optional list of widget IDs to update. If null, updates all.
  /// - [condition]: If false, the update is skipped.
  void update([List<Object>? ids, bool condition = true]) {
    if (!condition) return;
    if (ids == null) {
      refresh();
    } else {
      for (final id in ids) {
        final listeners = _updatesById[id];
        if (listeners != null) {
          for (final listener in listeners) {
            listener();
          }
        }
      }
    }
  }

  // Internal access to id-based listeners
  final Map<Object, List<VoidCallback>> _updatesById = {};
}

/// A mixin version of GetxController for use when you already extend another class.
mixin GetxControllerMixin on ListNotifier, GetLifeCycleMixin {
  final Map<Object, List<VoidCallback>> _updatesById = {};

  void update([List<Object>? ids, bool condition = true]) {
    if (!condition) return;
    if (ids == null) {
      refresh();
    } else {
      for (final id in ids) {
        final listeners = _updatesById[id];
        if (listeners != null) {
          for (final listener in listeners) {
            listener();
          }
        }
      }
    }
  }
}

// ============================================================
// GetLifeCycleMixin with SchedulerBinding
// ============================================================

// Re-export lifecycle from di so it's accessible from state layer
export '../di/lifecycle.dart';
