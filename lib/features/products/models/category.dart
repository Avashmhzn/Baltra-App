class Category {
  final int id;
  final String banner;
  final String name;
  final String image_url;

  Category({
    required this.id,
    required this.banner,
    required this.image_url,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['id'] as num?)?.toInt() ?? 0,
      banner: json['banner'] as String? ?? "",
      image_url: json['image_url'] as String? ?? "",
      name: json['name'] as String? ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'banner': banner,
        'image_url': image_url,
        'name': name,
      };
}
