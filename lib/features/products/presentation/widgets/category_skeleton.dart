import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CategorySkeleton extends StatelessWidget {
  const CategorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            // Image placeholder (takes up more space)
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
              ),
            ),
            // Text placeholder (for category name)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0, top: 4.0), // Fixed typo
              child: Container(
                height: 14,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}