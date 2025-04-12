import 'package:baltra/features/products/models/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Homepagecard extends StatelessWidget {
  final Product product;

  const Homepagecard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffE4E4E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: CachedNetworkImage(
                imageUrl: product.main_image!,
                fit: BoxFit.contain,
                placeholder: (context, url) => const SizedBox.shrink(), // No visible loader
                errorWidget: (context, url, error) => const Center(
                  child: Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
                fadeInDuration: const Duration(milliseconds: 300),
                fadeOutDuration: const Duration(milliseconds: 300),
              ),
            ),
          ),
          const Divider(
            thickness: 1,
            height: 0,
            color: Color(0xffE4E4E4),
          ),
          Padding(
            padding:
            const EdgeInsets.only(left: 8.0, right: 8, bottom: 10, top: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.model_name!,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor),
                ),
                detailRow(
                    title: 'Warranty: ', value: "${product.warranty} Months"),
                detailRow(title: 'Price: ', value: "${product.price!}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Row detailRow({String? title, required String value}) {
    return Row(
      children: [
        Text(
          title!,
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
            maxLines: 2,
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