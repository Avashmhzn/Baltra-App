import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

@JsonSerializable(explicitToJson: true)
class Review {
  final int rating;
  final String review;
  final String date_joined;
  final Customer customer;

  Review({
    required this.rating,
    required this.review,
    required this.date_joined,
    required this.customer,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}

@JsonSerializable()
class Customer {
  final String id;
  final String first_name;
  final String last_name;
  final String? image_url;

  Customer({
    required this.id,
    required this.first_name,
    required this.last_name,
    this.image_url,
  });

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RatingData {
  final double average_rating;
  final int rating_sum;
  final int total_reviews;
  final Map<String, int> rating_distribution;

  RatingData({
    required this.average_rating,
    required this.rating_sum,
    required this.total_reviews,
    required this.rating_distribution,
  });

  factory RatingData.fromJson(Map<String, dynamic> json) =>
      _$RatingDataFromJson(json);
  Map<String, dynamic> toJson() => _$RatingDataToJson(this);
}
