import 'dart:developer';

import 'package:baltra/features/products/controller/productController.dart';
import 'package:baltra/features/products/data/productRepository.dart';
import 'package:baltra/features/products/models/subcategory.dart';
import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
import 'package:baltra/features/products/presentation/widgets/categoryCard.dart';
import 'package:baltra/features/products/presentation/widgets/sub_catagory_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart'; // Kept shimmer import as it's used in SubcategoryItemSkeleton

class SubcategoryPage extends StatefulWidget {
  SubcategoryPage({super.key});

  @override
  _SubcategoryPageState createState() => _SubcategoryPageState();
}

class _SubcategoryPageState extends State<SubcategoryPage> {
  final ProductController productController =
  Get.put(ProductController(productRepository: ProductRepository()));

  final TextEditingController searchController = TextEditingController();
  final RxList<Subcategory> filteredCategories = <Subcategory>[].obs;

  @override
  void initState() {
    super.initState();

    // Initially, show all categories
    ever(productController.subCategoryList, (_) {
      filteredCategories.assignAll(productController.subCategoryList);
    });

    // If subcategories are already available, ensure they're assigned
    if (productController.subCategoryList.isNotEmpty) {
      filteredCategories.assignAll(productController.subCategoryList);
    }
  }

  // Search functionality with debouncing
  void searchCategory(String query) {
    if (query.isEmpty) {
      // If the search is empty, show all subcategories
      filteredCategories.assignAll(productController.subCategoryList);
    } else {
      // Filter subcategories based on name
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AppBarWithSVG(
                backbutton: true,
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
                        hintText: 'Search categories',
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
                if (productController.isLoading.value) {
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
                      itemCount: 8, // Show 4 skeleton items
                      itemBuilder: (context, index) {
                        return const SubcategoryItemSkeleton(); // Use provided skeleton widget
                      },
                    ),
                  );
                }

                if (filteredCategories.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 50, color: Colors.grey),
                        SizedBox(height: 10),
                        Text('No categories found.'),
                      ],
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
                      Subcategory subcategory = filteredCategories[index];
                      return CategoryCard(
                        where: 'subCategory',
                        controller: productController,
                        id: subcategory.id,
                        image_url: subcategory.image_url,
                        name: subcategory.name,
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}