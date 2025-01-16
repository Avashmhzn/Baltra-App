import 'package:baltra/core/utils/constants.dart';
import 'package:baltra/features/products/models/review.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ReviewController extends GetxController {
  var reviews = <Review>[].obs;
  var ratingData = RatingData(
    average_rating: 0.0,
    rating_sum: 0,
    total_reviews: 0,
    rating_distribution: {},
  ).obs;

  var isLoading = false.obs;

  Future<void> fetchReviewsAndRatings(int id) async {
    final url = '$URL/products/productratings/$id';

    try {
      isLoading(true);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        reviews.value =
            (data['data'] as List).map((i) => Review.fromJson(i)).toList();
        ratingData.value = RatingData.fromJson(data['rating_data']);
      } else {
        _showErrorDialog('Failed to load data');
      }
    } catch (error) {
      _showErrorDialog('An error occurred: $error');
    } finally {
      isLoading(false);
    }
  }

  void _showErrorDialog(String message) {
    Get.dialog(
      AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  // api to post review which have text, productid and rating

  Future<void> postReview(int productId, String reviewText, int rating) async {
    final url = '$URL/products/addrating';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      _showErrorDialog('Token not found');
      return;
    }

    try {
      isLoading(true);
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(
            {'review': reviewText, 'rating': rating, 'product_id': productId}),
      );

      if (response.statusCode == 200) {
        fetchReviewsAndRatings(productId);
        Get.snackbar('Success', 'Review submitted successfully');
      } else {
        _showErrorDialog('Failed to submit review');
      }
    } catch (error) {
      _showErrorDialog('An error occurred: $error');
    } finally {
      isLoading(false);
    }
  }
}
