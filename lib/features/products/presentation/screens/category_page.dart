import 'package:baltra/features/products/controller/productController.dart';
import 'package:baltra/features/products/data/productRepository.dart';
import 'package:baltra/features/products/models/category.dart';
import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
import 'package:baltra/features/products/presentation/widgets/categoryCard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import the CategorySkeleton widget
import 'package:baltra/features/products/presentation/widgets/category_skeleton.dart'; // Adjust the import path as needed

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final ProductController productController =
      Get.put(ProductController(productRepository: ProductRepository()));
  final TextEditingController searchController = TextEditingController();
  final RxList<Category> filteredCategories = <Category>[].obs;

  @override
  void initState() {
    super.initState();
    // Update filteredCategories whenever categoryList changes
    ever(productController.categoryList, (_) {
      filteredCategories.assignAll(productController.categoryList);
    });
    // Initialize filteredCategories if categoryList already has data
    if (productController.categoryList.isNotEmpty) {
      filteredCategories.assignAll(productController.categoryList);
    }
    // Fetch categories on page load
    productController.fetchCategories();
  }

  // Function to filter categories based on search query
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

  // Function to refresh categories
  Future<void> _refreshCategories() async {
    await productController.fetchCategories(); // Fetch categories on refresh
    filteredCategories.assignAll(productController.categoryList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshCategories,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const AppBarWithSVG(
                  backbutton: false,
                  title: 'Our Product',
                  subtitle: 'Explore variety of Baltra products',
                ),
                const SizedBox(height: 21),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(12.0),
                    shadowColor: Colors.black45,
                    child: Container(
                      height: 45,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: TextFormField(
                        controller: searchController,
                        style: const TextStyle(fontSize: 14.0),
                        decoration: const InputDecoration(
                          hintText: 'Search product using name or category',
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w200,
                            fontSize: 14.0,
                            color: Color(0xff545454),
                          ),
                          prefixIcon:
                              Icon(Icons.search, color: Color(0xff545454)),
                          border: InputBorder.none,
                        ),
                        onChanged: searchCategory,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 21),
                Obx(() {
                  // Show skeleton while loading or if no categories are available
                  if (productController.isLoading.value) {
                    const int skeletonCount =
                        8; // Fixed number of skeletons while loading
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                        ),
                        itemCount: skeletonCount,
                        itemBuilder: (context, index) {
                          return const CategorySkeleton();
                        },
                      ),
                    );
                  }
                  // Show actual category cards when data is loaded
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        Category category = filteredCategories[index];
                        return CategoryCard(
                          where: 'category',
                          controller: productController,
                          id: category.id,
                          image_url: category.image_url,
                          name: category.name,
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
