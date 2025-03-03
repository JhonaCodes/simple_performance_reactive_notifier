import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

enum LogLevel { TRACE, DEBUG, INFO, WARN, ERROR, FATAL }

class Logger {
  static final Logger _instance = Logger._internal();
  static Logger get instance => _instance;

  bool _enableColors = true;
  LogLevel _minLevel = LogLevel.TRACE;

  Logger._internal();

  // Colores para Flutter/VSCode/Android Studio
  static const String _black = '■'; // Marcador visual en lugar de color
  static const String _red = '🔴'; // Rojo
  static const String _green = '🟢'; // Verde
  static const String _yellow = '⚠️'; // Amarillo
  static const String _blue = '🔵'; // Azul
  static const String _magenta = '🟣'; // Magenta
  static const String _cyan = '📘'; // Cyan

  String _getPrefix(LogLevel level) {
    if (!_enableColors) return '';

    switch (level) {
      case LogLevel.TRACE:
        return _cyan;
      case LogLevel.DEBUG:
        return _blue;
      case LogLevel.INFO:
        return _green;
      case LogLevel.WARN:
        return _yellow;
      case LogLevel.ERROR:
        return _red;
      case LogLevel.FATAL:
        return _magenta;
    }
  }

  void _log(LogLevel level, String message,
      [Object? error, StackTrace? stackTrace]) {
    if (level.index < _minLevel.index) return;

    final timestamp = DateTime.now().toIso8601String();
    final prefix = _getPrefix(level);

    final errorInfo = error != null ? '\nError: ${error.toString()}' : '';
    final stack =
        stackTrace != null ? '\nStack Trace:\n${stackTrace.toString()}' : '';

    final output = '''
$prefix [${level.toString().split('.').last}][$timestamp]
--> $message
$errorInfo$stack
''';

    if (kDebugMode) {
      debugPrint(output);
    } else {
      developer.log(
        message,
        time: DateTime.now(),
        level: level.index,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  // El resto de métodos igual que antes...
  void trace(String message) => _log(LogLevel.TRACE, message);
  void debug(String message) => _log(LogLevel.DEBUG, message);
  void info(String message) => _log(LogLevel.INFO, message);
  void warn(String message, [Object? error]) =>
      _log(LogLevel.WARN, message, error);
  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _log(LogLevel.ERROR, message, error, stackTrace);
  void fatal(String message, [Object? error, StackTrace? stackTrace]) =>
      _log(LogLevel.FATAL, message, error, stackTrace);

  void setMinLevel(LogLevel level) => _minLevel = level;
  void enableColors(bool enable) => _enableColors = enable;
}
