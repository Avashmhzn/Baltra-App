import 'package:baltra/features/products/controller/productController.dart';
import 'package:baltra/features/products/models/category.dart';
import 'package:baltra/features/products/models/subcategory.dart';
import 'package:baltra/features/products/presentation/screens/product_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class SubcategoryPage extends StatefulWidget {
  final Category? category;

  const SubcategoryPage({super.key, this.category});

  @override
  _SubcategoryPageState createState() => _SubcategoryPageState();
}

class _SubcategoryPageState extends State<SubcategoryPage> {
  final ProductController productController = Get.find<ProductController>();

  final TextEditingController searchController = TextEditingController();
  final RxList<Subcategory> filteredCategories = <Subcategory>[].obs;

  @override
  void initState() {
    super.initState();
    // Cache clearing on init to avoid showing previous categories
    if (productController.subCategoryList.isNotEmpty) {
      filteredCategories.assignAll(productController.subCategoryList);
    }

    ever(productController.subCategoryList, (_) {
      filteredCategories.assignAll(productController.subCategoryList);
    });
  }

  void searchCategory(String query) {
    if (query.isEmpty) {
      filteredCategories.assignAll(productController.subCategoryList);
    } else {
      filteredCategories.assignAll(
        productController.subCategoryList
            .where((subcategory) =>
                subcategory.name.toLowerCase().contains(query.toLowerCase()))
            .toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button + title header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, size: 24),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sub Categories',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff1A1A1A),
                            ),
                          ),
                          if (cat?.name != null && cat!.name.isNotEmpty)
                            Text(
                              cat.name,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
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
                      hintText: 'Search sub categories',
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
                    onChanged: searchCategory,
                  ),
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
                          memCacheWidth: 600, // Faster load & cache
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

              // Feature icons row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _featureChip(Icons.grid_view_rounded, 'Wide Range'),
                    _featureChip(Icons.verified, 'Best Quality'),
                    _featureChip(Icons.bolt, 'Energy Efficient'),
                    _featureChip(Icons.people, 'Trusted'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Popular Categories horizontal scroll
              Obx(() {
                if (productController.subCategoryList.length > 2) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Popular Categories',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff1A1A1A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount:
                              productController.subCategoryList.length > 6
                                  ? 6
                                  : productController.subCategoryList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final sub =
                                productController.subCategoryList[index];
                            return GestureDetector(
                              onTap: () {
                                productController
                                    .fetchSubCategoryProducts(sub.id);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductPage(category: widget.category),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xffE91C1C),
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: sub.image_url,
                                        fit: BoxFit.contain,
                                        placeholder: (_, __) => Container(
                                          color: Colors.grey.shade100,
                                        ),
                                        errorWidget: (_, __, ___) => const Icon(
                                          Icons.category,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    width: 70,
                                    child: Text(
                                      sub.name,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff4A4A4A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),

              // Subcategory list
              Obx(() {
                if (productController.isLoading.value) {
                  return _buildSkeletonList();
                }

                if (filteredCategories.isEmpty) {
                  return const SizedBox(
                    height: 200,
                    child: Center(
                      child: Text('No sub categories found.',
                          style: TextStyle(color: Colors.grey)),
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
                    final sub = filteredCategories[index];
                    return GestureDetector(
                      onTap: () {
                        productController.fetchSubCategoryProducts(sub.id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductPage(category: widget.category),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xffEEEEEE)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Image left
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFFFFFFF),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: CachedNetworkImage(
                                      imageUrl: sub.image_url,
                                      fit: BoxFit.contain,
                                      memCacheWidth: 200,
                                      fadeInDuration:
                                          const Duration(milliseconds: 150),
                                      placeholder: (_, __) =>
                                          const SizedBox.shrink(),
                                      errorWidget: (_, __, ___) => Icon(
                                        Icons.broken_image,
                                        color: Colors.grey.shade400,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Name
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  sub.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff1A1A1A),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Arrow
                            Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Color(0xffE91C1C),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureChip(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xffFFF0F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xffE91C1C), size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xff4A4A4A),
          ),
        ),
      ],
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
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
