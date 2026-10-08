import 'package:baltra/features/applicationCare/controller/myProductController.dart';
import 'package:baltra/features/applicationCare/data/productRepository.dart';
import 'package:baltra/features/products/presentation/widgets/eligiabilityCard.dart';
import 'package:baltra/features/products/presentation/widgets/qnaSection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart'; // Add this for skeleton effect

class RewardsPage extends StatefulWidget {
  const RewardsPage(
      {super.key,
        required this.stockId,
        required this.duration,
        required this.price});
  final int stockId;
  final int duration;
  final double price;

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

final Myproductcontroller myproductcontroller =
Get.put(Myproductcontroller(productRepository: MyProductRepository()));

class _RewardsPageState extends State<RewardsPage> {
  @override
  void initState() {
    super.initState();
    // Delay the fetch until after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      myproductcontroller.getLoyalty(widget.stockId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 214,
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                        top: 10, left: 20, right: 20, bottom: 0),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/reward.png'),
                          fit: BoxFit.fill),
                      gradient: LinearGradient(
                          colors: [Color(0xffE91C1C), Color(0xff831010)]),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RichText(
                              text: const TextSpan(children: [
                                TextSpan(
                                    text: "Welcome to",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.w400,
                                    )),
                                TextSpan(
                                    text: '\nBALTRA\'S\nLOYALTY PAGE',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.w700,
                                    )),
                              ]),
                            ),
                            const Spacer(),
                            const Image(
                              image: AssetImage('assets/images/pp.png'),
                              height: 115,
                              width: 115,
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/medal.png',
                                  height: 36,
                                  width: 36,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Obx(
                                          () {
                                        if (myproductcontroller.isLoading.value ||
                                            myproductcontroller.loyalty.value == null) {
                                          return _buildPointsSkeleton();
                                        }
                                        return Text(
                                          '${myproductcontroller.loyalty.value!.reward_points} Points',
                                          style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white),
                                        );
                                      },
                                    ),
                                    const Text(
                                      'Available Points',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Obx(
                                  () {
                                if (myproductcontroller.isLoading.value ||
                                    myproductcontroller.loyalty.value == null) {
                                  return _buildRedeemButtonSkeleton();
                                }
                                return GestureDetector(
                                  onTap: () {
                                    myproductcontroller.redeemLoyaltyController(
                                        widget.stockId,
                                        widget.duration,
                                        widget.price);
                                  },
                                  child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 15),
                                      padding: const EdgeInsets.all(10),
                                      height: 50,
                                      color: Theme.of(context).primaryColor,
                                      child: const Center(
                                        child: Text(
                                          'Redeem Warranty',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      )),
                                );
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                height: 80,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    opacity: 0.3,
                    image: AssetImage('assets/images/bg.png'),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: const TextSpan(children: [
                        TextSpan(
                            text: "HOW IT",
                            style: TextStyle(
                              color: Color(0XFFF02323),
                              fontSize: 32,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w700,
                            )),
                        TextSpan(
                            text: ' WORKS!',
                            style: TextStyle(
                              fontSize: 32,
                              color: Color(0xff000C22),
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w700,
                            )),
                      ]),
                    ),
                    const Text(
                      'Get rewards for purchasing Baltra products',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: Color(0xff494040)),
                    ),
                    const SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
              Container(
                height: 300,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    opacity: 0.3,
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/bg.png'),
                  ),
                ),
                child: Center(
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    height: 250,
                    width: 250,
                    color: const Color(0xffFAEAAF),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: AssetImage('assets/images/loyalty1.png'),
                          height: 160,
                          width: 240,
                        ),
                        Text(
                          'Buy Products',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Explore and buy products from our Baltra Retail Outlet in Teku',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 300,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    opacity: 0.3,
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/bg.png'),
                  ),
                ),
                child: Center(
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    height: 250,
                    width: 250,
                    color: const Color(0xffFAEAAF),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: AssetImage('assets/images/loyalty2.png'),
                          height: 160,
                          width: 300,
                        ),
                        Text(
                          'Buy Products',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Explore and buy products from our Baltra Retail Outlet in Teku',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 300,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    opacity: 0.3,
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/bg.png'),
                  ),
                ),
                child: Center(
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    height: 250,
                    width: 250,
                    color: const Color(0xffFAEAAF),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: AssetImage('assets/images/loyalty3.png'),
                          height: 160,
                          width: 240,
                        ),
                        Text(
                          'Buy Products',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Explore and buy products from our Baltra Retail Outlet in Teku',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              RichText(
                text: const TextSpan(children: [
                  TextSpan(
                      text: "TERMS",
                      style: TextStyle(
                        color: Color(0XFFF02323),
                        fontSize: 32,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w700,
                      )),
                  TextSpan(
                      text: ' AND',
                      style: TextStyle(
                        fontSize: 32,
                        color: Color(0xff000C22),
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w700,
                      )),
                  TextSpan(
                      text: "CONDITIONS",
                      style: TextStyle(
                        color: Color(0XFFF02323),
                        fontSize: 32,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w700,
                      )),
                ]),
              ),
              const Text('Get rewards for purchasing Baltra products',
                  style: TextStyle(fontSize: 14, color: Color(0xff494040))),
              const Image(
                image: AssetImage('assets/images/tnc.png'),
                height: 278,
              ),
              const SizedBox(
                height: 22,
              ),
              const EligibabilityCard(
                desc: '''
      - Only registered users with valid Baltra accounts are eligible to redeem points.
      - Points earned through legitimate actions outlined in the rewards program terms may be redeemed.''',
                title: '1. Eligibality',
              ),
              const EligibabilityCard(
                desc: '''
      - Upon reaching the threshold, users can utilize their points to purchase warranty directly  from the website/app''',
                title: '2. Utilization',
              ),
              const EligibabilityCard(
                desc: '''
      - If users opt not to purchase additional warranty, they must visit the Baltra retail outlet in Teku to redeem their points.''',
                title: '3. Redeem',
              ),
              const EligibabilityCard(
                desc: '''
      - Point redemption offers are subject to the discretion of the company and will be determined solely by the company''',
                title: '4. Offers',
              ),
              const EligibabilityCard(
                desc: '''
      - Users are not permitted to redeem the entire point balance. A certain portion of points will remain in the user's account and will not be nullified.''',
                title: '5. Point Balance',
              ),
              const SizedBox(height: 15),
              const QnaSection(),
              const SizedBox(
                height: 15,
              )
            ],
          ),
        ),
      ),
    );
  }

  // Skeleton for points display
  Widget _buildPointsSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 24,
        width: 100,
        color: Colors.grey[300],
      ),
    );
  }

  // Skeleton for redeem button
  Widget _buildRedeemButtonSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 15),
        padding: const EdgeInsets.all(10),
        height: 50,
        width: 200,
        color: Colors.grey[300],
      ),
    );
  }
}