import 'dart:convert';
import 'dart:developer';

import 'package:baltra/core/utils/constants.dart';
import 'package:baltra/features/authetication/models/user.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  final Rx<User?> userData = Rx<User?>(null);
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      error('User is not authenticated');
      return;
    }

    log('Fetching user data with token: $token');
    try {
      isLoading.value = true;
      final response =
          await http.get(Uri.parse('$URL/customer/getprofiledata'), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        log(response.body);
        final dynamic data = json.decode(response.body);

        final dynamic userResponseData = data['data'];

        User user = User.fromJson(userResponseData);

        userData(user);
      } else {
        error('Failed to load user data');
      }
    } catch (e) {
      error('An error occurred: $e');
    } finally {
      isLoading(false);
    }
  }
}
