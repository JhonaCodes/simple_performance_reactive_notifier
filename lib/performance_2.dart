import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:reactive_notifier/reactive_notifier.dart';

// Widget principal de la aplicación
void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReactiveNotifier Benchmark',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        useMaterial3: true,
        cardTheme: const CardTheme(
          elevation: 4,
          margin: EdgeInsets.all(8),
        ),
      ),
      home: const TestDashboard(),
    );
  }
}

// Dashboard principal con menú de pruebas
class TestDashboard extends StatefulWidget {
  const TestDashboard({Key? key}) : super(key: key);

  @override
  State<TestDashboard> createState() => _TestDashboardState();
}

class _TestDashboardState extends State<TestDashboard> {
  final ValueNotifier<double> _fps = ValueNotifier(0);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _frameCount = 0;
  Timer? _fpsTimer;

  @override
  void initState() {
    super.initState();
    _startFpsCounter();
  }

  @override
  void dispose() {
    _fpsTimer?.cancel();
    super.dispose();
  }

  void _startFpsCounter() {
    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _fps.value = _frameCount.toDouble();
      _frameCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    _frameCount++; // Incrementar en cada frame

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('ReactiveNotifier Benchmark'),
        actions: [
          ValueListenableBuilder<double>(
            valueListenable: _fps,
            builder: (context, fps, _) {
              // Código de color para FPS
              final Color fpsColor = fps >= 55
                  ? Colors.green
                  : (fps >= 30 ? Colors.orange : Colors.red);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    'FPS: ${fps.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: fpsColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sección de actualización de estado
              _buildSectionCard(
                'Rendimiento de Actualización de Estado',
                'Mide qué tan rápido se procesan múltiples actualizaciones de estado',
                Icons.speed,
                Colors.blue,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const UpdatePerformanceTest())),
              ),

              // Sección de prueba de memoria
              _buildSectionCard(
                'Prueba de Consumo de Memoria',
                'Crea múltiples instancias con datos pesados y monitorea el uso de memoria',
                Icons.memory,
                Colors.purple,
                () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MemoryUsageTest())),
              ),

              // Sección de ciclo de vida
              _buildSectionCard(
                'Prueba de Ciclo de Vida',
                'Verifica la correcta disposición y limpieza de recursos',
                Icons.recycling,
                Colors.green,
                () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LifecycleTest())),
              ),

              // Sección de carga completa
              _buildSectionCard(
                'Prueba de Carga Completa',
                'Combina todas las pruebas para evaluar el comportamiento bajo carga extrema',
                Icons.warning_amber,
                Colors.orange,
                () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const FullLoadTest())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, String description, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 36,
                    color: color,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar Prueba'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: color,
                  ),
                  onPressed: onTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============== MODELOS Y VIEWMODELS PARA PRUEBAS ===============

// Modelo para prueba de rendimiento de actualización
class UpdateTestState {
  final List<ColoredItem> items;
  final int updateCount;
  final double progress;
  final bool isRunning;

  const UpdateTestState({
    required this.items,
    required this.updateCount,
    required this.progress,
    required this.isRunning,
  });

