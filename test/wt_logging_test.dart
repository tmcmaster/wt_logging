import 'package:flutter_test/flutter_test.dart';
import 'package:wt_logging/src/logging.dart';

void main() {
  test('Placeholder Test', () {
    Example1();
  });
}

class Example1 {
  static final log = logger(Example1, level: Level.debug);

  Example1() {
    log.d('Creating instance of the Example1 class');
  }
}
