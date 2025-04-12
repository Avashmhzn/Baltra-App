import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SubcategoryItemSkeleton extends StatelessWidget {
  const SubcategoryItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300], // Changed to grey for visibility
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Placeholder for the image
            Container(
              height: 120,
              width: double.infinity,
              color: Colors.grey[300], // Changed to grey for visibility
            ),
            const SizedBox(height: 8),
            // Placeholder for the category name
            Container(
              width: 80,
              height: 16,
              color: Colors.grey[300], // Changed to grey for visibility
            ),
          ],
        ),
      ),
    );
  }
}