import 'package:baltra/features/products/controller/reviewController.dart';
import 'package:baltra/features/products/models/review.dart';
import 'package:baltra/features/products/presentation/widgets/reviewCard.dart';
import 'package:flutter/material.dart';
import 'package:rating_summary/rating_summary.dart';

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
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();
  bool showAllReviews = false; // Added showAllReviews flag

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      _loadMoreReviews();
    }
  }

  Future<void> _loadMoreReviews() async {
    setState(() {
      _isLoadingMore = true;
    });

    await widget.reviewController.loadMoreReviews(widget.productId);

    setState(() {
      _isLoadingMore = false;
    });
  }

  Widget _buildStar(int index) {
    if (index < _currentRating) {
      return const Icon(
        Icons.star,
        color: Colors.amber,
        size: 30,
      );
    } else {
      return const Icon(
        Icons.star_border,
        color: Colors.amber,
        size: 30,
      );
    }
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
    bool hasRatings =
        widget.reviewController.ratingData.value.total_reviews > 0;
    bool hasReviews = widget.reviewController.reviews.isNotEmpty;
    int reviewCount = widget.reviewController.reviews.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasRatings || hasReviews) ...[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: RatingSummary(
              counter: widget.reviewController.ratingData.value.total_reviews,
              average: hasRatings
                  ? widget.reviewController.ratingData.value.average_rating
                  : 0.0,
              counterFiveStars: widget.reviewController.ratingData.value
                      .rating_distribution['5'] ??
                  0,
              counterFourStars: widget.reviewController.ratingData.value
                      .rating_distribution['4'] ??
                  0,
              counterThreeStars: widget.reviewController.ratingData.value
                      .rating_distribution['3'] ??
                  0,
              counterTwoStars: widget.reviewController.ratingData.value
                      .rating_distribution['2'] ??
                  0,
              counterOneStars: widget.reviewController.ratingData.value
                      .rating_distribution['1'] ??
                  0,
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
              child:
                  Text('No reviews yet', style: TextStyle(color: Colors.grey))),
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
          onTap: () async {
            if (reviewTextController.text.isNotEmpty && !_isSubmitting) {
              setState(() {
                _isSubmitting = true;
              });

              await widget.reviewController.postReview(
                widget.productId,
                reviewTextController.text,
                _currentRating,
              );

              setState(() {
                _isSubmitting = false;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 10,
            ),
            color: Theme.of(context).primaryColor,
            child: _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
