// import 'package:baltra/core/utils/sessionController.dart';
// import 'package:baltra/features/authetication/presentation/pages/loginPage.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// mixin SessionManager {
//   void checkSession(BuildContext context) {
//     final sessionController = Get.find<SessionController>();

//     if (sessionController.isSessionExpired) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _showSessionExpiredDialog(context);
//       });
//     }
//   }

//   void _showSessionExpiredDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         // Schedule automatic dialog dismissal and navigation after 8 seconds
//         Future.delayed(const Duration(seconds: 8), () {
//           if (Navigator.canPop(context)) {
//             Navigator.of(context).pop(); // Close the dialog
//             Get.offAll(() => const Loginpage()); // Navigate to login page
//           }
//         });

//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.0),
//           ),
//           title: Row(
//             children: [
//               Icon(Icons.lock, color: Colors.red),
//               SizedBox(width: 8),
//               Text('Session Expired', style: TextStyle(fontSize: 20)),
//             ],
//           ),
//           content: Text(
//             'Your session has expired. Please log in again.',
//             style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//           ),
//           actions: [
//             TextButton(
//               style: TextButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8.0)),
//               ),
//               onPressed: () {
//                 Get.offAll(() => const Loginpage());
//               },
//               child: Text('OK', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

import 'package:baltra/core/utils/sessionController.dart';
import 'package:baltra/features/authetication/presentation/pages/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Mix this into any StatefulWidget State that needs session protection.
///
/// Usage:
///   class _MyPageState extends State<MyPage> with SessionManager { ... }
///
/// Call checkSession(context) inside initState or build, e.g.:
///   @override
///   void initState() {
///     super.initState();
///     WidgetsBinding.instance.addPostFrameCallback((_) => checkSession(context));
///   }
mixin SessionManager {
  void checkSession(BuildContext context) {
    try {
      final sessionController = Get.find<SessionController>();
      if (sessionController.isSessionExpired) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSessionExpiredDialog(context);
        });
      }
    } catch (_) {
      // SessionController not registered — skip
    }
  }

  void _showSessionExpiredDialog(BuildContext context) {
    // Prevent duplicate dialogs
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        // Auto-redirect after 8 s if user doesn't tap OK
        Future.delayed(const Duration(seconds: 8), () {
          if (dialogContext.mounted && Navigator.canPop(dialogContext)) {
            Navigator.of(dialogContext).pop();
          }
          _navigateToLogin();
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: const Row(
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
                if (Navigator.canPop(dialogContext)) {
                  Navigator.of(dialogContext).pop();
                }
                _navigateToLogin();
              },
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _navigateToLogin() {
    Get.offAll(() => const Loginpage());
  }
}
