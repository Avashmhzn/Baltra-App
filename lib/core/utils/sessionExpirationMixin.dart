import 'package:baltra/core/utils/sessionController.dart';
import 'package:baltra/features/authetication/presentation/pages/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

mixin SessionManager {
  void checkSession(BuildContext context) {
    final sessionController = Get.find<SessionController>();

    if (sessionController.isSessionExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSessionExpiredDialog(context);
      });
    }
  }

  void _showSessionExpiredDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (context) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text('Your session has expired. Please log in again.'),
        actions: [
          TextButton(
            onPressed: () {
              Get.offAll(() => const Loginpage());
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
