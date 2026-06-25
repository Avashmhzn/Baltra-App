// /// authRepository.dart — example showing how to wire ApiClient into your
// /// existing Authrepository so login saves the token and all calls go through
// /// the global 400-interceptor.
// ///
// /// Merge this into your real authRepository.dart.
// /// Only the relevant additions are shown — keep the rest of your existing code.

// import 'package:baltra/core/utils/apiclient.dart';
// import 'package:get/get.dart';
// import 'sessionController.dart';

// class Authrepository extends GetxService {
//   // ── Use ApiClient instead of raw GetConnect or http ──────────────────────
//   final ApiClient _client = ApiClient();

//   final RxBool isLoading = false.obs;
//   final RxString errorMessage = ''.obs;

//   /// Login — on success, save the token so ApiClient can attach it later.
//   Future<int> loginUser(int phone, String password) async {
//     isLoading.value = true;
//     errorMessage.value = '';
//     try {
//       final response = await _client.post(
//         '/login', // relative to base URL set in ApiClient
//         {'phone': phone, 'password': password},
//       );

//       if (response.statusCode == 200) {
//         // ── Extract token from response and persist it ──────────────────
//         final token =
//             response.body?['token'] as String?; // adjust key to match your API
//         final session = Get.find<SessionController>();
//         await session.setLoggedIn(token: token);
//         return 200;
//       } else {
//         errorMessage.value = response.body?['message'] ?? 'Login failed';
//         // 400/401/403 are already intercepted by ApiClient → auto-logout
//         return response.statusCode ?? 0;
//       }
//     } catch (e) {
//       errorMessage.value = e.toString();
//       return 0;
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// Registration — no token needed; just call the endpoint.
//   Future<int> registerCustomer(
//     String firstName,
//     String lastName,
//     String email,
//     String password,
//     int phone, {
//     String? gender,
//     String? customerAddress,
//     String? city,
//     String? district,
//     String? dob,
//   }) async {
//     isLoading.value = true;
//     errorMessage.value = '';
//     try {
//       final response = await _client.post('/register', {
//         'first_name': firstName,
//         'last_name': lastName,
//         'email': email,
//         'password': password,
//         'phone': phone,
//         if (gender != null) 'gender': gender,
//         if (customerAddress != null) 'address': customerAddress,
//         if (city != null) 'city': city,
//         if (district != null) 'district': district,
//         if (dob != null) 'dob': dob,
//       });

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final token = response.body?['token'] as String?;
//         final session = Get.find<SessionController>();
//         await session.setLoggedIn(token: token);
//         return 200;
//       } else {
//         errorMessage.value = response.body?['message'] ?? 'Registration failed';
//         return response.statusCode ?? 0;
//       }
//     } catch (e) {
//       errorMessage.value = e.toString();
//       return 0;
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:baltra/core/utils/apiclient.dart';
import 'package:baltra/core/utils/constants.dart';
import 'package:baltra/core/utils/sessionController.dart';
import 'package:baltra/features/authetication/models/user.dart';
import 'package:baltra/features/authetication/presentation/pages/otp_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Authrepository extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // ✅ FIXED: this is now a real field, not an empty setter.
  // loginPage.dart sets this BEFORE calling loginUser().
  bool rememberMe = true;

  // Used only for endpoints not yet migrated to ApiClient (OTP flows, etc.)
  // New code should prefer ApiClient, which auto-attaches the token and
  // auto-handles 400/401/403 centrally.
  final ApiClient _client = ApiClient();

  Future<void> requestOTP(int number) async {
    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse('$URL/customer/requestotp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, int>{'contact': number}),
      );
      log("****************");
      log(response.body);
      log("****************");

      final dynamic responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final bool isVerified = responseData['data']['is_verified'] ?? false;

        if (isVerified) {
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ??
                  'Contact number is already verified.'),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          Get.to(() => OtpPage(phone: number, reset: false));
        }
      } else {
        errorMessage.value =
            responseData['message'] ?? 'Failed to process request';
      }
    } on SocketException catch (_) {
      errorMessage.value = 'No internet connection';
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<int> verifyOTP(int number, int otp) async {
    try {
      final response = await http
          .post(
            Uri.parse('$URL/customer/verifyotp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(<String, dynamic>{'contact': number, 'otp': otp}),
          )
          .timeout(const Duration(seconds: 10));

      log("Verify OTP Response: ${response.body}");

      dynamic data;
      try {
        data = json.decode(response.body);
      } catch (_) {
        errorMessage.value = 'Invalid response from server';
        return -1;
      }

      if (response.statusCode == 200) {
        return response.statusCode;
      } else {
        errorMessage.value =
            'Failed to login: ${data['message'] ?? "Unknown error"}';
        return response.statusCode;
      }
    } on SocketException {
      errorMessage.value = 'No internet connection';
      return -1;
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      return -1;
    } finally {
      isLoading.value = false;
    }
  }

  Future<int> registerCustomer(
    String firstname,
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> requestBody = {
        "firstname": firstname,
        "lastname": lastName,
        "email": email,
        "password": password,
        "contact": phone,
      };

      if (gender != null && gender.isNotEmpty) requestBody["gender"] = gender;
      if (customerAddress != null && customerAddress.isNotEmpty) {
        requestBody["customerAddress"] = customerAddress;
      }
      if (city != null && city.isNotEmpty) requestBody["city"] = city;
      if (district != null && district.isNotEmpty) {
        requestBody["district"] = district;
      }
      if (dob != null && dob.isNotEmpty) requestBody["dob"] = dob;

      final response = await http.post(
        Uri.parse('$URL/customer/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      log("Register Request Body: ${jsonEncode(requestBody)}");
      log(response.body);
      log(response.statusCode.toString());

      final dynamic data = json.decode(response.body);
      if (response.statusCode == 200) {
        final String token = data['token'] ?? '';
        final dynamic userResponseData = data['data'];
        User user = User.fromJson(userResponseData);

        log("***************");
        log("reward Points: ${user.reward_points}");
        log("***************");

        final sessionController = Get.find<SessionController>();
        await sessionController.setLoggedIn(token: token);

        await prefs.setString('name', user.firstname);
        await prefs.setInt('reward_points', user.reward_points ?? 0);

        return response.statusCode;
      } else {
        errorMessage.value =
            'Failed to create User: ${data['message'] ?? 'Unknown error'}';
        return response.statusCode;
      }
    } on SocketException catch (_) {
      errorMessage.value = 'No internet connection';
      return -1;
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      return -1;
    } finally {
      isLoading.value = false;
    }
  }

  Future<int> passwordResetOTP(int number) async {
    try {
      final response = await http.post(
        Uri.parse('$URL/customer/requestpasswordreset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, int>{'contact': number}),
      );
      log('request reset Response: ${response.body}');
      final dynamic data = json.decode(response.body);
      if (response.statusCode == 200) {
        return response.statusCode;
      } else {
        errorMessage.value = 'Failed to login: ${data['message']}';
        return response.statusCode;
      }
    } on SocketException catch (_) {
      errorMessage.value = 'No internet connection';
      return -1;
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      return -1;
    } finally {
      isLoading.value = false;
    }
  }

  Future<int> resetverifyOTP(int number, int otp) async {
    try {
      final response = await http.post(
        Uri.parse('$URL/customer/resetverifyotp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{'contact': number, 'otp': otp}),
      );

      log('resetOTP Response: ${response.body}');

      final dynamic data = json.decode(response.body);
      if (response.statusCode == 200) {
        return response.statusCode;
      } else {
        errorMessage.value = 'Failed to login: ${data['message']}';
        return response.statusCode;
      }
    } on SocketException catch (_) {
      errorMessage.value = 'No internet connection';
      return -1;
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      return -1;
    } finally {
      isLoading.value = false;
    }
  }

  Future<int> resetpassword(
      int number, String newPassword, String confirmPassword) async {
    try {
      final response = await http.put(
        Uri.parse('$URL/customer/resetpassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          'contact': number,
          'new_password': newPassword,
          'confirm_password': confirmPassword
        }),
      );

      log("Reset Password Response: ${response.body}");

      final dynamic data = json.decode(response.body);
      if (response.statusCode == 200) {
        return response.statusCode;
      } else {
        errorMessage.value = 'Failed to reset: ${data['message']}';
        return response.statusCode;
      }
    } on SocketException catch (_) {
      errorMessage.value = 'No internet connection';
      return -1;
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      return -1;
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Migrated to ApiClient — token is attached automatically and
  /// 400/401/403 are handled centrally (logout + redirect), so we don't
  /// need to special-case them here anymore.
  Future<Map<String, dynamic>> changePassword(
    int number,
    String oldPassword,
    String newPassword,
    String confirmNewPassword,
  ) async {
    if (number <= 0 ||
        oldPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmNewPassword.isEmpty) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          content: Text('All fields are required.'),
          duration: Duration(seconds: 2),
        ),
      );
      return {'status': -1, 'message': 'All fields are required.'};
    }

    try {
      final requestBody = {
        'contact': number.toString(),
        'old_password': oldPassword.trim(),
        'new_password': newPassword.trim(),
        'confirm_newpassword': confirmNewPassword.trim(),
      };

      log('Request Body: ${jsonEncode(requestBody)}');

      final response =
          await _client.put('/customer/changepassword', requestBody);

      log("Change Password Response: ${response.body}");

      final dynamic data =
          response.body is String ? json.decode(response.body) : response.body;

      if (response.statusCode == 200) {
        return {
          'status': response.statusCode,
          'message': data['message'] ?? 'Password changed successfully.',
        };
      } else if (response.statusCode == 401 ||
          response.statusCode == 400 ||
          response.statusCode == 403) {
        // ApiClient's interceptor already triggers logout + redirect.
        errorMessage.value = 'Session expired. Please log in again.';
        return {
          'status': response.statusCode,
          'message': 'Session expired. Please log in again.',
        };
      } else {
        errorMessage.value = data['message'] ?? 'Failed to change password';
        return {
          'status': response.statusCode,
          'message': data['message'] ?? 'Failed to change password',
        };
      }
    } on SocketException catch (_) {
      errorMessage.value = 'No internet connection';
      return {'status': -1, 'message': 'No internet connection'};
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      return {'status': -1, 'message': 'Unexpected error: $e'};
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Reads rememberMe from the class field instead of a parameter.
  Future<int> loginUser(int phone, String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isLoading.value = true;
    errorMessage.value = '';

    try {
      log('Calling login API');
      final response = await http.post(
        Uri.parse('$URL/customer/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          "contact": phone,
          "password": password,
        }),
      );

      log('Response: ${response.body}');
      final dynamic data = json.decode(response.body);

      if (response.statusCode == 200) {
        log(response.statusCode.toString());

        final String token = data['token'] ?? '';
        final dynamic userResponseData = data['data'];
        User user = User.fromJson(userResponseData);

        log("***************");
        log("reward Points: ${user.reward_points}");
        log("***************");

        final sessionController = Get.find<SessionController>();

        // Always save token so APIs work during this session
        await sessionController.setLoggedIn(token: token);

        if (!rememberMe) {
          // Remember Me OFF: set login_time to 0 so next app launch
          // immediately sees session as expired → goes to login screen
          await prefs.setInt('login_time', 0);
        }
        // Remember Me ON: login_time = now → auto logout after 1 day

        await prefs.setString('name', user.firstname);
        await prefs.setInt('reward_points', user.reward_points ?? 0);

        return response.statusCode;
      } else {
        errorMessage.value = 'Failed to login: ${data['message']}';
        return response.statusCode;
      }
    } on SocketException catch (_) {
      errorMessage.value = 'No internet connection';
      return -1;
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      return -1;
    } finally {
      isLoading.value = false;
    }
  }
}
