import 'dart:developer';

import 'package:baltra/core/utils/constants.dart';
import 'package:baltra/features/products/controller/productController.dart';
import 'package:baltra/features/products/data/productRepository.dart';
import 'package:baltra/features/products/presentation/screens/product_detail_page.dart';
import 'package:baltra/features/products/presentation/widgets/homepageCard.dart';
// import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List _promotionList = [
    'assets/images/promotion_1.png',
    'assets/images/promotion_2.png',
    'assets/images/promotion_3.png',
  ];
  final ProductController productController =
      Get.put(ProductController(productRepository: ProductRepository()));

  String name = 'Guest';
  int loyaltyPoint = 1;

  @override
  void initState() {
    super.initState();
    _loadName();
    productController.fetchProducts(1);
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                // mainAxisSize: MainAxisSize.min,
                fit: StackFit.loose,
                children: [
                  Container(
                      height: 150,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Color(0xffE91C1C), Color(0xff831010)]),
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
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
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
                      )),
                  Material(
                    color: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 20,
                    child: Container(
                      margin:
                          const EdgeInsets.only(top: 88, right: 15, left: 15),
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
                                height:
                                    MediaQuery.of(context).size.height * 0.1,
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
                                  SizedBox(
                                    height: 10,
                                  ),
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
                padding: const EdgeInsets.only(left: 16.0, bottom: 8, top: 10),
                child: Text(
                  "Our Products",
                  softWrap: true,
                  maxLines: 2, // Adjust maxLines as needed
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff4A4A4A)),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                ),
                child: Obx(() {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Other components, like header, etc.
                        // const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: [
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 14.0,
                                        mainAxisSpacing: 8.0,
                                        childAspectRatio: 0.5),
                                itemCount:
                                    productController.allProductsList.length,
                                itemBuilder: (context, index) {
                                  final product =
                                      productController.allProductsList[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Get.to(
                                          ProductDetailPage(product: product));
                                    },
                                    child: Homepagecard(product: product),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              if (productController.isLoading.isFalse &&
                                  productController.allProductsList.isNotEmpty)
                                ElevatedButton(
                                  onPressed: productController.loadMore,
                                  child: const Text('Load More'),
                                ),
                              if (productController.isLoading.isTrue)
                                const CircularProgressIndicator(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(
                height: 20,
              ),
              // CarouselSlider(
              //   options: CarouselOptions(
              //     autoPlay: true,
              //   ),
              //   items: _promotionList
              //       .map((item) => ClipRRect(
              //             borderRadius: BorderRadius.circular(20),
              //             child: Container(
              //               decoration:
              //                   const BoxDecoration(color: Colors.white),
              //               margin: const EdgeInsets.symmetric(horizontal: 8),
              //               child: Image(
              //                 image: AssetImage(item),
              //                 fit: BoxFit.contain,
              //               ),
              //             ),
              //           ))
              //       .toList(),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
