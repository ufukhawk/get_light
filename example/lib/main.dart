import 'package:flutter/material.dart';
import 'package:get_light/get_light.dart';

// ─────────────────────────────────────────────
// Controllers
// ─────────────────────────────────────────────

/// Reactive counter using .obs — UI updates via Obx.
class ReactiveController extends GetxController {
  final count = 0.obs;
  final history = RxList<String>();

  Worker? _historyWorker;

  @override
  void onInit() {
    super.onInit();
    // ever: runs on every change
    _historyWorker = ever(count, (value) {
      history.add('count → $value');
      if (history.length > 5) history.removeAt(0);
    });
  }

  void increment() => count.value++;
  void decrement() => count.value--;
  void reset() => count.value = 0;

  @override
  void onClose() {
    _historyWorker?.dispose();
    super.onClose();
  }
}

/// Simple counter using update() — UI updates via GetBuilder.
class SimpleController extends GetxController {
  int count = 0;

  void increment() {
    count++;
    update();
  }

  void decrement() {
    count--;
    update();
  }
}

/// A service registered as a permanent singleton.
class AppService extends GetxService {
  final sessionId = DateTime.now().millisecondsSinceEpoch;

  String get info => 'Session #$sessionId';
}

// ─────────────────────────────────────────────
// App entry point
// ─────────────────────────────────────────────

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AppService(), permanent: true);
  runApp(const GetLightExampleApp());
}

class GetLightExampleApp extends StatelessWidget {
  const GetLightExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'get_light example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// ─────────────────────────────────────────────
// Home — tab controller
// ─────────────────────────────────────────────

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('get_light example'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.bolt), text: 'Reactive'),
              Tab(icon: Icon(Icons.widgets), text: 'Simple'),
              Tab(icon: Icon(Icons.storage), text: 'DI'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ReactiveTab(),
            SimpleTab(),
            DiTab(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tab 1 — Reactive (Obx + .obs)
// ─────────────────────────────────────────────

class ReactiveTab extends StatelessWidget {
  const ReactiveTab({super.key});

  @override
  Widget build(BuildContext context) {
    // GetBuilder registers & exposes the controller
    return GetBuilder<ReactiveController>(
      init: ReactiveController(),
      builder: (_) => _ReactiveBody(),
    );
  }
}

class _ReactiveBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ReactiveController>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Reactive counter (.obs + Obx)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // Obx rebuilds only this Text when count changes
          Obx(() => Text(
                '${ctrl.count}',
                style: Theme.of(context).textTheme.displayLarge,
              )),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: ctrl.decrement,
                icon: const Icon(Icons.remove),
                label: const Text('−'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: ctrl.reset,
                child: const Text('Reset'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: ctrl.increment,
                icon: const Icon(Icons.add),
                label: const Text('+'),
              ),
            ],
          ),

          const SizedBox(height: 32),
          const Text('Change history (ever worker)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // Obx for the history list
          Obx(() => Column(
                children: ctrl.history
                    .map((e) => Text(e, style: const TextStyle(fontSize: 12)))
                    .toList(),
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tab 2 — Simple state (GetBuilder + update())
// ─────────────────────────────────────────────

class SimpleTab extends StatelessWidget {
  const SimpleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SimpleController>(
      init: SimpleController(),
      builder: (ctrl) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Simple counter (GetBuilder + update())',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Text(
              '${ctrl.count}',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: ctrl.decrement,
                  icon: const Icon(Icons.remove),
                  label: const Text('−'),
                ),
                const SizedBox(width: 24),
                FilledButton.icon(
                  onPressed: ctrl.increment,
                  icon: const Icon(Icons.add),
                  label: const Text('+'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tab 3 — Dependency Injection
// ─────────────────────────────────────────────

class DiTab extends StatefulWidget {
  const DiTab({super.key});

  @override
  State<DiTab> createState() => _DiTabState();
}

class _DiTabState extends State<DiTab> {
  String _log = '';

  void _appendLog(String line) => setState(() => _log += '$line\n');

  void _demoPut() {
    Get.put('Hello from Get.put!', tag: 'demo');
    final value = Get.find<String>(tag: 'demo');
    _appendLog('put → found: "$value"');
  }

  void _demoLazyPut() {
    var built = false;
    Get.lazyPut<int>(() {
      built = true;
      return 42;
    }, tag: 'lazy');
    _appendLog('lazyPut registered. built before find: $built');
    final value = Get.find<int>(tag: 'lazy');
    _appendLog('find → value: $value (now built: true)');
  }

  void _demoService() {
    final svc = Get.find<AppService>();
    _appendLog('AppService: ${svc.info}');
  }

  void _demoDelete() {
    if (Get.isRegistered<String>(tag: 'demo')) {
      Get.delete<String>(tag: 'demo');
      _appendLog('Deleted "demo" String.');
    } else {
      _appendLog('Nothing to delete (run "put" first).');
    }
  }

  void _clearLog() => setState(() => _log = '');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Dependency Injection',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(onPressed: _demoPut, child: const Text('Get.put')),
              FilledButton(
                  onPressed: _demoLazyPut, child: const Text('lazyPut')),
              FilledButton(
                  onPressed: _demoService, child: const Text('Service')),
              FilledButton(
                  onPressed: _demoDelete, child: const Text('delete')),
              OutlinedButton(
                  onPressed: _clearLog, child: const Text('Clear')),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _log.isEmpty ? 'Tap a button to see output…' : _log,
                  style: const TextStyle(
                      color: Colors.greenAccent,
                      fontFamily: 'monospace',
                      fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
