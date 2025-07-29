// import 'package:baltra/features/products/controller/productController.dart';
// import 'package:baltra/features/products/controller/reviewController.dart';
// import 'package:baltra/features/products/data/productRepository.dart';
// import 'package:baltra/features/products/models/subcategoryProduct.dart';
// import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
// import 'package:baltra/features/products/presentation/widgets/prdouct2_skeletion.dart';
// import 'package:baltra/features/products/presentation/widgets/productItem.dart';
// import 'package:baltra/features/products/presentation/widgets/product_detail_loading%20_page_skeleton.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class ProductPage extends StatefulWidget {
//   ProductPage({super.key});

//   @override
//   State<ProductPage> createState() => _ProductPageState();
// }

// class _ProductPageState extends State<ProductPage> {
//   final ProductController controller =
//       Get.put(ProductController(productRepository: ProductRepository()));

//   final ReviewController reviewController = Get.put(ReviewController());

//   final TextEditingController searchController = TextEditingController();

//   RxList<Subcategoryproduct> filteredProducts = <Subcategoryproduct>[].obs;

//   @override
//   Widget build(BuildContext context) {
//     void filterProducts(String query) {
//       if (query.isEmpty) {
//         filteredProducts.assignAll(controller.subCategoryProductsList);
//       } else {
//         filteredProducts
//             .assignAll(controller.subCategoryProductsList.where((product) {
//           return product.name.toLowerCase().contains(query.toLowerCase()) ||
//               product.model_name.toLowerCase().contains(query.toLowerCase());
//         }).toList());
//       }
//     }

//     ever(controller.subCategoryProductsList, (_) {
//       filterProducts(searchController.text);
//     });

//     searchController.addListener(() {
//       filterProducts(searchController.text);
//     });

//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               const AppBarWithSVG(
//                 backbutton: true,
//                 title: 'Our Product',
//                 subtitle: 'Explore variety of Baltra products',
//               ),
//               const SizedBox(height: 21),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                 child: Material(
//                   elevation: 5.0,
//                   borderRadius: BorderRadius.circular(12.0),
//                   shadowColor: Colors.black45,
//                   child: Container(
//                     height: 45,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 4.0, vertical: 10.0),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12.0),
//                     ),
//                     child: TextFormField(
//                       controller: searchController,
//                       style: const TextStyle(fontSize: 14.0),
//                       decoration: const InputDecoration(
//                         hintText: 'Search product using name or category',
//                         hintStyle: TextStyle(
//                           fontWeight: FontWeight.w200,
//                           fontSize: 14.0,
//                           color: Color(0xff545454),
//                         ),
//                         prefixIcon:
//                             Icon(Icons.search, color: Color(0xff545454)),
//                         border: InputBorder.none,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 21),
//               Obx(() {
//                 if (controller.isLoading.value ||
//                     controller.subCategoryProductsList.isEmpty) {
//                   return GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     padding: const EdgeInsets.all(8.0),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       crossAxisSpacing: 8.0,
//                       mainAxisSpacing: 8.0,
//                       childAspectRatio: 0.57,
//                     ),
//                     itemCount: 8,
//                     itemBuilder: (context, index) {
//                       return const Product2Skeleton();
//                     },
//                   );
//                 }
//                 if (filteredProducts.isEmpty) {
//                   return const Center(child: Text('No products found.'));
//                 }
//                 return GridView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   padding: const EdgeInsets.all(8.0),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 8.0,
//                     mainAxisSpacing: 8.0,
//                     childAspectRatio: 0.57,
//                   ),
//                   itemCount: filteredProducts.length,
//                   itemBuilder: (context, index) {
//                     final product = filteredProducts[index];
//                     return GestureDetector(
//                       onTap: () {
//                         Get.to(() =>
//                             ProductDetailLoadingPage(productId: product.id));
//                       },
//                       child: ProductItem(product: product),
//                     );
//                   },
//                 );
//               }),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:baltra/features/products/controller/productController.dart';
import 'package:baltra/features/products/controller/reviewController.dart';
import 'package:baltra/features/products/data/productRepository.dart';
import 'package:baltra/features/products/models/subcategoryProduct.dart';
import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
import 'package:baltra/features/products/presentation/widgets/prdouct2_skeletion.dart';
import 'package:baltra/features/products/presentation/widgets/productItem.dart';
import 'package:baltra/features/products/presentation/widgets/product_detail_loading%20_page_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductPage extends StatefulWidget {
  ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final ProductController controller =
      Get.put(ProductController(productRepository: ProductRepository()));

  final ReviewController reviewController = Get.put(ReviewController());

  final TextEditingController searchController = TextEditingController();

  RxList<Subcategoryproduct> filteredProducts = <Subcategoryproduct>[].obs;

  @override
  Widget build(BuildContext context) {
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
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 21),
              Obx(() {
                // Show skeleton only when actually loading
                if (controller.isLoading.value) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 0.57,
                    ),
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      return const Product2Skeleton();
                    },
                  );
                }
                // Show "No products found" when not loading and no products available
                if (controller.subCategoryProductsList.isEmpty ||
                    filteredProducts.isEmpty) {
                  return const Center(child: Text('No products available.'));
                }
                // Show products when available
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
                      onTap: () {
                        Get.to(() =>
                            ProductDetailLoadingPage(productId: product.id));
                      },
                      child: ProductItem(product: product),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
