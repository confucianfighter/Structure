import 'dart:io';


/// Singleton Log Manager
class LogManager {
  static final LogManager _instance = LogManager._internal();
  factory LogManager() => _instance;
  LogManager._internal();

  final List<String> _logs = [];
  final String _logFilePath = 'error_log.log';

  Future<void> _appendToFile(String logEntry) async {
    final file = File(_logFilePath);
    await file.writeAsString('$logEntry\n', mode: FileMode.append);
  }

  void log(String message) {
    final logEntry = "[INFO]: $message";
    _logs.add(logEntry);
    _appendToFile(logEntry);
  }

  void logError(String error) {
    final logEntry = "[ERROR]: $error";
    _logs.add(logEntry);
    _appendToFile(logEntry);
  }

  List<String> get logs => List.unmodifiable(_logs);
}
log(String message) => LogManager().log(message);
logError(String error) => LogManager().logError(error);