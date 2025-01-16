import 'package:baltra/core/utils/sessionController.dart';
import 'package:baltra/features/authetication/presentation/pages/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

mixin SessionManager {
  void checkSession(BuildContext context) {
    final sessionController = Get.find<SessionController>();
    if (sessionController.isSessionExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSessionExpiredDialog(context);
      });
    }
  }

  void showSessionExpiredDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Session Expired'),
          content: const Text(
              'Your session has expired. Please log in again to continue.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const Loginpage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
