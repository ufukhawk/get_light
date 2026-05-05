import 'core/get_interface.dart';
import 'di/dependency_injection.dart';

// Re-export from dependency_injection for convenience
export 'di/dependency_injection.dart' show InstanceInfo, InstanceBuilderCallback, InstanceCreateBuilderCallback;

/// The global Get instance providing dependency injection.
///
/// Usage:
/// ```dart
/// Get.put(MyController());
/// final controller = Get.find<MyController>();
/// ```
class GetImpl extends GetInterface {
  final _di = GetInstance();

  /// Dependency injection methods.

  S put<S>(S dependency, {String? tag, bool permanent = false}) =>
      _di.put(dependency, tag: tag, permanent: permanent);

  void lazyPut<S>(InstanceBuilderCallback<S> builder, {String? tag, bool? fenix, bool permanent = false}) =>
      _di.lazyPut(builder, tag: tag, fenix: fenix, permanent: permanent);

  void create<S>(InstanceBuilderCallback<S> builder, {String? tag, bool permanent = true}) =>
      _di.create(builder, tag: tag, permanent: permanent);

  S find<S>({String? tag}) => _di.find(tag: tag);
  S? findOrNull<S>({String? tag}) => _di.findOrNull(tag: tag);

  bool isRegistered<S>({String? tag}) => _di.isRegistered(tag: tag);
  bool isPrepared<S>({String? tag}) => _di.isPrepared(tag: tag);

  bool delete<S>({String? tag, String? key, bool force = false}) =>
      _di.delete(tag: tag, key: key, force: force);

  void deleteAll({bool force = false}) => _di.deleteAll(force: force);
  void reload<S>({String? tag, bool force = false}) => _di.reload(tag: tag, force: force);
  void reloadAll({bool force = false}) => _di.reloadAll(force: force);
  void replace<P>(P child, {String? tag}) => _di.replace(child, tag: tag);

  InstanceInfo getInstanceInfo<S>({String? tag}) => _di.getInstanceInfo(tag: tag);

  /// Internal log method.
  void logMsg(String msg, {bool isError = false}) {
    if (isLogEnable) {
      log.call(msg, isError: isError);
    }
  }
}

// ignore: non_constant_identifier_names
final Get = GetImpl();
