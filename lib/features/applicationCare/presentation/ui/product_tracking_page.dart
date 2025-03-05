import 'dart:io';
import 'package:baltra/features/applicationCare/controller/crmController.dart';
import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:collection/collection.dart';
import 'video_preview.dart';

class TrackingPage extends StatefulWidget {
  final int stockId;
  const TrackingPage({super.key, required this.stockId});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final CrmController controller = Get.find<CrmController>();

  @override
  void initState() {
    super.initState();
    print("Received Stock ID: ${widget.stockId}");
    // Clear any previously fetched product data, then fetch new data.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.customerProduct.value = null;
      controller.fetchCustomerProduct(widget.stockId);
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
    if (imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No image URL provided")),
      );
      return;
    }

    try {
      // Request storage permission
      if (await Permission.storage.request().isGranted) {
        // For Android 10 and above
        if (await Permission.manageExternalStorage.request().isGranted) {
          final response = await http.get(Uri.parse(imageUrl));

          if (response.statusCode == 200) {
            // Get the downloads directory
            final directory = Directory('/storage/emulated/0/Download');
            if (!await directory.exists()) {
              await directory.create(recursive: true);
            }

            // Create a unique filename
            final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
            final file = File('${directory.path}/$fileName');

            // Write the file
            await file.writeAsBytes(response.bodyBytes);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Image saved to Downloads/$fileName"),
                duration: const Duration(seconds: 3),
              ),
            );
          } else {
            throw Exception('Failed to download image: ${response.statusCode}');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Storage permission denied")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission denied")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error downloading image: $e")),
      );
    }
  }

  Future<void> downloadVideo(BuildContext context, String videoUrl) async {
    if (videoUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No video URL provided")),
      );
      return;
    }

    try {
      // Request storage permission
      if (await Permission.storage.request().isGranted) {
        // For Android 10 and above
        if (await Permission.manageExternalStorage.request().isGranted) {
          final response = await http.get(Uri.parse(videoUrl));

          if (response.statusCode == 200) {
            // Get the downloads directory
            final directory = Directory('/storage/emulated/0/Download');
            if (!await directory.exists()) {
              await directory.create(recursive: true);
            }

            // Create a unique filename
            final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
            final file = File('${directory.path}/$fileName');

            // Write the file
            await file.writeAsBytes(response.bodyBytes);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Video saved to Downloads/$fileName"),
                duration: const Duration(seconds: 3),
              ),
            );
          } else {
            throw Exception('Failed to download video: ${response.statusCode}');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Storage permission denied")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission denied")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error downloading video: $e")),
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
        } else if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text("Error: ${controller.errorMessage.value}"));
        } else if (controller.customerProduct.value == null) {
          return const Center(child: Text("No Product Data Available"));
        }

        final product = controller.customerProduct.value!;
        final List<dynamic> stepperData = product.stepper ?? [];

        // Build the list of step widgets with arrows inserted between steps.
        List<Widget> stepWidgets = [];
        for (int i = 0; i < stepperData.length; i++) {
          final step = stepperData[i];
          bool isActive = step["newServiceStatusName"] == product.status;
          stepWidgets.add(
            Padding(
              padding: const EdgeInsets.only(right: 25.0, bottom: 20.0),
              child: Column(
                children: [
                  // Circular Step Number
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? Colors.red : Colors.red.shade300,
                    ),
                    child: Center(
                      child: Text(
                        "${i + 1}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Step Title
                  Text(
                    step["newServiceStatusName"] ?? "Unknown Step",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.black : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Step Date
                  Text(
                    formatDate(step["dateAdded"]),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
          // If more than one step and not the last step, add an arrow.
          if (stepperData.length > 1 && i < stepperData.length - 1) {
            stepWidgets.add(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  Icons.arrow_right_alt,
                  color: Colors.red,
                  size: 50,
                ),
              ),
            );
          }
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 34),
              AppBarWithSVG(
                subtitle: "Know the status of your product",
                title: "Track Your Product",
                backbutton: false,
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red, width: 2),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.red),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.modelName ?? "Unknown Model",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Job ID: ${product.jobNo ?? 'N/A'}",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Conditionally display the stepper if a valid Job ID exists.
              (product.jobNo != null &&
                  product.jobNo!.trim().isNotEmpty &&
                  product.jobNo != 'N/A')
                  ? Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Tracking Progress Steps
                    stepperData.isNotEmpty
                        ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: stepWidgets,
                      ),
                    )
                        : const Center(
                      child: Text("Wait for process",
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              )
                  : Container(),
              // Product Details Section
              Container(
                padding:
                const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                margin:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 150,
                          width: 140,
                          child: Image.network(
                            product.damagedImage ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.modelName ?? 'Unknown Model',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text("Model Num: ${product.modelNum ?? 'N/A'}",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey)),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Table(
                              border: TableBorder.symmetric(
                                  outside: BorderSide.none),
                              children: [
                                _buildTableRow("Job ID", product.jobNo),
                                _buildTableRow(
                                    "Tracking ID", product.serialNumber),
                                _buildTableRow("Sent for", product.problemType),
                                _buildTableRow(
                                    "Complaint", product.problemDescription),
                                _buildTableRow("Stage", product.status),
                                _buildTableRow("Sent Date", product.dateJoined),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Damaged product picture section with heading and download button
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
                          "Damaged Product Picture",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: () => downloadImage(
                              context, product.damagedImage ?? ''),
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
                                    product.damagedImage ?? '',
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
              // Damaged product video section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                          "Damaged Product Video",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              downloadVideo(context, product.damagedVideo ?? ''),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF000000),
                          ),
                          child: const Text(
                            "Download",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Video preview section: play video from the database
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: product.damagedVideo != null && product.damagedVideo!.isNotEmpty
                              ? Container(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: VideoPreview(videoUrl: product.damagedVideo!))
                              : Container(

                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.play_circle_fill,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5,)
                  ],
                ),
              ),

              Builder(
                builder: (context) {
                  final currentStep = stepperData
                      .cast<Map<String, dynamic>>()
                      .firstWhereOrNull(
                          (step) => step['newServiceStatusName'] == product.status);
                  if (currentStep == null) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Heading
                            const Text(
                              'Current Stage',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Find out which stage your product is in.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // The "Stage Card"
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Status icon
                                  const Icon(
                                    Icons.build_circle_outlined,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                  const SizedBox(width: 16),
                                  // Text details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        // Stage name
                                        Text(
                                          currentStep["newServiceStatusName"] ??
                                              "",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Stage date
                                        Text(
                                          formatDate(currentStep["dateAdded"]),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Custom stage message
                                        Text(
                                          'Your repaired item is ready for collection. '
                                              'Please visit our service center located in Teku.',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20,)
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  // Finds the active step index safely
  int getActiveStep(List<dynamic> steps, String? status) {
    if (status == null) return 0;
    int index = steps.indexWhere((step) => step["newServiceStatusName"] == status);
    return index >= 0 ? index : 0;
  }

  Color getStatusColor(String? status) {
    if (status == null) return Colors.black;
    switch (status.toLowerCase()) {
      case 'assigned':
        return Colors.green;
      case 'un-assigned':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }


  // Builds a table row for product details with status text color change.
  TableRow _buildTableRow(String label, String? value) {
    bool isStatusRow = label.toLowerCase() == "stage";
    return TableRow(
      children: [
        TableCell(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        TableCell(
          child: Text(
            value?.isNotEmpty == true ? value! : 'N/A',
            style: TextStyle(
              fontSize: 11,
              color: isStatusRow ? getStatusColor(value) : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
