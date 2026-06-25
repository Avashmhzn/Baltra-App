import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:baltra/core/utils/constants.dart';
import 'package:baltra/core/utils/sessionController.dart';
import 'package:baltra/features/authetication/models/user.dart';
import 'package:baltra/features/authetication/presentation/pages/loginPage.dart';
import 'package:baltra/features/authetication/presentation/pages/otp_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Authrepository extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  set rememberMe(bool rememberMe) {}

  Future<void> requestOTP(int number) async {
    try {
      isLoading.value = true; // Start loading indicator

      final response = await http.post(
        Uri.parse('$URL/customer/requestotp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, int>{'contact': number}),
      );
      log("****************");
      log(response.body);
      log("****************");

      final dynamic responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final bool isVerified = responseData['data']['is_verified'] ?? false;

        if (isVerified) {
          // Show snackbar with the message if the number is verified
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ??
                  'Contact number is already verified.'),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          // Navigate to OTP page if the number is not verified
          Get.to(
            () => OtpPage(
              phone: number,
              reset: false,
            ),
          );
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
      isLoading.value = false; // Stop loading indicator
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
          .timeout(Duration(seconds: 10));

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
      // Specific handling for no internet connection
      errorMessage.value = 'No internet connection';
      return -1;
    } catch (e) {
      // Generic fallback for any other unexpected errors
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

      // Add optional fields only if provided and non-empty
      if (gender != null && gender.isNotEmpty) requestBody["gender"] = gender;
      if (customerAddress != null && customerAddress.isNotEmpty)
        requestBody["customerAddress"] = customerAddress;
      if (city != null && city.isNotEmpty) requestBody["city"] = city;
      if (district != null && district.isNotEmpty)
        requestBody["district"] = district;
      if (dob != null && dob.isNotEmpty) requestBody["dob"] = dob;

      final response = await http.post(
        Uri.parse('$URL/customer/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      log("Register Request Body: ${jsonEncode(requestBody)}");
      log(response.body);
      log(response.statusCode.toString());

      final dynamic data = json.decode(response.body);
      if (response.statusCode == 200) {
        final dynamic userResponseData = data['data'];

        User user = User.fromJson(userResponseData);
        log("***************");
        log("reward Points: ${user.reward_points}");
        log("***************");

        final sessionController = Get.find<SessionController>();
        await sessionController.setLoggedIn();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('name', user.firstname);
        await prefs.setBool('logedin', true);
        await prefs.setInt(
          'reward_points',
          user.reward_points ?? 0,
        );
        final int status = response.statusCode;
        return status;
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
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, int>{'contact': number}),
      );
      log('request reset Response: ${response.body}');
      final dynamic data = json.decode(response.body);
      if (response.statusCode == 200) {
        final int status = response.statusCode;
        return status;
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
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{'contact': number, 'otp': otp}),
      );

      log(' resetOTP Response: ${response.body}');

      final dynamic data = json.decode(response.body);
      if (response.statusCode == 200) {
        final int status = response.statusCode;
        return status;
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
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'contact': number,
          'new_password': newPassword,
          'confirm_password': confirmPassword
        }),
      );

      log("Reset Pasword Response: ${response.body}");

      final dynamic data = json.decode(response.body);
      if (response.statusCode == 200) {
        final int status = response.statusCode;
        return status;
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
      return {
        'status': -1,
        'message': 'All fields are required.',
      };
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final requestBody = jsonEncode(<String, dynamic>{
        'contact': number.toString(), // Ensure proper type
        'old_password': oldPassword.trim(),
        'new_password': newPassword.trim(),
        'confirm_newpassword': confirmNewPassword.trim(),
      });

      log('Request Body: $requestBody');

      final response = await http.put(
        Uri.parse('$URL/customer/changepassword'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${prefs.getString('auth_token')}', // Add the token
        },
        body: requestBody,
      );

      log("Change Password Response: ${response.body}");

      final dynamic data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': response.statusCode,
          'message': data['message'] ?? 'Password changed successfully.',
        };
      } else if (response.statusCode == 401) {
        errorMessage.value = 'Session expired. Please log in again.';
        Get.offAll(Loginpage()); // Navigate to login page
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
      return {
        'status': -1,
        'message': 'No internet connection',
      };
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      return {
        'status': -1,
        'message': 'Unexpected error: $e',
      };
    } finally {
      isLoading.value = false;
    }
  }

  Future<int> loginUser(
    int phone,
    String password,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isLoading.value = true;
    errorMessage.value = '';

    try {
      log('Calling');
      final response = await http.post(
        Uri.parse('$URL/customer/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "contact": phone,
          "password": password,
        }),
      );

      log('Response: ${response.body}');
      final dynamic data = json.decode(response.body);

      final dynamic userResponseData = data['data'];
      if (response.statusCode == 200) {
        log(response.statusCode.toString());

        User user = User.fromJson(userResponseData);

        final sessionController = Get.find<SessionController>();
        await sessionController.setLoggedIn();
        log("***************");
        log("reward Points: ${user.reward_points}");
        log("***************");
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('name', user.firstname);
        await prefs.setBool('logedin', true);
        await prefs.setInt(
          'reward_points',
          user.reward_points ?? 0,
        );
        final int status = response.statusCode;
        return status;
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
