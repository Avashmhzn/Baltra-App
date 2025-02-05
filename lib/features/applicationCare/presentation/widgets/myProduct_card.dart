
// new
/*import 'package:baltra/features/applicationCare/controller/myProductController.dart';
import 'package:baltra/features/applicationCare/data/productRepository.dart';
import 'package:baltra/features/applicationCare/models/myProduct.dart';
import 'package:baltra/features/applicationCare/presentation/ui/extend_warranty_page.dart';
import 'package:baltra/features/applicationCare/presentation/ui/product_maintainance_page.dart';
import 'package:baltra/features/applicationCare/presentation/ui/register_complaint_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
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
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductMaintainancePage()),
                  );
                },
                child: ClipRRect(
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
              ),
              Positioned(
                right: 10,
                top: 5,
                child: GestureDetector(
                  onTap: () {
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
                                myproductcontroller.deleteMyProduct(product.id);
                                myproductcontroller.fetchMyProduct();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    radius: 15,
                    child: Image.asset(
                      'assets/icons/delete.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Status: ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: product.status == 'Pending'
                            ? Colors.grey
                            : Colors.green,
                      ),
                      child: Text(
                        product.status == 'Pending' ? 'Pending' : 'Approved',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          GestureDetector(
            onTap: () {
              product.status == 'Pending'
                  ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text(
                    'Complain can be registered only for verified products!'),
                backgroundColor: Theme.of(context).primaryColor,
              ))
                  : showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ComplaintRegistrationPage(
                    productId: product.id,
                    serialNo: product.serial_number,
                    status: product.status,
                    modelName: product.model_name,
                    modelNo: product.model_num,
                  );
                },
              );
            },
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xff000C22),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              width: double.infinity,
              height: 50,
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

          // Extend Warranty Button
          Center(
            child: TextButton(
              onPressed: () {
                product.status == 'Pending'
                    ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text(
                      'Warranty can be extended only for verified products!'),
                  backgroundColor: Theme.of(context).primaryColor,
                ))
                    : Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ExtendWarrantyPage(id: product.id),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xff000C22),
              ),
              child: const Text('Extend Warranty'),
            ),
          ),
        ],
      ),
    );
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
}*/

// new
import 'package:baltra/features/applicationCare/controller/myProductController.dart';
import 'package:baltra/features/applicationCare/data/productRepository.dart';
import 'package:baltra/features/applicationCare/models/myProduct.dart';
import 'package:baltra/features/applicationCare/presentation/ui/extend_warranty_page.dart';
import 'package:baltra/features/applicationCare/presentation/ui/product_maintainance_page.dart';
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
              GestureDetector(
                onTap: (){
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => ProductMaintainancePage()),
                  // );
                },
                child: ClipRRect(
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
              ),
              Positioned(
                right: 10,
                top: 5,
                child: GestureDetector(
                  onTap: () {
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
                                myproductcontroller.deleteMyProduct(product.id);
                                myproductcontroller.fetchMyProduct();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    radius: 15,
                    child: Image.asset(
                      'assets/icons/delete.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Status: ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: product.status == 'Pending'
                            ? Colors.grey
                            : Colors.green,
                      ),
                      child: Text(
                        product.status == 'Pending' ? 'Pending' : 'Approved',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          GestureDetector(
            onTap: () {
              product.status == 'Pending'
                  ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text(
                    'Complain can be registered only for verified products!'),
                backgroundColor: Theme.of(context).primaryColor,
              ))
                  : showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ComplaintRegistrationPage(
                    productId: product.id,
                    serialNo: product.serial_number,
                    status: product.status,
                    modelName: product.model_name,
                    modelNo: product.model_num,
                  );
                },
              );
            },
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xff000C22),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              width: double.infinity,
              height: 50,
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

          // Extend Warranty Button
          Center(
            child: TextButton(
              onPressed: () {
                product.status == 'Pending'
                    ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text(
                      'Warranty can be extended only for verified products!'),
                  backgroundColor: Theme.of(context).primaryColor,
                ))
                    : Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ExtendWarrantyPage(id: product.id),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xff000C22),
              ),
              child: const Text('Extend Warranty'),
            ),
          ),
        ],
      ),
    );
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
}