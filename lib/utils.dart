import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

void showSnackBar({
  required String message,
  required BuildContext context,
  bool isError = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      backgroundColor: isError ? Colors.red : const Color(0xFF1F1F1F),
    ),
  );
}

void redirect({
  required String to,
  required BuildContext context,
  Object? arguments,
}) async {
  if (!to.contains("login")) {
    var sessionManager = SessionManager();
    if (await sessionManager.get("session") == null) {
      // ignore: use_build_context_synchronously
      showSnackBar(
        message: "Login terlebih dahulu",
        context: context,
        isError: true,
      );
      // ignore: use_build_context_synchronously
      Navigator.of(context).popAndPushNamed("/login");
      return;
    }
  }
  // ignore: use_build_context_synchronously
  Navigator.of(context).popAndPushNamed(to, arguments: arguments);
}
