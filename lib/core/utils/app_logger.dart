import 'package:logger/logger.dart';

class AppLogger {
  static final _logger = Logger(
    printer: PrettyPrinter(methodCount: 1, colors: true, printEmojis: true),
  );

  static void info(String msg) => _logger.i(msg);
  static void error(String msg, dynamic error, StackTrace stack) => _logger.e(msg, error: error, stackTrace: stack);
  static void debug(String msg) => _logger.d(msg);
}