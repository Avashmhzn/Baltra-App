import 'package:baltra/features/products/controller/productController.dart';
import 'package:baltra/features/products/controller/reviewController.dart';
import 'package:baltra/features/products/data/productRepository.dart';
import 'package:baltra/features/products/models/subcategoryProduct.dart';
import 'package:baltra/features/products/presentation/screens/product_detail_page.dart';
import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
import 'package:baltra/features/products/presentation/widgets/productItem.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductPage extends StatelessWidget {
  final ProductController controller =
      Get.put(ProductController(productRepository: ProductRepository()));
  final ReviewController reviewController = Get.put(ReviewController());

  final TextEditingController searchController = TextEditingController();
  RxList<Subcategoryproduct> filteredProducts = <Subcategoryproduct>[].obs;

  ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    // This method will filter products based on the search query
    void filterProducts(String query) {
      if (query.isEmpty) {
        // If search query is empty, show all products
        filteredProducts.assignAll(controller.subCategoryProductsList);
      } else {
        filteredProducts
            .assignAll(controller.subCategoryProductsList.where((product) {
          return product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.model_name.toLowerCase().contains(query.toLowerCase());
        }).toList());
      }
    }

    // Call filterProducts when the products list or search query changes
    ever(controller.subCategoryProductsList, (_) {
      filterProducts(
          searchController.text); // Filter based on current search text
    });

    // Listen to search input changes
    searchController.addListener(() {
      filterProducts(searchController.text);
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            const AppBarWithSVG(
              backbutton: true,
              title: 'Our Product',
              subtitle: 'Explore variety of Baltra products',
            ),
            const SizedBox(height: 21),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(12.0),
                shadowColor: Colors.black45,
                child: Container(
                  height: 45,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: TextFormField(
                    controller: searchController, // Use the controller here
                    style: const TextStyle(fontSize: 14.0),
                    decoration: const InputDecoration(
                      hintText: 'Search product using name or category',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w200,
                        fontSize: 14.0,
                        color: Color(0xff545454),
                      ),
                      prefixIcon: Icon(Icons.search, color: Color(0xff545454)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 21),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (filteredProducts.isEmpty) {
                return const Center(child: Text('No products found.'));
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.57,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return GestureDetector(
                    onTap: () async {
                      Get.dialog(
                        const Center(child: CircularProgressIndicator()),
                        barrierDismissible: false,
                      );
                      Get.back();

                      try {
                        await Future.wait([
                          controller.fetchProduct(product.id),
                          controller.fetchRelatedProducts(product.id),
                          reviewController.fetchReviewsAndRatings(product.id),
                        ]);
                        Get.back();
                        Get.to(() => ProductDetailPage(
                              product: controller.productDetails.value,
                              relatedProducts: controller.relatedProductsList,
                            ));
                      } catch (error) {
                        Get.back();
                        Get.snackbar(
                          'Error',
                          'Failed to load product details',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    child: ProductItem(product: product),
                  );
                },
              );
            })
          ]),
        ),
      ),
    );
  }
}
