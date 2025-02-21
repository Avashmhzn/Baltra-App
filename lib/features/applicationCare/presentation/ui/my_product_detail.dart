import 'dart:io';

import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:baltra/features/applicationCare/controller/myProductController.dart';
import 'package:baltra/features/applicationCare/models/myProduct.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';


class MyProductDetailPage extends StatefulWidget {
  final int productId;

  const MyProductDetailPage({Key? key, required this.productId})
      : super(key: key);

  @override
  State<MyProductDetailPage> createState() => _MyProductDetailPageState();
}

class _MyProductDetailPageState extends State<MyProductDetailPage> {
  final Myproductcontroller controller = Get.find<Myproductcontroller>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchSingleMyProduct(widget.productId);
    });
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "No Date";
    try {
      DateTime parsedDate = DateTime.parse(dateStr);
      return DateFormat('EEE, MMM dd, yyyy').format(parsedDate);
    } catch (e) {
      return "Invalid Date";
    }
  }

  Future<void> downloadImage(BuildContext context, String imageUrl) async {
    if (imageUrl.isEmpty) return;

    // Request storage permission if not already granted.
    PermissionStatus permissionStatus = await Permission.storage.status;
    if (!permissionStatus.isGranted) {
      permissionStatus = await Permission.storage.request();
      if (!permissionStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
              Text("Storage permission is required to save images.")),
        );
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Downloading image...")),
    );

    try {
      final http.Response response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final Directory tempDir = await getTemporaryDirectory();
        final String fileName =
            'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String savePath = '${tempDir.path}/$fileName';

        final File file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);

        final bool? success = await GallerySaver.saveImage(file.path);
        if (success == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Image saved to gallery!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to save image to gallery.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed: $e")),
      );
    }
  }

  Future<void> downloadVideo(BuildContext context, String videoUrl) async {
    if (videoUrl.isEmpty) return;

    // Request storage permission if not already granted.
    PermissionStatus permissionStatus = await Permission.storage.status;
    if (!permissionStatus.isGranted) {
      permissionStatus = await Permission.storage.request();
      if (!permissionStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Storage permission is required to save videos."),
          ),
        );
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Downloading video...")),
    );

    try {
      final http.Response response = await http.get(Uri.parse(videoUrl));

      if (response.statusCode == 200) {
        final Directory tempDir = await getTemporaryDirectory();
        final String fileName =
            'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
        final String savePath = '${tempDir.path}/$fileName';

        final File file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);

        final bool? success = await GallerySaver.saveVideo(file.path);
        if (success == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Video saved to gallery!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to save video to gallery.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed: $e")),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text("Error: ${controller.errorMessage.value}"));
        }
        final Myproduct? product = controller.singleMyProduct.value;
        if (product == null) {
          return const Center(child: Text("No product details available."));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 34),
              AppBarWithSVG(
                subtitle: "Registered product's page",
                title: "Welcome to ",
                backbutton: false,
              ),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.red, width: 2),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.model_name ?? "Unknown Model",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Job ID: ${product.job_No ?? 'N/A'}",
                            style:
                                TextStyle(fontSize: 16, color: Colors.black87),
                          )
                        ],
                      ),
                    ],
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: product.product_image != null
                                  ? Image.network(
                                      product.product_image!,
                                      height: 120,
                                      width: 120,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      Icons.image_not_supported,
                                      size: 120,
                                    ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.model_name ?? 'Unknown Product',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Job ID: ${product.job_No ?? '-'}',
                                      style: TextStyle(fontSize: 14,color: Colors.grey),
                                    ),
                                    SizedBox(height: 10),
                                    _buildInfoRow("Model Number", product.model_num),
                                    _buildInfoRow("Serial Number", product.serial_number),
                                    _buildInfoRow("Store Name", product.store_name),
                                    _buildInfoRow("Store Location", product.store_location),
                                    _buildInfoRow("Purchase Date", product.purchase_date),
                                    _buildInfoRow("Status", product.status),


                                  ],
                                ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16),
                    Container(
                      padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                      margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Heading row with text on the left and download button on the right
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Product Image",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              ElevatedButton(
                                onPressed: () => downloadImage(
                                    context, product.product_image ?? ''),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  const Color(0xFF000000), // Or any color you prefer
                                ),
                                child: const Text("Download",style: TextStyle(color: Colors.white),),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // The image section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: SizedBox(
                                        height: 150,
                                        width: screenWidth * 0.8,
                                        child: Image.network(
                                          product.product_image ?? '',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                          const Icon(
                                              Icons.image_not_supported),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    // The image section
                    Container(
                      padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                      margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Heading row with text on the left and download button on the right
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Bill Image ",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              ElevatedButton(
                                onPressed: () => downloadImage(
                                    context, product.bill_image_one ?? ''),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  const Color(0xFF000000), // Or any color you prefer
                                ),
                                child: const Text("Download",style: TextStyle(color: Colors.white),),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // The image section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: SizedBox(
                                        height: 150,
                                        width: screenWidth * 0.8,
                                        child: Image.network(
                                          product.bill_image_one ?? '',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                          const Icon(
                                              Icons.image_not_supported),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    // The image section
                    Container(
                      padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                      margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Heading row with text on the left and download button on the right
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Product Warranty Image",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              ElevatedButton(
                                onPressed: () => downloadImage(
                                    context, product.warranty_image ?? ''),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  const Color(0xFF000000), // Or any color you prefer
                                ),
                                child: const Text("Download",style: TextStyle(color: Colors.white),),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // The image section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: SizedBox(
                                        height: 150,
                                        width: screenWidth * 0.8,
                                        child: Image.network(
                                          product.warranty_image ?? '',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                          const Icon(
                                              Icons.image_not_supported),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value ?? 'N/A',overflow: TextOverflow.ellipsis,),
          ),
        ],
      ),
    );
  }

}
