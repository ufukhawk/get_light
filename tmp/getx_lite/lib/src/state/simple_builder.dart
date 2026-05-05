import 'dart:async';
import 'package:flutter/widgets.dart';
import '../rx/rx_interface.dart';
import 'list_notifier.dart';

// ============================================================
// Observer / ObxStatelessWidget
// ============================================================

/// Internal widget that listens to Rx changes and rebuilds.
class Observer extends StatefulWidget {
  final Widget Function(BuildContext) builder;

  const Observer({super.key, required this.builder});

  @override
  State<Observer> createState() => _ObserverState();
}

class _ObserverState extends State<Observer> with NotifierTracker {
  @override
  Widget build(BuildContext context) {
    _notify = () {
      if (mounted) setState(() {});
    };
    return widget.builder(context);
  }
}

/// Base class for reactive stateless widgets that track Rx dependencies.
abstract class ObxStatelessWidget extends StatelessWidget {
  const ObxStatelessWidget({super.key});

  @override
  StatelessElement createElement() => _ObxStatelessElement(this);
}

class _ObxStatelessElement extends StatelessElement with NotifierTracker {
  _ObxStatelessElement(super.widget);

  @override
  Widget build() {
    _notify = () {
      if (mounted) markNeedsBuild();
    };
    return super.build();
  }
}

// ============================================================
// NotifierTracker - Tracks Rx reads to rebuild on changes
// ============================================================

mixin NotifierTracker {
  VoidCallback? _notify;
  List<StreamSubscription>? _subscriptions;
  Set<RxInterface>? _trackedNotifiers;

  /// Call this on each Rx value read to track it.
  ///
  /// When the Rx value changes, the widget rebuilds automatically.
  T listenTo<T>(T rx) {
    if (rx is RxInterface) {
      _trackedNotifiers ??= <RxInterface>{};
      if (!_trackedNotifiers!.contains(rx)) {
        _trackedNotifiers!.add(rx);
        _subscriptions ??= [];
        _subscriptions!.add(rx.listen((_) {
          _notify?.call();
        }));
      }
      return rx.value;
    }
    return rx;
  }

  void _dispose() {
    for (final sub in _subscriptions ?? []) {
      sub.cancel();
    }
    _subscriptions = null;
    _trackedNotifiers = null;
  }
}
