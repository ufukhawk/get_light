## 1.0.2

- Fixed package metadata for pub.dev verification.
- Shortened `pubspec.yaml` description to meet pub.dev length guidelines.
- Removed duplicate nested package copy from `tmp/getx_lite` and added `tmp/` to `.gitignore`.
- Confirmed repository URL and package name consistency.

## 1.0.0

Initial release.

### State management
- `GetxController` with `update()` / `update([ids])` for targeted rebuilds
- `GetBuilder<T>` widget with auto-registration and lifecycle management
- `GetView<T>` convenience base widget

### Reactive state
- `Rx<T>`, `RxInt`, `RxDouble`, `RxBool`, `RxString` reactive value types
- `RxList<E>`, `RxMap<K,V>`, `RxSet<E>` reactive collection types
- `.obs` extension on any type
- `Obx` and `ObxValue` widgets for automatic reactive rebuilds

### Dependency injection
- `Get.put` — eager singleton registration
- `Get.lazyPut` — deferred singleton (created on first `find`)
- `Get.create` — factory registration (new instance per `find`)
- `Get.find` / `Get.findOrNull`
- `Get.delete` / `Get.deleteAll`
- `Get.replace` — swap a registered instance
- `Get.reload` / `Get.reloadAll`
- `Get.isRegistered` / `Get.isPrepared`
- `tag` support for multiple instances of the same type
- `GetxService` — permanent service mixin (survives `deleteAll`)

### Workers
- `ever` — fires on every value change
- `once` — fires once when the condition is met
- `interval` — rate-limits to at most once per duration
- `debounce` — fires after a period of silence
- `Workers` utility class for bulk disposal

### Lifecycle
- `GetLifeCycleMixin` with `onInit`, `onReady`, `onClose`, `onDelete`
- `onReady` is called one frame after `onInit` via `SchedulerBinding.addPostFrameCallback`
