// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';

// import 'package:baltra/core/utils/constants.dart';
// import 'package:baltra/features/applicationCare/models/crmModel.dart';
// import 'package:baltra/features/applicationCare/models/loyaltyRedeem.dart';
// import 'package:baltra/features/applicationCare/models/myProduct.dart';
// import 'package:baltra/features/applicationCare/models/warrantyProduct.dart';
// import 'package:dartz/dartz.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class MyProductRepository {
//   Future<Either<Exception, List<Myproduct>>> fetchMyProduct() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? token = prefs.getString('auth_token');

//     try {
//       final response = await http.get(
//         Uri.parse('$URL/stocks/getmyproduct'),
//         headers: {
//           HttpHeaders.authorizationHeader: 'Bearer $token',
//         },
//       );

//       log(response.body);

//       final Map<String, dynamic> jsonResponse = json.decode(response.body);
//       log('Json Response: ${jsonResponse['data']}');
//       if (jsonResponse['success']) {
//         log("Hello");
//         final List<dynamic> data = jsonResponse['data'];

//         final List<Myproduct> myProduct =
//             data.map((json) => Myproduct.fromJson(json)).toList();
//         return Right(myProduct);
//       } else {
//         return const Left(HttpException("Failed to fetch your products"));
//       }
//     } on SocketException catch (e) {
//       return Left(e);
//     } catch (e) {
//       return Left(Exception("Unknown error occurred: $e"));
//     }
//   }

//   Future<int> deleteMyProduct(int id) async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? token = prefs.getString('auth_token');

//     try {
//       final response = await http.delete(
//         Uri.parse('$URL/stocks/deletemyproduct/$id'),
//         headers: {
//           HttpHeaders.authorizationHeader: 'Bearer $token',
//         },
//       );

//       log(response.body);
//       final Map<String, dynamic> jsonResponse = json.decode(response.body);

//       if (jsonResponse['success']) {
//         return 1;
//       } else {
//         return 0;
//       }
//     } on SocketException {
//       return 0;
//     } catch (e) {
//       return 0;
//     }
//   }

//   Future<Either<Exception, ProductModel>> getWarranty(int stockId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? token = prefs.getString('auth_token');

//     try {
//       // Make the HTTP GET request
//       final response = await http.get(
//         Uri.parse('$URL/stocks/warrantydetailpage/$stockId'),
//         headers: {
//           HttpHeaders.authorizationHeader: 'Bearer $token',
//         },
//       );

//       // Decode the response body into a Map
//       final Map<String, dynamic> jsonResponse = json.decode(response.body);
//       // Check if the response indicates success and `data` exists
//       if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
//         // Deserialize the stock_details and warranty_details into ProductModel
//         final ProductModel myProduct =
//             ProductModel.fromJson(jsonResponse['data']);

//         log("Product fetched successfully");
//         return Right(myProduct);
//       } else {
//         final String errorMessage =
//             jsonResponse['message'] ?? "Unknown error occurred";
//         log("Failed to fetch product: $errorMessage");
//         return Left(HttpException(errorMessage));
//       }
//     } on SocketException catch (e) {
//       log("SocketException: $e");
//       return Left(e); // Return network error (SocketException)
//     } catch (e) {
//       log("Unknown error occurred: $e");
//       return Left(
//           Exception("Unknown error occurred: $e")); // Return unknown error
//     }
//   }

//   Future<Either<Exception, LoyaltyRedeem>> getCustonerLoyalty(
//       int stockId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? token = prefs.getString('auth_token');

//     try {
//       // Make the HTTP GET request
//       final response = await http.get(
//         Uri.parse('$URL/stocks/loyaltyredeem/$stockId'),
//         headers: {
//           HttpHeaders.authorizationHeader: 'Bearer $token',
//         },
//       );

//       // Decode the response body into a Map
//       final Map<String, dynamic> jsonResponse = json.decode(response.body);
//       // Check if the response indicates success and `data` exists
//       if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
//         // Deserialize the stock_details and warranty_details into ProductModel
//         final LoyaltyRedeem loyaltys =
//             LoyaltyRedeem.fromJson(jsonResponse['data']);

//         log("Product fetched successfully");
//         return Right(loyaltys);
//       } else {
//         final String errorMessage =
//             jsonResponse['message'] ?? "Unknown error occurred";
//         log("Failed to fetch loyalty: $errorMessage");
//         return Left(HttpException(errorMessage));
//       }
//     } on SocketException catch (e) {
//       log("SocketException: $e");
//       return Left(e); // Return network error (SocketException)
//     } catch (e) {
//       log("Unknown error occurred: $e");
//       return Left(
//           Exception("Unknown error occurred: $e")); // Return unknown error
//     }
//   }

//   Future<Either<Exception, int>> redeemLoyalty(
//       int stockId, int duration, double price) async {
//     log("callimg redeem loaylty*************88 product");
//     final prefs = await SharedPreferences.getInstance();
//     final String? token = prefs.getString('auth_token');

