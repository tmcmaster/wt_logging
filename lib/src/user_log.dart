import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wt_logging/src/logging.dart';
import 'package:wt_logging/src/user_log_store.dart';

typedef LogFunction = void Function(
  dynamic message, {
  DateTime? time,
  Object? error,
  StackTrace? stackTrace,
});

class UserLog extends ChangeNotifier {
  static final consoleLog = logger(UserLog, level: Level.debug);

  static final provider = ChangeNotifierProvider(
    name: 'UserLog',
    (ref) => UserLog._(ref),
  );

  static const levelColors = {
    Level.trace: Colors.purple,
    Level.error: Colors.red,
    Level.warning: Colors.orange,
    Level.info: Colors.green,
    Level.debug: Colors.blue,
    Level.verbose: Colors.yellow,
    Level.nothing: Colors.grey,
  };

  static bool _appDetailsLogged = false;

  static void logAppDetails(WidgetRef ref) async {
    if (!_appDetailsLogged) {
      _appDetailsLogged = true;
      final userLog = ref.read(UserLog.provider);
      final info = await PackageInfo.fromPlatform();
      const releaseMode = kReleaseMode;
      final logsDirectory = await getApplicationDocumentsDirectory();
      userLog.info('Release Mode: $releaseMode', log: consoleLog.i);
      userLog.info('App Name: ${info.appName}', log: consoleLog.i);
      userLog.info('Package Name: ${info.packageName}', log: consoleLog.i);
      userLog.info('Version: ${info.version}', log: consoleLog.i);
      userLog.info('Build Number: ${info.buildNumber}', log: consoleLog.i);
      userLog.info('Log Level: ${Logger.level}', log: consoleLog.i);
      userLog.info('Logs Dir: $logsDirectory', log: consoleLog.i);
    }
  }

  final Ref ref;

  UserLog._(this.ref);

  final _userLog = <LogMessage>[];

  void error(
    String message, {
    String? error,
    bool showSnackBar = false,
    bool showDialog = false,
    LogFunction? log,
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
    LogFunction? log,
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
    LogFunction? log,
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
    LogFunction? log,
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
    LogFunction? log,
  }) {
    _userLog.add(
      LogMessage(
        message: message,
        error: error,
        level: level,
      ),
    );
    if (showSnackBar) {
      snackBar(message, level: level, error: error);
    } else if (showDialog) {
      dialog(message, level: level, error: error);
    }

    if (log != null) {
      log(message, error: error);
    }

    notifyListeners();
  }

  void snackBar(
    dynamic message, {
    Level level = Level.info,
    String? error,
  }) {
    final context = ref.read(UserLogStore.navigatorKey).currentContext;
    if (context != null) {
      final theme = Theme.of(context);
      const textColor = Colors.white;
      final messageStyle = theme.textTheme.titleMedium?.copyWith(
        color: textColor,
      );
      final errorStyle = theme.textTheme.bodyMedium?.copyWith(
        color: textColor,
      );
      Flushbar(
        backgroundColor: level == Level.error
            ? Colors.red
            : level == Level.warning
                ? Colors.orange
                : Colors.blue,
        messageText: Column(
          children: [
            Text(
              message,
              style: messageStyle,
            ),
            if (error != null)
              Text(
                error,
                style: errorStyle,
              ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ).show(context);
    }
  }

  void dialog(
    dynamic message, {
    Level level = Level.info,
    String? error,
    double? width = double.minPositive,
  }) {
    final context = ref.read(UserLogStore.navigatorKey).currentContext;
    if (context != null) {
      final theme = Theme.of(context);
      showDialog(
        barrierLabel: level == Level.error
            ? 'Error!'
            : level == Level.warning
                ? 'Warning'
                : 'FYI',
        context: context,
        builder: (_) => AlertDialog(
          surfaceTintColor: level == Level.error
              ? Colors.red
              : level == Level.warning
                  ? Colors.yellow
                  : Colors.blue,
          content: SizedBox(
            width: width,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (level == Level.error || level == Level.warning)
                    Text(
                      level == Level.error
                          ? 'Error'
                          : level == Level.warning
                              ? 'Warning'
                              : '',
                      style: theme.textTheme.headlineMedium,
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      message,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        error,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                ],
              ),
            ),
          ),
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
