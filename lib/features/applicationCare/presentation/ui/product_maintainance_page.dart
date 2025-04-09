import 'package:baltra/features/applicationCare/controller/crmController.dart';
import 'package:baltra/features/applicationCare/data/crm.dart';
import 'package:baltra/features/applicationCare/models/crmModel.dart';
import 'package:baltra/features/applicationCare/presentation/ui/product_tracking_page.dart';
import 'package:baltra/features/products/presentation/widgets/baltra_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

// Helper function to return color based on status.
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

// Widget for displaying complaint details with conditional color for "Status:".
Widget detailRow({required String title, required String? value}) {
  // Check if this row is the status row.
  bool isStatusRow = title.toLowerCase().contains('status');
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
            value ?? "Not Available",
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isStatusRow ? getStatusColor(value) : Colors.black54,
            ),
          ),
        ),
      ],
    ),
  );
}

// Skeleton loader widget with shimmer animation
Widget complaintSkeleton() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6.0,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!, // Base color of the skeleton
      highlightColor:
          Colors.grey[100]!, // Highlight color for the shimmer effect
      period:
          const Duration(milliseconds: 1000), // Speed of the shimmer animation
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skeleton for the 7 text rows
          for (int i = 0; i < 7; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 120, // Approximate width for the label
                    height: 14,
                    color: Colors.white, // Shimmer will animate over this
                  ),
                  Container(
                    width: 100, // Approximate width for the value
                    height: 14,
                    color: Colors.white, // Shimmer will animate over this
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          // Skeleton for the image
          Container(
            height: 150,
            width: double.infinity,
            color: Colors.white, // Shimmer will animate over this
          ),
        ],
      ),
    ),
  );
}

class ProductMaintainancePage extends StatefulWidget {
  const ProductMaintainancePage({Key? key}) : super(key: key);

  @override
  State<ProductMaintainancePage> createState() =>
      _ProductMaintainancePageState();
}

class _ProductMaintainancePageState extends State<ProductMaintainancePage> {
  final CrmController crmController =
      Get.put(CrmController(crmService: CrmServices()));

  @override
  void initState() {
    super.initState();
    // Schedule the fetchAllComplaints call after the current build is complete.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      crmController.fetchAllComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Wrap the Obx widget inside a FutureBuilder with a zero‑duration delay.
      body: FutureBuilder(
        future: Future.delayed(Duration.zero),
        builder: (context, snapshot) {
          return Obx(() {
            if (crmController.isLoading.value) {
              // Show animated skeleton loader instead of CircularProgressIndicator
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Complaints",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 3, // Show 3 skeleton cards while loading
                      itemBuilder: (context, index) {
                        return complaintSkeleton();
                      },
                    ),
                  ),
                ],
              );
            } else if (crmController.errorMessage.value.isNotEmpty) {
              return Center(
                  child: Text("Error: ${crmController.errorMessage.value}"));
            } else if (crmController.complaints.isEmpty) {
              return const Center(
                child: Text(
                  "No complaints found!",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Complaints",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: crmController.complaints.length,
                    itemBuilder: (context, index) {
                      CustomerProduct complaint =
                          crmController.complaints[index];

                      return GestureDetector(
                        onTap: () {
                          // Navigate to TrackingPage with stockId
                          Get.to(() => TrackingPage(stockId: complaint.id));
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
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
                              detailRow(
                                  title: 'Product Name:',
                                  value: complaint.modelName),
                              detailRow(
                                  title: 'Model Code:',
                                  value: complaint.modelNum),
                              detailRow(
                                  title: 'Job No:',
                                  value: complaint.jobNo ?? "Not Available"),
                              detailRow(
                                  title: 'Sent For:',
                                  value: complaint.problemType),
                              detailRow(
                                  title: 'Complaint:',
                                  value: complaint.problemDescription),
                              detailRow(
                                  title: 'Status:', value: complaint.status),
                              detailRow(
                                  title: 'Complaint Date:',
                                  value: complaint.dateJoined),
                              if ((complaint.damagedImage ?? "").isNotEmpty)
                                Image.network(
                                  complaint.damagedImage,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          });
        },
      ),
    );
  }
}
