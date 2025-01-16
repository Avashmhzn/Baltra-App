import 'package:baltra/features/products/models/review.dart';
import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.review,
  });

  final Review review;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(review.customer.image_url ??
                  'https://t4.ftcdn.net/jpg/02/15/84/43/360_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg'),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              "${review.customer.first_name} ${review.customer.last_name}",
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return index < review.rating
                        ? const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 17,
                          )
                        : const Icon(
                            Icons.star_border_outlined,
                            color: Colors.amber,
                            size: 17,
                          );
                  }),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    review.date_joined,
                    style:
                        const TextStyle(fontSize: 9, color: Color(0xff5f5f5f)),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                textAlign: TextAlign.left,
                review.review,
                style: const TextStyle(color: Color(0xff515151), fontSize: 12),
              ),
              const SizedBox(
                height: 14,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
