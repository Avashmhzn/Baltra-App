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
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        title: Row(
          children: [
            Icon(Icons.lock, color: Colors.red),
            SizedBox(width: 8),
            Text('Session Expired', style: TextStyle(fontSize: 20)),
          ],
        ),
        content: Text(
          'Your session has expired. Please log in again.',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
            ),
            onPressed: () {
              Get.offAll(() => const Loginpage());
            },
            child: Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
