class Subcategory {
  final int id;
  final String name;
  final String image_url;

  Subcategory({
    required this.id,
    required this.name,
    required this.image_url,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? "",
      image_url: json['image_url'] as String? ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image_url': image_url,
      };
}
