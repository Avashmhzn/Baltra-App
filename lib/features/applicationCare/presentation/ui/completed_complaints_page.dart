import 'package:baltra/features/applicationCare/controller/completedController.dart';
import 'package:baltra/features/applicationCare/models/completedModel.dart';
import 'package:baltra/features/applicationCare/presentation/ui/product_tracking_page.dart';
import 'package:baltra/features/applicationCare/presentation/widgets/completed_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class CompletedComplaintsPage extends StatefulWidget {
  const CompletedComplaintsPage({super.key});

  @override
  State<CompletedComplaintsPage> createState() => _CompletedComplaintsPageState();
}

class _CompletedComplaintsPageState extends State<CompletedComplaintsPage> {
  final CompletedComplaintsController controller =
      Get.put(CompletedComplaintsController());

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      itemCount: 4,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xffD7D7D7)),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: double.infinity, height: 14, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 150, height: 14, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 100, height: 14, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 120, height: 14, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchCompleted(),
        child: Obx(() {
          if (controller.isLoading.value && controller.complaints.isEmpty) {
            return _buildSkeletonLoader();
          }

          if (controller.errorMessage.value.isNotEmpty && controller.complaints.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => controller.fetchCompleted(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.refresh),
                          label: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          if (controller.complaints.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline,
                            size: 72,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "No Completed Complaints",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Your completed product maintenance or resolved complaints will appear here.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 24),
                        OutlinedButton.icon(
                          onPressed: () => controller.fetchCompleted(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Theme.of(context).primaryColor),
                            foregroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.refresh),
                          label: const Text("Refresh List"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: controller.complaints.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              final CompletedComplaint complaint = controller.complaints[index];
              return GestureDetector(
                onTap: () {
                  if (complaint.id > 0) {
                    Get.to(() => TrackingPage(stockId: complaint.id));
                  } else {
                    Get.snackbar(
                      "Details Unavailable",
                      "This complaint details cannot be tracked.",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.black87,
                      colorText: Colors.white,
                    );
                  }
                },
                child: CompletedComplaintCard(complaint: complaint),
              );
            },
          );
        }),
      ),
    );
  }
}
