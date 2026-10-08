import 'dart:developer';

import 'package:baltra/core/utils/sessionController.dart';
import 'package:baltra/features/authetication/presentation/pages/loginPage.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/// Call this right after every authenticated API response, across every
/// repository in the app (ProfileController, MyProductRepository,
/// ProductRepository, etc).
///
/// If the response indicates the token is invalid/expired (400/401/403),
/// this logs the user out and redirects to Loginpage — safely, deferred to
/// the next frame so it never races with navigation the user triggers at
/// the same moment (e.g. switching bottom-nav tabs).
///
/// Returns true if an auth failure was detected and handled (caller should
/// stop processing the response as normal data). Returns false if the
/// response was fine and the caller should proceed as usual.
bool _handlingAuthFailure = false;

Future<bool> handleAuthFailureIfAny(http.Response response) async {
  final code = response.statusCode;
  final isAuthFailure = code == 401 || code == 403;

  if (!isAuthFailure) return false;

  log('AuthGuard: detected auth failure (status $code), logging out');

  if (_handlingAuthFailure) {
    return true;
  }
  _handlingAuthFailure = true;

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      final sessionController = Get.find<SessionController>();
      sessionController.showSessionExpiredDialog();
    } catch (_) {
      if (Get.currentRoute != '/Loginpage') {
        Get.offAll(() => const Loginpage());
      }
    }
    _handlingAuthFailure = false;
  });

  return true;
}
