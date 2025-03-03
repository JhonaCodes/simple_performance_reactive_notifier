import 'dart:async';
import 'dart:math';

import 'package:app/performance_2.dart';
import 'package:flutter/material.dart';
import 'package:reactive_notifier/reactive_notifier.dart';

void main() {
  runApp(const TestApp());
}

class LifecycleTest extends StatefulWidget {
  const LifecycleTest({Key? key}) : super(key: key);

  @override
  _LifecycleTestState createState() => _LifecycleTestState();
}

class _LifecycleTestState extends State<LifecycleTest> {
  @override
  Widget build(BuildContext context) {
    return FpsMonitor(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Prueba de Ciclo de Vida'),
        ),
        body: ReactiveViewModelBuilder<LifecycleTestState>(
          viewmodel: LifecycleTestService.lifecycleTestVM.notifier,
          builder: (state, keep) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Panel de resultados
                if (state.lastTestResults != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resultados de la Última Prueba',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          _buildResultItem('Tipo de prueba',
                              state.lastTestResults!.testType),
                          _buildResultItem('Instancias con autoDispose',
                              '${state.lastTestResults!.autoDisposeInstances}'),
                          _buildResultItem('Instancias sin autoDispose',
                              '${state.lastTestResults!.nonAutoDisposeInstances}'),
                          _buildResultItem('Auto-dispuestas',
                              '${state.lastTestResults!.autoDisposedCount}'),
                          _buildResultItem('Dispuestas manualmente',
                              '${state.lastTestResults!.manuallyDisposedCount}'),
                          if (state.lastTestResults!.autoDisposeInstances > 0)
                            _buildResultItem('Tasa de auto-limpieza',
                                '${(state.lastTestResults!.autoDisposedCount / state.lastTestResults!.autoDisposeInstances * 100).toStringAsFixed(1)}%'),
                        ],
                      ),
                    ),
                  ),

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
                                  : () => LifecycleTestService
                                      .lifecycleTestVM.notifier
                                      .createInstances(10, autoDispose: true),
                            )),
                            keep(ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Crear 10 sin autoDispose'),
                              onPressed: state.isRunning
                                  ? null
                                  : () => LifecycleTestService
                                      .lifecycleTestVM.notifier
                                      .createInstances(10, autoDispose: false),
                            )),
                            keep(ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('Simular Uso (10 ciclos)'),
                              onPressed: (state.isRunning ||
                                      state.instanceStatus.isEmpty)
                                  ? null
                                  : () => LifecycleTestService
                                      .lifecycleTestVM.notifier
                                      .simulateUsage(10),
                            )),
                            keep(ElevatedButton.icon(
                              icon: const Icon(Icons.cleaning_services),
                              label: const Text('Verificar Estado'),
                              onPressed: (state.isRunning ||
                                      state.instanceStatus.isEmpty)
                                  ? null
                                  : () => LifecycleTestService
                                      .lifecycleTestVM.notifier
                                      .checkInstanceStatus(),
                            )),
                            keep(ElevatedButton.icon(
                              icon: const Icon(Icons.delete),
                              label: const Text('Limpiar Todo'),
                              onPressed: (state.isRunning ||
                                      state.instanceStatus.isEmpty)
                                  ? null
                                  : () => LifecycleTestService
                                      .lifecycleTestVM.notifier
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

  Widget _buildResultItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    MemoryTestService.memoryTestVM.notifier.startMemoryMonitoring();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Ejecutar prueba completa
  Future<void> _runFullTest() async {
    if (FullTestService.testStatusNotifier.notifier.isRunning) return;

    FullTestService.testStatusNotifier
        .updateState(FullTestService.testStatusNotifier.notifier.copyWith(
      isRunning: true,
      progress: 0.0,
      status: 'Iniciando prueba completa',
    ));

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Fase 1: Crear instancias
      FullTestService.testStatusNotifier
          .updateState(FullTestService.testStatusNotifier.notifier.copyWith(
        status: 'Fase 1: Creando instancias',
        progress: 0.1,
      ));

      await Future.delayed(const Duration(milliseconds: 500));
      await _createInstances(500);

      // Fase 2: Prueba de actualización rápida
      FullTestService.testStatusNotifier
          .updateState(FullTestService.testStatusNotifier.notifier.copyWith(
        status: 'Fase 2: Prueba de actualización rápida',
        progress: 0.3,
      ));

      _tabController.index = 0; // Cambiar a pestaña de actualización

      await Future.delayed(const Duration(milliseconds: 500));
      await _runUpdateTest();

      // Fase 3: Prueba de ciclo de vida
      FullTestService.testStatusNotifier
          .updateState(FullTestService.testStatusNotifier.notifier.copyWith(
        status: 'Fase 3: Prueba de ciclo de vida',
        progress: 0.6,
      ));

      _tabController.index = 2; // Cambiar a pestaña de ciclo de vida

      await Future.delayed(const Duration(milliseconds: 500));
      await _runLifecycleTest();

      // Fase 4: Limpieza de memoria
      FullTestService.testStatusNotifier
          .updateState(FullTestService.testStatusNotifier.notifier.copyWith(
        status: 'Fase 4: Limpieza de memoria',
        progress: 0.9,
      ));

      _tabController.index = 1; // Cambiar a pestaña de memoria

      await Future.delayed(const Duration(milliseconds: 500));
      await _cleanupAll();

      // Completado
      final finalResult = '''
🟢 Resultados finales de la prueba completa:
• Actualizaciones: ${UpdateTestService.updateTestVM.notifier.data.results?.totalUpdates ?? 0}
• Tiempo promedio: ${UpdateTestService.updateTestVM.notifier.data.results?.avgUpdateTime.toStringAsFixed(2) ?? "0.00"} μs
• Memoria máxima: ${MemoryTestService.memoryTestVM.notifier.data.results?.memoryAfter.toStringAsFixed(2) ?? "0.00"} MB
• Instancias creadas: ${MemoryTestService.memoryTestVM.notifier.data.results?.instancesCreated ?? 0}
• Tasa de auto-limpieza: ${LifecycleTestService.lifecycleTestVM.notifier.data.lastTestResults != null ? (LifecycleTestService.lifecycleTestVM.notifier.data.lastTestResults!.autoDisposedCount / max(LifecycleTestService.lifecycleTestVM.notifier.data.lastTestResults!.autoDisposeInstances, 1) * 100).toStringAsFixed(1) : "0.0"}%
''';

      FullTestService.testStatusNotifier
          .updateState(FullTestService.testStatusNotifier.notifier.copyWith(
        isRunning: false,
        progress: 1.0,
        status: 'Prueba completa finalizada con éxito',
        results: finalResult,
      ));

      print('=== FULL TEST COMPLETED SUCCESSFULLY ===');
    } catch (e) {
      FullTestService.testStatusNotifier
          .updateState(FullTestService.testStatusNotifier.notifier.copyWith(
        isRunning: false,
        status: 'Error: $e',
      ));

      print('ERROR EN PRUEBA COMPLETA: $e');
    }
  }

  Future<void> _createInstances(int count) async {
    await MemoryTestService.memoryTestVM.notifier.createInstances(count);
    LifecycleTestService.lifecycleTestVM.notifier
        .createInstances(20, autoDispose: true);
    LifecycleTestService.lifecycleTestVM.notifier
        .createInstances(20, autoDispose: false);
  }

  Future<void> _runUpdateTest() async {
    final completer = Completer<void>();

    // Crear un listener temporal
    void listener() {
      if (!UpdateTestService.updateTestVM.notifier.data.isRunning &&
          UpdateTestService.updateTestVM.notifier.data.progress >= 0.99) {
        UpdateTestService.updateTestVM.notifier.removeListener(listener);
        completer.complete();
      }
    }

    UpdateTestService.updateTestVM.notifier.addListener(listener);
    UpdateTestService.updateTestVM.notifier
        .startTest(updatesPerSecond: 60, durationSeconds: 3);

    return completer.future;
  }

  Future<void> _runLifecycleTest() async {
    LifecycleTestService.lifecycleTestVM.notifier.simulateUsage(15);
    await Future.delayed(const Duration(seconds: 2));
    LifecycleTestService.lifecycleTestVM.notifier.checkInstanceStatus();
    return Future.value();
  }

  Future<void> _cleanupAll() async {
    await MemoryTestService.memoryTestVM.notifier.clearInstances();
    LifecycleTestService.lifecycleTestVM.notifier.cleanupAllInstances();
    return Future.value();
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
            ReactiveBuilder<TestStatus>(
                notifier: FullTestService.testStatusNotifier,
                builder: (status, _) {
                  return Card(
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
                            status.status,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(value: status.progress),
                          const SizedBox(height: 16),

                          // Resultados finales
                          if (status.results != null)
                            Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status.results!,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            ),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Iniciar Prueba Completa'),
                              onPressed: status.isRunning ? null : _runFullTest,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

            // Contenido de pestañas
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Pestaña de actualización
                  ReactiveViewModelBuilder<UpdateTestState>(
                    viewmodel: UpdateTestService.updateTestVM.notifier,
                    builder: (state, keep) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            margin: const EdgeInsets.all(8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Actualizaciones: ${state.updateCount}',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  if (state.results != null) ...[
                                    const SizedBox(height: 8),
                                    _buildResultItem('Tiempo promedio',
                                        '${state.results!.avgUpdateTime.toStringAsFixed(2)} μs'),
                                    _buildResultItem('Jank updates',
                                        '${state.results!.jankUpdates}'),
                                  ],
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
                              itemCount: min(state.items.length,
                                  50), // Limitar para mejor rendimiento
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
                    viewmodel: MemoryTestService.memoryTestVM.notifier,
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
                    viewmodel: LifecycleTestService.lifecycleTestVM.notifier,
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

  Widget _buildResultItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}

// =============== MIXINS PARA ESTADOS GLOBALES ===============

// Mixin para datos de FPS
mixin FpsService {
  static final fpsNotifier = ReactiveNotifier<List<double>>(() => []);
  static final currentFpsNotifier = ReactiveNotifier<double>(() => 0.0);

  static void addFpsValue(double fps) {
    currentFpsNotifier.updateState(fps);

    final currentValues = List<double>.from(fpsNotifier.notifier);
    if (currentValues.length > 60) {
      currentValues.removeAt(0);
    }
    currentValues.add(fps);
    fpsNotifier.updateState(currentValues);
  }
}

// Mixin para prueba de rendimiento
mixin UpdateTestService {
  static final updateTestVM =
      ReactiveNotifierViewModel<UpdateTestViewModel, UpdateTestState>(
    () => UpdateTestViewModel(),
    autoDispose: true,
  );
}

// Mixin para prueba de memoria
mixin MemoryTestService {
  static final memoryTestVM =
      ReactiveNotifierViewModel<MemoryTestViewModel, MemoryTestState>(
    () => MemoryTestViewModel(),
    autoDispose: true,
  );
}

// Mixin para prueba de ciclo de vida
mixin LifecycleTestService {
  static final lifecycleTestVM =
      ReactiveNotifierViewModel<LifecycleTestViewModel, LifecycleTestState>(
    () => LifecycleTestViewModel(),
    autoDispose: true,
  );
}

// Mixin para la prueba completa
mixin FullTestService {
  static final testStatusNotifier =
      ReactiveNotifier<TestStatus>(() => TestStatus(
            isRunning: false,
            progress: 0.0,
            status: 'Listo para iniciar',
          ));
}

// =============== MODELOS Y VIEWMODELS PARA PRUEBAS ===============

// Modelo para prueba de rendimiento de actualización
class UpdateTestResultData {
  final int totalUpdates;
  final double avgUpdateTime;
  final int minUpdateTime;
  final int maxUpdateTime;
  final int jankUpdates;

  UpdateTestResultData({
    required this.totalUpdates,
    required this.avgUpdateTime,
    required this.minUpdateTime,
    required this.maxUpdateTime,
    required this.jankUpdates,
  });
}

class UpdateTestState {
  final List<ColoredItem> items;
  final int updateCount;
  final double progress;
  final bool isRunning;
  final UpdateTestResultData? results;

  const UpdateTestState({
    required this.items,
    required this.updateCount,
    required this.progress,
    required this.isRunning,
    this.results,
  });

  UpdateTestState copyWith({
    List<ColoredItem>? items,
    int? updateCount,
    double? progress,
    bool? isRunning,
    UpdateTestResultData? results,
  }) {
    return UpdateTestState(
      items: items ?? this.items,
      updateCount: updateCount ?? this.updateCount,
      progress: progress ?? this.progress,
      isRunning: isRunning ?? this.isRunning,
      results: results ?? this.results,
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
      results: null,
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

        // Crear objeto de resultados
        final resultData = _generateResults();

        updateState(data.copyWith(
          isRunning: false,
          progress: 1.0,
          results: resultData,
        ));

        _logResults(resultData);
      }
    });
  }

  UpdateTestResultData _generateResults() {
    if (_updateTimes.isEmpty) {
      return UpdateTestResultData(
        totalUpdates: 0,
        avgUpdateTime: 0,
        minUpdateTime: 0,
        maxUpdateTime: 0,
        jankUpdates: 0,
      );
    }

    final avgUpdateTime =
        _updateTimes.reduce((a, b) => a + b) / _updateTimes.length;
    final maxUpdateTime = _updateTimes.reduce((a, b) => a > b ? a : b);
    final minUpdateTime = _updateTimes.reduce((a, b) => a < b ? a : b);
    final jankUpdates = _updateTimes.where((t) => t > 16000).length;

    return UpdateTestResultData(
      totalUpdates: _updateTimes.length,
      avgUpdateTime: avgUpdateTime,
      minUpdateTime: minUpdateTime,
      maxUpdateTime: maxUpdateTime,
      jankUpdates: jankUpdates,
    );
  }

  void _logResults(UpdateTestResultData results) {
    print('=== UPDATE PERFORMANCE RESULTS ===');
    print('Total updates: ${results.totalUpdates}');
    print('Avg update time: ${results.avgUpdateTime.toStringAsFixed(2)} μs');
    print('Min update time: ${results.minUpdateTime} μs');
    print('Max update time: ${results.maxUpdateTime} μs');
    print('Jank updates (>16ms): ${results.jankUpdates}');
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

class MemoryTestResultData {
  final int instancesCreated;
  final double memoryBefore;
  final double memoryAfter;
  final double memoryIncrease;
  final double avgMemoryPerInstance;

  MemoryTestResultData({
    required this.instancesCreated,
    required this.memoryBefore,
    required this.memoryAfter,
    required this.memoryIncrease,
    required this.avgMemoryPerInstance,
  });
}

class MemoryCleanupResultData {
  final int instancesDisposed;
  final double memoryBefore;
  final double memoryAfter;
  final double memoryReleased;
  final double recoveryRate;

  MemoryCleanupResultData({
    required this.instancesDisposed,
    required this.memoryBefore,
    required this.memoryAfter,
    required this.memoryReleased,
    required this.recoveryRate,
  });
}

class MemoryTestState {
  final List<HeavyItem> items;
  final int instanceCount;
  final double memoryUsage; // En MB
  final double progress;
  final bool isRunning;
  final MemoryTestResultData? results;
  final MemoryCleanupResultData? cleanupResults;

  const MemoryTestState({
    required this.items,
    required this.instanceCount,
    required this.memoryUsage,
    required this.isRunning,
    required this.progress,
    this.results,
    this.cleanupResults,
  });

  MemoryTestState copyWith({
    List<HeavyItem>? items,
    int? instanceCount,
    double? memoryUsage,
    bool? isRunning,
    double? progress,
    MemoryTestResultData? results,
    MemoryCleanupResultData? cleanupResults,
  }) {
    return MemoryTestState(
      items: items ?? this.items,
      instanceCount: instanceCount ?? this.instanceCount,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      isRunning: isRunning ?? this.isRunning,
      progress: progress ?? this.progress,
      results: results ?? this.results,
      cleanupResults: cleanupResults ?? this.cleanupResults,
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

    final endMemory = await _getApproximateMemoryUsage();
    final memoryDelta = endMemory - startMemory;

    final resultData = MemoryTestResultData(
      instancesCreated: count,
      memoryBefore: startMemory,
      memoryAfter: endMemory,
      memoryIncrease: memoryDelta,
      avgMemoryPerInstance: memoryDelta / count,
    );

    updateState(data.copyWith(
      isRunning: false,
      results: resultData,
    ));

    _logResults(resultData);
  }

  void _logResults(MemoryTestResultData results) {
    print('=== MEMORY TEST RESULTS ===');
    print('Instances created: ${results.instancesCreated}');
    print('Memory before: ${results.memoryBefore.toStringAsFixed(2)} MB');
    print('Memory after: ${results.memoryAfter.toStringAsFixed(2)} MB');
    print('Memory increase: ${results.memoryIncrease.toStringAsFixed(2)} MB');
    print(
        'Avg memory per instance: ${results.avgMemoryPerInstance.toStringAsFixed(2)} MB');
    print('==========================');
  }

  // Liberar instancias y medir memoria liberada
  Future<void> clearInstances() async {
    if (data.isRunning) return;

    updateState(data.copyWith(
      isRunning: true,
    ));

    final startMemory = await _getApproximateMemoryUsage();
    final instanceCount = _instances.length;
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
    final recoveryRate = memoryDelta / startMemory * 100;

    final cleanupData = MemoryCleanupResultData(
      instancesDisposed: instanceCount,
      memoryBefore: startMemory,
      memoryAfter: endMemory,
      memoryReleased: memoryDelta,
      recoveryRate: recoveryRate,
    );

    updateState(data.copyWith(
      items: [],
      instanceCount: 0,
      memoryUsage: endMemory,
      isRunning: false,
      cleanupResults: cleanupData,
    ));

    _logCleanupResults(cleanupData);
  }

  void _logCleanupResults(MemoryCleanupResultData results) {
    print('=== MEMORY CLEANUP RESULTS ===');
    print('Instances disposed: ${results.instancesDisposed}');
    print(
        'Memory before cleanup: ${results.memoryBefore.toStringAsFixed(2)} MB');
    print('Memory after cleanup: ${results.memoryAfter.toStringAsFixed(2)} MB');
    print('Memory released: ${results.memoryReleased.toStringAsFixed(2)} MB');
    print('Memory recovery rate: ${results.recoveryRate.toStringAsFixed(1)}%');
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
class LifecycleTestResultData {
  final String testType;
  final int autoDisposeInstances;
  final int nonAutoDisposeInstances;
  final int autoDisposedCount;
  final int manuallyDisposedCount;

  LifecycleTestResultData({
    required this.testType,
    required this.autoDisposeInstances,
    required this.nonAutoDisposeInstances,
    required this.autoDisposedCount,
    required this.manuallyDisposedCount,
  });
}

class LifecycleTestState {
  final int activeInstances;
  final int disposedInstances;
  final List<bool> instanceStatus; // true = active, false = disposed
  final bool isRunning;
  final LifecycleTestResultData? lastTestResults;

  const LifecycleTestState({
    required this.activeInstances,
    required this.disposedInstances,
    required this.instanceStatus,
    required this.isRunning,
    this.lastTestResults,
  });

  LifecycleTestState copyWith({
    int? activeInstances,
    int? disposedInstances,
    List<bool>? instanceStatus,
    bool? isRunning,
    LifecycleTestResultData? lastTestResults,
  }) {
    return LifecycleTestState(
      activeInstances: activeInstances ?? this.activeInstances,
      disposedInstances: disposedInstances ?? this.disposedInstances,
      instanceStatus: instanceStatus ?? this.instanceStatus,
      isRunning: isRunning ?? this.isRunning,
      lastTestResults: lastTestResults ?? this.lastTestResults,
    );
  }
}

class SimpleViewModel extends ViewModel<String> {
  final int id;
  final bool autoDispose;
  bool isDisposed = false;

  SimpleViewModel(this.id, this.autoDispose)
      : super('ViewModel #$id (autoDispose: $autoDispose)');

  @override
  void init() {
    // Simular inicialización
    updateState('ViewModel #$id initialized (autoDispose: $autoDispose)');
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
  final Map<int, bool> _autoDisposeSettings = {};

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
      final instanceId = _instances.length + newInstances.length;

      newInstances.add(ReactiveNotifierViewModel<SimpleViewModel, String>(
        () => SimpleViewModel(instanceId, autoDispose),
        autoDispose: autoDispose,
      ));
      status.add(true);
      _autoDisposeSettings[instanceId] = autoDispose;
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
    int autoDisposedCount = 0;
    int manuallyDisposedCount = 0;

    // Contar instancias originales con cada configuración
    int totalAutoDisposeInstances =
        _autoDisposeSettings.values.where((v) => v).length;
    int totalNonAutoDisposeInstances =
        _autoDisposeSettings.values.where((v) => !v).length;

    for (final instance in _instances) {
      final isActive = !instance.notifier.isDisposed;
      final instanceId = instance.notifier.id;
      final wasAutoDispose = _autoDisposeSettings[instanceId] ?? false;

      status.add(isActive);

      if (isActive) {
        activeCount++;
      } else {
        disposedCount++;
        if (wasAutoDispose) {
          autoDisposedCount++;
        } else {
          manuallyDisposedCount++;
        }
      }
    }

    final resultData = LifecycleTestResultData(
      testType: "Verificación de estado",
      autoDisposeInstances: totalAutoDisposeInstances,
      nonAutoDisposeInstances: totalNonAutoDisposeInstances,
      autoDisposedCount: autoDisposedCount,
      manuallyDisposedCount: manuallyDisposedCount,
    );

    updateState(data.copyWith(
      activeInstances: activeCount,
      disposedInstances: disposedCount,
      instanceStatus: status,
      lastTestResults: resultData,
    ));

    print('=== INSTANCE STATUS CHECK ===');
    print('Active instances: $activeCount');
    print('Disposed instances: $disposedCount');
    print(
        'Auto-disposed instances: $autoDisposedCount / $totalAutoDisposeInstances');
    print(
        'Manually-disposed instances: $manuallyDisposedCount / $totalNonAutoDisposeInstances');
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
        listener() {}
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

    int autoDisposeCount = 0;
    int nonAutoDisposeCount = 0;

    for (final instance in _instances) {
      final instanceId = instance.notifier.id;
      final wasAutoDispose = _autoDisposeSettings[instanceId] ?? false;

      if (wasAutoDispose) {
        autoDisposeCount++;
      } else {
        nonAutoDisposeCount++;
      }

      instance.dispose();
    }

    _instances.clear();

    final resultData = LifecycleTestResultData(
      testType: "Limpieza manual",
      autoDisposeInstances: autoDisposeCount,
      nonAutoDisposeInstances: nonAutoDisposeCount,
      autoDisposedCount: 0,
      // No auto dispuestos, todos manualmente
      manuallyDisposedCount: autoDisposeCount + nonAutoDisposeCount,
    );

    updateState(data.copyWith(
      activeInstances: 0,
      disposedInstances: 0,
      instanceStatus: [],
      isRunning: false,
      lastTestResults: resultData,
    ));

    print('=== MANUAL CLEANUP ===');
    print('All instances have been disposed');
    print('Auto-dispose instances: $autoDisposeCount');
    print('Non-auto-dispose instances: $nonAutoDisposeCount');
    print('======================');
  }

  @override
  void dispose() {
    cleanupAllInstances();
    super.dispose();
  }
}

// Modelo para estado de prueba completa
class TestStatus {
  final bool isRunning;
  final double progress;
  final String status;
  final String? results;

  TestStatus({
    required this.isRunning,
    required this.progress,
    required this.status,
    this.results,
  });

  TestStatus copyWith({
    bool? isRunning,
    double? progress,
    String? status,
    String? results,
  }) {
    return TestStatus(
      isRunning: isRunning ?? this.isRunning,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      results: results ?? this.results,
    );
  }
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
      FpsService.addFpsValue(_frameCount.toDouble());
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
          ReactiveBuilder<double>(
            notifier: FpsService.currentFpsNotifier,
            builder: (fps, _) {
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
