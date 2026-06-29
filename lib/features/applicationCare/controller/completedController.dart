import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:baltra/core/utils/constants.dart';
import 'package:baltra/features/applicationCare/models/completedModel.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CompletedComplaintsController extends GetxController {
  final RxList<CompletedComplaint> complaints = <CompletedComplaint>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCompleted();
  }

  Future<void> fetchCompleted() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token == null) {
        errorMessage.value = "Authentication token not founAd";
        log("Authentication token not found");
        complaints.clear();
        return;
      }

      final url = '$URL/stocks/getallcomplaintsbycustomer?status=Completed';
      log("Fetching completed complaints from: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      log("Completed complaints response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List data = jsonResponse['data'] as List;
          complaints.value =
              data.map((e) => CompletedComplaint.fromJson(e)).toList();
          log('Successfully fetched ${complaints.length} completed complaints');
        } else {
          errorMessage.value =
              jsonResponse['message'] ?? "Failed to fetch completed complaints";
          complaints.clear();
        }
      } else {
        errorMessage.value = "Server error: ${response.statusCode}";
        log('Failed to fetch completed complaints: ${response.statusCode}');
        complaints.clear();
      }
    } catch (e) {
      errorMessage.value = "An unexpected error occurred";
      log('Error fetching completed complaints: $e');
      complaints.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
