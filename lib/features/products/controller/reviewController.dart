import 'package:baltra/core/utils/constants.dart';
import 'package:baltra/features/products/models/review.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

class RatingData {
  final double? average_rating;
  final int? rating_sum;
  final int? total_reviews;
  final Map<String, int>? rating_distribution;

  RatingData({
    required this.average_rating,
    required this.rating_sum,
    required this.total_reviews,
    required this.rating_distribution,
  });

  factory RatingData.fromJson(Map<String, dynamic> json) {
    double? avgRating = (json['average_rating'] as num?)?.toDouble();
    if (avgRating != null && (avgRating.isNaN || avgRating.isInfinite)) {
      avgRating = 0.0;
    }
    return RatingData(
      average_rating: avgRating,
      rating_sum: json['rating_sum'] as int? ?? 0,
      total_reviews: json['total_reviews'] as int? ?? 0,
      rating_distribution: (json['rating_distribution'] as Map?)?.cast<String, int>() ??
          {'1': 0, '2': 0, '3': 0, '4': 0, '5': 0},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average_rating': average_rating,
      'rating_sum': rating_sum,
      'total_reviews': total_reviews,
      'rating_distribution': rating_distribution,
    };
  }
}

class ReviewController extends GetxController {
  var reviews = <Review>[].obs;
  var ratingData = RatingData(
    average_rating: 0.0,
    rating_sum: 0,
    total_reviews: 0,
    rating_distribution: {'1': 0, '2': 0, '3': 0, '4': 0, '5': 0},
  ).obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  int _currentPage = 1;
  bool _hasMoreReviews = true;
  int? _lastProductId;

  // Expose _hasMoreReviews as a public getter
  bool get hasMoreReviews => _hasMoreReviews;

  @override
  void onInit() {
    super.onInit();
    log('ReviewController initialized');
  }

  Future<void> fetchReviewsAndRatings(int id) async {
    if (_lastProductId == id && reviews.isNotEmpty) {
      log('ReviewController: Reviews already fetched for product ID: $id, skipping fetch');
      return;
    }

    log('Fetching reviews for product ID: $id');
    _lastProductId = id;
    _currentPage = 1;
    _hasMoreReviews = true;
    isLoading.value = true;
    reviews.value = [];
    ratingData.value = RatingData(
      average_rating: 0.0,
      rating_sum: 0,
      total_reviews: 0,
      rating_distribution: {'1': 0, '2': 0, '3': 0, '4': 0, '5': 0},
    );
    await _fetchReviews(id, page: _currentPage);
    isLoading.value = false;
    log('Fetched reviews for product ID: $id, review count: ${reviews.length}, rating data: ${ratingData.value.toJson()}');
  }

  Future<void> loadMoreReviews(int id) async {
    if (!_hasMoreReviews || isLoadingMore.value) {
      log('ReviewController: Skipping load more, hasMoreReviews: $_hasMoreReviews, isLoadingMore: ${isLoadingMore.value}');
      return;
    }

    log('Loading more reviews for product ID: $id, page: ${_currentPage + 1}');
    isLoadingMore.value = true;
    _currentPage++;
    await _fetchReviews(id, page: _currentPage);
    isLoadingMore.value = false;
    log('Loaded more reviews for product ID: $id, review count: ${reviews.length}');
  }

  Future<void> _fetchReviews(int id, {int page = 1}) async {
    final url = '$URL/products/productratings/$id?page=$page';
    log('Making API call to: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log('API response for product ID: $id, page: $page, data: $data');

        if (data['data'] != null) {
          List<Review> newReviews = (data['data'] as List)
              .map((i) => Review.fromJson(i))
              .toList();
          if (newReviews.isNotEmpty) {
            reviews.addAll(newReviews);
          } else {
            _hasMoreReviews = false;
            log('No more reviews to load for product ID: $id');
          }
        }

        if (data['rating_data'] != null) {
          final newRatingData = RatingData.fromJson(data['rating_data']);
          if (newRatingData.average_rating?.isFinite == true &&
              newRatingData.total_reviews != null &&
              newRatingData.rating_distribution != null) {
            ratingData.value = newRatingData;
          } else {
            ratingData.value = RatingData(
              average_rating: 0.0,
              rating_sum: 0,
              total_reviews: 0,
              rating_distribution: {'1': 0, '2': 0, '3': 0, '4': 0, '5': 0},
            );
            log('Invalid rating data received, using default for product ID: $id');
          }
        }
      } else {
        _showErrorDialog('Failed to load data. Status code: ${response.statusCode}');
        log('API error for product ID: $id, status code: ${response.statusCode}');
      }
    } catch (error) {
      _showErrorDialog('An error occurred: $error');
      log('Error fetching reviews for product ID: $id, error: $error');
    }
  }

  Future<void> postReview(int productId, String reviewText, int rating) async {
    final url = '$URL/products/addrating';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      _showErrorDialog('Token not found');
      log('No auth token found for posting review for product ID: $productId');
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
        _lastProductId = null; // Reset to force refresh
        await fetchReviewsAndRatings(productId);
        Get.snackbar('Success', 'Review submitted successfully');
        log('Review submitted successfully for product ID: $productId');
      } else {
        _showErrorDialog('Failed to submit review. Status code: ${response.statusCode}');
        log('Failed to submit review for product ID: $productId, status code: ${response.statusCode}');
      }
    } catch (error) {
      _showErrorDialog('An error occurred: $error');
      log('Error posting review for product ID: $productId, error: $error');
    } finally {
      isLoading.value = false;
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
}