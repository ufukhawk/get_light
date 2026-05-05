import 'package:flutter/widgets.dart';
import '../rx/rx_interface.dart';
import 'rx_notifier.dart';

// ============================================================
// ObxStatelessWidget - Base class for reactive widgets
// ============================================================

/// Base class for all GetX reactive widgets (Obx, ObxValue).
/// Uses a custom Element that tracks Rx reads during build.
abstract class ObxStatelessWidget extends StatelessWidget {
  const ObxStatelessWidget({super.key});

  @override
  StatelessElement createElement() => _ObxStatelessElement(this);
}

class _ObxStatelessElement extends StatelessElement {
  _ObxStatelessElement(super.widget);

  bool _dirty = false;
  bool _building = false;
  final Set<RxInterface> _subscriptions = {};
  final List<void Function()> _unsubscribers = [];

  @override
  Widget build() {
    if (_building) return super.build();

    _building = true;
    // Set this element as the current Rx read context.
    // When an Rx value is read during build, _onRxRead is called.
    pushRxContext(_onRxRead);
    final result = super.build();
    popRxContext();
    _building = false;
    _dirty = false;
    return result;
  }

  void _onRxRead(RxInterface rx) {
    if (_subscriptions.add(rx)) {
      // Subscribe to the Rx variable's changes
      final sub = rx.listen((_) {
        if (!_dirty && !_building) {
          _dirty = true;
          markNeedsBuild();
        }
      });
      _unsubscribers.add(() => sub.cancel());
    }
  }

  @override
  void unmount() {
    for (final unsub in _unsubscribers) {
      unsub();
    }
    _unsubscribers.clear();
    _subscriptions.clear();
    super.unmount();
  }
}
