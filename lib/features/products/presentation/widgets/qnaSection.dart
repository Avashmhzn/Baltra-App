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
            question: "01. What is Loyalty points programs?",
            answer:
                "Our loyalty points program is designed to reward our valued customers for their continued support and purchases of Baltra home appliances. With every purchase made through our outlet, you earn points that can be redeemed for exciting rewards and discounts on future purchases.",
          ),
          const SizedBox(
            height: 10,
          ),
          EasyFaq(
            question: "02. How do I earn loyalty points?",
            answer:
                "Earning loyalty points is simple!For every rupee spent on eligible purchases from our outlet,you will earn a certain number of points.The more you spend,the more points you earn.Keep an eye out for special promotions and bonus point offers to maximize your rewards",
          ),
          const SizedBox(
            height: 10,
          ),
          EasyFaq(
            question: "03. Do my loyalty points expire?",
            answer:
                "Typically,loyalty points do not expires as long as your account remains active.However,in rare cases or under certain circumstances,we reserve the right to adjust our loyalty program terms,including the expiration of points.We will notify you in advance of any changes to our program",
          ),
          const SizedBox(
            height: 10,
          ),
          EasyFaq(
            question: "04. Can I transfer my loyalty points to another account?",
            answer:
            "Loyalty points are non-transferable and can only be redeemed by the account holder who earned them.Points cannot be combined or transferred between accounts",
          ),
          const SizedBox(
            height: 10,
          ),
          EasyFaq(
            question: "05. How are loyalty points calculated?",
            answer:
            "Loyalty Points are typically calculated based on the amount spent on eligible purchases. For example,you might earn one point for every rupee spent.The exact calculation may vary depending on promotions or specific terms of the loyalty program",
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
