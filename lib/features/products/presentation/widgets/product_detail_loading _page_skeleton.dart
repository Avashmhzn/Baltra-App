import 'package:baltra/features/products/controller/productController.dart';
import 'package:baltra/features/products/controller/reviewController.dart';
import 'package:baltra/features/products/presentation/screens/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ProductDetailLoadingPage extends StatefulWidget {
  final int productId;

  const ProductDetailLoadingPage({super.key, required this.productId});

  @override
  State<ProductDetailLoadingPage> createState() => _ProductDetailLoadingPageState();
}

class _ProductDetailLoadingPageState extends State<ProductDetailLoadingPage> {
  final ProductController controller = Get.find<ProductController>();
  final ReviewController reviewController = Get.find<ReviewController>();

  @override
  void initState() {
    super.initState();
    // Delay the fetch until after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProductData();
    });
  }

  void _fetchProductData() async {
    try {
      controller.isLoading.value = true;
      controller.productDetails.value = null;
      controller.relatedProductsList.clear();
      await Future.wait([
        controller.fetchSelectedProduct(widget.productId), // Use fetchSelectedProduct for consistency
        controller.fetchRelatedProducts(widget.productId),
        reviewController.fetchReviewsAndRatings(widget.productId),
      ]);
      if (mounted) {
        if (controller.productDetails.value != null) {
          Get.off(() => ProductDetailPage(
            product: controller.productDetails.value,
            relatedProducts: controller.relatedProductsList,
          ));
        } else {
          throw Exception("Product details not found");
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('Error', 'Failed to load product details: $e',
            snackPosition: SnackPosition.BOTTOM);
        Navigator.pop(context); // Return to HomePage on error
      }
    } finally {
      if (mounted) {
        controller.isLoading.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ProductDetailSkeleton(),
    );
  }
}

class ProductDetailSkeleton extends StatelessWidget {
  const ProductDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Arrow
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    color: Colors.white,
                  ),
                ],
              ),
              // Breadcrumb
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 8.0, bottom: 8.0),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Container(
                      width: 120,
                      height: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Container(
                      width: 100,
                      height: 14,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              // Main Image with Thumbnail
              SizedBox(
                height: 300,
                width: double.infinity,
                child: Stack(
                  children: [
                    Container(
                      height: 300,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: Container(
                        width: 75,
                        height: 75,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Thumbnails Row
              Container(
                height: 80,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4, // Simulate 4 thumbnails
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 75,
                      height: 75,
                      color: Colors.white,
                    );
                  },
                ),
              ),
              // Product Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  width: 150,
                  height: 24,
                  color: Colors.white,
                ),
              ),
              // Model Number
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  width: 100,
                  height: 16,
                  color: Colors.white,
                ),
              ),
              // Divider
              Container(
                margin: const EdgeInsets.only(
                  top: 12,
                  bottom: 12,
                  right: 80,
                ),
                height: 1.5,
                color: Colors.grey[300],
              ),
              // Color Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Color',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              // Pricing Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Pricing',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  width: 100,
                  height: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              // Tabs
              SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 24),
                    Container(
                      width: 60,
                      height: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 24),
                    Container(
                      width: 60,
                      height: 20,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              // Specifications (under DESCRIPTION tab)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Product Specifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  2, // Match the number of bullet points in the image
                      (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(fontSize: 18),
                        ),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            height: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}