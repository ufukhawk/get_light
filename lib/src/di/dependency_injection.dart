import 'package:flutter/widgets.dart';
import 'lifecycle.dart';

// ============================================================
// InstanceInfo
// ============================================================

class InstanceInfo {
  final bool? isPermanent;
  final bool? isSingleton;
  final bool? isRegistered;
  final bool? isPrepared;
  final bool? isInit;

  InstanceInfo({
    this.isPermanent,
    this.isSingleton,
    this.isRegistered,
    this.isPrepared,
    this.isInit,
  });
}

// ============================================================
// Typedefs
// ============================================================

typedef InstanceBuilderCallback<S> = S Function();
typedef InstanceCreateBuilderCallback<S> = S Function(BuildContext _);

// ============================================================
// _InstanceBuilderFactory - Internal instance holder
// ============================================================

class _InstanceBuilderFactory<S> {
  bool? isSingleton;
  bool fenix;
  S? dependency;
  InstanceBuilderCallback<S> builderFunc;
  bool permanent = false;
  bool isInit = false;
  _InstanceBuilderFactory? lateRemove;
  bool isDirty = false;
  String? tag;

  _InstanceBuilderFactory({
    required this.isSingleton,
    required this.builderFunc,
    required this.permanent,
    required this.isInit,
    required this.fenix,
    required this.tag,
    required this.lateRemove,
  });

  S getDependency() {
    if (isSingleton!) {
      if (dependency == null) {
        dependency = builderFunc();
      }
      return dependency!;
    } else {
      return builderFunc();
    }
  }
}

// ============================================================
// GetInstance - The DI container
// ============================================================

class GetInstance {
  /// Holds references to every registered Instance when using Get.put()
  static final Map<String, _InstanceBuilderFactory> _singl = {};

  /// Insert a dependency synchronously.
  S put<S>(
    S dependency, {
    String? tag,
    bool permanent = false,
  }) {
    _insert<S>(
      isSingleton: true,
      name: tag,
      permanent: permanent,
      builder: (() => dependency),
    );
    return find<S>(tag: tag);
  }

  /// Creates a new Instance lazily from the [builder] callback.
  ///
  /// The first time you call [find], the builder creates the Instance.
  /// If [fenix] is true, the factory is kept after disposal.
  void lazyPut<S>(
    InstanceBuilderCallback<S> builder, {
    String? tag,
    bool? fenix,
    bool permanent = false,
  }) {
    _insert<S>(
      isSingleton: true,
      name: tag,
      permanent: permanent,
      builder: builder,
      fenix: fenix ?? false,
    );
  }

  /// Creates a new Instance from builder every time [find] is called.
  void create<S>(
    InstanceBuilderCallback<S> builder, {
    String? tag,
    bool permanent = true,
  }) {
    _insert<S>(
      isSingleton: false,
      name: tag,
      builder: builder,
      permanent: permanent,
    );
  }

  void _insert<S>({
    bool? isSingleton,
    String? name,
    bool permanent = false,
    required InstanceBuilderCallback<S> builder,
    bool fenix = false,
  }) {
    final key = _getKey(S, name);

    if (_singl.containsKey(key)) {
      final newDep = _singl[key];
      if (newDep == null || !newDep.isDirty) {
        return;
      }
    }

    _singl[key] = _InstanceBuilderFactory<S>(
      isSingleton: isSingleton,
      builderFunc: builder,
      permanent: permanent,
      isInit: false,
      fenix: fenix,
      tag: name,
      lateRemove: _singl[key],
    );
  }

  S? _initDependencies<S>({String? name}) {
    final key = _getKey(S, name);
    final isInit = _singl[key]!.isInit;
    S? i;
    if (!isInit) {
      final isSingleton = _singl[key]?.isSingleton ?? false;
      if (isSingleton) {
        _singl[key]!.isInit = true;
      }
      i = _startController<S>(tag: name);
    }
    return i;
  }

  InstanceInfo getInstanceInfo<S>({String? tag}) {
    final build = _getDependency<S>(tag: tag);
    return InstanceInfo(
      isPermanent: build?.permanent,
      isSingleton: build?.isSingleton,
      isRegistered: isRegistered<S>(tag: tag),
      isPrepared: !(build?.isInit ?? true),
      isInit: build?.isInit,
    );
  }

