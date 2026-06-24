// import 'dart:io';

// import 'package:flutter/material.dart';

// void showErrorDialog(BuildContext context, Object error) {
//   String errorMessage = "An unexpected error occurred.";

//   switch (error.runtimeType) {
//     case HttpException:
//       errorMessage =
//           "Sorry, we couldn't retrieve the information you requested.";
//       break;
//     case SocketException:
//       errorMessage =
//           "Our servers are currently unavailable. Please try again later.";
//       break;
//     default:
//       errorMessage =
//           "Oops Something went wrong on our end. We're working on fixing it right away.";
//       break;
//   }

//   showDialog(
//     barrierDismissible: false,
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Text('Error'),
//         content: Text(errorMessage),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('OK'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'sessionController.dart';

/// Shows an error dialog for common network / HTTP errors.
/// If the error is a 400 / 401 / 403, it also logs the user out
/// and redirects to the login screen after dismissal.
void showErrorDialog(BuildContext context, Object error,
    {int? statusCode}) async {
  String errorMessage;
  bool isAuthError = false;

  if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
    isAuthError = true;
    errorMessage =
        'Your session has expired or is no longer valid. Please log in again.';
  } else {
    switch (error.runtimeType) {
      case HttpException:
        errorMessage =
            "Sorry, we couldn't retrieve the information you requested.";
        break;
      case SocketException:
        errorMessage =
            "Our servers are currently unavailable. Please try again later.";
        break;
      default:
        errorMessage =
            "Oops! Something went wrong on our end. We're working on fixing it right away.";
        break;
    }
  }

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(isAuthError ? 'Session Expired' : 'Error'),
        content: Text(errorMessage),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () async {
              Navigator.of(context).pop();
              if (isAuthError) {
                try {
                  final session = Get.find<SessionController>();
                  await session.setLoggedOut();
                } catch (_) {}
                Get.offAllNamed('/login',
                    arguments: {'reason': 'session_expired'});
              }
            },
          ),
        ],
      );
    },
  );
}
