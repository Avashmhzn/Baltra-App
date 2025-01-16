import 'package:baltra/features/products/models/subcategoryProduct.dart';
import 'package:flutter/material.dart';

class ProductItem extends StatelessWidget {
  final Subcategoryproduct product;

  const ProductItem({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffE4E4E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 175,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(product.main_image_url),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Divider(
            color: Color(0xffE4E4E4),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                detailRow(title: 'Model Name: ', value: product.model_name),
                detailRow(title: 'Model Number: ', value: product.model_no),
                detailRow(title: 'Power: ', value: product.power),
                detailRow(title: 'Warranty: ', value: "${product.warranty}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Row detailRow({required String title, required String value}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: Color(0xff4A4A4A),
          ),
        ),
        Expanded(
          child: Text(
            value,
            softWrap: true,
            maxLines: 2, // Adjust maxLines as needed
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xff4A4A4A),
            ),
          ),
        ),
      ],
    );
  }
}
