// import 'dart:developer';

// import 'package:baltra/features/applicationCare/data/productRepository.dart';
// import 'package:baltra/features/applicationCare/models/crmModel.dart';
// import 'package:baltra/features/applicationCare/models/loyaltyRedeem.dart';
// import 'package:baltra/features/applicationCare/models/myProduct.dart';
// import 'package:baltra/features/applicationCare/models/warrantyProduct.dart';
// import 'package:baltra/features/authetication/presentation/pages/buttomNavbar.dart';
// import 'package:dartz/dartz.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class Myproductcontroller extends GetxController {
//   var isLoading = true.obs;
//   var myProducts = <Myproduct>[].obs;
//   var complaints = <CustomerProduct>[].obs;
//   var myProduct = Rxn<ProductModel>();
//   var loyalty = Rxn<LoyaltyRedeem>();
//   var errorMessage = ''.obs;
//   var singleMyProduct = Rxn<Myproduct>();

//   final MyProductRepository productRepository;

//   Myproductcontroller({required this.productRepository});

//   @override
//   void onInit() {
//     fetchMyProduct();
//     super.onInit();
//   }

//   Future<void> fetchMyProduct() async {
//     isLoading(true);
//     try {
//       final Either<Exception, List<Myproduct>> result =
//           await productRepository.fetchMyProduct();
//       log(result.toString());

//       result.fold(
//         (failure) {
//           showErrorDialog(Get.context!, failure);
//           errorMessage(failure.toString());
//         },
//         (myProductList) {
//           myProducts.assignAll(myProductList);
//         },
//       );
//     } catch (e) {
//       errorMessage('An unexpected error occurred');
//       showErrorDialog(Get.context!, Exception('An unexpected error occurred'));
//     } finally {
//       isLoading(false);
//     }
//   }

//   Future<void> fetchAllComplaints() async {
//     isLoading(true);
//     errorMessage('');
//     final result = await productRepository.fetchAllComplaints();
//     result.fold(
//       (error) => errorMessage(error.toString()),
//       (data) => complaints.assignAll(data),
//     );
//     isLoading(false);
//   }

//   Future<int> deleteMyProduct(int id) async {
//     isLoading(true);
//     final int result = await productRepository.deleteMyProduct(id);

//     if (result == 1) {
//       myProducts.removeWhere((element) => element.id == id);
//     }

//     if (result == 0) {
//       errorMessage('Failed to delete product');
//     }

//     isLoading(false);
//     return result;
//   }

//   Future<void> fetchWarrantyProduct(int stockId) async {
//     isLoading(true);
//     log("callimg fetch warranty product");
//     final Either<Exception, ProductModel> result =
//         await productRepository.getWarranty(stockId);

//     log('Result: ${result.toString()}');

//     result.fold(
//       (failure) {
//         log(failure.toString());
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           showErrorDialog(Get.context!, failure);
//           errorMessage(failure.toString());
//         });
//         isLoading(false);
//       },
//       (product) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           myProduct.value = product;
//           log("Product assigned to myProduct: ${product.stockDetails.modelName}");
//         });
//         isLoading(false);
//       },
//     );
//   }

//   Future<void> getLoyalty(int stockId) async {
//     isLoading(true);
//     log("callimg fetch warranty product");
//     final Either<Exception, LoyaltyRedeem> result =
//         await productRepository.getCustonerLoyalty(stockId);

//     log('Result: ${result.toString()}');

//     result.fold(
//       (failure) {
//         log(failure.toString());
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           showErrorDialog(Get.context!, failure);
//           errorMessage(failure.toString());
//         });
//         isLoading(false);
//       },
//       (loyaltys) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           loyalty.value = loyaltys;
//         });
//         isLoading(false);
//       },
//     );
//   }

//   Future<void> redeemLoyaltyController(
//       int stockId, int duration, double price) async {
//     isLoading(true);
//     log("callimg redeem loyalty of $stockId product in controller");
//     final Either<Exception, int> result =
//         await productRepository.redeemLoyalty(stockId, duration, price);

//     log('Result*******: ${result}');

