import 'package:baltra/features/products/controller/productController.dart';
import 'package:baltra/features/products/controller/reviewController.dart';
import 'package:baltra/features/products/data/productRepository.dart';
import 'package:baltra/features/products/models/category.dart';
import 'package:baltra/features/products/models/subcategoryProduct.dart';
import 'package:baltra/features/products/presentation/widgets/prdouct2_skeletion.dart';
import 'package:baltra/features/products/presentation/widgets/productItem.dart';
import 'package:baltra/features/products/presentation/widgets/product_detail_loading%20_page_skeleton.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductPage extends StatefulWidget {
  final Category? category;
  const ProductPage({super.key, this.category});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final ProductController controller =
      Get.put(ProductController(productRepository: ProductRepository()));

  final ReviewController reviewController = Get.put(ReviewController());

  final TextEditingController searchController = TextEditingController();

  RxList<Subcategoryproduct> filteredProducts = <Subcategoryproduct>[].obs;
  final RxString selectedSort = ''.obs;

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;

    void filterProducts(String query) {
      if (query.isEmpty) {
        filteredProducts.assignAll(controller.subCategoryProductsList);
      } else {
        filteredProducts
            .assignAll(controller.subCategoryProductsList.where((product) {
          return product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.model_name.toLowerCase().contains(query.toLowerCase());
        }).toList());
      }
    }

    ever(controller.subCategoryProductsList, (_) {
      filterProducts(searchController.text);
    });

    searchController.addListener(() {
      filterProducts(searchController.text);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button + title
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, size: 24),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'Products',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff1A1A1A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xffF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: searchController,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search by name or model',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      prefixIcon: Icon(Icons.search,
                          color: Colors.grey.shade500, size: 22),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Filter chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(() => Row(
                        children: [
                          _filterChip('Sort', Icons.swap_vert,
                              isSelected: selectedSort.value == 'Sort'),
                          const SizedBox(width: 8),
                          _filterChip('Price', Icons.attach_money,
                              isSelected: selectedSort.value == 'Price'),
                          const SizedBox(width: 8),
                          _filterChip('Warranty', Icons.shield_outlined,
                              isSelected: selectedSort.value == 'Warranty'),
                          const SizedBox(width: 8),
                          _filterChip('Power', Icons.bolt,
                              isSelected: selectedSort.value == 'Power'),
                        ],
                      )),
                ),
              ),
              const SizedBox(height: 16),

              // Hero banner
              if (cat != null && cat.banner.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: cat.banner,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          memCacheWidth: 600,
                          placeholder: (_, __) => Container(
                            height: 160,
                            color: Colors.grey.shade200,
                          ),
                          errorWidget: (_, __, ___) => const SizedBox.shrink(),
                        ),
                        Container(
                          width: double.infinity,
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.black.withValues(alpha: 0.6),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(20),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            cat.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Products grid
              Obx(() {
                if (controller.isLoading.value) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.57,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return const Product2Skeleton();
                    },
                  );
                }

                if (controller.subCategoryProductsList.isEmpty ||
                    filteredProducts.isEmpty) {
                  return const SizedBox(
                    height: 200,
                    child: Center(
                      child: Text('No products available.',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'All Products (${filteredProducts.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff1A1A1A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.57,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return GestureDetector(
                          onTap: () {
                            Get.to(() => ProductDetailLoadingPage(
                                productId: product.id));
                          },
                          child: ProductItem(product: product),
                        );
                      },
                    ),
                  ],
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label, IconData icon, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        if (selectedSort.value == label) {
          selectedSort.value = '';
        } else {
          selectedSort.value = label;
        }
        // ponytail: filter chips are visual-only for now, add sorting logic when API supports it
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffE91C1C) : const Color(0xffF5F5F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xffE91C1C) : const Color(0xffE0E0E0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isSelected ? Colors.white : const Color(0xff4A4A4A)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xff4A4A4A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
