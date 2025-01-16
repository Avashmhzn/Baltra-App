import 'package:json_annotation/json_annotation.dart';

part 'subcategoryProduct.g.dart';

@JsonSerializable()
class Subcategoryproduct {
  final int id;
  final String name;
  final String main_image_url;
  final int warranty;
  final String power;
  final String model_no;
  final String model_name;
  int? price;
  Subcategoryproduct({
    required this.id,
    required this.name,
    required this.main_image_url,
    required this.warranty,
    required this.power,
    required this.model_no,
    required this.model_name,
    this.price,
  });
  factory Subcategoryproduct.fromJson(Map<String, dynamic> json) =>
      _$SubcategoryproductFromJson(json);

  Map<String, dynamic> toJson() => _$SubcategoryproductToJson(this);
}



//   "id": 1,
            // "name": "Blender: Crush 3",
            // "model_name": "Blender",
            // "model_no": "BMG 174",
            // "power": "50KW",
            // "warranty": "12 Months Warranty",
            // "main_image_url": "http://192.168.1.215:8000/media/product_images/WhatsApp_Image_2024-05-27_at_12.54_6_Qs1Gvgq.png"