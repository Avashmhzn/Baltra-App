import 'package:baltra/features/products/models/subcategoryProduct.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProductItem extends StatelessWidget {
  final Subcategoryproduct product;

  const ProductItem({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive scaling
    final screenWidth = MediaQuery.of(context).size.width;
    // Scale font size and padding for smaller/larger screens
    final fontSize = screenWidth < 360 ? 10.0 : screenWidth < 600 ? 12.0 : 14.0;
    final paddingVertical = screenWidth < 360 ? 2.0 : 4.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffE4E4E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            flex: 4, // Fix: Increase space for image
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                    product.main_image_url,
                  ),
                  fit: BoxFit.contain, // Fix: Show full image without cropping
                ),
              ),
            ),
          ),
          const Divider(
            color: Color(0xffE4E4E4),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: paddingVertical),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                detailRow(
                  title: 'Model Name: ',
                  value: product.model_name,
                  fontSize: fontSize,
                ),
                detailRow(
                  title: 'Model Number: ',
                  value: product.model_no,
                  fontSize: fontSize,
                ),
                detailRow(
                  title: 'Power: ',
                  value: product.power,
                  fontSize: fontSize,
                ),
                detailRow(
                  title: 'Warranty: ',
                  value: "${product.warranty}",
                  fontSize: fontSize,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Row detailRow({
    required String title,
    required String value,
    required double fontSize,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w300,
            color: const Color(0xff4A4A4A),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: const Color(0xff4A4A4A),
            ),
          ),
        ),
      ],
    );
  }
}