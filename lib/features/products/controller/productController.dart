import 'dart:developer';

import 'package:baltra/core/utils/errorHandler.dart';
import 'package:baltra/features/products/data/productRepository.dart';
import 'package:baltra/features/products/models/category.dart';
import 'package:baltra/features/products/models/product.dart';
import 'package:baltra/features/products/models/subcategory.dart';
import 'package:baltra/features/products/models/subcategoryProduct.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

// Import your global error handler

class  ProductController extends GetxController {
  var isLoading = true.obs;
  Rx<Product?> productDetails = Rx<Product?>(null);
  var categoryList = <Category>[].obs;
  var subCategoryList = <Subcategory>[].obs;
  var subCategoryProductsList = <Subcategoryproduct>[].obs;
  var relatedProductsList = <Subcategoryproduct>[].obs;
  var allProductsList = <Product>[].obs;
  RxInt currentPage = 1.obs;
  final int pageSize = 8; // Number of products per page

  // var productList = <Products>[].obs;
  var errorMessage = ''.obs;

  final ProductRepository productRepository;

  ProductController({required this.productRepository});

  @override
  void onInit() {
    fetchCategories();
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
    isLoading(true);
    final Either<Exception, List<Subcategoryproduct>> result =
        await productRepository.fetcRelatedProducts(id);
    log('caliing fetch related product controller');

    result.fold(
      (failure) {
        showErrorDialog(Get.context!, failure);
        errorMessage(failure.toString());
      },
      (relatedProducts) {
        relatedProductsList.assignAll(relatedProducts);
      },
    );
    isLoading(false);
  }

  Future<void> fetchProduct(int id) async {
    isLoading(true);
    final Either<Exception, Product> result =
        await productRepository.fetchProduct(id);
    log('caliing fetch product controller');
    result.fold(
      (failure) {
        showErrorDialog(Get.context!, failure);
        errorMessage(failure.toString());
      },
      (product) {
        productDetails.value = product;
      },
    );
    isLoading(false);
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