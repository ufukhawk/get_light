/// GetX Lite - Lightweight state management for Flutter.
///
/// A trimmed-down version of GetX focusing exclusively on state management
/// and dependency injection. No routing, no utilities, no bloat.
///
/// ## Features
/// - **Reactive State Management**: `Obx`, `.obs`, `Rx` types
/// - **Simple State Management**: `GetBuilder`, `GetxController`
/// - **Dependency Injection**: `Get.put()`, `Get.find()`, `Get.lazyPut()`
/// - **Workers**: `ever`, `once`, `interval`, `debounce`
library get_light;

// Core
export 'src/core/get_interface.dart';
export 'src/core/smart_management.dart';
export 'src/core/typedefs.dart';

// Reactive types
export 'src/rx/rx_impl.dart';
export 'src/rx/rx_interface.dart';
export 'src/rx/rx_stream.dart';
export 'src/rx/rx_typedefs.dart';
export 'src/rx/rx_workers.dart';

// State management
export 'src/state/get_builder.dart';
export 'src/state/get_controllers.dart';
export 'src/state/get_view.dart';
export 'src/state/list_notifier.dart';
export 'src/state/obx_widget.dart';
export 'src/state/rx_notifier.dart';
export 'src/state/simple_builder.dart';

// Dependency Injection
export 'src/di/dependency_injection.dart';
export 'src/di/lifecycle.dart';

// Global Get instance
export 'src/get_instance.dart';
