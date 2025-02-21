import 'dart:developer';

import 'package:baltra/features/applicationCare/data/productRepository.dart';
import 'package:baltra/features/applicationCare/models/crmModel.dart';
import 'package:baltra/features/applicationCare/models/loyaltyRedeem.dart';
import 'package:baltra/features/applicationCare/models/myProduct.dart';
import 'package:baltra/features/applicationCare/models/warrantyProduct.dart';
import 'package:baltra/features/authetication/presentation/pages/buttomNavbar.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import your global error handler

class Myproductcontroller extends GetxController {
  var isLoading = true.obs;

  var myProducts = <Myproduct>[].obs;
  var complaints = <CustomerProduct>[].obs;
  // var myProduct = Rxn<ProductModel>();
  var myProduct = Rxn<ProductModel>(); // Observable for product
  var loyalty = Rxn<LoyaltyRedeem>(); // Observable for product

  // var productList = <Products>[].obs;
  var errorMessage = ''.obs;
  var singleMyProduct = Rxn<Myproduct>();


  final MyProductRepository productRepository;

  Myproductcontroller({required this.productRepository});

  @override
  void onInit() {
    fetchMyProduct();
    super.onInit();
  }

  /*Future<void> fetchMyProduct() async {
    isLoading(true);
    final Either<Exception, List<Myproduct>> result =
        await productRepository.fetchMyProduct();
    log(result.toString());
    result.fold(
      (failure) {
        showErrorDialog(Get.context!, failure);
        errorMessage(failure.toString());
      },
      (myProduct) {
        myProducts.assignAll(myProduct);
      },
    );
    isLoading(false);
  }*/
  Future<void> fetchMyProduct() async {
    isLoading(true);
    try {
      final Either<Exception, List<Myproduct>> result = await productRepository.fetchMyProduct();
      log(result.toString());

      result.fold(
            (failure) {
          showErrorDialog(Get.context!, failure);
          errorMessage(failure.toString());
        },
            (myProductList) {
          myProducts.assignAll(myProductList);  // Update the products list
        },
      );
    } catch (e) {
      errorMessage('An unexpected error occurred');
      showErrorDialog(Get.context!, Exception('An unexpected error occurred'));
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchAllComplaints() async {
    isLoading(true);
    errorMessage('');
    final result = await productRepository.fetchAllComplaints();
    result.fold(
          (error) => errorMessage(error.toString()),
          (data) => complaints.assignAll(data),
    );
    isLoading(false);
  }


  Future<int> deleteMyProduct(int id) async {
    isLoading(true);
    final int result = await productRepository.deleteMyProduct(id);

    if (result == 1) {
      myProducts.removeWhere((element) => element.id == id);
    }

    if (result == 0) {
      errorMessage('Failed to delete product');
    }

    isLoading(false);
    return result;
  }

  Future<void> fetchWarrantyProduct(int stockId) async {
    // isLoading(true); // Start loading
    log("callimg fetch warranty product");
    // Fetch the single product using stockId
    final Either<Exception, ProductModel> result =
        await productRepository.getWarranty(stockId);

    log('Result: ${result.toString()}'); // Log the result for debugging

    result.fold(
      (failure) {
        // Handle error
        log(failure.toString()); // Log the failure
        log("callimg fetch warranty product");

        WidgetsBinding.instance.addPostFrameCallback((_) {
          showErrorDialog(Get.context!, failure); // Show error dialog
          errorMessage(failure.toString()); // Set the error message
        });

        isLoading(false); // Stop loading
      },
      (product) {
        // Handle success
        WidgetsBinding.instance.addPostFrameCallback((_) {
          myProduct.value =
              product; // Assign the fetched product to the observable
        });

        isLoading(false); // Stop loading
      },
    );
  }

  Future<void> getLoyalty(int stockId) async {
    // isLoading(true); // Start loading
    log("callimg fetch warranty product");
    // Fetch the single product using stockId
    final Either<Exception, LoyaltyRedeem> result =
        await productRepository.getCustonerLoyalty(stockId);

    log('Result: ${result.toString()}'); // Log the result for debugging

    result.fold(
      (failure) {
        // Handle error
        log(failure.toString()); // Log the failure
        log("callimg fetch warranty product");

        WidgetsBinding.instance.addPostFrameCallback((_) {
          showErrorDialog(Get.context!, failure); // Show error dialog
          errorMessage(failure.toString()); // Set the error message
        });

        isLoading(false); // Stop loading
      },
      (loyaltys) {
        // Handle success
        WidgetsBinding.instance.addPostFrameCallback((_) {
          loyalty.value =
              loyaltys; // Assign the fetched product to the observable
        });

        isLoading(false); // Stop loading
      },
    );
  }

  Future<void> redeemLoyaltyController(
      int stockId, int duration, double price) async {
    // isLoading(true); // Start loading
    log("callimg redeem loyalty of $stockId product in controller");
    // Fetch the single product using stockId
    final Either<Exception, int> result =
        await productRepository.redeemLoyalty(stockId, duration, price);

    log('Result*******: ${result}'); // Log the result for debugging

    result.fold(
      (failure) {
        // Handle error
        log(failure.toString()); // Log the failure
        log("callimg fetch warranty product");

        WidgetsBinding.instance.addPostFrameCallback((_) {
          showErrorDialog(Get.context!, failure); // Show error dialog
          errorMessage(failure.toString()); // Set the error message
        });

        isLoading(false); // Stop loading
      },
      (loyaltys) {
        log("callimg redeem loyalty of $stockId product in success controller");
        // Handle success
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // getx snackbar

          Get.snackbar('Success', 'Loyalty points redeemed successfully',
              snackPosition: SnackPosition.BOTTOM,
              colorText: Colors.white,
              backgroundColor: Colors.green);
          Get.offAll(() => const ButtomNavBar(
                pageno: 3,
              ));
        });

        isLoading(false); // Stop loading
      },
    );
  }

  void showErrorDialog(BuildContext context, Exception failure) {
    // Implement your error dialog logic here
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

    try {
      // This repository method should return Either<Exception, Myproduct>.
      final Either<Exception, Myproduct> result =
      await productRepository.fetchSingleMyProduct(id);

      result.fold(
            (failure) {
          showErrorDialog(Get.context!, failure);
          errorMessage.value = failure.toString();
        },
            (product) {
          // If successful, store the product in singleMyProduct
          singleMyProduct.value = product;
        },
      );
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: $e';
      showErrorDialog(Get.context!, Exception('An unexpected error occurred: $e'));
    } finally {
      isLoading(false);
    }
  }

}