//     try {
//       // Make the HTTP GET request
//       final response = await http.post(
//         Uri.parse('$URL/stocks/redeemloyaltypoints'),
//         headers: {
//           HttpHeaders.authorizationHeader: 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'stock_id': stockId, // Pass int directly
//           'duration': duration, // Pass int directly
//           'price': price.toInt(), // Pass double directly
//         }),
//       );
//       log("***********");
//       log('RESPONSE of redeem : ${response.body}');
//       // Decode the response body into a Map
//       final Map<String, dynamic> jsonResponse = json.decode(response.body);
//       // Check if the response indicates success and `data` exists
//       if (jsonResponse['success'] == true) {
//         log("***********2");

//         log("Product fetched successfully");
//         log(jsonResponse.toString());
//         final SharedPreferences _prefs = await SharedPreferences.getInstance();
//         _prefs.setInt('reward_points', jsonResponse['new_reward_points']);
//         int loyaltys = 1;
//         return Right(loyaltys);
//       } else {
//         final String errorMessage =
//             jsonResponse['message'] ?? "Unknown error occurred";
//         log("Failed to fetch loyalty: $errorMessage");
//         return Left(HttpException(errorMessage));
//       }
//     } on SocketException catch (e) {
//       log("SocketException: $e");
//       return Left(e); // Return network error (SocketException)
//     } catch (e) {
//       log("Unknown error occurred: $e");
//       return Left(
//           Exception("Unknown error occurred: $e")); // Return unknown error
//     }
//   }

//   Future<Either<Exception, List<CustomerProduct>>> fetchAllComplaints() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? token = prefs.getString('auth_token');

//     try {
//       final response = await http.get(
//         Uri.parse('$URL/stocks/getallcomplaintsbycustomer'),
//         headers: {
//           HttpHeaders.authorizationHeader: 'Bearer $token',
//         },
//       );

//       log(response.body);

//       final Map<String, dynamic> jsonResponse = json.decode(response.body);
//       if (jsonResponse['success']) {
//         final List<dynamic> data = jsonResponse['data'];
//         final List<CustomerProduct> complaints =
//             data.map((json) => CustomerProduct.fromJson(json)).toList();
//         return Right(complaints);
//       } else {
//         return const Left(HttpException("Failed to fetch complaints"));
//       }
//     } on SocketException catch (e) {
//       return Left(e);
//     } catch (e) {
//       return Left(Exception("Unknown error occurred: $e"));
//     }
//   }

//   // my_product_repository.dart
//   Future<Either<Exception, Myproduct>> fetchSingleMyProduct(int id) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String? token = prefs.getString('auth_token');

//       final response = await http.get(
//         Uri.parse('$URL/stocks/customerproductbyidcustomer/$id'),
//         headers: {
//           HttpHeaders.authorizationHeader: 'Bearer $token',
//         },
//       );

