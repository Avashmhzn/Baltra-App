
import 'package:baltra/features/products/controller/productController.dart';
import 'package:baltra/features/products/data/productRepository.dart';
import 'package:baltra/features/products/models/subcategory.dart';
import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
import 'package:baltra/features/products/presentation/widgets/categoryCard.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubcategoryPage extends StatelessWidget {
  SubcategoryPage({super.key});
  final ProductController productController =
      Get.put(ProductController(productRepository: ProductRepository()));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            const AppBarWithSVG(
              backbutton: false,
              title: 'Our Product',
              subtitle: 'Explore variety of Baltra products',
            ),
            const SizedBox(
              height: 21,
            ),
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
              if (productController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (productController.subCategoryList.isEmpty) {
                return const Center(child: Text('No categories found.'));
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: productController.subCategoryList.length,
                  itemBuilder: (context, index) {
                    Subcategory subcategory =
                        productController.subCategoryList[index];
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
      )),
    );
  }
}
