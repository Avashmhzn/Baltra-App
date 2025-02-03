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
 