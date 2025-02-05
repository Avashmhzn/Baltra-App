/*
import 'package:baltra/features/applicationCare/presentation/widgets/product_tracking_card.dart';

import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
import 'package:flutter/material.dart';

class ProductMaintainancePage extends StatelessWidget {
  const ProductMaintainancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppBarWithSVG(
                subtitle: 'Know the status of your product',
                title: "Track Your Product",
                backbutton: true),
            const SizedBox(
              height: 24,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.0),
              child: Column(
                children: [
                  Text(
                    'On Process',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff1a1a1a)),
                  ),
                ],
              ),
            ),
            const Text(
              'The products that have been sent for repair',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff1a1a1a)),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: Text(
                      'Complained Registered',
                      maxLines: 2,
                      softWrap: true,
                      style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: const Text(
                      'Received at Service Center',
                      softWrap: true,
                      maxLines: 2,
                      style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: const Text(
                      maxLines: 2,
                      softWrap: true,
                      'Service Ongoing',
                      style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: const Text(
                      maxLines: 2,
                      softWrap: true,
                      'Dispatched',
                      style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    height: 6.0,
                    width: 6.0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    height: 2,
                    width: MediaQuery.of(context).size.width * 0.2,
                    color: Colors.grey,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    height: 6.0,
                    width: 6.0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    height: 2,
                    width: MediaQuery.of(context).size.width * 0.25,
                    color: Colors.grey,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    height: 6.0,
                    width: 6.0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    height: 2,
                    width: MediaQuery.of(context).size.width * 0.25,
                    color: Colors.grey,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    height: 6.0,
                    width: 6.0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  const ProductTrackingCard(),
                  const SizedBox(
                    height: 35,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Damaged Product Image',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                      ),
                      Container(
                        height: 30,
                        width: 100,
                        color: const Color(0xff202D31),
                        padding: const EdgeInsets.all(8),
                        child: const Center(
                          child: Text(
                            'Download',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Image.asset(
                    'assets/images/damagedproduct.png',
                    height: 180,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}

class ProcessStep {
  final String title;
  final String date;
  final bool isCompleted;

  ProcessStep(
      {required this.title, required this.date, required this.isCompleted});
}
*/

import 'dart:math';

import 'package:baltra/features/applicationCare/controller/myProductController.dart';
import 'package:baltra/features/applicationCare/data/productRepository.dart';
import 'package:baltra/features/applicationCare/models/myProduct.dart';
import 'package:baltra/features/applicationCare/presentation/ui/product_tracking_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductMaintainancePage extends StatefulWidget {
  const ProductMaintainancePage({Key? key}) : super(key: key);

  @override
  State<ProductMaintainancePage> createState() => _ProductMaintainancePageState();
}

class _ProductMaintainancePageState extends State<ProductMaintainancePage> {
  final Myproductcontroller myproductcontroller =
  Get.put(Myproductcontroller(productRepository: MyProductRepository()));

  @override
  void initState() {
    super.initState();
    myproductcontroller.fetchMyProduct();

  }

  @override
  Widget build(BuildContext context) {
    return  Obx(() {
      if (myproductcontroller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      } else if (myproductcontroller.errorMessage.value.isNotEmpty) {
        return Center(child: Text("Error: ${myproductcontroller.errorMessage.value}"));
      }

      return ListView.builder(
        itemCount: myproductcontroller.myProducts.length,
        itemBuilder: (context, index) {
          Myproduct product =
          myproductcontroller.myProducts[index];

          return GestureDetector(
            onTap: () {
              // Navigate to TrackingPage with stockId
              Get.to(() => TrackingPage(stockId: product.id));
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 20),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        child: Image(
                          image: NetworkImage(product.product_image),
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                    ],
                  ),

                  // Product Details
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        detailRow(title: 'Model Name: ', value: product.model_name),
                        detailRow(title: 'Model Number: ', value: product.model_num),
                        detailRow(title: 'Purchase Date: ', value: product.purchase_date),
                        detailRow(
                            title: 'Serial Number: ', value: product.serial_number),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
    );
  }

  TableRow _buildTableRow(String title, String? value) {
    return TableRow(
      children: [
        TableCell(
          child: Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
        ),
        TableCell(
          child: Text(value?? 'null', style: TextStyle(fontSize: 10)),
        ),
      ],
    );
  }
}
Widget detailRow({required String title, required String value}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    ),
  );
}
