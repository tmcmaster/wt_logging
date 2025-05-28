typedef LogFunction = void Function(
  dynamic message, {
  DateTime? time,
  Object? error,
  StackTrace? stackTrace,
});
