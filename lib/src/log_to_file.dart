import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:wt_logging/wt_logging.dart';

class LogToFile extends LogOutput {
  static final log = logger(LogToFile);
  static LogToFile? _instance;
  static Future<void> initialise() async {
    if (_instance == null) {
      _instance = LogToFile._();
      await _instance!._init();
      Logger.defaultOutput = () => _instance!;
    } else {
      log.w('Logging to file has already been initialised');
    }
  }

  late final File _logFile;
  late final IOSink _sink;

  LogToFile._() {
    print('Creating global log to file logger.');
  }

  Future<void> _init() async {
    final dir = await getApplicationDocumentsDirectory();
    _logFile = File('${dir.path}/app.log');

    print('Log file: ${_logFile.absolute}');
    // Make sure the file exists
    if (!(await _logFile.exists())) {
      await _logFile.create(recursive: true);
    }

    _sink = _logFile.openWrite(mode: FileMode.append);
  }

  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      _sink.writeln(line);
      print('LOGGING: $line'); // Optional: Also log to console
    }
  }

  Future<void> dispose() async {
    await _sink.flush();
    await _sink.close();
  }
}
