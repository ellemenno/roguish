
import 'dart:io';


enum LogLevel {
  none,
  fatal,
  error,
  warn,
  info,
  debug,
}

abstract class Printer {
  void print(String message);
}

class FilePrinter extends Printer {
  final File _logFile;

  void print(String message) {
    _logFile.writeAsStringSync("${message}\n", mode: FileMode.append);
  }

  FilePrinter(String fileName) : _logFile = File(fileName) {
    _logFile.writeAsStringSync('');
  }
}

class StderrPrinter extends Printer {
  void print(String message) {
    stderr.write("${message}\n");
  }
}

class Formatter {
  final StringBuffer _buffer = StringBuffer();

  String format(DateTime time, LogLevel level, String label, String message) {
    _buffer.clear();

    _buffer.write(time.hour.toString().padLeft(2, '0'));
    _buffer.write(':');
    _buffer.write(time.minute.toString().padLeft(2, '0'));
    _buffer.write(':');
    _buffer.write(time.second.toString().padLeft(2, '0'));
    _buffer.write('.');
    _buffer.write(time.millisecond.toString().padLeft(3, '0'));
    _buffer.write(' [');
    _buffer.write(level.name.toUpperCase().padLeft(5, ' '));
    _buffer.write('] ');
    _buffer.write(label);
    _buffer.write(': ');
    _buffer.write(message);

    return _buffer.toString();
  }
}

class Log {
  static LogLevel level = LogLevel.info;
  static Formatter formatter = Formatter();
  static Printer printer = StderrPrinter();

  static void toFile({String logFile = 'log.txt'}) {
    printer = FilePrinter(logFile);
  }

  static void debug(String label, Object? messageGenerator) {
    if (level.index >= LogLevel.debug.index) { _processMessage(LogLevel.debug, label, messageGenerator); }
  }

  static void info(String label, Object? messageGenerator) {
    if (level.index >= LogLevel.info.index) { _processMessage(LogLevel.info, label, messageGenerator); }
  }

  static void warn(String label, Object? messageGenerator) {
    if (level.index >= LogLevel.warn.index) { _processMessage(LogLevel.warn, label, messageGenerator); }
  }

  static void error(String label, Object? messageGenerator) {
    if (level.index >= LogLevel.error.index) { _processMessage(LogLevel.error, label, messageGenerator); }
  }

  static void fatal(String label, Object? messageGenerator) {
    if (level.index >= LogLevel.fatal.index) { _processMessage(LogLevel.fatal, label, messageGenerator); }
  }

  static void _processMessage(LogLevel level, String label, Object? messageGenerator) {
    if (messageGenerator is Function) { messageGenerator = messageGenerator(); }
    printer.print(formatter.format(DateTime.now(), level, label, '${messageGenerator}'));
  }
}
