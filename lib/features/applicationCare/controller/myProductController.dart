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
    fetchMyProduct();
    super.onInit();
  }

  Future<void> fetchMyProduct() async {
    isLoading(true);
    try {
      final Either<Exception, List<Myproduct>> result =
      await productRepository.fetchMyProduct();
      log(result.toString());

      result.fold(
            (failure) {
          showErrorDialog(Get.context!, failure);
          errorMessage(failure.toString());
        },
            (myProductList) {
          myProducts.assignAll(myProductList);
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
    isLoading(true);
    log("callimg fetch warranty product");
    final Either<Exception, ProductModel> result =
    await productRepository.getWarranty(stockId);

    log('Result: ${result.toString()}');

    result.fold(
          (failure) {
        log(failure.toString());
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showErrorDialog(Get.context!, failure);
          errorMessage(failure.toString());
        });
        isLoading(false);
      },
          (product) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          myProduct.value = product;
          log("Product assigned to myProduct: ${product.stockDetails.modelName}");
        });
        isLoading(false);
      },
    );
  }

  Future<void> getLoyalty(int stockId) async {
    isLoading(true);
    log("callimg fetch warranty product");
    final Either<Exception, LoyaltyRedeem> result =
    await productRepository.getCustonerLoyalty(stockId);

    log('Result: ${result.toString()}');

    result.fold(
          (failure) {
        log(failure.toString());
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showErrorDialog(Get.context!, failure);
          errorMessage(failure.toString());
        });
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
    log("callimg redeem loyalty of $stockId product in controller");
    final Either<Exception, int> result =
    await productRepository.redeemLoyalty(stockId, duration, price);

    log('Result*******: ${result}');

    result.fold(
          (failure) {
        log(failure.toString());
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showErrorDialog(Get.context!, failure);
          errorMessage(failure.toString());
        });
        isLoading(false);
      },
          (loyaltys) {
        log("callimg redeem loyalty of $stockId product in success controller");
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
      final Either<Exception, Myproduct> result =
      await productRepository.fetchSingleMyProduct(id);

      result.fold(
            (failure) {
          showErrorDialog(Get.context!, failure);
          errorMessage.value = failure.toString();
        },
            (product) {
          singleMyProduct.value = product;
        },
      );
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: $e';
      showErrorDialog(
          Get.context!, Exception('An unexpected error occurred: $e'));
    } finally {
      isLoading(false);
    }
  }
}