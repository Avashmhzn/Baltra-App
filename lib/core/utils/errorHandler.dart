import 'dart:io';

import 'package:flutter/material.dart';

void showErrorDialog(BuildContext context, Object error) {
  String errorMessage = "An unexpected error occurred.";

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
          "Oops Something went wrong on our end. We're working on fixing it right away.";
      break;
  }

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Error'),
        content: Text(errorMessage),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
