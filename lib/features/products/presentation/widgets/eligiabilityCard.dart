import 'package:flutter/material.dart';

class EligibabilityCard extends StatelessWidget {
  const EligibabilityCard({
    required this.title,
    required this.desc,
    super.key,
  });
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      color: const Color(0xffece6e6).withOpacity(0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Color(0xff303A42),
                fontSize: 15,
                fontWeight: FontWeight.w500),
          ),
          Text(
            desc,
            style: TextStyle(
                color: Colors.black.withAlpha(60),
                fontSize: 12,
                fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }
}
