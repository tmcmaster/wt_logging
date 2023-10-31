import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

class UserLog extends ChangeNotifier {
  static final provider = ChangeNotifierProvider(
    name: 'UserLog',
    (ref) => UserLog._(ref),
  );

  static final snackBarKey = Provider<GlobalKey<ScaffoldMessengerState>>(
    name: 'UserLog.snackBarKey',
    (ref) =>
        throw Exception('UserLog.snackBarKey provider needs to be overridden.'),
  );

  static const levelColors = {
    Level.wtf: Colors.purple,
    Level.error: Colors.red,
    Level.warning: Colors.orange,
    Level.info: Colors.green,
    Level.debug: Colors.blue,
    Level.verbose: Colors.yellow,
    Level.nothing: Colors.grey,
  };

  final Ref ref;
  UserLog._(this.ref);

  final _userLog = <LogMessage>[];

  void error(
    String message, {
    String? error,
    bool showSnackBar = false,
    bool showDialog = false,
    void Function(dynamic message, [dynamic error, StackTrace? stackTrace])?
        log,
  }) =>
      _log(
        message,
        error: error,
        level: Level.error,
        showSnackBar: showSnackBar,
        showDialog: showDialog,
        log: log,
      );

  void warn(
    String message, {
    String? error,
    bool showSnackBar = false,
    bool showDialog = false,
    void Function(dynamic message, [dynamic error, StackTrace? stackTrace])?
        log,
  }) =>
      _log(
        message,
        error: error,
        level: Level.warning,
        showSnackBar: showSnackBar,
        showDialog: showDialog,
        log: log,
      );

  void info(
    String message, {
    String? error,
    bool showSnackBar = false,
    bool showDialog = false,
    void Function(dynamic message, [dynamic error, StackTrace? stackTrace])?
        log,
  }) =>
      _log(
        message,
        error: error,
        level: Level.info,
        showSnackBar: showSnackBar,
        showDialog: showDialog,
        log: log,
      );

  void log(
    String message, {
    String? error,
    bool showSnackBar = false,
    bool showDialog = false,
    void Function(dynamic message, [dynamic error, StackTrace? stackTrace])?
        log,
  }) =>
      _log(
        message,
        error: error,
        level: Level.debug,
        showSnackBar: showSnackBar,
        showDialog: showDialog,
        log: log,
      );

  void _log(
    String message, {
    Level level = Level.info,
    String? error,
    bool showSnackBar = false,
    bool showDialog = false,
    void Function(dynamic message, [dynamic error, StackTrace? stackTrace])?
        log,
  }) {
    _userLog.add(LogMessage(message: message, level: level));
    if (showSnackBar) {
      snackBar(message, level: level);
    } else if (showDialog) {
      dialog(message, level: level);
    }

    if (log != null) {
      log(message, error, null);
    }

    notifyListeners();
  }

  void snackBar(
    dynamic message, {
    Level level = Level.info,
  }) {
    ref.read(snackBarKey).currentState?.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: levelColors[level],
          ),
        );
  }

  void dialog(
    dynamic message, {
    Level level = Level.info,
  }) {
    final context = ref.read(snackBarKey).currentContext;
    if (context != null) {
      showDialog(
        barrierColor: level == Level.error
            ? Colors.red
            : level == Level.warning
                ? Colors.orange
                : Colors.blue,
        barrierLabel: level == Level.error
            ? 'Error!'
            : level == Level.warning
                ? 'Warning'
                : 'FYI',
        context: context,
        builder: (_) => AlertDialog(
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  List<LogMessage> getErrors() {
    return _userLog.where((log) => log.level == Level.error).toList();
  }

  List<LogMessage> getAll() {
    return _userLog.where((log) => true).toList();
  }

  void clear() {
    _userLog.clear();
    notifyListeners();
  }
}

class LogMessage {
  final String message;
  final String? error;
  final Level level;

  LogMessage({
    required this.message,
    this.error,
    this.level = Level.info,
  });
}
