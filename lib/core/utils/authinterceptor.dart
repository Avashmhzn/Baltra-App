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
    try {
      final sessionController = Get.find<SessionController>();
      sessionController.showSessionExpiredDialog();
    } catch (_) {
      // Fallback
      if (Get.currentRoute != '/login' && Get.currentRoute != '/Loginpage') {
        Get.offAllNamed('/login', arguments: {'reason': 'session_expired'});
      }
    }
  }
}
