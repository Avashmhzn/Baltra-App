import 'package:baltra/features/products/controller/productController.dart';
import 'package:baltra/features/products/data/productRepository.dart';
import 'package:baltra/features/products/models/category.dart';
import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
import 'package:baltra/features/products/presentation/widgets/categoryCard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import the ProductItemSkeleton widget
import 'package:baltra/features/products/presentation/widgets/product_skeleton_item.dart';

class CategoryPage extends StatefulWidget {
  CategoryPage({super.key});

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
    ever(productController.categoryList, (_) {
      filteredCategories.assignAll(productController.categoryList);
    });
    if (productController.categoryList.isNotEmpty) {
      filteredCategories.assignAll(productController.categoryList);
    }
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
    await productController.fetchCategories(); // Assuming this method exists
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
                  if (productController.isLoading.value ||
                      filteredCategories.isEmpty) {
                    // Show skeleton loader while loading or if the filtered list is empty
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
                        itemCount: 4, // Show 4 skeleton items while loading
                        itemBuilder: (context, index) {
                          return const ProductItemSkeleton();
                        },
                      ),
                    );
                  }
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