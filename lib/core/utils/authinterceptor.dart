import 'package:get/get.dart';
import 'sessionController.dart';

/// A GetConnect interceptor that watches every API response.
/// If a 400, 401, or 403 comes back, it immediately logs the user out
/// and redirects to the login screen — no matter which part of the app
/// made the request.
class AuthInterceptor extends GetConnect {
  @override
  void onInit() {
    // Attach response interceptor
    httpClient.addResponseModifier<dynamic>((request, response) async {
      if (_isAuthFailure(response.statusCode)) {
        await _handleAuthFailure();
      }
      return response;
    });

    super.onInit();
  }

  bool _isAuthFailure(int? statusCode) {
    return statusCode == 400 || statusCode == 401 || statusCode == 403;
  }

  Future<void> _handleAuthFailure() async {
    // Guard: only act if we're currently logged in to avoid looping
    try {
      final sessionController = Get.find<SessionController>();
      if (!sessionController.isLoggedIn.value) return;

      await sessionController.setLoggedOut();
    } catch (_) {
      // SessionController not registered yet — nothing to do
    }

    // Navigate to login, clearing the entire stack
    // Using Get.offAllNamed avoids importing the login page here directly.
    if (Get.currentRoute != '/login') {
      Get.offAllNamed('/login', arguments: {'reason': 'session_expired'});
    }
  }
}
