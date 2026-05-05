# get_light

[![pub.dev](https://img.shields.io/pub/v/get_light.svg)](https://pub.dev/packages/get_light)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Lightweight Flutter state management and dependency injection, extracted from [GetX](https://pub.dev/packages/get).

Keeps only the essential pieces — reactive state, simple state, and DI — with no routing or utility overhead.

---

## Features

| Feature | API |
|---|---|
| Reactive variables | `.obs`, `Rx<T>`, `RxInt`, `RxBool`, `RxList`, … |
| Reactive widget | `Obx(() => ...)` |
| Simple state | `GetxController` + `update()` + `GetBuilder` |
| Dependency injection | `Get.put`, `Get.lazyPut`, `Get.find`, `Get.delete` |
| Reactive workers | `ever`, `once`, `debounce`, `interval` |
| Controller lifecycle | `onInit`, `onReady`, `onClose` |
| Permanent services | `GetxService` |

---

## Installation

```yaml
dependencies:
  get_light: ^1.0.0
```

```dart
import 'package:get_light/get_light.dart';
```

---

## Reactive state

Append `.obs` to any value to make it reactive. Wrap the UI in `Obx` to rebuild automatically.

```dart
class CounterController extends GetxController {
  final count = 0.obs;

  void increment() => count.value++;
}
```

```dart
final ctrl = Get.put(CounterController());

Obx(() => Text('${ctrl.count}'))
```

### Reactive types

| Type | Shorthand |
|---|---|
| `Rx<T>` | `value.obs` |
| `RxInt` | `0.obs` |
| `RxDouble` | `0.0.obs` |
| `RxBool` | `false.obs` |
| `RxString` | `''.obs` |
| `RxList<T>` | `RxList<T>()` |
| `RxMap<K,V>` | `RxMap<K,V>()` |
| `RxSet<T>` | `RxSet<T>()` |

---

## Simple state

Use `update()` instead of `.obs` when you prefer explicit control over rebuilds.

```dart
class CounterController extends GetxController {
  int count = 0;

  void increment() {
    count++;
    update();        // rebuilds all GetBuilder widgets bound to this controller
    update(['card']); // rebuilds only widgets with id: 'card'
  }
}
```

```dart
GetBuilder<CounterController>(
  init: CounterController(),
  builder: (ctrl) => Text('${ctrl.count}'),
)
```

---

## Dependency injection

```dart
// Register
Get.put(AuthService());                        // eager singleton
Get.lazyPut<ApiService>(() => ApiService());   // created on first find
Get.create<Repo>(() => Repo());                // new instance every find

// Retrieve
final svc = Get.find<AuthService>();
final svc = Get.findOrNull<AuthService>();      // null if not registered

// Inspect
Get.isRegistered<AuthService>();
Get.isPrepared<ApiService>();                  // true = lazyPut not yet built

// Remove
Get.delete<AuthService>();
Get.deleteAll();
```

### Tags

Use `tag` to register multiple instances of the same type:

```dart
Get.put(ApiService(baseUrl: 'https://api.example.com'), tag: 'prod');
Get.put(ApiService(baseUrl: 'https://staging.example.com'), tag: 'staging');

final prod = Get.find<ApiService>(tag: 'prod');
```

### Services

`GetxService` is a permanent singleton that survives `deleteAll()` unless `force: true` is passed.

```dart
class AuthService extends GetxService {
  final token = ''.obs;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AuthService(), permanent: true);
  runApp(MyApp());
}
```

---

## Controller lifecycle

```dart
class MyController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // called immediately when the controller is created
  }

  @override
  void onReady() {
    // called one frame after onInit (post-frame callback)
  }

  @override
  void onClose() {
    // called when the controller is removed from memory
    super.onClose();
  }
}
```

---

## Workers

Workers observe a `GetListenable` (any `.obs` variable) and run a callback on changes.
Always dispose workers in `onClose`.

```dart
class SearchController extends GetxController {
  final query = ''.obs;
  final results = RxList<String>();

  Worker? _debouncer;
  Worker? _logger;

  @override
  void onInit() {
    super.onInit();

    // runs on every change
    _logger = ever(query, (val) => print('query: $val'));

    // runs once, when the condition is first met
    once(query, (val) => print('first search: $val'),
        condition: () => query.value.isNotEmpty);

    // fires at most once per 500 ms
    _debouncer = debounce(query, _search,
        time: const Duration(milliseconds: 500));
  }

  void _search(String val) { /* call API */ }

  @override
  void onClose() {
    _debouncer?.dispose();
    _logger?.dispose();
    super.onClose();
  }
}
```

| Worker | Behaviour |
|---|---|
| `ever` | Every change |
| `once` | First change that meets the condition |
| `interval` | First change, then ignores changes for `time` |
| `debounce` | Last change after `time` of silence |

---

## GetView

`GetView<T>` is a stateless widget with a built-in `controller` getter — a shortcut when a screen always maps 1-to-1 to a controller.

```dart
class CounterPage extends GetView<CounterController> {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => Text('${controller.count}')),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

---

## Differences from GetX

| | get_light | get |
|---|---|---|
| Routing | — | ✓ |
| Translations / i18n | — | ✓ |
| Utils (validator, extensions) | — | ✓ |
| State management | ✓ | ✓ |
| Dependency injection | ✓ | ✓ |
| Workers | ✓ | ✓ |
| Pub.dev dependency count | 1 (flutter) | many |

---

## License

MIT — see [LICENSE](LICENSE).