  UpdateTestState copyWith({
    List<ColoredItem>? items,
    int? updateCount,
    double? progress,
    bool? isRunning,
  }) {
    return UpdateTestState(
      items: items ?? this.items,
      updateCount: updateCount ?? this.updateCount,
      progress: progress ?? this.progress,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class ColoredItem {
  final Color color;
  final int value;

  ColoredItem(this.color, this.value);
}

// ViewModel para prueba de rendimiento
class UpdateTestViewModel extends ViewModel<UpdateTestState> {
  Timer? _updateTimer;
  final Random _random = Random();
  final List<int> _updateTimes = [];

  UpdateTestViewModel()
      : super(UpdateTestState(
          items: List.generate(
              200,
              (i) => ColoredItem(
                  Colors.primaries[i % Colors.primaries.length], i)),
          updateCount: 0,
          progress: 0.0,
          isRunning: false,
        ));

  @override
  void init() {}

  void startTest({int updatesPerSecond = 30, int durationSeconds = 5}) {
    if (data.isRunning) return;

    _updateTimes.clear();
    final updateInterval = 1000 ~/ updatesPerSecond;
    final totalUpdates = updatesPerSecond * durationSeconds;
    int currentUpdate = 0;
    final stopwatch = Stopwatch()..start();

    updateState(data.copyWith(
      isRunning: true,
      updateCount: 0,
      progress: 0.0,
    ));

    _updateTimer?.cancel();
    _updateTimer =
        Timer.periodic(Duration(milliseconds: updateInterval), (timer) {
      final updateStart = stopwatch.elapsedMicroseconds;

      // Generar nuevos items con colores y valores aleatorios
      final newItems = List.generate(
        200,
        (i) => ColoredItem(
          HSVColor.fromAHSV(
            1.0,
            _random.nextDouble() * 360,
            0.7 + _random.nextDouble() * 0.3,
            0.8 + _random.nextDouble() * 0.2,
          ).toColor(),
          _random.nextInt(1000),
        ),
      );

      currentUpdate++;

      updateState(data.copyWith(
        items: newItems,
        updateCount: currentUpdate,
        progress: currentUpdate / totalUpdates,
      ));

      // Registrar tiempo de actualización
      final updateTime = stopwatch.elapsedMicroseconds - updateStart;
      _updateTimes.add(updateTime);

      if (currentUpdate >= totalUpdates) {
        timer.cancel();
        updateState(data.copyWith(
          isRunning: false,
          progress: 1.0,
        ));
        _logResults();
      }
    });
  }

  void _logResults() {
    if (_updateTimes.isEmpty) return;

    final avgUpdateTime =
        _updateTimes.reduce((a, b) => a + b) / _updateTimes.length;
    final maxUpdateTime = _updateTimes.reduce((a, b) => a > b ? a : b);
    final minUpdateTime = _updateTimes.reduce((a, b) => a < b ? a : b);
    final jankUpdates = _updateTimes.where((t) => t > 16000).length;

    print('=== UPDATE PERFORMANCE RESULTS ===');
    print('Total updates: ${_updateTimes.length}');
    print('Avg update time: ${avgUpdateTime.toStringAsFixed(2)} μs');
    print('Min update time: $minUpdateTime μs');
    print('Max update time: $maxUpdateTime μs');
    print('Jank updates (>16ms): $jankUpdates');
    print('=================================');
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}

// Modelo para prueba de memoria
class HeavyItem {
  final String id;
  final List<double> data;
  final Color color;
  final String text;

  HeavyItem(this.id, this.data, this.color, this.text);

  // Método para crear un objeto pesado aproximadamente de 8KB por item
  static HeavyItem createHeavy(int index) {
    final random = Random();
    // Crear un array largo de doubles (aproximadamente 1000 doubles = ~8KB)
    final largeData = List.generate(1000, (_) => random.nextDouble() * 1000);
    // Generar un color aleatorio
    final color = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
    // Generar un texto largo
    final text =
        List.generate(100, (_) => String.fromCharCode(random.nextInt(26) + 97))
            .join();

    return HeavyItem('item_$index', largeData, color, text);
  }
}

class MemoryTestState {
  final List<HeavyItem> items;
  final int instanceCount;
  final double memoryUsage; // En MB
  final double progress;
  final bool isRunning;

  const MemoryTestState(
      {required this.items,
      required this.instanceCount,
      required this.memoryUsage,
      required this.isRunning,
      required this.progress});

  MemoryTestState copyWith({
    List<HeavyItem>? items,
    int? instanceCount,
    double? memoryUsage,
    bool? isRunning,
    double? progress,
  }) {
    return MemoryTestState(
      items: items ?? this.items,
      instanceCount: instanceCount ?? this.instanceCount,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      isRunning: isRunning ?? this.isRunning,
      progress: progress ?? this.progress,
    );
  }
}

// ViewModel para prueba de memoria
class MemoryTestViewModel extends ViewModel<MemoryTestState> {
  final List<ReactiveNotifier<HeavyItem>> _instances = [];
  Timer? _memoryCheckTimer;

  MemoryTestViewModel()
      : super(MemoryTestState(
          items: [],
          instanceCount: 0,
          memoryUsage: 0.0,
          isRunning: false,
          progress: 0.0,
        ));

  @override
  void init() {}

  // Simular medición de memoria
  Future<double> _getApproximateMemoryUsage() async {
    // Nota: En un entorno real, usarías una herramienta como
    // flutter_memory_manager para obtener el valor real

    // Usamos una aproximación para fines de simulación
    // Asume ~8KB por HeavyItem y ~0.5KB por ReactiveNotifier
    final itemMemory = data.items.length * 8.0; // KB
    final instanceMemory = _instances.length * 0.5; // KB

    return (itemMemory + instanceMemory) / 1024.0; // Convertir a MB
  }

  // Crear múltiples instancias con datos pesados
  Future<void> createInstances(int count) async {
    if (data.isRunning) return;

    updateState(data.copyWith(
      isRunning: true,
    ));

    final startMemory = await _getApproximateMemoryUsage();
    print('Memoria inicial: ${startMemory.toStringAsFixed(2)} MB');

    // Crear lotes de instancias para evitar bloquear la UI
    const batchSize = 100;
    final totalBatches = (count / batchSize).ceil();

    for (int batch = 0; batch < totalBatches; batch++) {
      await Future.delayed(const Duration(milliseconds: 100));

      final startIdx = batch * batchSize;
      final endIdx = min((batch + 1) * batchSize, count);

      final newItems = <HeavyItem>[];

      for (int i = startIdx; i < endIdx; i++) {
        final item = HeavyItem.createHeavy(i);
        newItems.add(item);

        // Crear ReactiveNotifier para cada item
        final notifier = ReactiveNotifier<HeavyItem>(() => item);
        _instances.add(notifier);
      }

      final currentItems = [...data.items, ...newItems];
      final memoryUsage = await _getApproximateMemoryUsage();

      updateState(data.copyWith(
        items: currentItems,
        instanceCount: _instances.length,
        memoryUsage: memoryUsage,
        progress: (batch + 1) / totalBatches,
      ));
    }

    updateState(data.copyWith(
      isRunning: false,
    ));

    final endMemory = await _getApproximateMemoryUsage();
    final memoryDelta = endMemory - startMemory;

    print('=== MEMORY TEST RESULTS ===');
    print('Instances created: ${_instances.length}');
    print('Memory before: ${startMemory.toStringAsFixed(2)} MB');
    print('Memory after: ${endMemory.toStringAsFixed(2)} MB');
    print('Memory increase: ${memoryDelta.toStringAsFixed(2)} MB');
    print(
        'Avg memory per instance: ${(memoryDelta / count).toStringAsFixed(2)} MB');
    print('==========================');
  }

  // Liberar instancias y medir memoria liberada
  Future<void> clearInstances() async {
    if (data.isRunning) return;

    updateState(data.copyWith(
      isRunning: true,
    ));

    final startMemory = await _getApproximateMemoryUsage();
    print('Memoria antes de limpieza: ${startMemory.toStringAsFixed(2)} MB');

    // Llamar explícitamente a cleanCurrentNotifier en cada instancia
    for (final instance in _instances) {
      instance.cleanCurrentNotifier();
    }

    _instances.clear();

    await Future.delayed(const Duration(milliseconds: 500));

    // Forzar recolección de basura para una medición más precisa
    // Nota: En una app real, no puedes forzar la GC
    // Esto es solo para propósitos de simulación
    await Future.delayed(const Duration(seconds: 1));

    final endMemory = await _getApproximateMemoryUsage();
    final memoryDelta = startMemory - endMemory;

    updateState(data.copyWith(
      items: [],
      instanceCount: 0,
      memoryUsage: endMemory,
      isRunning: false,
    ));

    print('=== MEMORY CLEANUP RESULTS ===');
    print('Instances disposed: ${_instances.length}');
    print('Memory before cleanup: ${startMemory.toStringAsFixed(2)} MB');
    print('Memory after cleanup: ${endMemory.toStringAsFixed(2)} MB');
    print('Memory released: ${memoryDelta.toStringAsFixed(2)} MB');
    print(
        'Memory recovery rate: ${(memoryDelta / startMemory * 100).toStringAsFixed(1)}%');
    print('==============================');
  }

  // Iniciar timer para monitoreo de memoria
  void startMemoryMonitoring() {
    _memoryCheckTimer?.cancel();
    _memoryCheckTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (data.isRunning) return;

      final memoryUsage = await _getApproximateMemoryUsage();

      updateState(data.copyWith(
        memoryUsage: memoryUsage,
      ));
    });
  }

  void stopMemoryMonitoring() {
    _memoryCheckTimer?.cancel();
  }

  @override
  void dispose() {
    stopMemoryMonitoring();
    _memoryCheckTimer?.cancel();
    clearInstances();
    super.dispose();
  }
}

// Modelo para prueba de ciclo de vida
class LifecycleTestState {
  final int activeInstances;
  final int disposedInstances;
  final List<bool> instanceStatus; // true = active, false = disposed
  final bool isRunning;

  const LifecycleTestState({
    required this.activeInstances,
    required this.disposedInstances,
    required this.instanceStatus,
    required this.isRunning,
  });

  LifecycleTestState copyWith({
    int? activeInstances,
    int? disposedInstances,
    List<bool>? instanceStatus,
    bool? isRunning,
  }) {
    return LifecycleTestState(
      activeInstances: activeInstances ?? this.activeInstances,
      disposedInstances: disposedInstances ?? this.disposedInstances,
      instanceStatus: instanceStatus ?? this.instanceStatus,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class SimpleViewModel extends ViewModel<String> {
  final int id;
  bool isDisposed = false;

  SimpleViewModel(this.id) : super('ViewModel #$id');

  @override
  void init() {
    // Simular inicialización
    updateState('ViewModel #$id (initialized)');
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }
}

// ViewModel para prueba de ciclo de vida
class LifecycleTestViewModel extends ViewModel<LifecycleTestState> {
  final List<ReactiveNotifierViewModel<SimpleViewModel, String>> _instances =
      [];

  LifecycleTestViewModel()
      : super(LifecycleTestState(
          activeInstances: 0,
          disposedInstances: 0,
          instanceStatus: [],
          isRunning: false,
        ));

  @override
  void init() {}

  // Crear instancias con autoDispose activado
  void createInstances(int count, {bool autoDispose = true}) {
    if (data.isRunning) return;

    updateState(data.copyWith(
      isRunning: true,
    ));

    final newInstances = <ReactiveNotifierViewModel<SimpleViewModel, String>>[];
    final status = List<bool>.from(data.instanceStatus);

    for (int i = 0; i < count; i++) {
      final vm = ReactiveNotifierViewModel<SimpleViewModel, String>(
        () => SimpleViewModel(_instances.length + newInstances.length),
        autoDispose: autoDispose,
      );
      newInstances.add(vm);
      status.add(true);
    }

    _instances.addAll(newInstances);

    updateState(data.copyWith(
      activeInstances: data.activeInstances + count,
      instanceStatus: status,
      isRunning: false,
    ));

    print('=== LIFECYCLE TEST INFO ===');
    print('Created $count instances');
    print('Auto-dispose setting: $autoDispose');
    print('Total active instances: ${_instances.length}');
    print('===========================');
  }

  // Verificar estado de las instancias
  void checkInstanceStatus() {
    final status = <bool>[];
    int activeCount = 0;
    int disposedCount = 0;

    for (final instance in _instances) {
      final isActive = !instance.notifier.isDisposed;
      status.add(isActive);

      if (isActive) {
        activeCount++;
      } else {
        disposedCount++;
      }
    }

    updateState(data.copyWith(
      activeInstances: activeCount,
      disposedInstances: disposedCount,
      instanceStatus: status,
    ));

    print('=== INSTANCE STATUS CHECK ===');
    print('Active instances: $activeCount');
    print('Disposed instances: $disposedCount');
    print('Total tracked instances: ${_instances.length}');
    print('=============================');
  }

  // Simular uso de instancias (crear y eliminar listeners)
  void simulateUsage(int iterations) {
    if (_instances.isEmpty || data.isRunning) return;

    updateState(data.copyWith(
      isRunning: true,
    ));

    // Simular múltiples ciclos de agregar/remover listeners
    _simulateIterations(iterations);
  }

  Future<void> _simulateIterations(int iterations) async {
    final random = Random();

    for (int i = 0; i < iterations; i++) {
      // Simular actividad en instancias aleatorias
      final listeners = <VoidCallback>[];
      final usedInstances =
          <ReactiveNotifierViewModel<SimpleViewModel, String>>[];

      // Seleccionar instancias aleatorias para usar
      for (int j = 0; j < min(_instances.length, 10); j++) {
        final idx = random.nextInt(_instances.length);
        final instance = _instances[idx];
        if (!instance.notifier.isDisposed) {
          usedInstances.add(instance);
        }
      }

      // Agregar listeners a las instancias seleccionadas
      for (final instance in usedInstances) {
        final listener = () {};
        listeners.add(listener);
        instance.notifier.addListener(listener);
      }

      // Esperar un poco
      await Future.delayed(const Duration(milliseconds: 50));

      // Hacer algunos updates
      for (final instance in usedInstances) {
        if (!instance.notifier.isDisposed) {
          instance.notifier
              .updateState('Updated: ${DateTime.now().millisecondsSinceEpoch}');
        }
      }

      // Esperar otro poco
      await Future.delayed(const Duration(milliseconds: 50));

      // Remover los listeners
      for (int j = 0; j < usedInstances.length; j++) {
        if (j < listeners.length) {
          usedInstances[j].notifier.removeListener(listeners[j]);
        }
      }
    }

    // Verificar estado final
    checkInstanceStatus();

    updateState(data.copyWith(
      isRunning: false,
    ));
  }

  // Limpiar todas las instancias manualmente
  void cleanupAllInstances() {
    if (data.isRunning) return;

    updateState(data.copyWith(
      isRunning: true,
    ));

    for (final instance in _instances) {
      instance.dispose();
    }

    _instances.clear();

    updateState(data.copyWith(
      activeInstances: 0,
      disposedInstances: 0,
      instanceStatus: [],
      isRunning: false,
    ));

    print('=== MANUAL CLEANUP ===');
    print('All instances have been disposed');
    print('======================');
  }

  @override
  void dispose() {
    cleanupAllInstances();
    super.dispose();
  }
}

// Clase para medir y visualizar FPS
class FpsMonitor extends StatefulWidget {
  final Widget child;

  const FpsMonitor({Key? key, required this.child}) : super(key: key);

  @override
  State<FpsMonitor> createState() => _FpsMonitorState();
}

class _FpsMonitorState extends State<FpsMonitor> {
  final ValueNotifier<double> _fps = ValueNotifier(0);
  final List<double> _fpsHistory = [];
  int _frameCount = 0;
  Timer? _fpsTimer;

  @override
  void initState() {
    super.initState();
    _startFpsCounter();
  }

  @override
  void dispose() {
    _fpsTimer?.cancel();
    super.dispose();
  }

  void _startFpsCounter() {
    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final newFps = _frameCount.toDouble();
      _fps.value = newFps;
      _fpsHistory.add(newFps);
      if (_fpsHistory.length > 60) {
        _fpsHistory.removeAt(0);
      }
      _frameCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    _frameCount++; // Incrementar en cada frame

    return Stack(
      children: [
        widget.child,
        Positioned(
          right: 0,
          bottom: 0,
          child: ValueListenableBuilder<double>(
            valueListenable: _fps,
            builder: (context, fps, _) {
              // Código de color para FPS
              final Color fpsColor = fps >= 55
                  ? Colors.green
                  : (fps >= 30 ? Colors.orange : Colors.red);

              return Card(
                margin: EdgeInsets.all(8),
                color: Colors.black54,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'FPS: ${fps.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: fpsColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      SizedBox(
                        height: 40,
                        width: 120,
                        child: CustomPaint(
                          painter: FpsChartPainter(_fpsHistory),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Painter para gráfico de FPS
class FpsChartPainter extends CustomPainter {
  final List<double> fpsValues;

  FpsChartPainter(this.fpsValues);

  @override
  void paint(Canvas canvas, Size size) {
    if (fpsValues.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    final width = size.width;
    final height = size.height;

    // Dibujar línea base de 60 FPS
    final baseLinePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(0, height * (1 - 60 / 60)),
      Offset(width, height * (1 - 60 / 60)),
      baseLinePaint,
    );

    for (int i = 0; i < fpsValues.length; i++) {
      final x = width * i / (fpsValues.length - 1);
      final fps = fpsValues[i].clamp(0, 60);
      final y = height * (1 - fps / 60);

      // Color basado en FPS
      paint.color =
          fps >= 55 ? Colors.green : (fps >= 30 ? Colors.orange : Colors.red);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// =============== PANTALLAS DE PRUEBA ===============

// Pantalla de prueba de rendimiento de actualización
class UpdatePerformanceTest extends StatefulWidget {
  const UpdatePerformanceTest({Key? key}) : super(key: key);

  @override
  _UpdatePerformanceTestState createState() => _UpdatePerformanceTestState();
}

class _UpdatePerformanceTestState extends State<UpdatePerformanceTest> {
  final updateTestVM =
      ReactiveNotifierViewModel<UpdateTestViewModel, UpdateTestState>(
    () => UpdateTestViewModel(),
    autoDispose: true,
  );

  @override
  void dispose() {
    updateTestVM.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FpsMonitor(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Prueba de Rendimiento'),
        ),
        body: ReactiveViewModelBuilder<UpdateTestState>(
          viewmodel: updateTestVM.notifier,
          builder: (state, keep) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Controles
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prueba de Actualización de Estado',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Actualizaciones: ${state.updateCount}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(value: state.progress),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            keep(ElevatedButton(
                              onPressed: state.isRunning
                                  ? null
                                  : () => updateTestVM.notifier.startTest(
                                        updatesPerSecond: 10,
                                        durationSeconds: 5,
                                      ),
                              child: const Text('10 UPS'),
                            )),
                            keep(ElevatedButton(
                              onPressed: state.isRunning
                                  ? null
                                  : () => updateTestVM.notifier.startTest(
                                        updatesPerSecond: 30,
                                        durationSeconds: 5,
                                      ),
                              child: const Text('30 UPS'),
                            )),
                            keep(ElevatedButton(
                              onPressed: state.isRunning
                                  ? null
                                  : () => updateTestVM.notifier.startTest(
                                        updatesPerSecond: 60,
                                        durationSeconds: 5,
                                      ),
                              child: const Text('60 UPS'),
                            )),
                            keep(ElevatedButton(
                              onPressed: state.isRunning
                                  ? null
                                  : () => updateTestVM.notifier.startTest(
                                        updatesPerSecond: 100,
                                        durationSeconds: 5,
                                      ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('100 UPS'),
                            )),
                          ],
                        ),
                        if (state.isRunning)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Row(
                              children: [
                                const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Ejecutando prueba... ${(state.progress * 100).toStringAsFixed(0)}%',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Grilla de ítems
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${item.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Pantalla de prueba de memoria
class MemoryUsageTest extends StatefulWidget {
  const MemoryUsageTest({Key? key}) : super(key: key);

  @override
  _MemoryUsageTestState createState() => _MemoryUsageTestState();
}

class _MemoryUsageTestState extends State<MemoryUsageTest> {
  final memoryTestVM =
      ReactiveNotifierViewModel<MemoryTestViewModel, MemoryTestState>(
    () => MemoryTestViewModel(),
    autoDispose: true,
  );

  @override
  void initState() {
    super.initState();
    memoryTestVM.notifier.startMemoryMonitoring();
  }

  @override
  void dispose() {
    memoryTestVM.notifier.stopMemoryMonitoring();
    memoryTestVM.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FpsMonitor(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Prueba de Memoria'),
        ),
        body: ReactiveViewModelBuilder<MemoryTestState>(
          viewmodel: memoryTestVM.notifier,
          builder: (state, keep) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Panel de información
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Uso de Memoria',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          'Instancias activas',
                          '${state.instanceCount}',
                          Icons.memory,
                          Colors.blue,
                        ),
                        _buildInfoRow(
                          'Memoria aproximada',
                          '${state.memoryUsage.toStringAsFixed(2)} MB',
                          Icons.storage,
                          Colors.orange,
                        ),
                        _buildInfoRow(
                          'Items en memoria',
                          '${state.items.length}',
                          Icons.data_array,
                          Colors.green,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            keep(ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('100 Instancias'),
                              onPressed: state.isRunning
                                  ? null
                                  : () => memoryTestVM.notifier
                                      .createInstances(100),
                            )),
                            keep(ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('500 Instancias'),
                              onPressed: state.isRunning
                                  ? null
                                  : () => memoryTestVM.notifier
                                      .createInstances(500),
                            )),
                            keep(ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('1000 Instancias'),
                              onPressed: state.isRunning
                                  ? null
                                  : () => memoryTestVM.notifier
                                      .createInstances(1000),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                            )),
                            keep(ElevatedButton.icon(
                              icon: const Icon(Icons.delete),
                              label: const Text('Limpiar Todo'),
                              onPressed: () =>
                                  memoryTestVM.notifier.clearInstances(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Visualización de memoria
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Impacto en Memoria',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Center(
                              child: CustomPaint(
                                size: const Size(
                                    double.infinity, double.infinity),
                                painter: MemoryVisualizationPainter(
                                  itemCount: state.items.length,
                                  instanceCount: state.instanceCount,
                                  memoryUsage: state.memoryUsage,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Panel de resultado
                if (state.isRunning)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Operación en progreso...',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Painter para visualización de memoria
class MemoryVisualizationPainter extends CustomPainter {
  final int itemCount;
  final int instanceCount;
  final double memoryUsage;

  MemoryVisualizationPainter({
    required this.itemCount,
    required this.instanceCount,
    required this.memoryUsage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Dibujar fondo
    final bgPaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      bgPaint,
    );

    // Dibujar grid
    final gridPaint = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 10; i++) {
      final y = height * i / 10;
      canvas.drawLine(
        Offset(0, y),
        Offset(width, y),
        gridPaint,
      );

      final x = width * i / 10;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, height),
        gridPaint,
      );
    }

    // Dibujar representación de memoria
    // Asumimos un máximo de 20MB para escala completa
    final memoryHeight = (memoryUsage / 20) * height;
    final memoryPaint = Paint()
      ..color = _getMemoryColor(memoryUsage)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(
        width * 0.1,
        height - memoryHeight,
        width * 0.8,
        memoryHeight,
      ),
      memoryPaint,
    );

    // Dibujar texto
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Texto de memoria
    textPainter.text = TextSpan(
      text: '${memoryUsage.toStringAsFixed(2)} MB',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );

    textPainter.layout(maxWidth: width * 0.8);
    textPainter.paint(
      canvas,
      Offset(
        width * 0.1 + (width * 0.8 - textPainter.width) / 2,
        height - memoryHeight - textPainter.height - 4,
      ),
    );

    // Texto de instancias
    textPainter.text = TextSpan(
      text: '$instanceCount instancias',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
    );

    textPainter.layout(maxWidth: width * 0.8);
    textPainter.paint(
      canvas,
      Offset(
        width * 0.1 + (width * 0.8 - textPainter.width) / 2,
        height - memoryHeight + 4,
      ),
    );
  }

  Color _getMemoryColor(double memoryUsage) {
    if (memoryUsage < 5) {
      return Colors.green;
    } else if (memoryUsage < 10) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Pantalla de prueba de ciclo de vida
class LifecycleTest extends StatefulWidget {
  const LifecycleTest({Key? key}) : super(key: key);

  @override
  _LifecycleTestState createState() => _LifecycleTestState();
}

class _LifecycleTestState extends State<LifecycleTest> {
  final lifecycleTestVM =
      ReactiveNotifierViewModel<LifecycleTestViewModel, LifecycleTestState>(
    () => LifecycleTestViewModel(),
    autoDispose: true,
  );

  @override
  void dispose() {
    lifecycleTestVM.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FpsMonitor(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Prueba de Ciclo de Vida'),
        ),
        body: ReactiveViewModelBuilder<LifecycleTestState>(
          viewmodel: lifecycleTestVM.notifier,
          builder: (state, keep) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Panel de controles
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Control de Ciclo de Vida',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            keep(ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Crear 10 con autoDispose'),
                              onPressed: state.isRunning
                                  ? null
                                  : () => lifecycleTestVM.notifier
                                      .createInstances(10, autoDispose: true),
                            )),
                            keep(ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Crear 10 sin autoDispose'),
                              onPressed: state.isRunning
                                  ? null
                                  : () => lifecycleTestVM.notifier
                                      .createInstances(10, autoDispose: false),
                            )),
                            keep(ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('Simular Uso (10 ciclos)'),
                              onPressed: () =>
                                  lifecycleTestVM.notifier.simulateUsage(10),
                            )),
                            keep(ElevatedButton.icon(
                              icon: const Icon(Icons.cleaning_services),
                              label: const Text('Verificar Estado'),
                              onPressed: () => lifecycleTestVM.notifier
                                  .checkInstanceStatus(),
                            )),
                            keep(ElevatedButton.icon(
                              icon: const Icon(Icons.delete),
                              label: const Text('Limpiar Todo'),
                              onPressed: () => lifecycleTestVM.notifier
                                  .cleanupAllInstances(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Panel de estadísticas
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estadísticas de Instancias',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard(
                              'Activas',
                              state.activeInstances.toString(),
                              Icons.check_circle,
                              Colors.green,
                            ),
                            _buildStatCard(
                              'Dispuestas',
                              state.disposedInstances.toString(),
                              Icons.cancel,
                              Colors.red,
                            ),
                            _buildStatCard(
                              'Total',
                              state.instanceStatus.length.toString(),
                              Icons.info,
                              Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Visualización de instancias
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estado de Instancias',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          if (state.instanceStatus.isNotEmpty)
                            Expanded(
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  childAspectRatio: 1.0,
                                  crossAxisSpacing: 4,
                                  mainAxisSpacing: 4,
                                ),
                                itemCount: state.instanceStatus.length,
                                itemBuilder: (context, index) {
                                  final isActive = state.instanceStatus[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? Colors.green
                                          : Colors.red[900],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isActive
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '#$index',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            isActive ? 'Activo' : 'Dispuesto',
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.7),
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          else
                            const Expanded(
                              child: Center(
                                child: Text(
                                  'No hay instancias para mostrar.\nCrea algunas instancias usando los botones arriba.',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Panel de progreso
                if (state.isRunning)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Operación en progreso...',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// Pantalla de prueba de carga completa
class FullLoadTest extends StatefulWidget {
  const FullLoadTest({Key? key}) : super(key: key);

  @override
  _FullLoadTestState createState() => _FullLoadTestState();
}

class _FullLoadTestState extends State<FullLoadTest>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final updateTestVM =
      ReactiveNotifierViewModel<UpdateTestViewModel, UpdateTestState>(
    () => UpdateTestViewModel(),
    autoDispose: true,
  );
  final memoryTestVM =
      ReactiveNotifierViewModel<MemoryTestViewModel, MemoryTestState>(
    () => MemoryTestViewModel(),
    autoDispose: true,
  );
  final lifecycleTestVM =
      ReactiveNotifierViewModel<LifecycleTestViewModel, LifecycleTestState>(
    () => LifecycleTestViewModel(),
    autoDispose: true,
  );

  // Estado de prueba
  bool _isRunning = false;
  double _progress = 0.0;
  String _status = 'Listo para iniciar';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    memoryTestVM.notifier.startMemoryMonitoring();
  }

  @override
  void dispose() {
    memoryTestVM.notifier.stopMemoryMonitoring();
    updateTestVM.dispose();
    memoryTestVM.dispose();
    lifecycleTestVM.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Ejecutar prueba completa
  Future<void> _runFullTest() async {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _progress = 0.0;
      _status = 'Iniciando prueba completa';
    });

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Fase 1: Crear instancias
      setState(() {
        _status = 'Fase 1: Creando instancias';
        _progress = 0.1;
      });

      await Future.delayed(const Duration(milliseconds: 500));
      await _createInstances(500);

      // Fase 2: Prueba de actualización rápida
      setState(() {
        _status = 'Fase 2: Prueba de actualización rápida';
        _progress = 0.3;
        _tabController.index = 0; // Cambiar a pestaña de actualización
      });

      await Future.delayed(const Duration(milliseconds: 500));
      await _runUpdateTest();

      // Fase 3: Prueba de ciclo de vida
      setState(() {
        _status = 'Fase 3: Prueba de ciclo de vida';
        _progress = 0.6;
        _tabController.index = 2; // Cambiar a pestaña de ciclo de vida
      });

      await Future.delayed(const Duration(milliseconds: 500));
      await _runLifecycleTest();

      // Fase 4: Limpieza de memoria
      setState(() {
        _status = 'Fase 4: Limpieza de memoria';
        _progress = 0.9;
        _tabController.index = 1; // Cambiar a pestaña de memoria
      });

      await Future.delayed(const Duration(milliseconds: 500));
      await _cleanupAll();

      // Completado
      setState(() {
        _isRunning = false;
        _progress = 1.0;
        _status = 'Prueba completa finalizada con éxito';
      });

      print('=== FULL TEST COMPLETED SUCCESSFULLY ===');
    } catch (e) {
      setState(() {
        _isRunning = false;
        _status = 'Error: $e';
      });

      print('ERROR EN PRUEBA COMPLETA: $e');
    }
  }

  Future<void> _createInstances(int count) async {
    await memoryTestVM.notifier.createInstances(count);
    lifecycleTestVM.notifier.createInstances(20, autoDispose: true);
    lifecycleTestVM.notifier.createInstances(20, autoDispose: false);
  }

  Future<void> _runUpdateTest() async {
    final completer = Completer<void>();

    // Crear un listener temporal
    void listener() {
      if (!updateTestVM.notifier.data.isRunning &&
          updateTestVM.notifier.data.progress >= 0.99) {
        updateTestVM.notifier.removeListener(listener);
        completer.complete();
      }
    }

    updateTestVM.notifier.addListener(listener);
    updateTestVM.notifier.startTest(updatesPerSecond: 60, durationSeconds: 3);

    return completer.future;
  }

  Future<void> _runLifecycleTest() async {
    lifecycleTestVM.notifier.simulateUsage(15);
    lifecycleTestVM.notifier.checkInstanceStatus();
  }

  Future<void> _cleanupAll() async {
    await memoryTestVM.notifier.clearInstances();
    lifecycleTestVM.notifier.cleanupAllInstances();
  }

  @override
  Widget build(BuildContext context) {
    return FpsMonitor(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Prueba de Carga Completa'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Actualización'),
              Tab(text: 'Memoria'),
              Tab(text: 'Ciclo de Vida'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Panel de control de prueba
            Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prueba de Carga Completa',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(value: _progress),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Iniciar Prueba Completa'),
                        onPressed: _isRunning ? null : _runFullTest,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Contenido de pestañas
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Pestaña de actualización
                  ReactiveViewModelBuilder<UpdateTestState>(
                    viewmodel: updateTestVM.notifier,
                    builder: (state, keep) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            margin: const EdgeInsets.all(8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Actualizaciones: ${state.updateCount}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ),
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.all(8),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                childAspectRatio: 1.0,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                              ),
                              itemCount: state.items.length,
                              itemBuilder: (context, index) {
                                final item = state.items[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: item.color,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${item.value}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // Pestaña de memoria
                  ReactiveViewModelBuilder<MemoryTestState>(
                    viewmodel: memoryTestVM.notifier,
                    builder: (state, keep) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            margin: const EdgeInsets.all(8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      const Icon(Icons.memory,
                                          color: Colors.blue),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${state.instanceCount}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      const Text('Instancias'),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Icon(Icons.storage,
                                          color: Colors.orange),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${state.memoryUsage.toStringAsFixed(2)} MB',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      const Text('Memoria'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Card(
                              margin: const EdgeInsets.all(8),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: CustomPaint(
                                  painter: MemoryVisualizationPainter(
                                    itemCount: state.items.length,
                                    instanceCount: state.instanceCount,
                                    memoryUsage: state.memoryUsage,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // Pestaña de ciclo de vida
                  ReactiveViewModelBuilder<LifecycleTestState>(
                    viewmodel: lifecycleTestVM.notifier,
                    builder: (state, keep) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            margin: const EdgeInsets.all(8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      const Icon(Icons.check_circle,
                                          color: Colors.green),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${state.activeInstances}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      const Text('Activas'),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Icon(Icons.cancel,
                                          color: Colors.red),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${state.disposedInstances}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      const Text('Dispuestas'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.all(8),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                childAspectRatio: 1.0,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                              ),
                              itemCount: state.instanceStatus.length,
                              itemBuilder: (context, index) {
                                final isActive = state.instanceStatus[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.green
                                        : Colors.red[900],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isActive
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        Text(
                                          '#$index',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
