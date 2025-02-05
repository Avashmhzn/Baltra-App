import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:baltra/features/applicationCare/models/crmModel.dart';
import 'package:get/get.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baltra/core/utils/constants.dart';

class CrmServices extends GetxService {
  Future<Either<String, CustomerProduct?>> fetchCustomerProduct(int stockId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (token == null) {
      return Left("Authentication token not found");
    }

    final String url = '$URL/stocks/customerproductbyidcustomer/$stockId';

    log("Fetching data from: $url");
    log("Bearer Token (masked): ${token.substring(0, 6)}...${token.substring(token.length - 4)}");
    log("Bearer Token : ${token}");

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      log("Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          final CustomerProduct customerProduct = CustomerProduct.fromJson(jsonResponse['data']);
          log('this is cutomer product${customerProduct}');
          return Right(customerProduct);
        } else {
          return Left(jsonResponse['message'] ?? "Failed to fetch data");
        }
      } else {
        return Left("HTTP Error: ${response.statusCode}");
      }
    } on SocketException {
      return Left("No Internet connection");
    } catch (e) {
      return Left("Unknown error occurred: $e");
    }
  }
}