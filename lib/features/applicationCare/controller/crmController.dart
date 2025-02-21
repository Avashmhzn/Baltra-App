import 'package:baltra/features/applicationCare/data/crm.dart';
import 'package:baltra/features/applicationCare/models/crmModel.dart';
import 'package:get/get.dart';
import 'package:dartz/dartz.dart';
import 'dart:developer';

class CrmController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var customerProduct = Rxn<CustomerProduct>();
  var complaints = <CustomerProduct>[].obs; // List to store complaints

  final CrmServices crmService;

  CrmController({required this.crmService});

  Future<void> fetchCustomerProduct(int stockId) async {
    if (customerProduct.value != null) return;
    isLoading.value = true;
    errorMessage.value = '';
    customerProduct.value = null;

    try {
      log("Fetching customer product for Stock ID: $stockId");

      final Either<String, CustomerProduct?> result =
      await crmService.fetchCustomerProduct(stockId);
      result.fold(
            (error) {
          log("Error fetching product: $error");
          errorMessage.value = error;
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
      isLoading.value = false;
    }
  }

  // Fetch all complaints using CrmServices
  Future<void> fetchAllComplaints() async {
    isLoading(true);
    errorMessage('');

    final result = await crmService.fetchAllComplaints();

    result.fold(
          (error) {
        log("Error fetching complaints: $error");
        errorMessage(error.toString());
      },
          (data) {
        complaints.assignAll(data);
        log("Successfully fetched ${data.length} complaints");
      },
    );

    isLoading(false);
  }
}
