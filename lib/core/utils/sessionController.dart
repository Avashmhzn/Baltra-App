// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'constants.dart';

// class SessionController extends GetxController {
//   static const String KEY_LOGIN_TIME = 'login_time';
//   static const String KEY_SAVED_ENDPOINT = 'saved_endpoint';
//   static const String KEY_AUTH_TOKEN = 'auth_token';
//   static const int SESSION_DURATION = 7 * 24 * 60 * 60; // 1 week in seconds

//   RxBool isLoggedIn = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     checkLoginStatus();
//   }

//   /// Called after a successful login.
//   /// Saves the login timestamp, current endpoint, and token.
//   Future<void> setLoggedIn({String? token}) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt(KEY_LOGIN_TIME, DateTime.now().millisecondsSinceEpoch);
//     await prefs.setString(KEY_SAVED_ENDPOINT, URL); // snapshot current endpoint
//     if (token != null) {
//       await prefs.setString(KEY_AUTH_TOKEN, token);
//     }
//     isLoggedIn.value = true;
//   }

//   /// Full logout: clears all session data and navigates to login.
//   Future<void> setLoggedOut() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(KEY_LOGIN_TIME);
//     await prefs.remove(KEY_SAVED_ENDPOINT);
//     await prefs.remove(KEY_AUTH_TOKEN);
//     await prefs.clear();
//     isLoggedIn.value = false;
//   }

//   /// Checks on app start whether the session is still valid.
//   /// Logs out if:
//   ///   1. No login timestamp found
//   ///   2. Session is older than SESSION_DURATION
//   ///   3. The saved endpoint differs from the current URL constant
//   Future<void> checkLoginStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     final loginTime = prefs.getInt(KEY_LOGIN_TIME);
//     final savedEndpoint = prefs.getString(KEY_SAVED_ENDPOINT);

//     if (loginTime == null) {
//       isLoggedIn.value = false;
//       return;
//     }

//     // Check if endpoint has changed since last login
//     if (savedEndpoint != null && savedEndpoint != URL) {
//       // Endpoint changed (e.g. local → live) — old token is useless
//       await setLoggedOut();
//       return;
//     }

//     // Check session age
//     final currentTime = DateTime.now().millisecondsSinceEpoch;
//     final elapsedSeconds = (currentTime - loginTime) ~/ 1000;
//     isLoggedIn.value = elapsedSeconds < SESSION_DURATION;

//     if (!isLoggedIn.value) {
//       // Session expired — clean up stored data
//       await setLoggedOut();
//     }
//   }

//   bool get isSessionExpired => !isLoggedIn.value;

//   Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(KEY_AUTH_TOKEN);
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'package:baltra/features/authetication/presentation/pages/loginPage.dart';

class SessionController extends GetxController {
  static const String KEY_LOGIN_TIME = 'login_time';
  static const String KEY_SAVED_ENDPOINT = 'saved_endpoint';
  static const String KEY_AUTH_TOKEN = 'auth_token';

  static const int SESSION_DURATION = 8 * 60 * 60; // 8 hours in seconds

  // static const int SESSION_DURATION = 10 * 60; // 10 minutes for testing

  RxBool isLoggedIn = false.obs;
  int? _loginTimeMemory;
  bool _dialogShowing = false;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  /// Called after successful login
  Future<void> setLoggedIn({String? token}) async {
    final prefs = await SharedPreferences.getInstance();

    final now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(KEY_LOGIN_TIME, now);
    _loginTimeMemory = now;
    await prefs.setString(KEY_SAVED_ENDPOINT, URL);

    if (token != null) {
      await prefs.setString(KEY_AUTH_TOKEN, token);
    }

    isLoggedIn.value = true;
  }

  /// Full logout
  Future<void> setLoggedOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(KEY_LOGIN_TIME);
    await prefs.remove(KEY_SAVED_ENDPOINT);
    await prefs.remove(KEY_AUTH_TOKEN);
    _loginTimeMemory = null;
    isLoggedIn.value = false;
  }

  /// Check login status on app start
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTime = prefs.getInt(KEY_LOGIN_TIME);
    final savedEndpoint = prefs.getString(KEY_SAVED_ENDPOINT);
    _loginTimeMemory = loginTime;

    if (loginTime == null) {
      isLoggedIn.value = false;
      return;
    }

    // Endpoint changed (e.g. dev → prod)
    if (savedEndpoint != null && savedEndpoint != URL) {
      await setLoggedOut();
      return;
    }

    // Check if session is still valid
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final elapsedSeconds = (currentTime - loginTime) ~/ 1000;

    final isValid = elapsedSeconds < SESSION_DURATION;

    if (isValid) {
      isLoggedIn.value = true;
    } else {
      await setLoggedOut();
    }
  }

  bool get isSessionExpired {
    if (!isLoggedIn.value) return true;
    if (_loginTimeMemory == null) return true;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final elapsedSeconds = (currentTime - _loginTimeMemory!) ~/ 1000;
    return elapsedSeconds >= SESSION_DURATION;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_AUTH_TOKEN);
  }

  void showSessionExpiredDialog() {
    if (_dialogShowing) return;
    _dialogShowing = true;

    // Log out first to clear session
    setLoggedOut();

    // Show the expiration dialog using Get.dialog
    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
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
          content: const Text(
            'Your session has expired. Please log in again.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
              onPressed: () {
                _dialogShowing = false;
                if (Get.isDialogOpen ?? false) {
                  Get.back(); // Close dialog
                }
                Get.offAll(() => const Loginpage());
              },
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}
