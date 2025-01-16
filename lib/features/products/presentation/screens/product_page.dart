import 'package:baltra/features/products/controller/productController.dart';
import 'package:baltra/features/products/controller/reviewController.dart';
import 'package:baltra/features/products/data/productRepository.dart';
import 'package:baltra/features/products/presentation/screens/product_detail_page.dart';
import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
import 'package:baltra/features/products/presentation/widgets/productItem.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductPage extends StatelessWidget {
  final ProductController controller =
      Get.put(ProductController(productRepository: ProductRepository()));
  final ReviewController reviewController = Get.put(ReviewController());

  ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Column(children: [
          const AppBarWithSVG(
            backbutton: true,
            title: 'Our Product',
            subtitle: 'Explore variety of Baltra products',
          ),
          const SizedBox(
            height: 21,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Material(
              elevation: 5.0,
              borderRadius: BorderRadius.circular(12.0),
              shadowColor: Colors.black45,
              child: Container(
                height: 45,
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: TextFormField(
                  style: const TextStyle(
                    fontSize: 14.0,
                  ),
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
          const SizedBox(
            height: 21,
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.subCategoryProductsList.isEmpty) {
              return const Center(
                  child: Text('No any Products for this Subcategory found.'));
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
              itemCount: controller.subCategoryProductsList.length,
              itemBuilder: (context, index) {
                final product = controller.subCategoryProductsList[index];
                return GestureDetector(
                  onTap: () async {
                    Get.dialog(
                      const Center(child: CircularProgressIndicator()),
                      barrierDismissible: false,
                    );

                    try {
                      // Run all fetch operations concurrently
                      await Future.wait([
                        controller.fetchProduct(product.id),
                        controller.fetchRelatedProducts(product.id),
                        reviewController.fetchReviewsAndRatings(product.id),
                      ]);

                      // Close loading indicator
                      Get.back();

                      // Navigate to product detail page
                      Get.to(() => ProductDetailPage(
                            product: controller.productDetails.value,
                            relatedProducts: controller.relatedProductsList,
                          ));
                    } catch (error) {
                      // Close loading indicator
                      Get.back();

                      // Show error message
                      Get.snackbar(
                        'Error',
                        'Failed to load product details',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  child: ProductItem(
                    product: product,
                  ),
                );
              },
            );
          })
        ]),
      ),
    ));
  }
}
