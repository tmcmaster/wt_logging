import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

class UserLog extends ChangeNotifier {
  static final provider = ChangeNotifierProvider(
    name: 'user_log',
    (ref) => UserLog._(ref),
  );

  static final snackBarKey = Provider<GlobalKey<ScaffoldMessengerState>>(
      (ref) => throw Exception('UserLog.snackBarKey provider needs to be overriden'));

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

  void error(String message, {String? error, bool snackBar = false}) =>
      _log(message, error: error, level: Level.error, snackBar: snackBar);

  void warn(String message, {String? error, bool snackBar = false}) =>
      _log(message, error: error, level: Level.warning, snackBar: snackBar);

  void info(String message, {String? error, bool snackBar = false}) =>
      _log(message, error: error, level: Level.info, snackBar: snackBar);

  void log(String message, {String? error, bool snackBar = false}) =>
      _log(message, error: error, level: Level.debug, snackBar: snackBar);

  void _log(String message, {Level level = Level.info, String? error, bool snackBar = false}) {
    _userLog.add(LogMessage(message: message, level: level));
    if (snackBar) {
      ref.read(snackBarKey).currentState?.showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: levelColors[level],
            ),
          );
    }

    notifyListeners();
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
