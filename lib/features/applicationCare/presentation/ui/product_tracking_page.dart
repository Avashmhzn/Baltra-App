// import 'dart:io';
// import 'package:baltra/features/applicationCare/controller/crmController.dart';
// import 'package:baltra/features/applicationCare/presentation/widgets/tracking_details_skeletion.dart';
// import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'video_preview.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:gal/gal.dart';

// class TrackingPage extends StatefulWidget {
//   final int stockId;
//   const TrackingPage({super.key, required this.stockId});

//   @override
//   State<TrackingPage> createState() => _TrackingPageState();
// }

// class _TrackingPageState extends State<TrackingPage> {
//   final CrmController controller = Get.find<CrmController>();

//   @override
//   void initState() {
//     super.initState();
//     print("Received Stock ID: ${widget.stockId}");
//     // Clear any previously fetched product data, then fetch new data.
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       controller.customerProduct.value = null;
//       controller.fetchCustomerProduct(widget.stockId);
//     });
//   }

//   String formatDate(String? dateStr) {
//     if (dateStr == null || dateStr.isEmpty) return "No Date";
//     try {
//       DateTime parsedDate = DateTime.parse(dateStr);
//       return DateFormat('EEE, MMM dd, yyyy').format(parsedDate);
//     } catch (e) {
//       return "Invalid Date";
//     }
//   }

//   // New method for date-only formatting
//   String formatDateOnly(String? dateStr) {
//     if (dateStr == null || dateStr.isEmpty) return "No Date";
//     try {
//       DateTime parsedDate = DateTime.parse(dateStr);
//       return DateFormat('yyyy-MM-dd').format(parsedDate);
//     } catch (e) {
//       return "Invalid Date";
//     }
//   }

//   // Show Full-Screen Image with Zoom & Pan
//   void showFullScreenImage(BuildContext context, String imageUrl) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.transparent,
//         child: GestureDetector(
//           onTap: () => Navigator.of(context).pop(), // Tap to close
//           child: Hero(
//             tag: imageUrl,
//             child: InteractiveViewer(
//               panEnabled: true, // Enable zoom and pan
//               boundaryMargin: EdgeInsets.all(20),
//               minScale: 0.5,
//               maxScale: 3.0,
//               child: Image.network(
//                 imageUrl,
//                 fit: BoxFit.contain,
//                 errorBuilder: (context, error, stackTrace) =>
//                     const Icon(Icons.image_not_supported, size: 100),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> downloadImage(BuildContext context, String imageUrl) async {
//     if (imageUrl.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("No image URL provided")),
//       );
//       return;
//     }

//     try {
//       final hasAccess = await Gal.hasAccess();
//       if (!hasAccess) {
//         final request = await Gal.requestAccess();
//         if (!request) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Gallery permission denied")),
//           );
//           return;
//         }
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text("Downloading image..."),
//             duration: Duration(seconds: 1)),
//       );

//       final response = await http.get(Uri.parse(imageUrl));
//       if (response.statusCode == 200) {
//         final tempDir = await getTemporaryDirectory();
//         final tempPath =
//             '${tempDir.path}/temp_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
//         final file = File(tempPath);
//         await file.writeAsBytes(response.bodyBytes);

//         await Gal.putImage(tempPath);
//         await file.delete();

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Image saved to gallery successfully!"),
//             duration: Duration(seconds: 3),
//           ),
//         );
//       } else {
//         throw Exception('Failed to download image: ${response.statusCode}');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error downloading image: $e")),
//       );
//     }
//   }

//   Future<void> downloadVideo(BuildContext context, String videoUrl) async {
//     if (videoUrl.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("No video URL provided")),
//       );
//       return;
//     }

//     try {
//       final hasAccess = await Gal.hasAccess();
//       if (!hasAccess) {
//         final request = await Gal.requestAccess();
//         if (!request) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Gallery permission denied")),
//           );
//           return;
//         }
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text("Downloading video..."),
//             duration: Duration(seconds: 1)),
//       );

//       final response = await http.get(Uri.parse(videoUrl));
//       if (response.statusCode == 200) {
//         final tempDir = await getTemporaryDirectory();
//         final tempPath =
//             '${tempDir.path}/temp_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
//         final file = File(tempPath);
//         await file.writeAsBytes(response.bodyBytes);

