/// authRepository.dart — example showing how to wire ApiClient into your
/// existing Authrepository so login saves the token and all calls go through
/// the global 400-interceptor.
///
/// Merge this into your real authRepository.dart.
/// Only the relevant additions are shown — keep the rest of your existing code.

import 'package:baltra/core/utils/apiclient.dart';
import 'package:get/get.dart';
import 'sessionController.dart';

class Authrepository extends GetxService {
  // ── Use ApiClient instead of raw GetConnect or http ──────────────────────
  final ApiClient _client = ApiClient();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  /// Login — on success, save the token so ApiClient can attach it later.
  Future<int> loginUser(int phone, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _client.post(
        '/login', // relative to base URL set in ApiClient
        {'phone': phone, 'password': password},
      );

      if (response.statusCode == 200) {
        // ── Extract token from response and persist it ──────────────────
        final token =
            response.body?['token'] as String?; // adjust key to match your API
        final session = Get.find<SessionController>();
        await session.setLoggedIn(token: token);
        return 200;
      } else {
        errorMessage.value = response.body?['message'] ?? 'Login failed';
        // 400/401/403 are already intercepted by ApiClient → auto-logout
        return response.statusCode ?? 0;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      return 0;
    } finally {
      isLoading.value = false;
    }
  }

  /// Registration — no token needed; just call the endpoint.
  Future<int> registerCustomer(
    String firstName,
    String lastName,
    String email,
    String password,
    int phone, {
    String? gender,
    String? customerAddress,
    String? city,
    String? district,
    String? dob,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _client.post('/register', {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'phone': phone,
        if (gender != null) 'gender': gender,
        if (customerAddress != null) 'address': customerAddress,
        if (city != null) 'city': city,
        if (district != null) 'district': district,
        if (dob != null) 'dob': dob,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.body?['token'] as String?;
        final session = Get.find<SessionController>();
        await session.setLoggedIn(token: token);
        return 200;
      } else {
        errorMessage.value = response.body?['message'] ?? 'Registration failed';
        return response.statusCode ?? 0;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      return 0;
    } finally {
      isLoading.value = false;
    }
  }
}
