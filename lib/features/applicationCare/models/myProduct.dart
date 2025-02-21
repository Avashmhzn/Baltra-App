import 'package:json_annotation/json_annotation.dart';

part 'myProduct.g.dart';

@JsonSerializable()
class Myproduct {
  final int id;
  final String serial_number;
  final String warranty_issue;
  final String? warranty_expiry;
  final String warranty_image;
  final String store_name;
  final String store_location;
  final String store_number;
  final String model_num;
  final String model_name;
  final String bill_image_one;
  final String? warranty_card;
  final String product_image;
  final String status;
  final bool is_verified;
  final String created_at;
  final String purchase_date;
  final String customer;
  final int product;
  final String? extended_warranty;
  String job_No;

  Myproduct({
    required this.id,
    required this.serial_number,
    required this.warranty_issue,
    this.warranty_expiry,
    required this.warranty_image,
    required this.store_name,
    required this.store_location,
    required this.store_number,
    required this.model_num,
    required this.model_name,
    required this.bill_image_one,
    this.warranty_card,
    required this.product_image,
    required this.status,
    required this.is_verified,
    required this.created_at,
    required this.purchase_date,
    required this.customer,
    required this.product,
    this.extended_warranty,
    required this.job_No,
  });

  factory Myproduct.fromJson(Map<String, dynamic> json) =>
      _$MyproductFromJson(json);

  Map<String, dynamic> toJson() => _$MyproductToJson(this);
}
