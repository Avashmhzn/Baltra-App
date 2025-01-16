import 'package:baltra/features/applicationCare/controller/myProductController.dart';
import 'package:baltra/features/applicationCare/data/productRepository.dart';
import 'package:baltra/features/applicationCare/models/myProduct.dart';
import 'package:baltra/features/applicationCare/presentation/ui/extend_warranty_page.dart';
import 'package:baltra/features/applicationCare/presentation/ui/register_complaint_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyProdductCard extends StatelessWidget {
  MyProdductCard({
    super.key,
    required this.product,
  });

  final Myproduct product;
  final Myproductcontroller myproductcontroller =
      Get.put(Myproductcontroller(productRepository: MyProductRepository()));
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 20),
      width: 250,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: Stack(
              children: [
                Image(
                  image: NetworkImage(product.product_image),
                  height: 200,
                  width: 320,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  right: 10,
                  top: 5,
                  child: GestureDetector(
                    onTap: () {
                      myproductcontroller.deleteMyProduct(product.id);
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                                title: const Text('Delete Product'),
                                content: const Text(
                                    'Are you sure you want to delete this product?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Delete'),
                                    onPressed: () {
                                      myproductcontroller
                                          .deleteMyProduct(product.id);
                                      myproductcontroller.fetchMyProduct();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ]);
                          });
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[400],
                      radius: 15,
                      child: const Icon(
                        Icons.delete,
                        size: 20,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          detailRow(title: 'Model Name: ', value: product.model_name),
          detailRow(title: 'Model Number: ', value: product.model_num),
          detailRow(title: 'Serial Number: ', value: product.serial_number),
          detailRow(title: 'Purchase Date: ', value: product.purchase_date),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: product.status == 'Pending'
                    ? Colors.blue[300]
                    : Colors.green),
            child: Text(
              product.status,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          GestureDetector(
            onTap: () {
              product.status == 'Pending'
                  ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text(
                          'Complain can be registerd only for verified products!'),
                      backgroundColor: Theme.of(context).primaryColor,
                    ))
                  : showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ComplaintRegistrationPage(
                          productId: product.id,
                          serialNo: product.serial_number,
                          status: product.status,
                        );
                      },
                    );
            },
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xff000C22),
              ),
              margin: const EdgeInsets.only(
                top: 15,
                left: 14,
                right: 14,
              ),
              width: double.infinity,
              height: 55,
              child: const Center(
                child: Text(
                  'Register a Complaint',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Center(
            child: TextButton(
              onPressed: () {
                product.status == 'Pending'
                    ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text(
                            'Warranty can be extedned only for verified products!'),
                        backgroundColor: Theme.of(context).primaryColor,
                      ))
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ExtendWarrantyPage(
                                  id: product.id,
                                )));
              },
              style: TextButton.styleFrom(
                  foregroundColor: const Color(0xff000C22)),
              child: const Text('Extend Warranty'),
            ),
          )
        ],
      ),
    );
  }

  Padding detailRow({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Color(0xff4A4A4A),
            ),
          ),
          Expanded(
            child: Text(
              value,
              softWrap: true,
              maxLines: 2, // Adjust maxLines as needed
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xff4A4A4A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
