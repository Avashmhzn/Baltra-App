// import 'package:json_annotation/json_annotation.dart';

// part 'myProduct.g.dart';

// @JsonSerializable()
// class Myproduct {
//   final int id;
//   final String serial_number;
//   final String warranty_issue;
//   final String? warranty_expiry;
//   final String? warranty_image;
//   final String store_name;
//   final String store_location;
//   final String store_number;
//   final String model_num;
//   final String model_name;
//   final String? bill_image_one;
//   final String? warranty_card;
//   final String? product_image;
//   final String status;
//   final bool is_verified;
//   final String created_at;
//   final String purchase_date;
//   final String customer;
//   final int product;
//   final String? extended_warranty;
//   String job_No;

//   Myproduct({
//     required this.id,
//     required this.serial_number,
//     required this.warranty_issue,
//     this.warranty_expiry,
//     this.warranty_image,
//     required this.store_name,
//     required this.store_location,
//     required this.store_number,
//     required this.model_num,
//     required this.model_name,
//     this.bill_image_one,
//     this.warranty_card,
//     this.product_image,
//     required this.status,
//     required this.is_verified,
//     required this.created_at,
//     required this.purchase_date,
//     required this.customer,
//     required this.product,
//     this.extended_warranty,
//     required this.job_No,
//   });

//   factory Myproduct.fromJson(Map<String, dynamic> json) =>
//       _$MyproductFromJson(json);

//   Map<String, dynamic> toJson() => _$MyproductToJson(this);
// }

import 'package:json_annotation/json_annotation.dart';

part 'myProduct.g.dart';

@JsonSerializable()
class Myproduct {
  final int id;
  final String? serial_number;
  final String? warranty_issue;
  final String? warranty_expiry;
  final String? warranty_image;
  final String? store_name;
  final String? store_location;
  final String? store_number;
  final String? model_num;
  final String? model_name;
  final String? bill_image_one;
  final String? warranty_card;
  final String? product_image;
  final String? status;
  final bool? is_verified;
  final String? created_at;
  final String? purchase_date;
  final String? customer;
  final int? product;
  final String? extended_warranty;
  final String? job_No;

  Myproduct({
    required this.id,
    this.serial_number,
    this.warranty_issue,
    this.warranty_expiry,
    this.warranty_image,
    this.store_name,
    this.store_location,
    this.store_number,
    this.model_num,
    this.model_name,
    this.bill_image_one,
    this.warranty_card,
    this.product_image,
    this.status,
    this.is_verified,
    this.created_at,
    this.purchase_date,
    this.customer,
    this.product,
    this.extended_warranty,
    this.job_No,
  });

  // Override fromJson manually instead of using generated code
  factory Myproduct.fromJson(Map<String, dynamic> json) {
    return Myproduct(
      id: json['id'] as int? ?? 0,
      serial_number: json['serial_number'] as String?,
      warranty_issue: json['warranty_issue'] as String?,
      warranty_expiry: json['warranty_expiry'] as String?,
      warranty_image: json['warranty_image'] as String?,
      store_name: json['store_name'] as String?,
      store_location: json['store_location'] as String?,
      store_number: json['store_number'] as String?,
      model_num: json['model_num'] as String?,
      model_name: json['model_name'] as String?,
      bill_image_one: json['bill_image_one'] as String?,
      warranty_card: json['warranty_card'] as String?,
      product_image: json['product_image'] as String?,
      status: json['status'] as String?,
      is_verified: json['is_verified'] as bool?,
      created_at: json['created_at'] as String?,
      purchase_date: json['purchase_date'] as String?,
      customer: json['customer'] as String?,
      product: json['product'] as int?,
      extended_warranty: json['extended_warranty'] as String?,
      job_No: json['job_No'] as String? ?? json['job_no'] as String?,
    );
  }

  Map<String, dynamic> toJson() => _$MyproductToJson(this);
}
