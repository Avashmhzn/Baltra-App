import 'dart:developer';

import 'package:baltra/core/utils/errorHandler.dart';
import 'package:baltra/features/products/data/productRepository.dart';
import 'package:baltra/features/products/models/category.dart';
import 'package:baltra/features/products/models/product.dart';
import 'package:baltra/features/products/models/subcategory.dart';
import 'package:baltra/features/products/models/subcategoryProduct.dart';
import 'package:baltra/features/products/presentation/screens/product_detail_page.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import your global error handler

class ProductController extends GetxController {
  var isLoading = true.obs;
  var isLoadingProducts = true.obs;
  var isLoadingCategories = true.obs;
  Rx<Product?> productDetails = Rx<Product?>(null);
  var categoryList = <Category>[].obs;
  var subCategoryList = <Subcategory>[].obs;
  var subCategoryProductsList = <Subcategoryproduct>[].obs;
  /*var relatedProductsList = <Subcategoryproduct>[].obs;*/
  var allProductsList = <Product>[].obs;
  var selectedProduct = Product().obs;
  var isRelatedProductsLoading = false.obs;
  RxInt currentPage = 1.obs;
  final int pageSize = 8; // Number of products per page
  final RxList<Subcategoryproduct> relatedProductsList =
      <Subcategoryproduct>[].obs;

  // var productList = <Products>[].obs;
  var errorMessage = ''.obs;

  final ProductRepository productRepository;

  ProductController({required this.productRepository});

  @override
  void onInit() {
    fetchCategories();
    fetchProducts(1);
    super.onInit();
  }



  Future<void> fetchCategories() async {
    isLoading(true);
    final Either<Exception, List<Category>> result =
        await productRepository.fetchCategories();

    result.fold(
      (failure) {
        showErrorDialog(Get.context!, failure);
        errorMessage(failure.toString());
      },
      (categories) {
        categoryList.assignAll(categories);
      },
    );
    isLoading(false);
  }

  Future<void> fetchSubCategories(int id) async {
    isLoading(true);
    final Either<Exception, List<Subcategory>> result =
        await productRepository.fetchSubCategories(id);

    result.fold(
      (failure) {
        showErrorDialog(Get.context!, failure);
        errorMessage(failure.toString());
      },
      (subCategories) {
        subCategoryList.assignAll(subCategories);
      },
    );
    isLoading(false);
  }

  Future<void> fetchSubCategoryProducts(int id) async {
    isLoading(true);
    final Either<Exception, List<Subcategoryproduct>> result =
        await productRepository.fetchSubCategoryProducts(id);

    result.fold(
      (failure) {
        log("*****failure: $failure");
        showErrorDialog(Get.context!, failure);
        errorMessage(failure.toString());
      },
      (subCategoryProducts) {
        subCategoryProductsList.assignAll(subCategoryProducts);
      },
    );
    isLoading(false);
  }

  Future<void> fetchRelatedProducts(int id) async {
    print('Fetching related products for ID: $id');
    try {
      isRelatedProductsLoading(true);

      relatedProductsList.clear();

      final result = await productRepository.fetcRelatedProducts(id);
      log("API Response: $result");

      result.fold(
            (failure) {
          print("Failed to fetch related products: $failure");
          isRelatedProductsLoading(false);
        },
            (relatedProducts) {
          if (relatedProducts.isNotEmpty) {
            relatedProductsList.assignAll(relatedProducts);
          } else {
            print("Warning: No related products returned from API.");
          }
          isRelatedProductsLoading(false);
        },
      );
    } catch (e) {
      print("Error fetching related products: $e");
      isRelatedProductsLoading(false);
    }
  }


  /// Function to fetch the selected product when user clicks on a related product.
  Future<void> fetchSelectedProduct(int id) async {
    print('Fetching product details for ID: $id');
    try {
      isLoading(true);
      final result = await productRepository.fetchProduct(id);
      log("result: $result");
      result.fold(
            (failure) {
          isLoading(false);
          Get.snackbar("Error", failure.toString());
        },
            (product) {
          productDetails.value = product;
          productDetails.refresh(); // Force UI update
          isLoading(false);
        },
      );
    } catch (e) {
      isLoading(false);
      Get.snackbar("Error", "An error occurred: $e");
    }
  }

  // Function to refresh the screen with new product details.
  void refreshScreenWithNewProduct(int productId) async {
    await fetchSelectedProduct(productId);
    Get.to(() => ProductDetailPage(
      key: UniqueKey(),
      product: productDetails.value!,
      relatedProducts: relatedProductsList,
    ), arguments: {"productId": productId});
  }



  Future<void> fetchProduct(int? id) async {
    if (id == null) return;

    try {
      isLoading(true);
      final result = await productRepository.fetchProduct(id);
      result.fold(
            (failure) {
          isLoading(false);
          Get.snackbar("Error", failure.toString());
        },
            (product) {
          productDetails.value = product;
          isLoading(false);
        },
      );
    } catch (e) {
      isLoading(false);
      Get.snackbar("Error", "An error occurred: $e");
    }
  }


  Future<void> fetchProducts(int page) async {
    isLoading(true);
    final Either<Exception, List<Product>> result =
        await productRepository.fetchAllProduct();
    log('Fetching products for page $page');
    result.fold(
      (failure) {
        showErrorDialog(Get.context!, failure);
      },
      (allProducts) {
        final startIndex = (page - 1) * pageSize;
        final endIndex = startIndex + pageSize;
        if (allProducts.length > startIndex) {
          final paginatedProducts = allProducts.sublist(startIndex,
              endIndex > allProducts.length ? allProducts.length : endIndex);
          allProductsList.addAll(paginatedProducts);
        }
      },
    );
    isLoading(false);
  }


  void loadMore() {
    currentPage.value += 1;
    fetchProducts(currentPage.value);
  }
}

// fetchProduct
