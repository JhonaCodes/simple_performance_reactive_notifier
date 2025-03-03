import 'dart:async';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:reactive_notifier/reactive_notifier.dart';

// Modelo de Métricas de Rendimiento
class PerformanceMetrics {
  final double fps;
  final double averageFrameTime;
  final double memoryUsageMB;
  final int updateCount;
  final List<int> jankUpdates;

  PerformanceMetrics({
    this.fps = 0,
    this.averageFrameTime = 0,
    this.memoryUsageMB = 0,
    this.updateCount = 0,
    this.jankUpdates = const [],
  });

  PerformanceMetrics copyWith({
    double? fps,
    double? averageFrameTime,
    double? memoryUsageMB,
    int? updateCount,
    List<int>? jankUpdates,
  }) {
    return PerformanceMetrics(
      fps: fps ?? this.fps,
      averageFrameTime: averageFrameTime ?? this.averageFrameTime,
      memoryUsageMB: memoryUsageMB ?? this.memoryUsageMB,
      updateCount: updateCount ?? this.updateCount,
      jankUpdates: jankUpdates ?? this.jankUpdates,
    );
  }
}

// ViewModel para Métricas de Rendimiento
class PerformanceViewModel extends ViewModel<PerformanceMetrics> {
  final _frameTimings = <FrameTiming>[];
  final _random = Random();
  Timer? _updateTimer;

  PerformanceViewModel() : super(PerformanceMetrics());

  void startMonitoring() {
    // Iniciar seguimiento de frames
    WidgetsBinding.instance.addTimingsCallback(_onReportTimings);

    // Iniciar timer de actualizaciones periódicas
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateAndUpdateMetrics();
    });
  }

  void _onReportTimings(List<FrameTiming> timings) {
    _frameTimings.addAll(timings);

    // Mantener solo los últimos 120 frames
    if (_frameTimings.length > 120) {
      _frameTimings.removeRange(0, _frameTimings.length - 120);
    }
  }

  void _calculateAndUpdateMetrics() {
    // Calcular FPS
    final frameTimes = _frameTimings
        .map((timing) =>
            timing.buildDuration.inMicroseconds +
            timing.rasterDuration.inMicroseconds)
        .toList();

    final averageFrameTime = frameTimes.isNotEmpty
        ? frameTimes.reduce((a, b) => a + b) / frameTimes.length / 1000
        : 0.0;

    final fps = averageFrameTime > 0 ? 1000 / averageFrameTime : 0.0;

    // Identificar frames con jank (>16ms)
    final jankFrames = _frameTimings
        .where((timing) =>
            (timing.buildDuration.inMilliseconds +
                timing.rasterDuration.inMilliseconds) >
            16)
        .map((timing) =>
            timing.buildDuration.inMilliseconds +
            timing.rasterDuration.inMilliseconds)
        .toList();

    // Obtener uso de memoria (método simulado)
    final memoryUsage = _getMemoryUsage();

    // Actualizar estado
    updateState(data.copyWith(
      fps: fps,
      averageFrameTime: averageFrameTime,
      memoryUsageMB: memoryUsage,
      updateCount: data.updateCount + 1,
      jankUpdates: jankFrames,
    ));
  }

  // Método simulado de obtención de memoria
  double _getMemoryUsage() {
    try {
      // En un escenario real, usarías un método nativo
      return _random.nextDouble() * 100 + 50; // Rango simulado de 50-150 MB
    } catch (e) {
      print('Error obteniendo uso de memoria: $e');
      return 0.0;
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    WidgetsBinding.instance.removeTimingsCallback(_onReportTimings);
    super.dispose();
  }

  @override
  void init() {
    // TODO: implement init
  }
}

// Servicio de Benchmarking
mixin PerformanceBenchmarkService {
  static final performanceVM =
      ReactiveNotifierViewModel<PerformanceViewModel, PerformanceMetrics>(
    () => PerformanceViewModel(),
    autoDispose: true,
  );
}

// Widget de Visualización de Métricas
class PerformanceOverlay extends StatelessWidget {
  const PerformanceOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ReactiveViewModelBuilder<PerformanceMetrics>(
      viewmodel: PerformanceBenchmarkService.performanceVM.notifier,
      builder: (metrics, _) {
        return Container(
          padding: const EdgeInsets.all(8),
          color: Colors.black54,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMetricText('FPS', metrics.fps.toStringAsFixed(1),
                  _getFpsColor(metrics.fps)),
              _buildMetricText(
                  'Frame Time',
                  '${metrics.averageFrameTime.toStringAsFixed(2)}ms',
                  _getFrameTimeColor(metrics.averageFrameTime)),
              _buildMetricText(
                  'Memory',
                  '${metrics.memoryUsageMB.toStringAsFixed(2)} MB',
                  _getMemoryColor(metrics.memoryUsageMB)),
              _buildMetricText(
                  'Jank Frames',
                  metrics.jankUpdates.length.toString(),
                  _getJankColor(metrics.jankUpdates.length)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricText(String label, String value, Color color) {
    return Text(
      '$label: $value',
      style: TextStyle(color: color, fontSize: 12),
    );
  }

  Color _getFpsColor(double fps) {
    if (fps >= 55) return Colors.green;
    if (fps >= 30) return Colors.orange;
    return Colors.red;
  }

  Color _getFrameTimeColor(double frameTime) {
    if (frameTime <= 16) return Colors.green;
    if (frameTime <= 33) return Colors.orange;
    return Colors.red;
  }

  Color _getMemoryColor(double memory) {
    if (memory <= 100) return Colors.green;
    if (memory <= 200) return Colors.orange;
    return Colors.red;
  }

  Color _getJankColor(int jankFrames) {
    if (jankFrames == 0) return Colors.green;
    if (jankFrames <= 5) return Colors.orange;
    return Colors.red;
  }
}

// Ejemplo de Aplicación con Benchmark
class BenchmarkApp extends StatefulWidget {
  const BenchmarkApp({super.key});

  @override
  State<BenchmarkApp> createState() => _BenchmarkAppState();
}

class _BenchmarkAppState extends State<BenchmarkApp> {
  @override
  void initState() {
    super.initState();
    // Iniciar monitoreo de rendimiento
    PerformanceBenchmarkService.performanceVM.notifier.startMonitoring();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar:
            AppBar(title: const Text('ReactiveNotifier Performance Benchmark')),
        body: Stack(
          children: [
            // Contenido de la aplicación
            const Placeholder(),

            // Overlay de métricas
            const Positioned(
              top: 0,
              left: 0,
              child: PerformanceOverlay(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Limpiar recursos
    PerformanceBenchmarkService.performanceVM.notifier.dispose();
    super.dispose();
  }
}

// Ejecutar la aplicación
void main() {
  runApp(const BenchmarkApp());
}
