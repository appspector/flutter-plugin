import 'package:appspector/src/event_sender.dart';

class Logger {
  static void v(String tag, String message,
      [Object? error, StackTrace? stackTrace]) {
    log(LogLevel.VERBOSE, tag, message, error, stackTrace);
  }

  static void d(String tag, String message,
      [Object? error, StackTrace? stackTrace]) {
    log(LogLevel.DEBUG, tag, message, error, stackTrace);
  }

  static void i(String tag, String message,
      [Object? error, StackTrace? stackTrace]) {
    log(LogLevel.INFO, tag, message, error, stackTrace);
  }

  static void w(String tag, String message,
      [Object? error, StackTrace? stackTrace]) {
    log(LogLevel.WARN, tag, message, error, stackTrace);
  }

  static void e(String tag, String message,
      [Object? error, StackTrace? stackTrace]) {
    log(LogLevel.ERROR, tag, message, error, stackTrace);
  }

  static void wtf(String tag, String message,
      [Object? error, StackTrace? stackTrace]) {
    log(LogLevel.ASSERT, tag, message, error, stackTrace);
  }

  static void log(LogLevel level, String tag, String message,
      [Object? error, StackTrace? stackTrace]) {
    if (error != null) {
      message = "$message\n$error";
    }
    if (stackTrace != null) {
      message = "$message\n$stackTrace";
    }
    EventSender.sendEvent(new _LogEvent(level, tag, message));
  }
}

class _LogEvent extends Event {
  final LogLevel _level;
  final String _tag;
  final String _message;

  _LogEvent(this._level, this._tag, this._message);

  @override
  Map<String, dynamic> get arguments =>
      {"level": _level.value, "tag": _tag, "message": _message};

  @override
  String get name => "log-event";
}

class LogLevel {
  final int value;

  const LogLevel._internal(this.value);

  toString() => 'LogLevel.$value';

  static const VERBOSE = const LogLevel._internal(2);
  static const DEBUG = const LogLevel._internal(3);
  static const INFO = const LogLevel._internal(4);
  static const WARN = const LogLevel._internal(5);
  static const ERROR = const LogLevel._internal(6);
  static const ASSERT = const LogLevel._internal(6);
}
