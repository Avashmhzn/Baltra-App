import 'package:baltra/features/applicationCare/presentation/widgets/myproduct_details_skeletion.dart';
import 'package:baltra/features/products/controller/reviewController.dart';
import 'package:baltra/features/products/models/review.dart';
import 'package:baltra/features/products/presentation/widgets/reviewCard.dart';
import 'package:flutter/material.dart';
import 'package:rating_summary/rating_summary.dart';
import 'package:get/get.dart';
import 'dart:developer';

class ReviewsSection extends StatefulWidget {
  const ReviewsSection({
    super.key,
    required this.reviewController,
    required this.productId,
  });

  final ReviewController reviewController;
  final int productId;

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  final TextEditingController reviewTextController = TextEditingController();
  int _currentRating = 0;
  bool _isSubmitting = false;
  final ScrollController _scrollController = ScrollController();
  bool showAllReviews = false;
  bool _reviewsFetched = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_reviewsFetched && widget.reviewController.reviews.isEmpty) {
        log('ReviewsSection: Fetching reviews for product ID: ${widget.productId}');
        widget.reviewController.fetchReviewsAndRatings(widget.productId).then((_) {
          if (mounted) {
            setState(() {
              _reviewsFetched = true;
            });
          }
        });
      } else {
        log('ReviewsSection: Skipping fetch, reviews already loaded for product ID: ${widget.productId}');
      }
    });
    log('ReviewsSection initialized for product ID: ${widget.productId}');
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
        !widget.reviewController.isLoadingMore.value &&
        widget.reviewController.hasMoreReviews) { // Changed to public getter
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.reviewController.loadMoreReviews(widget.productId);
      });
    }
  }

  Widget _buildStar(int index) {
    return Icon(
      index < _currentRating ? Icons.star : Icons.star_border,
      color: Colors.amber,
      size: 30,
    );
  }

  Widget _buildRatingBar() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = index + 1;
            });
          },
          child: _buildStar(index),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.reviewController.isLoading.value) {
        log('ReviewsSection: Showing ProductDetailSkeleton for product ID: ${widget.productId}');
        return const Center(child: ProductDetailSkeleton());
      }

      final ratingData = widget.reviewController.ratingData.value;
      final totalReviews = ratingData.total_reviews ?? 0;
      final averageRating = (ratingData.average_rating?.isFinite == true
          ? ratingData.average_rating!
          : 0.0)
          .clamp(0.0, 5.0);
      final ratingDistribution = ratingData.rating_distribution?.isNotEmpty == true
          ? ratingData.rating_distribution!
          : {'1': 0, '2': 0, '3': 0, '4': 0, '5': 0};

      final counter = [
        ratingDistribution['5'] ?? 0,
        ratingDistribution['4'] ?? 0,
        ratingDistribution['3'] ?? 0,
        ratingDistribution['2'] ?? 0,
        ratingDistribution['1'] ?? 0,
      ];

      bool hasRatings = totalReviews > 0;
      bool hasReviews = widget.reviewController.reviews.isNotEmpty;
      int reviewCount = widget.reviewController.reviews.length;
      log('ReviewsSection: Rendering for product ID: ${widget.productId}, hasRatings: $hasRatings, hasReviews: $hasReviews, reviewCount: $reviewCount');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasRatings || hasReviews) ...[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: RatingSummary(
                counter: totalReviews,
                average: averageRating,
                counterFiveStars: counter[0],
                counterFourStars: counter[1],
                counterThreeStars: counter[2],
                counterTwoStars: counter[3],
                counterOneStars: counter[4],
              ),
            ),
            ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: showAllReviews
                  ? reviewCount
                  : (reviewCount > 3 ? 3 : reviewCount),
              itemBuilder: (context, index) {
                Review review = widget.reviewController.reviews[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: ReviewCard(review: review),
                );
              },
            ),
            if (reviewCount > 3 && !showAllReviews)
              TextButton(
                onPressed: () {
                  setState(() {
                    showAllReviews = true;
                  });
                  log('Clicked "See All Reviews" for product ID: ${widget.productId}');
                },
                child: const Text(
                  "See All Reviews",
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ),
          ] else
            const Center(
                child: Text('No reviews yet', style: TextStyle(color: Colors.grey))),
          const SizedBox(height: 20),
          const Text(
            'Rate this product',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
          ),
          const Text(
            'Tell others what you think',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xffA1A1A1)),
          ),
          _buildRatingBar(),
          const SizedBox(height: 16.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child: TextFormField(
              controller: reviewTextController,
              maxLines: 10,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Write your review here....',
                hintStyle: TextStyle(
                  color: Color(0xffA1A1A1),
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: _isSubmitting || reviewTextController.text.isEmpty
                ? null
                : () async {
              setState(() {
                _isSubmitting = true;
              });
              log('Submitting review for product ID: ${widget.productId}');
              await widget.reviewController.postReview(
                widget.productId,
                reviewTextController.text,
                _currentRating,
              );
              if (mounted) {
                setState(() {
                  _isSubmitting = false;
                  reviewTextController.clear();
                  _currentRating = 0;
                  _reviewsFetched = false;
                });
              }
              log('Review submission completed for product ID: ${widget.productId}');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              color: Theme.of(context).primaryColor,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                'Submit',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          if (widget.reviewController.isLoadingMore.value)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: ProductDetailSkeleton()),
            ),
          const SizedBox(height: 20),
        ],
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    reviewTextController.dispose();
    log('ReviewsSection disposed for product ID: ${widget.productId}');
    super.dispose();
  }
}