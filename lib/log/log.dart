/// a simple logging utility.
library log;

import 'dart:io';

/// Enumerates the verbosity levels of the logging system, from `none` (least verbose) to `debug` (most verbose).
///
/// The order of increasing verbosity is: `none` < `fatal` < `error` < `warn` < `info` < `debug`.
/// - `none` indicates no logging should occur.
/// - `fatal` allows only messages related to application crashes.
/// - `error` adds messages related to unexpected results that _will_ break expected behavior.
/// - `warn` adds messages related to unexpected results that will _not_ break expected behavior.
/// - `info` adds messages that track happy path execution.
/// - `debug` adds messages that track program state.
enum LogLevel {
  /// indicates no logging should occur.
  none,

  /// allows only messages related to application crashes.
  fatal,

  /// adds messages related to unexpected results that _will_ break expected behavior.
  error,

  /// adds messages related to unexpected results that will _not_ break expected behavior.
  warn,

  /// adds messages that track happy path execution.
  info,

  /// adds messages that track program state.
  debug,
}

/// Defines the generic recording function provided by [Log].
abstract class Printer {
  /// Records a formatted log message onto some destination.
  ///
  /// Message formatting is handled by [Log.formatter].
  void print(String message);
}

/// Provides a file recording function for use by [Log].
class FilePrinter extends Printer {
  final File _logFile;

  /// Records a formatted log message as a line entry in the file specified in the constructor.
  ///
  /// Message formatting is handled by [Log.formatter].
  @override
  void print(String message) {
    _logFile.writeAsStringSync("${message}\n", mode: FileMode.append);
  }

  FilePrinter(String fileName) : _logFile = File(fileName) {
    _logFile.writeAsStringSync('');
  }
}

/// Provides a terminal recording function for use by [Log].
class StderrPrinter extends Printer {
  /// Records a formatted log message as a line entry to the stderr stream of the terminal.
  ///
  /// Message formatting is handled by [Log.formatter].
  @override
  void print(String message) {
    stderr.write("${message}\n");
  }
}

/// Provides a message formatting function for use by [Log].
///
/// Formatted messages are sent to [Log.printer] for output.
class Formatter {
  final StringBuffer _buffer = StringBuffer();

  /// Generates a formatted log message by combining [time], [level],
  /// a message owner [label], and the [message] itself.
  ///
  /// This implementation's output format is: `hh:mm:ss.sss [LEVEL] label: message`
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

/// Provides methods for emitting and printing formatted log messages at various verbosity levels.
///
/// Messages that exceed the current verbosity threshold stored in [Log.level] will be ignored.
/// The default level is `info` (allowing `info`, `warn`, `error`, and `fatal` messages, but
/// not `debug`).
///
/// A default [Formatter] is provided. Custom formatters can be used by setting
/// the value of [Log.formatter] to a [Formatter]-compliant instance.
///
/// A default [Printer] is provided to log to the terminal: [StderrPrinter]. Custom printers
/// can be used by setting the value of [Log.printer] to a [Printer]-compliant instance.
///
/// Logging functions expect a label to indicate the owner of the message, and a string or
/// string-generating object (like a function) that can be evaluated to get the message string.
/// By capturing message formation in a closure, any costs associated with constructing the
/// message are avoided for logging calls above the current verbosity threshold ([Log.level]).
class Log {
  /// The current threshold for log messages.
  ///
  /// Only messages at the same or lower logging levels will be logged.
  ///
  /// The default level is `info` (allowing `info`, `warn`, `error`, and `fatal` messages, but
  /// not `debug`).
  static LogLevel level = LogLevel.info;

  /// The current message formatter in use.
  ///
  /// Formatters transform the raw message into what will actually be printed.
  ///
  /// A default formatter is provided (see [Formatter], but may be overridden with a custom one
  /// by setting the value of this field.
  static Formatter formatter = Formatter();

  /// The current printer in use.
  ///
  /// Printers record the formatted message onto some destination (e.g. terminal, file, etc).
  ///
  /// A default printer is provided {see [StderrPrinter], but may be overridden with a custom one
  /// by setting the value of this field.
  static Printer printer = StderrPrinter();

  /// Sets [Log.printer] to a [FilePrinter] instance that writes to the filename given in [logFile].
  static void toFile({String logFile = 'log.txt'}) {
    printer = FilePrinter(logFile);
  }

  /// Submit a message at `debug` level verbosity (the highest verbosity level).
  ///
  /// Debug messages help isolate problems in running systems, by showing what is being
  /// executed and the execution context.
  ///
  /// Debug messages should provide context to make spotting abnormal values or conditions easier.
  /// The system is generally not run with debug logging enabled, except when troubleshooting.
  ///
  /// [label] is the name of the message owner, and [messageGenerator] is a string, function,
  /// or object that can be evaluated to get the message string
  static void debug(String label, Object? messageGenerator) {
    if (level.index >= LogLevel.debug.index) {
      _processMessage(LogLevel.debug, label, messageGenerator);
    }
  }

  /// Submit a message at `info` level verbosity.
  ///
  /// Info messages announce&mdash;at a high level&mdash;what the running system is doing.
  /// The system should be able to run at full speed with info level logging enabled.
  ///
  /// Info messages should paint a clear picture of normal system operation.
  ///
  /// [label] is the name of the message owner, and [messageGenerator] is a string, function,
  /// or object that can be evaluated to get the message string
  static void info(String label, Object? messageGenerator) {
    if (level.index >= LogLevel.info.index) {
      _processMessage(LogLevel.info, label, messageGenerator);
    }
  }

  /// Submit a message at `warn` level verbosity.
  ///
  /// Warn messages signal that something unexpected has occurred; the system
  /// is still operating as expected, but some investigation may be warranted.
  ///
  /// Warn messages should be clear about what expectation was invalidated.
  ///
  /// [label] is the name of the message owner, and [messageGenerator] is a string, function,
  /// or object that can be evaluated to get the message string
  static void warn(String label, Object? messageGenerator) {
    if (level.index >= LogLevel.warn.index) {
      _processMessage(LogLevel.warn, label, messageGenerator);
    }
  }

  /// Submit a message at `error` level verbosity.
  ///
  /// Error messages record that something has gone wrong; the system is unable
  /// to recover, and an operator needs to investigate and fix something.
  ///
  /// Error messages should be clear about what went wrong and how it can be triaged or fixed.
  ///
  /// [label] is the name of the message owner, and [messageGenerator] is a string, function,
  /// or object that can be evaluated to get the message string
  static void error(String label, Object? messageGenerator) {
    if (level.index >= LogLevel.error.index) {
      _processMessage(LogLevel.error, label, messageGenerator);
    }
  }

  /// Submit a message at `fatal` level verbosity.
  ///
  /// Fatal messages document a failure that prevents the system from starting,
  /// and indicate the system is completely unusable.
  ///
  /// Fatal messages should be clear about what assertion was violated.
  ///
  /// [label] is the name of the message owner, and [messageGenerator] is a string, function,
  /// or object that can be evaluated to get the message string
  static void fatal(String label, Object? messageGenerator) {
    if (level.index >= LogLevel.fatal.index) {
      _processMessage(LogLevel.fatal, label, messageGenerator);
    }
  }

  static void _processMessage(LogLevel level, String label, Object? messageGenerator) {
    if (messageGenerator is Function) {
      messageGenerator = messageGenerator();
    }
    printer.print(formatter.format(DateTime.now(), level, label, '${messageGenerator}'));
  }
}