//     result.fold(
//       (failure) {
//         log(failure.toString());
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           showErrorDialog(Get.context!, failure);
//           errorMessage(failure.toString());
//         });
//         isLoading(false);
//       },
//       (loyaltys) {
//         log("callimg redeem loyalty of $stockId product in success controller");
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           Get.snackbar('Success', 'Loyalty points redeemed successfully',
//               snackPosition: SnackPosition.BOTTOM,
//               colorText: Colors.white,
//               backgroundColor: Colors.green);
//           Get.offAll(() => const ButtomNavBar(pageno: 3));
//         });
//         isLoading(false);
//       },
//     );
//   }

//   void showErrorDialog(BuildContext context, Exception failure) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Error'),
//         content: Text(failure.toString()),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> fetchSingleMyProduct(int id) async {
//     isLoading(true);
//     singleMyProduct.value = null;
//     errorMessage.value = '';

//     try {
//       final Either<Exception, Myproduct> result =
//           await productRepository.fetchSingleMyProduct(id);

//       result.fold(
//         (failure) {
//           showErrorDialog(Get.context!, failure);
//           errorMessage.value = failure.toString();
//         },
//         (product) {
//           singleMyProduct.value = product;
//         },
//       );
//     } catch (e) {
//       errorMessage.value = 'An unexpected error occurred: $e';
//       showErrorDialog(
//           Get.context!, Exception('An unexpected error occurred: $e'));
//     } finally {
//       isLoading(false);
//     }
//   }
// }
import 'dart:developer';

import 'package:baltra/core/utils/sessionController.dart';
import 'package:baltra/features/applicationCare/data/productRepository.dart';
import 'package:baltra/features/applicationCare/models/crmModel.dart';
import 'package:baltra/features/applicationCare/models/loyaltyRedeem.dart';
import 'package:baltra/features/applicationCare/models/myProduct.dart';
import 'package:baltra/features/applicationCare/models/warrantyProduct.dart';
import 'package:baltra/features/authetication/presentation/pages/buttomNavbar.dart';
import 'package:baltra/features/authetication/presentation/pages/loginPage.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Myproductcontroller extends GetxController {
  var isLoading = true.obs;
  var myProducts = <Myproduct>[].obs;
  var complaints = <CustomerProduct>[].obs;
  var myProduct = Rxn<ProductModel>();
  var loyalty = Rxn<LoyaltyRedeem>();
  var errorMessage = ''.obs;
  var singleMyProduct = Rxn<Myproduct>();

  final MyProductRepository productRepository;

  Myproductcontroller({required this.productRepository});

  @override
  void onInit() {
    log('Myproductcontroller: Initialized');
    fetchMyProduct();
    super.onInit();
  }

  Future<void> fetchMyProduct() async {
    isLoading(true);
    try {
      log('Myproductcontroller: Fetching my products');
      final Either<Exception, List<Myproduct>> result =
          await productRepository.fetchMyProduct();
      log('Myproductcontroller: Fetch result: $result');

      result.fold(
        (failure) {
          log('Myproductcontroller: Fetch failed: $failure');
          if (failure.toString().contains('Unauthorized')) {
            log('Myproductcontroller: Unauthorized error, triggering session expiration');
            final sessionController = Get.find<SessionController>();
            sessionController.setLoggedOut();
            Get.offAll(() => const Loginpage());
            Get.snackbar('Session Expired', 'Please log in again',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white);
          } else {
            showErrorDialog(Get.context!, failure);
            errorMessage(failure.toString());
          }
        },
        (myProductList) {
          log('Myproductcontroller: Fetched ${myProductList.length} products');
          myProducts.assignAll(myProductList);
        },
      );
    } catch (e) {
      log('Myproductcontroller: Unexpected error: $e');
      errorMessage('An unexpected error occurred');
      showErrorDialog(Get.context!, Exception('An unexpected error occurred'));
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchAllComplaints() async {
    isLoading(true);
    errorMessage('');
    log('Myproductcontroller: Fetching all complaints');
    final result = await productRepository.fetchAllComplaints();
    result.fold(
      (error) {
        log('Myproductcontroller: Fetch complaints failed: $error');
        if (error.toString().contains('Unauthorized')) {
          log('Myproductcontroller: Unauthorized error in fetchAllComplaints, triggering session expiration');
          final sessionController = Get.find<SessionController>();
          sessionController.setLoggedOut();
          Get.offAll(() => const Loginpage());
          Get.snackbar('Session Expired', 'Please log in again',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        } else {
          errorMessage(error.toString());
        }
      },
      (data) {
        log('Myproductcontroller: Fetched ${data.length} complaints');
        complaints.assignAll(data);
      },
    );
    isLoading(false);
  }

  Future<int> deleteMyProduct(int id) async {
    isLoading(true);
    log('Myproductcontroller: Deleting product with ID: $id');
    final int result = await productRepository.deleteMyProduct(id);

    if (result == 1) {
      myProducts.removeWhere((element) => element.id == id);
      log('Myproductcontroller: Product $id deleted successfully');
    } else {
      errorMessage('Failed to delete product');
      log('Myproductcontroller: Failed to delete product $id');
    }

    isLoading(false);
    return result;
  }

  Future<void> fetchWarrantyProduct(int stockId) async {
    isLoading(true);
    log("Myproductcontroller: Fetching warranty product for stockId: $stockId");
    final Either<Exception, ProductModel> result =
        await productRepository.getWarranty(stockId);

    log('Myproductcontroller: Warranty fetch result: ${result.toString()}');

    result.fold(
      (failure) {
        log('Myproductcontroller: Warranty fetch failed: $failure');
        if (failure.toString().contains('Unauthorized')) {
          log('Myproductcontroller: Unauthorized error in fetchWarrantyProduct, triggering session expiration');
          final sessionController = Get.find<SessionController>();
          sessionController.setLoggedOut();
          Get.offAll(() => const Loginpage());
          Get.snackbar('Session Expired', 'Please log in again',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showErrorDialog(Get.context!, failure);
            errorMessage(failure.toString());
          });
        }
        isLoading(false);
      },
      (product) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          myProduct.value = product;
          log("Myproductcontroller: Product assigned to myProduct: ${product.stockDetails.modelName}");
        });
        isLoading(false);
      },
    );
  }

  Future<void> getLoyalty(int stockId) async {
    isLoading(true);
    log("Myproductcontroller: Fetching loyalty for stockId: $stockId");
    final Either<Exception, LoyaltyRedeem> result =
        await productRepository.getCustonerLoyalty(stockId);

    log('Myproductcontroller: Loyalty fetch result: ${result.toString()}');

    result.fold(
      (failure) {
        log('Myproductcontroller: Loyalty fetch failed: $failure');
        if (failure.toString().contains('Unauthorized')) {
          log('Myproductcontroller: Unauthorized error in getLoyalty, triggering session expiration');
          final sessionController = Get.find<SessionController>();
          sessionController.setLoggedOut();
          Get.offAll(() => const Loginpage());
          Get.snackbar('Session Expired', 'Please log in again',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showErrorDialog(Get.context!, failure);
            errorMessage(failure.toString());
          });
        }
        isLoading(false);
      },
      (loyaltys) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          loyalty.value = loyaltys;
        });
        isLoading(false);
      },
    );
  }

  Future<void> redeemLoyaltyController(
      int stockId, int duration, double price) async {
    isLoading(true);
    log("Myproductcontroller: Redeeming loyalty for stockId: $stockId");
    final Either<Exception, int> result =
        await productRepository.redeemLoyalty(stockId, duration, price);

    log('Myproductcontroller: Redeem loyalty result: $result');

    result.fold(
      (failure) {
        log('Myproductcontroller: Redeem loyalty failed: $failure');
        if (failure.toString().contains('Unauthorized')) {
          log('Myproductcontroller: Unauthorized error in redeemLoyaltyController, triggering session expiration');
          final sessionController = Get.find<SessionController>();
          sessionController.setLoggedOut();
          Get.offAll(() => const Loginpage());
          Get.snackbar('Session Expired', 'Please log in again',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showErrorDialog(Get.context!, failure);
            errorMessage(failure.toString());
          });
        }
        isLoading(false);
      },
      (loyaltys) {
        log("Myproductcontroller: Redeem loyalty success for stockId: $stockId");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar('Success', 'Loyalty points redeemed successfully',
              snackPosition: SnackPosition.BOTTOM,
              colorText: Colors.white,
              backgroundColor: Colors.green);
          Get.offAll(() => const ButtomNavBar(pageno: 3));
        });
        isLoading(false);
      },
    );
  }

  void showErrorDialog(BuildContext context, Exception failure) {
    log('Myproductcontroller: Showing error dialog: $failure');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(failure.toString()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> fetchSingleMyProduct(int id) async {
    isLoading(true);
    singleMyProduct.value = null;
    errorMessage.value = '';
    log('Myproductcontroller: Fetching single product with ID: $id');

    try {
      final Either<Exception, Myproduct> result =
          await productRepository.fetchSingleMyProduct(id);

      result.fold(
        (failure) {
          log('Myproductcontroller: Fetch single product failed: $failure');
          if (failure.toString().contains('Unauthorized')) {
            log('Myproductcontroller: Unauthorized error in fetchSingleMyProduct, triggering session expiration');
            final sessionController = Get.find<SessionController>();
            sessionController.setLoggedOut();
            Get.offAll(() => const Loginpage());
            Get.snackbar('Session Expired', 'Please log in again',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white);
          } else {
            showErrorDialog(Get.context!, failure);
            errorMessage.value = failure.toString();
          }
        },
        (product) {
          singleMyProduct.value = product;
          log('Myproductcontroller: Fetched single product: ${product.id}');
        },
      );
    } catch (e) {
      log('Myproductcontroller: Unexpected error in fetchSingleMyProduct: $e');
      errorMessage.value = 'An unexpected error occurred: $e';
      showErrorDialog(
          Get.context!, Exception('An unexpected error occurred: $e'));
    } finally {
      isLoading(false);
    }
  }
}