//         await Gal.putVideo(tempPath);
//         await file.delete();

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Video saved to gallery successfully!"),
//             duration: Duration(seconds: 3),
//           ),
//         );
//       } else {
//         throw Exception('Failed to download video: ${response.statusCode}');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error downloading video: $e")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: TrackingPageSkeleton());
//         } else if (controller.errorMessage.value.isNotEmpty) {
//           return Center(child: Text("Error: ${controller.errorMessage.value}"));
//         } else if (controller.customerProduct.value == null) {
//           return const Center(child: Text("No Product Data Available"));
//         }

//         final product = controller.customerProduct.value!;
//         final List<dynamic> stepperData = product.stepper;

//         // Build the list of step widgets with arrows inserted between steps.
//         List<Widget> stepWidgets = [];
//         for (int i = 0; i < stepperData.length; i++) {
//           final step = stepperData[i];
//           bool isActive = step["newServiceStatusName"] == product.status;
//           stepWidgets.add(
//             Padding(
//               padding: const EdgeInsets.only(right: 25.0, bottom: 20.0),
//               child: Column(
//                 children: [
//                   // Circular Step Number
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: isActive ? Colors.red : Colors.red.shade300,
//                     ),
//                     child: Center(
//                       child: Text(
//                         "${i + 1}",
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   // Step Title
//                   Text(
//                     step["newServiceStatusName"] ?? "Unknown Step",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: isActive ? Colors.black : Colors.grey.shade600,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   // Step Date
//                   Text(
//                     formatDate(step["dateAdded"]),
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//           // If more than one step and not the last step, add an arrow.
//           if (stepperData.length > 1 && i < stepperData.length - 1) {
//             stepWidgets.add(
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 child: Icon(
//                   Icons.arrow_right_alt,
//                   color: Colors.red,
//                   size: 50,
//                 ),
//               ),
//             );
//           }
//         }

//         return SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 34),
//               AppBarWithSVG(
//                 subtitle: "Know the status of your product",
//                 title: "Track Your Product",
//                 backbutton: false,
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(15),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(color: Colors.red, width: 2),
//                       ),
//                       child: IconButton(
//                         onPressed: () => Navigator.of(context).pop(),
//                         icon: const Icon(Icons.arrow_back, color: Colors.red),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             product.modelName,
//                             style: const TextStyle(
//                                 fontSize: 20, fontWeight: FontWeight.bold),
//                             softWrap: true,
//                             overflow: TextOverflow.visible,
//                           ),
//                           const SizedBox(height: 2),
//                           Text(
//                             "Job ID: ${product.jobNo}",
//                             style: const TextStyle(
//                                 fontSize: 16, color: Colors.black87),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Conditionally display the stepper if a valid Job ID exists.
//               (product.jobNo.trim().isNotEmpty && product.jobNo != 'N/A')
//                   ? Padding(
//                       padding: const EdgeInsets.all(15.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           const SizedBox(height: 20),
//                           // Tracking Progress Steps
//                           stepperData.isNotEmpty
//                               ? SingleChildScrollView(
//                                   scrollDirection: Axis.horizontal,
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: stepWidgets,
//                                   ),
//                                 )
//                               : const Center(
//                                   child: Text("Wait for process",
//                                       style: TextStyle(color: Colors.red)),
//                                 ),
//                         ],
//                       ),
//                     )
//                   : Container(),
//               // Product Details Section
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//                 margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(15),
//                   border: Border.all(color: Colors.grey),
//                 ),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Product Image
//                     Padding(
//                       padding: const EdgeInsets.only(right: 10.0, top: 40),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: SizedBox(
//                           height: 100,
//                           width: 100,
//                           child: GestureDetector(
//                             onTap: () => showFullScreenImage(
//                                 context, product.damagedImage),
//                             child: Hero(
//                               tag: "${product.damagedImage}_image",
//                               child: Image.network(
//                                 product.damagedImage,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) =>
//                                     const Icon(Icons.image_not_supported),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     // Product Details
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Product Name
//                           Text(
//                             product.modelName,
//                             style: TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             'Model Number: ${product.modelNum}',
//                             style: TextStyle(fontSize: 14, color: Colors.grey),
//                           ),
//                           SizedBox(height: 10),
//                           // Table for product details
//                           Table(
//                             columnWidths: const {
//                               0: FlexColumnWidth(2),
//                               1: FlexColumnWidth(3),
//                             },
//                             children: [
//                               detailRow(
//                                   title: "Job ID: ", value: product.jobNo),
//                               detailRow(
//                                   title: "Sent for: ",
//                                   value: product.problemType),
//                               detailRow(
//                                   title: "Complaint: ",
//                                   value: product.problemDescription),
//                               detailRow(
//                                   title: "Stage: ", value: product.status),
//                               detailRow(
//                                   title: "Purchase Date: ",
//                                   value: formatDateOnly(product.dateJoined)),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Damaged product picture section with heading and download button
//               Container(
//                 padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//                 margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(15),
//                   border: Border.all(color: Colors.grey),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Heading row with text on the left and download button on the right
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           "Damaged Product Picture",
//                           style: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                         ElevatedButton(
//                           onPressed: () =>
//                               downloadImage(context, product.damagedImage),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(
//                                 0xFF000000), // Or any color you prefer
//                           ),
//                           child: const Text(
//                             "Download",
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     // The image section
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         GestureDetector(
//                           onTap: () => showFullScreenImage(
//                               context, product.damagedImage),
//                           child: Hero(
//                             tag: product.damagedImage,
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(10),
//                               child: SizedBox(
//                                 height: 150,
//                                 width: screenWidth * 0.8,
//                                 child: Image.network(
//                                   product.damagedImage,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) =>
//                                       const Icon(Icons.image_not_supported),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               // Damaged product video section
//               Container(
//                 padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//                 margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(15),
//                   border: Border.all(color: Colors.grey),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           "Damaged Product Video",
//                           style: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                         ElevatedButton(
//                           onPressed: () =>
//                               downloadVideo(context, product.damagedVideo),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF000000),
//                           ),
//                           child: const Text(
//                             "Download",
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 5),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           width: MediaQuery.of(context).size.width * 0.8,
//                           height: MediaQuery.of(context).size.height * 0.3,
//                           child: product.damagedVideo.isNotEmpty
//                               ? GestureDetector(
//                                   onTap: () {
//                                     // Open Full-Screen Video Preview
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => VideoPreview(
//                                             videoUrl: product.damagedVideo),
//                                       ),
//                                     );
//                                   },
//                                   child: Hero(
//                                     tag: "${product.damagedVideo}_video",
//                                     child: Container(
//                                       width: MediaQuery.of(context).size.width *
//                                           0.8,
//                                       height:
//                                           MediaQuery.of(context).size.height *
//                                               0.3,
//                                       child: VideoPreview(
//                                           videoUrl: product.damagedVideo),
//                                     ),
//                                   ),
//                                 )
//                               : Container(
//                                   decoration: BoxDecoration(
//                                     color: Colors.black12,
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: const Center(
//                                     child: Icon(
//                                       Icons.play_circle_fill,
//                                       size: 50,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: 5,
//                     )
//                   ],
//                 ),
//               ),
//               Builder(
//                 builder: (context) {
//                   final currentStep = stepperData
//                       .cast<Map<String, dynamic>>()
//                       .firstWhereOrNull((step) =>
//                           step['newServiceStatusName'] == product.status);
//                   if (currentStep == null) return const SizedBox.shrink();
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 16),
//                       Padding(
//                         padding: const EdgeInsets.all(15.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Heading
//                             const Text(
//                               'Current Stage',
//                               style: TextStyle(
//                                   fontSize: 20, fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'Find out which stage your product is in.',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.grey.shade600,
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             // The "Stage Card"
//                             Container(
//                               width: double.infinity,
//                               padding: const EdgeInsets.all(16.0),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.shade100,
//                                 borderRadius: BorderRadius.circular(8),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.grey.shade300,
//                                     blurRadius: 5,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ],
//                               ),
//                               child: Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   // Status icon
//                                   const Icon(
//                                     Icons.build_circle_outlined,
//                                     color: Colors.red,
//                                     size: 40,
//                                   ),
//                                   const SizedBox(width: 16),
//                                   // Text details
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         // Stage name
//                                         Text(
//                                           currentStep["newServiceStatusName"] ??
//                                               "",
//                                           style: const TextStyle(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 4),
//                                         // Stage date
//                                         Text(
//                                           formatDate(currentStep["dateAdded"]),
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.grey.shade600,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 8),
//                                         // Custom stage message
//                                         Text(
//                                           'Your repaired item is ready for collection. '
//                                           'Please visit our service center located in Teku.',
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.grey.shade700,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(
//                               height: 20,
//                             )
//                           ],
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }

//   // Finds the active step index safely
//   int getActiveStep(List<dynamic> steps, String? status) {
//     if (status == null) return 0;
//     int index =
//         steps.indexWhere((step) => step["newServiceStatusName"] == status);
//     return index >= 0 ? index : 0;
//   }

//   Color getStatusColor(String? status) {
//     if (status == null) return Colors.black;
//     switch (status.toLowerCase()) {
//       case 'assigned':
//         return Colors.green;
//       case 'un-assigned':
//         return Colors.red;
//       default:
//         return Colors.blue;
//     }
//   }

//   // Builds a table row for product details with status text color change.
//   TableRow detailRow({required String title, required String? value}) {
//     bool isStatusRow = title.toLowerCase().contains('stage');
//     return TableRow(
//       children: [
//         TableCell(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 4.0),
//             child: Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black87,
//               ),
//             ),
//           ),
//         ),
//         TableCell(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 4.0),
//             child: Text(
//               value?.isNotEmpty == true ? value! : 'Not Available',
//               textAlign: TextAlign.end,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: isStatusRow ? getStatusColor(value) : Colors.black54,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'dart:io';
import 'package:baltra/features/applicationCare/controller/crmController.dart';
import 'package:baltra/features/applicationCare/models/crmModel.dart';
import 'package:baltra/features/applicationCare/presentation/widgets/tracking_details_skeletion.dart';
import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'video_preview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

class TrackingPage extends StatefulWidget {
  final int stockId;
  const TrackingPage({super.key, required this.stockId});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final CrmController controller = Get.find<CrmController>();

  static const Color _red = Color(0xffE53935);
  static const Color _redLight = Color(0xffFDECEA);
  static const Color _green = Color(0xff2E7D32);
  static const Color _greenLight = Color(0xffEAF7EC);
  static const Color _borderGrey = Color(0xffE0E0E0);
  static const Color _textGrey = Color(0xff8A8A8A);
  static const Color _bg = Color(0xffF5F5F5);

  @override
  void initState() {
    super.initState();
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

  //date format updated

  String formatDateOnly(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "No Date";
    try {
      DateTime parsedDate = DateTime.parse(dateStr);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      return "Invalid Date";
    }
  }

  String formatDateCompact(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "—";
    try {
      DateTime parsedDate = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(parsedDate);
    } catch (e) {
      return "—";
    }
  }

  void showFullScreenImage(BuildContext context, String imageUrl, String tag) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Hero(
            tag: tag,
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 3.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 100),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> downloadImage(BuildContext context, String imageUrl) async {
    if (imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No image URL provided")),
      );
      return;
    }
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final request = await Gal.requestAccess();
        if (!request) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gallery permission denied")),
          );
          return;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Downloading image..."),
            duration: Duration(seconds: 1)),
      );
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final tempPath =
            '${tempDir.path}/temp_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File(tempPath);
        await file.writeAsBytes(response.bodyBytes);
        await Gal.putImage(tempPath);
        await file.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Image saved to gallery successfully!"),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        throw Exception('Failed to download image: ${response.statusCode}');
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
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final request = await Gal.requestAccess();
        if (!request) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gallery permission denied")),
          );
          return;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Downloading video..."),
            duration: Duration(seconds: 1)),
      );
      final response = await http.get(Uri.parse(videoUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final tempPath =
            '${tempDir.path}/temp_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
        final file = File(tempPath);
        await file.writeAsBytes(response.bodyBytes);
        await Gal.putVideo(tempPath);
        await file.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Video saved to gallery successfully!"),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        throw Exception('Failed to download video: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error downloading video: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: TrackingPageSkeleton());
        } else if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text("Error: ${controller.errorMessage.value}"));
        } else if (controller.customerProduct.value == null) {
          return const Center(child: Text("No Product Data Available"));
        }

        final product = controller.customerProduct.value!;
        final List<Map<String, dynamic>> stepperData =
            product.stepper.cast<Map<String, dynamic>>();

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppBarWithSVG(
                  subtitle: "Know the status of your product",
                  title: "Track Your Product",
                  backbutton: false,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(context, product),
                      const SizedBox(height: 12),
                      _buildJobInfoCard(product),
                      const SizedBox(height: 14),
                      if (product.jobNo.trim().isNotEmpty &&
                          product.jobNo != 'N/A')
                        _buildTimelineCard(product, stepperData),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child:
                                  _buildProductDetailsCard(context, product)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildStoreDetailsCard(product)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildCustomerDetailsCard(product),
                      const SizedBox(height: 14),
                      _buildEvidenceSection(context, product),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // Top bar
  // ---------------------------------------------------------------------------
  Widget _buildTopBar(BuildContext context, CustomerProduct product) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _red, width: 1.5),
          ),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: _red, size: 18),
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "REPAIR TRACKING",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _textGrey,
                  letterSpacing: 0.4,
                ),
              ),
              Text(
                product.modelName.isNotEmpty
                    ? product.modelName.toUpperCase()
                    : "—",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                softWrap: true,
              ),
            ],
          ),
        ),
        if (product.status.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: product.status.toLowerCase() == 'completed'
                  ? _greenLight
                  : _redLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (product.status.toLowerCase() == 'completed'
                        ? _green
                        : _red)
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              product.status,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color:
                    product.status.toLowerCase() == 'completed' ? _green : _red,
              ),
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Job info card
  // ---------------------------------------------------------------------------
  Widget _buildJobInfoCard(CustomerProduct product) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderGrey),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _infoColumn(
                "JOB ID", product.jobNo.isNotEmpty ? product.jobNo : "—"),
          ),
          Expanded(
            child:
                _infoColumn("SENT DATE", formatDateCompact(product.dateJoined)),
          ),
          Expanded(
            child: _infoColumn(
                "PURCHASE DATE", formatDateCompact(product.purchaseDate)),
          ),
        ],
      ),
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: _textGrey,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Timeline card
  // ---------------------------------------------------------------------------
  Widget _buildTimelineCard(
      CustomerProduct product, List<Map<String, dynamic>> stepperData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "REPAIR PROGRESS",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: 0.3,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _redLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _red.withValues(alpha: 0.25)),
                ),
                child: Text(
                  "JOB ID: ${product.jobNo.isNotEmpty ? product.jobNo : '—'}",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (stepperData.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text("Wait for process", style: TextStyle(color: _red)),
            )
          else
            Column(
              children: List.generate(stepperData.length, (index) {
                final step = stepperData[index];
                final bool isActive =
                    step["newServiceStatusName"] == product.status;
                final bool isPastOrCurrent = index <=
                    stepperData.indexWhere(
                      (s) => s["newServiceStatusName"] == product.status,
                    );
                return _buildTimelineStep(
                  title: step["newServiceStatusName"] ?? "Unknown Step",
                  date: step["dateAdded"],
                  isCompleted: isPastOrCurrent,
                  isCurrent: isActive,
                  isLast: index == stepperData.length - 1,
                  highlightMessage: (isActive &&
                          product.status.toLowerCase() == 'completed')
                      ? "Your repaired item is ready for collection. Please visit our service center located in ${product.storeLocation.isNotEmpty ? product.storeLocation : 'your nearest branch'}."
                      : null,
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String? date,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
    String? highlightMessage,
  }) {
    final Color dotColor = isCompleted ? _red : Colors.grey.shade300;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration:
                    BoxDecoration(color: dotColor, shape: BoxShape.circle),
                child: isCompleted
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: _borderGrey)),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? _redLight
                              : (isCompleted
                                  ? _greenLight
                                  : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isCurrent
                              ? "Current Stage"
                              : (isCompleted ? "Done" : "Pending"),
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: isCurrent
                                ? _red
                                : (isCompleted ? _green : _textGrey),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatDate(date),
                    style: const TextStyle(fontSize: 10.5, color: _textGrey),
                  ),
                  if (highlightMessage != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _redLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _red.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, size: 15, color: _red),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              highlightMessage,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xff8B2C2C),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Product details card
  // ---------------------------------------------------------------------------
  Widget _buildProductDetailsCard(
      BuildContext context, CustomerProduct product) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "PRODUCT DETAILS",
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // GestureDetector(
              //   onTap: () => showFullScreenImage(context, product.productImage),
              //   child: Hero(
              //     tag: "${product.productImage}_thumb",
              //     child: ClipRRect(
              //       borderRadius: BorderRadius.circular(8),
              //       child: product.productImage.isNotEmpty
              //           ? Image.network(
              //               product.productImage,
              //               width: 50,
              //               height: 50,
              //               fit: BoxFit.cover,
              //               errorBuilder: (_, __, ___) => _placeholderBox(),
              //             )
              //           : _placeholderBox(),
              //     ),
              //   ),
              // ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.modelName.isNotEmpty ? product.modelName : "—",
                      style: const TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      product.modelNum,
                      style: const TextStyle(fontSize: 10.5, color: _textGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 18, color: _borderGrey),
          _detailRow("JOB ID", product.jobNo),
          _detailRow("SENT FOR", product.problemType),
          _detailRow("COMPLAINT", product.problemDescription),
          _detailRow("PURCHASE DATE", formatDateOnly(product.purchaseDate)),
          _warrantyRow(product.warrantyExpiry),
        ],
      ),
    );
  }

  Widget _placeholderBox() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey.shade100,
      child: const Icon(Icons.image_outlined, color: _textGrey, size: 22),
    );
  }

  Widget _detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: _textGrey,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            (value != null && value.isNotEmpty) ? value : "—",
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _warrantyRow(String warrantyExpiry) {
    bool expired = true;
    String label = "—";
    try {
      if (warrantyExpiry.isNotEmpty) {
        final expiry = DateTime.parse(warrantyExpiry);
        expired = DateTime.now().isAfter(expiry);
        label = formatDateCompact(warrantyExpiry);
      }
    } catch (_) {}

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "WARRANTY",
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: _textGrey,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: expired ? _redLight : _greenLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                expired ? "Expired" : "Active",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: expired ? _red : _green,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(fontSize: 10.5, color: _textGrey)),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Store details card — uses fields available on CustomerProduct
  // ---------------------------------------------------------------------------
  Widget _buildStoreDetailsCard(CustomerProduct product) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "STORE DETAILS",
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          _detailRow("STORE", product.storeName),
          _detailRow("LOCATION", product.storeLocation),
          _detailRow("CONTACT", product.storeNumber),
          _detailRow("SERIAL NO.", product.serialNumber),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Customer details card
  // ---------------------------------------------------------------------------
  Widget _buildCustomerDetailsCard(CustomerProduct product) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "CUSTOMER DETAILS",
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow("NAME", product.customerName),
                    _detailRow("EMAIL", product.email),
                    _detailRow("ZONE", product.zone),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow("CONTACT", product.customerContact),
                    _detailRow("ADDRESS", product.customerAddress),
                    _detailRow("AREA", product.area),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Damage evidence section
  // ---------------------------------------------------------------------------
  Widget _buildEvidenceSection(BuildContext context, CustomerProduct product) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "DAMAGE EVIDENCE",
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _imageEvidenceTile(
                  context: context,
                  label: "Damaged Product",
                  url: product.damagedImage,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _imageEvidenceTile(
                  context: context,
                  label: "Warranty Image",
                  url: product.warrantyImage,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _videoEvidenceTile(context: context, product: product),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imageEvidenceTile({
    required BuildContext context,
    required String label,
    required String url,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (url.isNotEmpty)
              InkWell(
                onTap: () => downloadImage(context, url),
                child: const Padding(
                  padding: EdgeInsets.only(left: 4.0),
                  child: Icon(Icons.download_outlined, size: 15, color: _red),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        AspectRatio(
          aspectRatio: 1,
          child: GestureDetector(
            onTap:
                url.isNotEmpty ? () => showFullScreenImage(context, url, "${url}_evidence_$label") : null,
            child: Hero(
              tag: "${url}_evidence_$label",
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: url.isEmpty
                    ? Container(
                        color: Colors.grey.shade100,
                        child:
                            const Icon(Icons.image_outlined, color: _textGrey),
                      )
                    : Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.broken_image_outlined,
                              color: _textGrey),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _videoEvidenceTile(
      {required BuildContext context, required CustomerProduct product}) {
    final String url = product.damagedVideo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                "Damaged Video",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (url.isNotEmpty)
              InkWell(
                onTap: () => downloadVideo(context, url),
                child: const Padding(
                  padding: EdgeInsets.only(left: 4.0),
                  child: Icon(Icons.download_outlined, size: 15, color: _red),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        AspectRatio(
          aspectRatio: 1,
          child: url.isEmpty
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.videocam_off_outlined, color: _textGrey),
                )
              : GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          backgroundColor: Colors.black,
                          appBar: AppBar(
                            backgroundColor: Colors.transparent,
                            iconTheme: const IconThemeData(color: Colors.white),
                          ),
                          body: Center(
                            child: VideoPreview(videoUrl: url),
                          ),
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      color: Colors.black87,
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
