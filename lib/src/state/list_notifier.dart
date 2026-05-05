import 'dart:ui';

/// Lightweight listener-based notifier for GetxController.
///
/// This replaces Flutter's ChangeNotifier with a more performant
/// linked-list based listener system (no Streams).
class ListNotifier {
  final Set<VoidCallback> _listeners = {};
  final Map<Object, List<VoidCallback>> _updatesById = {};

  bool _isDisposed = false;

  /// Whether this notifier has been disposed.
  bool get isDisposed => _isDisposed;

  /// Report that a value was read (for reactivity tracking).
  void reportRead() {}

  /// Add a global listener that fires on any [refresh] call.
  VoidCallback addListener(VoidCallback listener) {
    _listeners.add(listener);
    return () => _listeners.remove(listener);
  }

  /// Remove a global listener.
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Add a listener for a specific [id].
  VoidCallback addListenerId(Object id, VoidCallback listener) {
    _updatesById.putIfAbsent(id, () => <VoidCallback>[]);
    _updatesById[id]!.add(listener);
    return () => _updatesById[id]?.remove(listener);
  }

  /// Notify all listeners (or only those for specific [ids]).
  void refresh() {
    _notify();
  }

  void _notify({List<Object>? ids}) {
    if (_isDisposed) return;

    if (ids == null) {
      for (final listener in _listeners) {
        listener();
      }
      for (final entry in _updatesById.entries) {
        for (final listener in entry.value) {
          listener();
        }
      }
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

  /// Dispose all listeners.
  void dispose() {
    _isDisposed = true;
    _listeners.clear();
    _updatesById.clear();
  }
}

/// A single-value version of ListNotifier.
class ListNotifierSingle<T> extends ListNotifier {}
