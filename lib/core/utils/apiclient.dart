import 'package:get/get.dart';
import 'constants.dart';
import 'sessionController.dart';

/// Base API client.
/// Every data-layer repository should use this instead of raw GetConnect or http.
/// It automatically:
///   - Attaches the auth token to every request
///   - Intercepts 400 / 401 / 403 and calls logout + redirect to login
class ApiClient extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = URL;
    httpClient.timeout = const Duration(seconds: 30);

    // ── Attach auth token to outgoing requests ──────────────────────────────
    httpClient.addRequestModifier<dynamic>((request) async {
      try {
        final sessionController = Get.find<SessionController>();
        final token = await sessionController.getToken();
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      } catch (_) {
        // SessionController not yet ready; proceed without token
      }
      return request;
    });

    // ── Intercept every response ─────────────────────────────────────────────
    httpClient.addResponseModifier<dynamic>((request, response) async {
      final code = response.statusCode;
      if (code == 400 || code == 401 || code == 403) {
        await _handleAuthFailure();
      }
      return response;
    });

    super.onInit();
  }

  Future<void> _handleAuthFailure() async {
    try {
      final sessionController = Get.find<SessionController>();
      if (!sessionController.isLoggedIn.value) return; // already logged out
      await sessionController.setLoggedOut();
    } catch (_) {}

    if (Get.currentRoute != '/login') {
      Get.offAllNamed('/login', arguments: {'reason': 'session_expired'});
    }
  }
}
