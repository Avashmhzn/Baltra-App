import 'package:baltra/features/applicationCare/presentation/widgets/product_tracking_card.dart';
import 'package:flutter/material.dart';

class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Padding(
      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ProductTrackingCard(),
            ProductTrackingCard(),
            ProductTrackingCard(),
          ],
        ),
      ),
    ));
  }
}
