import 'package:logger/logger.dart';

export 'package:logger/logger.dart';

Logger logger(dynamic prefix, {Level? level}) {
  if (prefix is String || prefix is Type) {
    return Logger(
      printer: CustomerColorPrinter(prefix.toString()),
      level: level ?? Level.warning,
    );
  } else {
    throw Exception('Logging prefix can only be a String or a Type');
  }
}

class CustomerPlainPrinter extends LogPrinter {
  final String className;

  CustomerPlainPrinter(this.className);

  @override
  List<String> log(LogEvent event) {
    return ['${event.level.name} : $className: ${event.message}'];
  }
}

class CustomerColorPrinter extends LogPrinter {
  final String className;

  CustomerColorPrinter(this.className);

  @override
  List<String> log(LogEvent event) {
    final AnsiColor color =
        PrettyPrinter.defaultLevelColors[event.level] ?? AnsiColor.none();
    final emoji = PrettyPrinter.defaultLevelEmojis[event.level];
    final message = event.message;
    return [color('$emoji : $className : $message')];
  }
}
