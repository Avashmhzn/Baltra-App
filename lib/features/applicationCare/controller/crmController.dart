import 'package:baltra/features/applicationCare/data/crm.dart';
import 'package:baltra/features/applicationCare/models/crmModel.dart';
import 'package:get/get.dart';
import 'package:dartz/dartz.dart';
import 'dart:developer';

class CrmController extends GetxController {
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var customerProduct = Rxn<CustomerProduct>(); 

  final CrmServices crmService;

  CrmController({required this.crmService});

  Future<void> fetchCustomerProduct(int stockId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      log("Fetching customer product for Stock ID: $stockId");

      final Either<String, CustomerProduct?> result = await crmService.fetchCustomerProduct(stockId);
      result.fold(
        (error) {
          log("Error fetching product: $error");
          errorMessage.value = error;
          customerProduct.value = null;
        },
        (product) {
          if (product == null) {
            errorMessage.value = "Product not found";
            log("Product not found for Stock ID: $stockId");
          } else {
            customerProduct.value = product;
            log("Successfully fetched product: ${product.modelName}");
          }
        },
      );
    } catch (e) {
      log("Unexpected error: $e");
      errorMessage.value = "An unexpected error occurred";
    } finally {
      isLoading(false);
    }
  }
}
