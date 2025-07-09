import 'dart:developer';

import 'package:baltra/features/applicationCare/controller/myProductController.dart';
import 'package:baltra/features/applicationCare/data/productRepository.dart';
import 'package:baltra/features/products/presentation/screens/reward_point_page.dart';
import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart'; // Add this for skeleton effect

class ExtendWarrantyPage extends StatefulWidget {
  const ExtendWarrantyPage({super.key, required this.id});
  final int id;

  @override
  State<ExtendWarrantyPage> createState() => _ExtendWarrantyPageState();
}

class _ExtendWarrantyPageState extends State<ExtendWarrantyPage>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  final Myproductcontroller myproductcontroller =
  Get.put(Myproductcontroller(productRepository: MyProductRepository()));

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 500), // Animation duration
      vsync: this,
    );

    // Define the Tween points
    animation = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut, // Animation curve
      ),
    );

    controller.forward();

    // Fetch product data after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      myproductcontroller.fetchWarrantyProduct(widget.id);
    });
    log("PRODUcT ID:::::::::::${widget.id}");
  }

  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.translationValues(
              0.0,
              animation.value * MediaQuery.of(context).size.height,
              0.0,
            ),
            child: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppBarWithSVG(
                      backbutton: true,
                      title: 'Extended Warranty',
                      subtitle: 'Get extended warranty for your products',
                    ),
                    const SizedBox(height: 40),
                    // Product details section
                    Obx(() {
                      if (myproductcontroller.isLoading.value ||
                          myproductcontroller.myProduct.value == null) {
                        return _buildProductSkeleton();
                      }

                      final product = myproductcontroller.myProduct.value!;
                      return Container(
                        margin: const EdgeInsets.only(left: 10, bottom: 32),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.network(
                              product.stockDetails.productImage,
                              height: 144,
                              width: 144,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.stockDetails.serialNumber,
                                  style: const TextStyle(
                                      color: Color(0xffB0B0B0), fontSize: 14),
                                ),
                                Text(
                                  product.stockDetails.modelName,
                                  style: const TextStyle(
                                      color: Color(0xff1a1a1a),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  'Model: ${product.stockDetails.modelNum}',
                                  style: const TextStyle(
                                      color: Color(0xff1a1a1a), fontSize: 16),
                                ),
                                Text(
                                  'Sotre: ${product.stockDetails.storeName}',
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: const TextStyle(
                                      color: Color(0xff1a1a1a), fontSize: 16),
                                ),
                                Text(
                                  'Purchased on: ${product.stockDetails.purchaseDate}',
                                  style: const TextStyle(
                                      color: Color(0xff1a1a1a), fontSize: 16),
                                ),
                                Text(
                                  'Warranty Expiry: ${product.stockDetails.warrantyExpiry}',
                                  style: const TextStyle(
                                      color: Color(0xff1a1a1a), fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    Center(
                        child: Text(
                          'Warranty Offers',
                          style: TextStyle(
                              fontSize: 24,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w700),
                        )),
                    const Center(
                        child: Text(
                          'Select the one that suits you best',
                          style: TextStyle(
                              fontSize: 15,
                              color: Color(0xff1a1a1a),
                              fontWeight: FontWeight.w300),
                        )),
                    Obx(() {
                      if (myproductcontroller.isLoading.value ||
                          myproductcontroller.myProduct.value == null) {
                        return _buildWarrantyOfferSkeleton();
                      }

                      final product = myproductcontroller.myProduct.value!;
                      return SizedBox(
                        height: 470,
                        width: 300,
                        child: PageView(
                          controller: _controller,
                          children: [
                            WarrantyCardWidget(
                                duration: product.warrantyDetails.duration,
                                price: product.warrantyDetails.price,
                                tier: product.warrantyDetails.tierType,
                                stockId: product.stockDetails.id),
                          ],
                          onPageChanged: (int index) {
                            setState(() {
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Skeleton for product details
  Widget _buildProductSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(left: 10, bottom: 32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 144,
              width: 144,
              color: Colors.grey[300],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: 100, color: Colors.grey[300]),
                const SizedBox(height: 10),
                Container(height: 24, width: 150, color: Colors.grey[300]),
                const SizedBox(height: 10),
                Container(height: 16, width: 120, color: Colors.grey[300]),
                const SizedBox(height: 10),
                Container(height: 16, width: 140, color: Colors.grey[300]),
                const SizedBox(height: 10),
                Container(height: 16, width: 130, color: Colors.grey[300]),
                const SizedBox(height: 10),
                Container(height: 16, width: 140, color: Colors.grey[300]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Skeleton for warranty offer
  Widget _buildWarrantyOfferSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 470,
        width: 300,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.only(top: 32, left: 28),
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 12, width: 50, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Container(height: 24, width: 100, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Container(height: 40, width: 120, color: Colors.grey[300]),
            const SizedBox(height: 20),
            Container(height: 14, width: 70, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Container(height: 12, width: 150, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Container(height: 12, width: 130, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Container(height: 12, width: 140, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Container(height: 12, width: 160, color: Colors.grey[300]),
            const SizedBox(height: 20),
            Container(height: 40, width: 200, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Container(height: 40, width: 200, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    _controller.dispose();
    super.dispose();
  }
}

class WarrantyCardWidget extends StatelessWidget {
  const WarrantyCardWidget({
    super.key,
    required this.price,
    required this.duration,
    required this.tier,
    required this.stockId,
  });
  final double price;
  final int duration;
  final String tier;
  final int stockId;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 700,
      width: 320,
      decoration: BoxDecoration(
          border: Border.all(color: const Color(0xffBE55FF)),
          borderRadius: BorderRadius.circular(24)),
      padding: const EdgeInsets.only(top: 32, left: 28),
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$duration Year',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xff0d0d0d).withOpacity(0.7),
            ),
          ),
          Text(
            tier,
            style: const TextStyle(fontSize: 24, color: Color(0xff0d0d0d)),
          ),
          Text(
            'Rs. $price',
            style: const TextStyle(
                fontSize: 40,
                color: Color(0xff0d0d0d),
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          const Text(
            'Includes',
            style: TextStyle(
                fontSize: 14,
                color: Color(0xff0d0d0d),
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 8),
          _buildRow(context, 'Loyalty Rewards Program'),
          _buildRow(context, 'Free Servicing'),
          _buildRow(context, 'Extended Warranty Offers'),
          _buildRow(context, 'Priority Customer Support'),
          _buildButton(context, 'Extend Now', () {
            // Handle warranty extension payment
          }),
          _buildButton(context, 'Redeem Loyalty', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return RewardsPage(
                stockId: stockId,
                duration: duration,
                price: price,
              );
            }));
          }),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, String text) {
    return Row(
      children: [
        SvgPicture.asset('assets/icons/right.svg'),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
              fontSize: 12, color: const Color(0xff0d0d0d).withOpacity(0.9)),
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsetsDirectional.only(
            top: 20, bottom: 0, start: 20, end: 20),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xffc871ca), Color(0xff6f2cff)]),
            borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}