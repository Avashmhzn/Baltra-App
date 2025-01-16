import 'package:flutter/material.dart';
import 'package:flutter_easy_faq/flutter_easy_faq.dart';

class QnaSection extends StatelessWidget {
  const QnaSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          EasyFaq(
            question: "01. What is Lorem Ipsum?",
            answer:
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
          ),
          const SizedBox(
            height: 10,
          ),
          EasyFaq(
            question: "01. What is Lorem Ipsum?",
            answer:
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
          ),
          const SizedBox(
            height: 10,
          ),
          EasyFaq(
            question: "01. What is Lorem Ipsum?",
            answer:
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
