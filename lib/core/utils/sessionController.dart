import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionController extends GetxController {
  static const String KEY_LOGIN_TIME = 'login_time';
  static const int SESSION_DURATION = 8 * 60 * 60; // 8 hours in seconds

  RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> setLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(KEY_LOGIN_TIME, DateTime.now().millisecondsSinceEpoch);
    isLoggedIn.value = true;
  }

  Future<void> setLoggedOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(KEY_LOGIN_TIME);
    prefs.clear();
    isLoggedIn.value = false;
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTime = prefs.getInt(KEY_LOGIN_TIME);
    if (loginTime != null) {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final elapsedTime =
          (currentTime - loginTime) ~/ 1000; // Convert to seconds
      isLoggedIn.value = elapsedTime < SESSION_DURATION;
    } else {
      isLoggedIn.value = false;
    }
  }

  bool get isSessionExpired => !isLoggedIn.value;
}
