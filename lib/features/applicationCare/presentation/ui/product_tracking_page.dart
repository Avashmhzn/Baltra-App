import 'package:baltra/features/applicationCare/controller/crmController.dart';
import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrackingPage extends StatefulWidget {
  final int stockId;
  const TrackingPage({super.key, required this.stockId});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}
class _TrackingPageState extends State<TrackingPage>{

  final CrmController controller = Get.find<CrmController>();

  @override
  void initState() {
    super.initState();

    print("Received Stock ID in TrackingPage: ${widget.stockId}");
    print("Stock ID Type: ${widget.stockId.runtimeType}");


    controller.fetchCustomerProduct(widget.stockId);
    }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text("Error: ${controller.errorMessage.value}"));
        } else if (controller.customerProduct.value == null) {
          return Center(child: Text("No Product Data Available"));
        }

        final product = controller.customerProduct.value!;
        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 34),
              AppBarWithSVG(
              subtitle: 'Know the status of your product',
              title: "Track Your Product",
              backbutton: true),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        height: 150,
                        width: 100,
                        child: Image.network(
                          product.productImage ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.image_not_supported),
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
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            product.modelNum ?? 'N/A',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Table(
                              border: TableBorder.symmetric(outside: BorderSide.none),
                              children: [
                                _buildTableRow("Tracking ID", product.serialNumber),
                                _buildTableRow("Sent for", product.problemType),
                                _buildTableRow("Stage", product.status),
                                _buildTableRow("Sent Date", product.createdAt),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      }),
    );
  }

  /// Helper method to create a TableRow for the tracking details
  TableRow _buildTableRow(String label, String? value) {
    return TableRow(
      children: [
        TableCell(
          child: Text(label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
        ),
        TableCell(
          child: Text(
            value ?? 'N/A',
            style: TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }
}
