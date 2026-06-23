import 'package:baltra/features/applicationCare/controller/myProductController.dart';
import 'package:baltra/features/applicationCare/data/productRepository.dart';
import 'package:baltra/features/applicationCare/models/myProduct.dart';
import 'package:baltra/features/applicationCare/presentation/ui/extend_warranty_page.dart';
import 'package:baltra/features/applicationCare/presentation/ui/register_complaint_page.dart';
import 'package:baltra/features/applicationCare/presentation/widgets/custom_delete_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
                onTap: () {
                  if (product.product_image != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImagePage(
                          imageUrl: product.product_image,
                          heroTag: product.id.toString(),
                        ),
                      ),
                    );
                  }
                },
                child: Hero(
                  tag: product.id.toString(),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    child: product.product_image != null
                        ? InteractiveViewer(
                            panEnabled: true,
                            boundaryMargin: const EdgeInsets.all(20),
                            minScale: 0.1,
                            maxScale: 4.0,
                            child: CachedNetworkImage(
                              imageUrl: product.product_image!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => Skeletonizer(
                                enabled: true,
                                child: Container(
                                  height: 150,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Center(child: Icon(Icons.error)),
                            ),
                          )
                        : Container(
                            height: 150,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
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
                        return CustomDeleteDialog(
                          productName: product.model_name,
                          onConfirm: () {
                            myproductcontroller.deleteMyProduct(product.id);
                            myproductcontroller.fetchMyProduct();
                          },
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
          const SizedBox(height: 20),

          // Product Details
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                detailRow(title: 'Model Name: ', value: product.model_name),
                detailRow(title: 'Model Number: ', value: product.model_num),
                detailRow(
                    title: 'Purchase Date: ', value: product.purchase_date),
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
          const SizedBox(height: 15), // Increased from 10

          // Function call to show buttons based on product status
          _buildActionButtons(context),
        ],
      ),
    );
  }

  // Function to conditionally show the "Register Complaint" and "Extend Warranty" buttons
  Widget _buildActionButtons(BuildContext context) {
    if (product.status == 'Approved') {
      return Column(
        children: [
          GestureDetector(
            onTap: () {
              showDialog(
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
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              width: double.infinity,
              height: 52, // Increased from 50
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExtendWarrantyPage(id: product.id),
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
      );
    } else {
      return const SizedBox(); // Hide buttons if status is 'Pending'
    }
  }

  // Function to display product details
  Widget detailRow({required String title, required String? value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
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
              value ?? 'N/A',
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

class FullScreenImagePage extends StatelessWidget {
  final String? imageUrl;
  final String heroTag;

  const FullScreenImagePage({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context); // Close the image viewer on tap
        },
        child: Center(
          child: Hero(
            tag: heroTag,
              child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.1,
              maxScale: 4.0,
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Skeletonizer(
                        enabled: true,
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          color: Colors.grey[300],
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Center(child: Icon(Icons.error)),
                    )
                  : const Center(
                      child: Icon(Icons.image_not_supported_outlined,
                          size: 64, color: Colors.grey)),
            ),
          ),
        ),
      ),
    );
  }
}