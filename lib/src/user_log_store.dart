import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

mixin UserLogStore {
  static final navigatorKey =
      StateNotifierProvider<UserLogNavigatorKey, GlobalKey<NavigatorState>>(
    name: 'UserLogStore.navigatorKey',
    (ref) => UserLogNavigatorKey(),
  );
  static final snackBarKey = StateNotifierProvider<UserLogSnackBarKey,
      GlobalKey<ScaffoldMessengerState>>(
    name: 'UserLogStore.snackBarKey',
    (ref) => UserLogSnackBarKey(),
  );
}

class UserLogNavigatorKey extends StateNotifier<GlobalKey<NavigatorState>> {
  UserLogNavigatorKey() : super(GlobalKey<NavigatorState>());
  GlobalKey<NavigatorState> generateNewKey() {
    final newKey = GlobalKey<NavigatorState>();
    Future.delayed(const Duration(microseconds: 1), () {
      state = newKey;
    });
    return newKey;
  }
}

class UserLogSnackBarKey
    extends StateNotifier<GlobalKey<ScaffoldMessengerState>> {
  UserLogSnackBarKey() : super(GlobalKey<ScaffoldMessengerState>());
  GlobalKey<ScaffoldMessengerState> generateNewKey() {
    final newKey = GlobalKey<ScaffoldMessengerState>();
    Future.delayed(const Duration(microseconds: 1), () {
      state = newKey;
    });
    return newKey;
  }
}
