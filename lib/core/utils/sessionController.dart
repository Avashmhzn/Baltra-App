// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SessionController extends GetxController {
//   static const String KEY_LOGIN_TIME = 'login_time';
//   static const int SESSION_DURATION = 7 * 24 * 60 * 60; // 1 week in seconds

//   RxBool isLoggedIn = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     checkLoginStatus();
//   }

//   Future<void> setLoggedIn() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt(KEY_LOGIN_TIME, DateTime.now().millisecondsSinceEpoch);
//     isLoggedIn.value = true;
//   }

//   Future<void> setLoggedOut() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(KEY_LOGIN_TIME);
//     prefs.clear();
//     isLoggedIn.value = false;
//   }

//   Future<void> checkLoginStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     final loginTime = prefs.getInt(KEY_LOGIN_TIME);
//     if (loginTime != null) {
//       final currentTime = DateTime.now().millisecondsSinceEpoch;
//       final elapsedTime =
//           (currentTime - loginTime) ~/ 1000; // Convert to seconds
//       isLoggedIn.value = elapsedTime < SESSION_DURATION;
//     } else {
//       isLoggedIn.value = false;
//     }
//   }

//   bool get isSessionExpired => !isLoggedIn.value;
// }

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class SessionController extends GetxController {
  static const String KEY_LOGIN_TIME = 'login_time';
  static const String KEY_SAVED_ENDPOINT = 'saved_endpoint';
  static const String KEY_AUTH_TOKEN = 'auth_token';
  static const int SESSION_DURATION = 7 * 24 * 60 * 60; // 1 week in seconds

  RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  /// Called after a successful login.
  /// Saves the login timestamp, current endpoint, and token.
  Future<void> setLoggedIn({String? token}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(KEY_LOGIN_TIME, DateTime.now().millisecondsSinceEpoch);
    await prefs.setString(KEY_SAVED_ENDPOINT, URL); // snapshot current endpoint
    if (token != null) {
      await prefs.setString(KEY_AUTH_TOKEN, token);
    }
    isLoggedIn.value = true;
  }

  /// Full logout: clears all session data and navigates to login.
  Future<void> setLoggedOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(KEY_LOGIN_TIME);
    await prefs.remove(KEY_SAVED_ENDPOINT);
    await prefs.remove(KEY_AUTH_TOKEN);
    await prefs.clear();
    isLoggedIn.value = false;
  }

  /// Checks on app start whether the session is still valid.
  /// Logs out if:
  ///   1. No login timestamp found
  ///   2. Session is older than SESSION_DURATION
  ///   3. The saved endpoint differs from the current URL constant
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTime = prefs.getInt(KEY_LOGIN_TIME);
    final savedEndpoint = prefs.getString(KEY_SAVED_ENDPOINT);

    if (loginTime == null) {
      isLoggedIn.value = false;
      return;
    }

    // Check if endpoint has changed since last login
    if (savedEndpoint != null && savedEndpoint != URL) {
      // Endpoint changed (e.g. local → live) — old token is useless
      await setLoggedOut();
      return;
    }

    // Check session age
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final elapsedSeconds = (currentTime - loginTime) ~/ 1000;
    isLoggedIn.value = elapsedSeconds < SESSION_DURATION;

    if (!isLoggedIn.value) {
      // Session expired — clean up stored data
      await setLoggedOut();
    }
  }

  bool get isSessionExpired => !isLoggedIn.value;

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_AUTH_TOKEN);
  }
}