//       final Map<String, dynamic> jsonResponse = json.decode(response.body);
//       if (jsonResponse['success'] == true) {
//         // 'data' should be the JSON for a single product
//         final data = jsonResponse['data'];
//         final Myproduct product = Myproduct.fromJson(data);
//         return Right(product);
//       } else {
//         return Left(HttpException("Failed to fetch product details"));
//       }
//     } on SocketException catch (e) {
//       return Left(e);
//     } catch (e) {
//       return Left(Exception("Unknown error occurred: $e"));
//     }
//   }
// }

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:baltra/core/utils/authGuard.dart';
import 'package:baltra/core/utils/constants.dart';
import 'package:baltra/core/utils/sessionController.dart';
import 'package:baltra/features/applicationCare/models/crmModel.dart';
import 'package:baltra/features/applicationCare/models/loyaltyRedeem.dart';
import 'package:baltra/features/applicationCare/models/myProduct.dart';
import 'package:baltra/features/applicationCare/models/warrantyProduct.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyProductRepository {
  Future<String?> _getToken() async {
    // ✅ Use SessionController instead of raw SharedPreferences, so token
    // reads stay consistent everywhere in the app.
    final sessionController = Get.find<SessionController>();
    return await sessionController.getToken();
  }

  Future<Either<Exception, List<Myproduct>>> fetchMyProduct() async {
    final token = await _getToken();

    try {
      final response = await http.get(
        Uri.parse('$URL/stocks/getmyproduct'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      log(response.body);

      // ✅ Check for expired/invalid token before anything else
      if (await handleAuthFailureIfAny(response)) {
        return const Left(HttpException('Session expired'));
      }

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      log('Json Response: ${jsonResponse['data']}');
      if (jsonResponse['success']) {
        log("Hello");
        final List<dynamic> data = jsonResponse['data'];

        final List<Myproduct> myProduct =
            data.map((json) => Myproduct.fromJson(json)).toList();
        return Right(myProduct);
      } else {
        return const Left(HttpException("Failed to fetch your products"));
      }
    } on SocketException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(Exception("Unknown error occurred: $e"));
    }
  }

  Future<int> deleteMyProduct(int id) async {
    final token = await _getToken();

    try {
      final response = await http.delete(
        Uri.parse('$URL/stocks/deletemyproduct/$id'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      log(response.body);

      if (await handleAuthFailureIfAny(response)) {
        return 0;
      }

      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['success']) {
        return 1;
      } else {
        return 0;
      }
    } on SocketException {
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<Either<Exception, ProductModel>> getWarranty(int stockId) async {
    final token = await _getToken();

    try {
      final response = await http.get(
        Uri.parse('$URL/stocks/warrantydetailpage/$stockId'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (await handleAuthFailureIfAny(response)) {
        return const Left(HttpException('Session expired'));
      }

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        final ProductModel myProduct =
            ProductModel.fromJson(jsonResponse['data']);

        log("Product fetched successfully");
        return Right(myProduct);
      } else {
        final String errorMessage =
            jsonResponse['message'] ?? "Unknown error occurred";
        log("Failed to fetch product: $errorMessage");
        return Left(HttpException(errorMessage));
      }
    } on SocketException catch (e) {
      log("SocketException: $e");
      return Left(e);
    } catch (e) {
      log("Unknown error occurred: $e");
      return Left(Exception("Unknown error occurred: $e"));
    }
  }

  Future<Either<Exception, LoyaltyRedeem>> getCustonerLoyalty(
      int stockId) async {
    final token = await _getToken();

    try {
      final response = await http.get(
        Uri.parse('$URL/stocks/loyaltyredeem/$stockId'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (await handleAuthFailureIfAny(response)) {
        return const Left(HttpException('Session expired'));
      }

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        final LoyaltyRedeem loyaltys =
            LoyaltyRedeem.fromJson(jsonResponse['data']);

        log("Product fetched successfully");
        return Right(loyaltys);
      } else {
        final String errorMessage =
            jsonResponse['message'] ?? "Unknown error occurred";
        log("Failed to fetch loyalty: $errorMessage");
        return Left(HttpException(errorMessage));
      }
    } on SocketException catch (e) {
      log("SocketException: $e");
      return Left(e);
    } catch (e) {
      log("Unknown error occurred: $e");
      return Left(Exception("Unknown error occurred: $e"));
    }
  }

  Future<Either<Exception, int>> redeemLoyalty(
      int stockId, int duration, double price) async {
    log("callimg redeem loaylty*************88 product");
    final token = await _getToken();

    try {
      final response = await http.post(
        Uri.parse('$URL/stocks/redeemloyaltypoints'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'stock_id': stockId,
          'duration': duration,
          'price': price.toInt(),
        }),
      );
      log("***********");
      log('RESPONSE of redeem : ${response.body}');

      if (await handleAuthFailureIfAny(response)) {
        return const Left(HttpException('Session expired'));
      }

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        log("***********2");

        log("Product fetched successfully");
        log(jsonResponse.toString());
        // Keep storing updated reward points directly in SharedPreferences,
        // same as the original implementation.
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('reward_points', jsonResponse['new_reward_points']);
        const loyaltys = 1;
        return Right(loyaltys);
      } else {
        final String errorMessage =
            jsonResponse['message'] ?? "Unknown error occurred";
        log("Failed to fetch loyalty: $errorMessage");
        return Left(HttpException(errorMessage));
      }
    } on SocketException catch (e) {
      log("SocketException: $e");
      return Left(e);
    } catch (e) {
      log("Unknown error occurred: $e");
      return Left(Exception("Unknown error occurred: $e"));
    }
  }

  Future<Either<Exception, List<CustomerProduct>>> fetchAllComplaints() async {
    final token = await _getToken();

    try {
      final response = await http.get(
        Uri.parse('$URL/stocks/getallcomplaintsbycustomer'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      log(response.body);

      if (await handleAuthFailureIfAny(response)) {
        return const Left(HttpException('Session expired'));
      }

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        final List<dynamic> data = jsonResponse['data'];
        final List<CustomerProduct> complaints =
            data.map((json) => CustomerProduct.fromJson(json)).toList();
        return Right(complaints);
      } else {
        return const Left(HttpException("Failed to fetch complaints"));
      }
    } on SocketException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(Exception("Unknown error occurred: $e"));
    }
  }

  Future<Either<Exception, Myproduct>> fetchSingleMyProduct(int id) async {
    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse('$URL/stocks/customerproductbyidcustomer/$id'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (await handleAuthFailureIfAny(response)) {
        return const Left(HttpException('Session expired'));
      }

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        final data = jsonResponse['data'];
        final Myproduct product = Myproduct.fromJson(data);
        return Right(product);
      } else {
        return Left(HttpException("Failed to fetch product details"));
      }
    } on SocketException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(Exception("Unknown error occurred: $e"));
    }
  }
}
