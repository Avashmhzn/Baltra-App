

class Review {
  final int rating;
  final String review;
  final String date_joined;
  final Customer customer;
  DateTime get reviewDate {
    try {
      return DateTime.parse(date_joined);
    } catch (_) {
      return DateTime.now();
    }
  }

  Review({
    required this.rating,
    required this.review,
    required this.date_joined,
    required this.customer,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      review: json['review']?.toString() ?? '',
      date_joined: json['date_joined']?.toString() ?? DateTime.now().toIso8601String(),
      customer: json['customer'] != null
          ? Customer.fromJson(json['customer'] as Map<String, dynamic>)
          : Customer(id: '', first_name: 'Anonymous', last_name: ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'review': review,
      'date_joined': date_joined,
      'customer': customer.toJson(),
    };
  }
}

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

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id']?.toString() ?? '',
      first_name: json['first_name']?.toString() ?? '',
      last_name: json['last_name']?.toString() ?? '',
      image_url: json['image_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': first_name,
      'last_name': last_name,
      'image_url': image_url,
    };
  }
}

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

  factory RatingData.fromJson(Map<String, dynamic> json) {
    final rawDistribution = json['rating_distribution'] as Map?;
    final Map<String, int> distribution = {'1': 0, '2': 0, '3': 0, '4': 0, '5': 0};
    if (rawDistribution != null) {
      rawDistribution.forEach((key, value) {
        if (key != null) {
          distribution[key.toString()] = (value as num?)?.toInt() ?? 0;
        }
      });
    }

    double? avgRating = (json['average_rating'] as num?)?.toDouble();
    if (avgRating == null || avgRating.isNaN || avgRating.isInfinite) {
      avgRating = 0.0;
    }

    return RatingData(
      average_rating: avgRating,
      rating_sum: (json['rating_sum'] as num?)?.toInt() ?? 0,
      total_reviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      rating_distribution: distribution,
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
