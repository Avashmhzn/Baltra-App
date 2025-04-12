import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:shimmer/shimmer.dart';

class Product2Skeleton extends StatelessWidget {
  const Product2Skeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true, // Always show skeleton effect
      effect: ShimmerEffect(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        duration: const Duration(milliseconds: 800),
      ),
      child: Container(
        margin: const EdgeInsets.all(4.0), // Match padding from reference
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: const Color(0xffE4E4E4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              width: double.infinity,
              height: 150, // Reduced height to fit within constraints
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
              ),
            ),
            const Divider(
              color: Color(0xffE4E4E4),
              height: 1, // Minimize divider height
              thickness: 1,
            ),
            // Product Details Placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0), // Reduced vertical padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Model Name Placeholder
                  Container(
                    width: 120, // Adjusted to match image proportions
                    height: 16, // Reduced height to fit
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 6), // Reduced spacing
                  // Model Number Placeholder
                  Container(
                    width: 140, // Adjusted to match image proportions
                    height: 16,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 6),
                  // Power Placeholder
                  Container(
                    width: 80, // Adjusted to match image proportions
                    height: 16,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 6),
                  // Warranty Placeholder
                  Container(
                    width: 60, // Adjusted to match image proportions
                    height: 16,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}