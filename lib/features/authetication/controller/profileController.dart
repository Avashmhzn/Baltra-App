// import 'dart:convert';
// import 'dart:developer';

// import 'package:baltra/core/utils/constants.dart';
// import 'package:baltra/features/authetication/models/user.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class ProfileController extends GetxController {
//   final Rx<User?> userData = Rx<User?>(null);
//   final RxBool isLoading = true.obs;
//   final RxString error = ''.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchUserData();
//   }

//   Future<void> fetchUserData() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final String? token = prefs.getString('auth_token');
//     if (token == null || token.isEmpty) {
//       error('User is not authenticated');
//       return;
//     }

//     log('Fetching user data with token: $token');
//     try {
//       isLoading.value = true;
//       final response =
//           await http.get(Uri.parse('$URL/customer/getprofiledata'), headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       });

//       if (response.statusCode == 200) {
//         log(response.body);
//         final dynamic data = json.decode(response.body);

//         final dynamic userResponseData = data['data'];

//         User user = User.fromJson(userResponseData);

//         userData(user);
//       } else {
//         error('Failed to load user data');
//       }
//     } catch (e) {
//       error('An error occurred: $e');
//     } finally {
//       isLoading(false);
//     }
//   }
// }
import 'dart:convert';
import 'dart:developer';

import 'package:baltra/core/utils/constants.dart';
import 'package:baltra/core/utils/sessionController.dart';
import 'package:baltra/features/authetication/models/user.dart';
import 'package:baltra/features/authetication/presentation/pages/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ProfileController extends GetxController {
  final Rx<User?> userData = Rx<User?>(null);
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  // ✅ Guard so we never trigger logout/navigation more than once,
  // even if this fires twice in quick succession.
  bool _loggingOut = false;

  @override
  void onInit() {
    super.onInit();
    log('ProfileController: onInit called');
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final sessionController = Get.find<SessionController>();
    final String? token = await sessionController.getToken();

    if (token == null || token.isEmpty) {
      error.value = 'User is not authenticated';
      log('ProfileController: No token found, redirecting to login');
      isLoading(false);
      _logoutAndRedirect(sessionController, showSnackbar: false);
      return;
    }

    log('ProfileController: Fetching user data with token: $token');
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse('$URL/customer/getprofiledata'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      log('ProfileController: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        log('ProfileController: Response data: $data');
        final dynamic userResponseData = data['data'];
        User user = User.fromJson(userResponseData);
        userData(user);
        log('ProfileController: User data loaded: ${user.toString()}');
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403) {
        log('ProfileController: Auth failure (${response.statusCode}), logging out');
        error.value = 'Session expired';
        _logoutAndRedirect(sessionController, showSnackbar: true);
      } else {
        error.value = 'Failed to load user data: ${response.statusCode}';
        log('ProfileController: Failed to load user data, status: ${response.statusCode}');
      }
    } catch (e) {
      error.value = 'An error occurred: $e';
      log('ProfileController: Error fetching user data: $e');
    } finally {
      isLoading(false);
    }
  }

  /// ✅ Defers the actual logout + navigation to the next frame, so it never
  /// collides with a Navigator/GetX operation the user is doing right now
  /// (e.g. switching bottom-nav tabs at the exact moment the token expires).
  /// This is what prevents the native crash we saw earlier.
  void _logoutAndRedirect(
    SessionController sessionController, {
    required bool showSnackbar,
  }) {
    if (_loggingOut) return; // already in progress, don't fire twice
    _loggingOut = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await sessionController.setLoggedOut();

      if (Get.currentRoute != '/Loginpage') {
        Get.offAll(() => const Loginpage());
      }

      if (showSnackbar) {
        Get.snackbar(
          'Session Expired',
          'Please log in again',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

      _loggingOut = false;
    });
  }
}
