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
  var isLoadingMore = false.obs;
  int _currentPage = 1;
  bool _hasMoreReviews = true;

  /// Fetches the first page of reviews and resets pagination.
  Future<void> fetchReviewsAndRatings(int id) async {
    _currentPage = 1;  // Reset to first page
    _hasMoreReviews = true;
    reviews.clear(); // Clear old reviews
    await _fetchReviews(id, page: _currentPage);
  }

  /// Loads more reviews when scrolling down.
  Future<void> loadMoreReviews(int id) async {
    if (!_hasMoreReviews || isLoadingMore.value) return; // Prevent multiple calls

    isLoadingMore.value = true;
    _currentPage++;
    await _fetchReviews(id, page: _currentPage);
    isLoadingMore.value = false;
  }

  /// Fetches reviews with pagination.
  Future<void> _fetchReviews(int id, {int page = 1}) async {
    final url = '$URL/products/productratings/$id?page=$page';

    try {
      isLoading.value = page == 1; // Show main loading only for first page
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Append new reviews instead of replacing
        if (data['data'] != null) {
          List<Review> newReviews = (data['data'] as List)
              .map((i) => Review.fromJson(i))
              .toList();
          if (newReviews.isNotEmpty) {
            reviews.addAll(newReviews);
          } else {
            _hasMoreReviews = false; // No more reviews to load
          }
        }

        if (data['rating_data'] != null) {
          ratingData.value = RatingData.fromJson(data['rating_data']);
        }
      } else {
        _showErrorDialog(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      _showErrorDialog('An error occurred: $error');
    } finally {
      isLoading.value = false;
    }
  }

  /// Posts a review for a product.
  Future<void> postReview(int productId, String reviewText, int rating) async {
    final url = '$URL/products/addrating';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      _showErrorDialog('Token not found');
      return;
    }

    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'review': reviewText,
          'rating': rating,
          'product_id': productId,
        }),
      );

      if (response.statusCode == 200) {
        await fetchReviewsAndRatings(productId); // Refresh reviews
        Get.snackbar('Success', 'Review submitted successfully');
      } else {
        _showErrorDialog(
            'Failed to submit review. Status code: ${response.statusCode}');
      }
    } catch (error) {
      _showErrorDialog('An error occurred: $error');
    } finally {
      isLoading.value = false;
    }
  }

  /// Displays an error dialog using GetX.
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

  @override
  void onInit() {
    super.onInit();
  }
}