  _InstanceBuilderFactory? _getDependency<S>({String? tag, String? key}) {
    final newKey = key ?? _getKey(S, tag);
    if (!_singl.containsKey(newKey)) {
      return null;
    }
    return _singl[newKey];
  }

  S _startController<S>({String? tag}) {
    final key = _getKey(S, tag);
    final i = _singl[key]!.getDependency() as S;
    if (i is GetLifeCycleMixin) {
      i.onStart();
    }
    return i;
  }

  /// Finds the registered Instance of type [S] (or [tag]).
  S find<S>({String? tag}) {
    final key = _getKey(S, tag);
    if (isRegistered<S>(tag: tag)) {
      final dep = _singl[key];
      if (dep == null) {
        throw '"$S" not found. You need to call "Get.put($S())" or "Get.lazyPut(()=>$S())"';
      }
      final i = _initDependencies<S>(name: tag);
      return i ?? dep.getDependency() as S;
    } else {
      throw '"$S" not found. You need to call "Get.put($S())" or "Get.lazyPut(()=>$S())"';
    }
  }

  /// Like [find] but returns null if not found.
  S? findOrNull<S>({String? tag}) {
    if (isRegistered<S>(tag: tag)) {
      return find<S>(tag: tag);
    }
    return null;
  }

  /// Replaces an existing Instance.
  void replace<P>(P child, {String? tag}) {
    final info = getInstanceInfo<P>(tag: tag);
    final permanent = (info.isPermanent ?? false);
    delete<P>(tag: tag, force: permanent);
    put(child, tag: tag, permanent: permanent);
  }

  /// Deletes the registered Instance of type [S] (or [tag]).
  bool delete<S>({String? tag, String? key, bool force = false}) {
    final newKey = key ?? _getKey(S, tag);
    if (!_singl.containsKey(newKey)) {
      return false;
    }

    final dep = _singl[newKey];
    if (dep == null) return false;

    final _InstanceBuilderFactory builder;
    if (dep.isDirty) {
      builder = dep.lateRemove ?? dep;
    } else {
      builder = dep;
    }

    if (builder.permanent && !force) {
      return false;
    }

    final i = builder.dependency;
    if (i is GetxServiceMixin && !force) {
      return false;
    }

    if (i is GetLifeCycleMixin) {
      i.onDelete();
    }

    if (builder.fenix) {
      builder.dependency = null;
      builder.isInit = false;
      return true;
    } else {
      if (dep.lateRemove != null) {
        dep.lateRemove = null;
        return false;
      } else {
        _singl.remove(newKey);
        return true;
      }
    }
  }

  /// Deletes all registered Instances.
  void deleteAll({bool force = false}) {
    final keys = _singl.keys.toList();
    for (final key in keys) {
      delete(key: key, force: force);
    }
  }

  /// Reloads a specific Instance.
  void reload<S>({String? tag, bool force = false}) {
    final newKey = _getKey(S, tag);
    final builder = _getDependency<S>(tag: tag, key: newKey);
    if (builder == null) return;
    if (builder.permanent && !force) return;
    final i = builder.dependency;
    if (i is GetxServiceMixin && !force) return;
    if (i is GetLifeCycleMixin) {
      i.onDelete();
    }
    builder.dependency = null;
    builder.isInit = false;
  }

  /// Reloads all registered Instances.
  void reloadAll({bool force = false}) {
    _singl.forEach((key, value) {
      if (value.permanent && !force) return;
      value.dependency = null;
      value.isInit = false;
    });
  }

  /// Checks if an Instance of type [S] is registered.
  bool isRegistered<S>({String? tag}) =>
      _singl.containsKey(_getKey(S, tag));

  /// Checks if a lazy factory for [S] exists but hasn't been initialized.
  bool isPrepared<S>({String? tag}) {
    final newKey = _getKey(S, tag);
    final builder = _getDependency<S>(tag: tag, key: newKey);
    if (builder == null) return false;
    return !builder.isInit;
  }

  /// Generates the key based on type and optional tag.
  String _getKey(Type type, String? name) {
    return name == null ? type.toString() : '$type$name';
  }
}
