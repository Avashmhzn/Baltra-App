// import 'dart:developer';
// import 'package:baltra/core/utils/constants.dart';
// import 'package:baltra/core/utils/sessionExpirationMixin.dart';
// import 'package:baltra/features/products/controller/productController.dart';
// import 'package:baltra/features/products/data/productRepository.dart';
// import 'package:baltra/features/products/models/product.dart';
// import 'package:baltra/features/products/presentation/widgets/homepageCard.dart';
// import 'package:baltra/features/products/presentation/widgets/product_detail_loading%20_page_skeleton.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../widgets/home_card_skeleton.dart' show HomepageCardSkeleton;

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> with SessionManager {
//   final ProductController productController =
//       Get.put(ProductController(productRepository: ProductRepository()));

//   String name = 'Guest';
//   int loyaltyPoint = 0;
//   int _itemsToShow = 4;
//   bool _isNavigating = false; // Debouncing flag

//   @override
//   void initState() {
//     super.initState();
//     checkSession(context);
//     _loadName();
//   }

//   Future<void> _loadName() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       name = prefs.getString('name') ?? 'Guest';
//       log("reward: ${prefs.getInt('reward_points')}");
//       loyaltyPoint = prefs.getInt('reward_points') ?? 0;
//       log("reward: $loyaltyPoint");
//     });
//   }

//   void _loadMoreItems() {
//     setState(() {
//       _itemsToShow += 4;
//     });
//   }

//   Future<void> _refreshProducts() async {
//     productController.allProductsList.clear(); // Clear existing products
//     await productController.fetchProducts(1); // Fetch fresh products
//     setState(() {
//       _itemsToShow = 4; // Reset to initial number
//     });
//     await _loadName();
//   }

//   // Method to get sorted products (latest first)
//   List<Product> _getSortedProducts() {
//     final products = productController.allProductsList.toList();
//     products.sort(
//         (a, b) => (b.id ?? 0).compareTo(a.id ?? 0)); // Sort by id descending
//     return products;
//   }

//   // Updated method to navigate to ProductDetailLoadingPage
//   Future<void> _navigateToProductDetails(int productId) async {
//     if (_isNavigating) return; // Prevent multiple simultaneous navigations
//     _isNavigating = true;

//     try {
//       log("Navigating to ProductDetailLoadingPage for productId: $productId");
//       // Navigate to ProductDetailLoadingPage, which will show the skeleton and fetch the data
//       await Get.to(() => ProductDetailLoadingPage(productId: productId));
//     } finally {
//       _isNavigating = false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: RefreshIndicator(
//           onRefresh: _refreshProducts,
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             padding: EdgeInsets.only(
//               bottom: 70.0 + MediaQuery.of(context).padding.bottom,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Stack(
//                   fit: StackFit.loose,
//                   children: [
//                     Container(
//                       height: 150,
//                       width: double.infinity,
//                       decoration: const BoxDecoration(
//                         gradient: LinearGradient(
//                             colors: [Color(0xffE91C1C), Color(0xff831010)]),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 15.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               children: [
//                                 SizedBox(
//                                   height:
//                                       MediaQuery.of(context).size.height * 0.02,
//                                 ),
//                                 RichText(
//                                   text: TextSpan(children: [
//                                     const TextSpan(
//                                         text: "Hello, ",
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 21.883,
//                                           fontStyle: FontStyle.normal,
//                                           fontWeight: FontWeight.w400,
//                                         )),
//                                     TextSpan(
//                                         text: name.toCapitalized(),
//                                         style: const TextStyle(
//                                           fontSize: 21.883,
//                                           color: Colors.white,
//                                           fontStyle: FontStyle.normal,
//                                           fontWeight: FontWeight.w700,
//                                         )),
//                                   ]),
//                                 ),
//                                 const Text(
//                                   'How are you doing today?',
//                                   style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w200),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Material(
//                       color: Colors.transparent,
//                       shadowColor: Colors.transparent,
//                       elevation: 20,
//                       child: Container(
//                         margin:
//                             const EdgeInsets.only(top: 88, right: 15, left: 15),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 13, vertical: 10),
//                         height: MediaQuery.of(context).size.height * 0.15,
//                         color: Colors.white,
//                         width: double.infinity,
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 SizedBox(
//                                   height:
//                                       MediaQuery.of(context).size.height * 0.1,
//                                   child: Image.asset(
//                                     'assets/images/medal.png',
//                                     fit: BoxFit.contain,
//                                   ),
//                                 ),
//                                 Column(
//                                   children: [
//                                     Text(
//                                       'Rewards Points',
//                                       style: TextStyle(
//                                         color: Color(0xff2F2F2F),
//                                         fontSize: 15,
//                                       ),
//                                     ),
//                                     Text(
//                                       '$loyaltyPoint',
//                                       style: TextStyle(
//                                           fontSize: 28,
//                                           fontWeight: FontWeight.w700,
//                                           color: Color(0xff2f2f2f)),
//                                     ),
//                                     SizedBox(height: 10),
//                                   ],
//                                 )
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Padding(
//                   padding:
//                       const EdgeInsets.only(left: 16.0, bottom: 8, top: 10),
//                   child: Text(
//                     "Our Products",
//                     softWrap: true,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xff4A4A4A)),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   child: Obx(() {
//                     log("Product list length: ${productController.allProductsList.length}");
//                     if (productController.isLoading.isTrue ||
//                         productController.allProductsList.isEmpty) {
//                       // Show skeleton loader while loading or if the list is empty
//                       return GridView.builder(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         gridDelegate:
//                             const SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: 2,
//                                 crossAxisSpacing: 14.0,
//                                 mainAxisSpacing: 8.0,
//                                 childAspectRatio: 0.5),
//                         itemCount: 4, // Show 4 skeleton cards while loading
//                         itemBuilder: (context, index) {
//                           return const HomepageCardSkeleton();
//                         },
//                       );
//                     }

//                     // Get sorted products (latest first)
//                     final sortedProducts = _getSortedProducts();

//                     return SingleChildScrollView(
//                       child: Column(
//                         children: [
//                           Padding(
//                             padding:
//                                 const EdgeInsets.symmetric(horizontal: 8.0),
//                             child: Column(
//                               children: [
//                                 GridView.builder(
//                                   shrinkWrap: true,
//                                   physics: const NeverScrollableScrollPhysics(),
//                                   gridDelegate:
//                                       const SliverGridDelegateWithFixedCrossAxisCount(
//                                           crossAxisCount: 2,
//                                           crossAxisSpacing: 14.0,
//                                           mainAxisSpacing: 8.0,
//                                           childAspectRatio: 0.5),
//                                   itemCount:
//                                       _itemsToShow < sortedProducts.length
//                                           ? _itemsToShow
//                                           : sortedProducts.length,
//                                   itemBuilder: (context, index) {
//                                     final product = sortedProducts[index];
//                                     return GestureDetector(
//                                       onTap: () {
//                                         log("Navigating to Product Detail: ${product.id} - ${product.name}");
//                                         _navigateToProductDetails(product.id ??
//                                             0); // Updated navigation
//                                       },
//                                       child: Homepagecard(product: product),
//                                     );
//                                   },
//                                 ),
//                                 const SizedBox(height: 20),
//                                 if (productController.isLoading.isFalse &&
//                                     sortedProducts.length > _itemsToShow)
//                                   Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 20.0),
//                                     child: ElevatedButton(
//                                       onPressed: _loadMoreItems,
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: Colors.redAccent,
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 30.0, vertical: 12.0),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(30.0),
//                                         ),
//                                         elevation: 5,
//                                         shadowColor:
//                                             Color.fromRGBO(0, 0, 0, 0.3),
//                                       ),
//                                       child: Row(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: const [
//                                           Icon(Icons.add, color: Colors.white),
//                                           SizedBox(width: 5),
//                                           Text(
//                                             'Load More',
//                                             style: TextStyle(
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.bold,
//                                               color: Colors.white,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 if (productController.isLoading.isTrue)
//                                   Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 20.0),
//                                     child: CircularProgressIndicator(
//                                       valueColor: AlwaysStoppedAnimation<Color>(
//                                           Colors.redAccent),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:developer';
import 'package:baltra/core/utils/constants.dart';
import 'package:baltra/core/utils/sessionExpirationMixin.dart';
import 'package:baltra/features/products/controller/productController.dart';
import 'package:baltra/features/products/data/productRepository.dart';
import 'package:baltra/features/products/models/product.dart';
import 'package:baltra/features/products/presentation/widgets/homepageCard.dart';
import 'package:baltra/features/products/presentation/widgets/product_detail_loading%20_page_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/home_card_skeleton.dart' show HomepageCardSkeleton;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SessionManager {
  final ProductController productController =
      Get.put(ProductController(productRepository: ProductRepository()));

  String name = 'Guest';
  int loyaltyPoint = 0;
  int _itemsToShow = 4;
  bool _isNavigating = false; // Debouncing flag

  @override
  void initState() {
    super.initState();
    checkSession(context);
    _loadName();
    // Set system UI overlay style when the page initializes
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent to show gradient
      statusBarIconBrightness: Brightness.light, // Light icons for red gradient
      statusBarBrightness: Brightness.light, // For iOS compatibility
    ));
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'Guest';
      log("reward: ${prefs.getInt('reward_points')}");
      loyaltyPoint = prefs.getInt('reward_points') ?? 0;
      log("reward: $loyaltyPoint");
    });
  }

  void _loadMoreItems() {
    setState(() {
      _itemsToShow += 4;
    });
  }

  Future<void> _refreshProducts() async {
    productController.allProductsList.clear(); // Clear existing products
    await productController.fetchProducts(1); // Fetch fresh products
    setState(() {
      _itemsToShow = 4; // Reset to initial number
    });
    await _loadName();
  }

  // Method to get sorted products (latest first)
  List<Product> _getSortedProducts() {
    final products = productController.allProductsList.toList();
    products.sort(
        (a, b) => (b.id ?? 0).compareTo(a.id ?? 0)); // Sort by id descending
    return products;
  }

  // Updated method to navigate to ProductDetailLoadingPage
  Future<void> _navigateToProductDetails(int productId) async {
    if (_isNavigating) return; // Prevent multiple simultaneous navigations
    _isNavigating = true;

    try {
      log("Navigating to ProductDetailLoadingPage for productId: $productId");
      // Navigate to ProductDetailLoadingPage, which will show the skeleton and fetch the data
      await Get.to(() => ProductDetailLoadingPage(productId: productId));
    } finally {
      _isNavigating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: RefreshIndicator(
            onRefresh: _refreshProducts,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: 70.0 + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    fit: StackFit.loose,
                    children: [
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xffE91C1C), Color(0xff831010)],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02,
                                  ),
                                  RichText(
                                    text: TextSpan(children: [
                                      const TextSpan(
                                          text: "Hello, ",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 21.883,
                                            fontStyle: FontStyle.normal,
                                            fontWeight: FontWeight.w400,
                                          )),
                                      TextSpan(
                                          text: name.toCapitalized(),
                                          style: const TextStyle(
                                            fontSize: 21.883,
                                            color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                            fontWeight: FontWeight.w700,
                                          )),
                                    ]),
                                  ),
                                  const Text(
                                    'How are you doing today?',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w200),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 20,
                        child: Container(
                          margin: const EdgeInsets.only(
                              top: 88, right: 15, left: 15),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 13, vertical: 10),
                          height: MediaQuery.of(context).size.height * 0.15,
                          color: Colors.white,
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.1,
                                    child: Image.asset(
                                      'assets/images/medal.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Rewards Points',
                                        style: TextStyle(
                                          color: Color(0xff2F2F2F),
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        '$loyaltyPoint',
                                        style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xff2f2f2f)),
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16.0, bottom: 8, top: 10),
                    child: Text(
                      "Our Products",
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff4A4A4A)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Obx(() {
                      log("Product list length: ${productController.allProductsList.length}");
                      if (productController.isLoading.isTrue ||
                          productController.allProductsList.isEmpty) {
                        // Show skeleton loader while loading or if the list is empty
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 14.0,
                                  mainAxisSpacing: 8.0,
                                  childAspectRatio: 0.5),
                          itemCount: 4, // Show 4 skeleton cards while loading
                          itemBuilder: (context, index) {
                            return const HomepageCardSkeleton();
                          },
                        );
                      }

                      // Get sorted products (latest first)
                      final sortedProducts = _getSortedProducts();

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                children: [
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 14.0,
                                            mainAxisSpacing: 8.0,
                                            childAspectRatio: 0.5),
                                    itemCount:
                                        _itemsToShow < sortedProducts.length
                                            ? _itemsToShow
                                            : sortedProducts.length,
                                    itemBuilder: (context, index) {
                                      final product = sortedProducts[index];
                                      return GestureDetector(
                                        onTap: () {
                                          log("Navigating to Product Detail: ${product.id} - ${product.name}");
                                          _navigateToProductDetails(
                                              product.id ??
                                                  0); // Updated navigation
                                        },
                                        child: Homepagecard(product: product),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  if (productController.isLoading.isFalse &&
                                      sortedProducts.length > _itemsToShow)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20.0),
                                      child: ElevatedButton(
                                        onPressed: _loadMoreItems,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30.0, vertical: 12.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                          elevation: 5,
                                          shadowColor:
                                              Color.fromRGBO(0, 0, 0, 0.3),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.add,
                                                color: Colors.white),
                                            SizedBox(width: 5),
                                            Text(
                                              'Load More',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (productController.isLoading.isTrue)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20.0),
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.redAccent),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
