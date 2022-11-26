import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'user_log.dart';

class UserLogView extends ConsumerWidget {
  const UserLogView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(UserLog.provider).getAll();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index].message;
            final color = UserLog.levelColors[messages[index].level];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                softWrap: true,
                message,
                style: TextStyle(color: color),
              ),
            );
          },
        ),
      ),
    );
  }
}
