// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
      rating: (json['rating'] as num).toInt(),
      review: json['review'] as String,
      date_joined: json['date_joined'] as String,
      customer: Customer.fromJson(json['customer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
      'rating': instance.rating,
      'review': instance.review,
      'date_joined': instance.date_joined,
      'customer': instance.customer.toJson(),
    };

Customer _$CustomerFromJson(Map<String, dynamic> json) => Customer(
      id: json['id'] as String,
      first_name: json['first_name'] as String,
      last_name: json['last_name'] as String,
      image_url: json['image_url'] as String?,
    );

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
      'id': instance.id,
      'first_name': instance.first_name,
      'last_name': instance.last_name,
      'image_url': instance.image_url,
    };

RatingData _$RatingDataFromJson(Map<String, dynamic> json) => RatingData(
      average_rating: (json['average_rating'] as num).toDouble(),
      rating_sum: (json['rating_sum'] as num).toInt(),
      total_reviews: (json['total_reviews'] as num).toInt(),
      rating_distribution:
          Map<String, int>.from(json['rating_distribution'] as Map),
    );

Map<String, dynamic> _$RatingDataToJson(RatingData instance) =>
    <String, dynamic>{
      'average_rating': instance.average_rating,
      'rating_sum': instance.rating_sum,
      'total_reviews': instance.total_reviews,
      'rating_distribution': instance.rating_distribution,
    };
