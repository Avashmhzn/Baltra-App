import 'package:baltra/features/products/controller/productController.dart';
import 'package:baltra/features/products/data/productRepository.dart';
import 'package:baltra/features/products/models/category.dart';
import 'package:baltra/features/products/presentation/screens/subcategory_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final ProductController productController =
      Get.put(ProductController(productRepository: ProductRepository()));
  final TextEditingController searchController = TextEditingController();
  final RxList<Category> filteredCategories = <Category>[].obs;

  @override
  void initState() {
    super.initState();
    ever(productController.categoryList, (_) {
      filteredCategories.assignAll(productController.categoryList);
    });
    if (productController.categoryList.isNotEmpty) {
      filteredCategories.assignAll(productController.categoryList);
    }
    productController.fetchCategories();
  }

  void searchCategory(String query) {
    if (query.isEmpty) {
      filteredCategories.assignAll(productController.categoryList);
    } else {
      filteredCategories.assignAll(
        productController.categoryList
            .where((category) =>
                category.name.toLowerCase().contains(query.toLowerCase()))
            .toList(),
      );
    }
  }

  Future<void> _refreshCategories() async {
    await productController.fetchCategories();
    filteredCategories.assignAll(productController.categoryList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshCategories,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Our Products',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Discover the complete Baltra range for your home and lifestyle.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

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
                        hintText: 'Search products, categories or models',
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                        prefixIcon: Icon(Icons.search,
                            color: Colors.grey.shade500, size: 22),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: searchCategory,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Category list
                Obx(() {
                  if (productController.isLoading.value) {
                    return _buildSkeletonList();
                  }

                  if (filteredCategories.isEmpty) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 48, color: Colors.grey),
                            SizedBox(height: 12),
                            Text(
                              'No categories found.',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredCategories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final category = filteredCategories[index];
                      return _CategoryListCard(
                        category: category,
                        onTap: () {
                          productController.fetchSubCategories(category.id);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SubcategoryPage(category: category),
                            ),
                          );
                        },
                      );
                    },
                  );
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// ponytail: hardcoded descriptors; upgrade to async API call `fetchCategoryDetails(id)` when backend supports it.
const _categoryDescriptors = {
  'home solutions': 'Fans • Air Coolers • AC • Iron Heaters & more',
  'kitchen appliances': 'Blenders • Juicers • Mixers • Rice Cookers & more',
  'personal care': 'Hair Dryers • Straighteners • Trimmers & more',
  'lighting': 'LED Bulbs • Tubes • Panel Lights & more',
  'grooming': 'Shavers • Trimmers • Hair Clippers & more',
  'home comfort': 'Heaters • Fans • Humidifiers & more',
  'cooking': 'Induction Cookers • Microwaves • Ovens & more',
  'water solutions': 'Water Purifiers • Dispensers & more',
};

String _getDescriptor(String name) {
  final key = name.toLowerCase().trim();
  return _categoryDescriptors[key] ??
      _categoryDescriptors.entries
          .firstWhere(
            (e) => key.contains(e.key.split(' ').first),
            orElse: () => const MapEntry('', 'Baltra - Quality for your home'),
          )
          .value;
}

class _CategoryListCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const _CategoryListCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasBanner = category.banner.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 140,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background: banner image or fallback color
              if (hasBanner)
                CachedNetworkImage(
                  imageUrl: category.banner,
                  fit: BoxFit.cover,
                  memCacheWidth: 800,
                  fadeInDuration: const Duration(milliseconds: 100),
                  placeholder: (_, __) => Container(
                    color: const Color(0xff2A2A2A),
                  ),
                  errorWidget: (_, __, ___) =>
                      Container(color: const Color(0xffFFF0F0)),
                )
              else
                Container(color: const Color(0xffFFF0F0)),

              // Gradient overlay for text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: hasBanner
                        ? [
                            Colors.black.withValues(alpha: 0.65),
                            Colors.black.withValues(alpha: 0.1),
                          ]
                        : [
                            const Color(0xffE91C1C).withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                  ),
                ),
              ),

              // Content row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            category.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: hasBanner ? Colors.white : const Color(0xff1A1A1A),
                              letterSpacing: 0.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _getDescriptor(category.name),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: hasBanner
                                  ? Colors.white.withValues(alpha: 0.85)
                                  : Colors.grey.shade600,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Arrow button
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: hasBanner
                            ? Colors.white.withValues(alpha: 0.2)
                            : const Color(0xffE91C1C),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
