import 'dart:developer';

import 'package:baltra/features/applicationCare/controller/myProductController.dart';
import 'package:baltra/features/applicationCare/data/productRepository.dart';
import 'package:baltra/features/applicationCare/models/myProduct.dart';
import 'package:baltra/features/applicationCare/presentation/widgets/add_product_dialog.dart';
import 'package:baltra/features/applicationCare/presentation/widgets/myProduct_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MyProductPage extends StatefulWidget {
  const MyProductPage({super.key});

  @override
  State<MyProductPage> createState() => _MyProductPageState();
}

final Myproductcontroller myproductcontroller =
    Get.put(Myproductcontroller(productRepository: MyProductRepository()));

class _MyProductPageState extends State<MyProductPage> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final newIndex = _pageController.page?.round() ?? 0;
      if (newIndex != _currentIndex) {
        setState(() {
          _currentIndex = newIndex;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return QRScannerScreen();
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      color: Theme.of(context).primaryColor,
                      child: const Text(
                        'Add Product',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
              Obx(() {
                if (myproductcontroller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (myproductcontroller.myProducts.isEmpty) {
                  return Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 6,
                      ),
                      const Center(
                          child: Text(
                              'You have not added any product.\nplease scan the QR code of package to add.')),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 6,
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    /*SizedBox(
                      height: 510,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 00.0),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,

                          itemCount: myproductcontroller.myProducts.length,
                          itemBuilder: (context, index) {
                            log(myproductcontroller.myProducts[index].toString());
                            Myproduct myproduct =
                                myproductcontroller.myProducts[index];

                            return MyProdductCard(
                              product: myproduct,
                            );
                          },
                        ),
                      ),
                    ),*/
                    SizedBox(
                      height: 510,
                      child: PageView.builder(
                        scrollDirection: Axis.horizontal,
                        controller: _pageController,
                        itemCount: myproductcontroller.myProducts.length,
                        itemBuilder: (context, index) {
                          log(myproductcontroller.myProducts[index].toString());
                          Myproduct myproduct =
                          myproductcontroller.myProducts[index];

                          return MyProdductCard(
                            product: myproduct,
                          );
                        },
                      ),
                    ),

                    AnimatedSmoothIndicator(
                      activeIndex: _currentIndex,
                      count: myproductcontroller.myProducts.length,
                      effect: ScrollingDotsEffect(
                        dotWidth: 8.0,
                        dotHeight: 8.0,
                        activeDotColor: Theme.of(context).primaryColor,
                        dotColor: Colors.grey.shade300,
                      ),
                    )
                  ],
                );
              }),
              Container(
                height: 135,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xffD7D7D7)),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset('assets/icons/what.svg'),
                    const Text(
                      'How do I add products?',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                    const Text(
                      'To add more products, scan the QR code in the product',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 14),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
