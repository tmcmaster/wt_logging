import 'package:logger/logger.dart';

export 'package:logger/logger.dart';

Logger logger(Type type, {Level level = Level.warning}) => Logger(
      printer: CustomerColorPrinter(type.toString()),
      level: level,
    );

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
    final AnsiColor color = PrettyPrinter.levelColors[event.level] ?? AnsiColor.none();
    final emoji = PrettyPrinter.levelEmojis[event.level];
    final message = event.message;
    return [color('$emoji : $className : $message')];
  }
}
