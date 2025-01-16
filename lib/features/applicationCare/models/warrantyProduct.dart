import 'package:json_annotation/json_annotation.dart';

part 'warrantyProduct.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductModel {
  @JsonKey(name: 'stock_details')
  final StockDetails stockDetails;

  @JsonKey(name: 'warranty_details')
  final WarrantyDetails warrantyDetails;

  ProductModel({
    required this.stockDetails,
    required this.warrantyDetails,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}

@JsonSerializable()
class StockDetails {
  final int id;

  @JsonKey(name: 'serial_number')
  final String serialNumber;

  @JsonKey(name: 'warranty_issue')
  final String warrantyIssue;

  @JsonKey(name: 'warranty_expiry')
  final String warrantyExpiry;

  @JsonKey(name: 'warranty_image')
  final String warrantyImage;

  @JsonKey(name: 'store_name')
  final String storeName;

  @JsonKey(name: 'store_location')
  final String storeLocation;

  @JsonKey(name: 'store_number')
  final String storeNumber;

  @JsonKey(name: 'model_num')
  final String modelNum;

  @JsonKey(name: 'model_name')
  final String modelName;

  @JsonKey(name: 'bill_image_one')
  final String? billImageOne;

  @JsonKey(name: 'warranty_card')
  final String? warrantyCard;

  @JsonKey(name: 'product_image')
  final String productImage;

  final String status;

  @JsonKey(name: 'is_verified')
  final bool isVerified;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'purchase_date')
  final String purchaseDate;

  @JsonKey(name: 'temp_reward')
  final int tempReward;

  final String customer;
  final int product;

  @JsonKey(name: 'extended_warranty')
  final String? extendedWarranty;

  StockDetails({
    required this.id,
    required this.serialNumber,
    required this.warrantyIssue,
    required this.warrantyExpiry,
    required this.warrantyImage,
    required this.storeName,
    required this.storeLocation,
    required this.storeNumber,
    required this.modelNum,
    required this.modelName,
    this.billImageOne,
    this.warrantyCard,
    required this.productImage,
    required this.status,
    required this.isVerified,
    required this.createdAt,
    required this.purchaseDate,
    required this.tempReward,
    required this.customer,
    required this.product,
    this.extendedWarranty,
  });

  factory StockDetails.fromJson(Map<String, dynamic> json) =>
      _$StockDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$StockDetailsToJson(this);
}

@JsonSerializable()
class WarrantyDetails {
  @JsonKey(name: 'product_mrp')
  final int productMrp;

  final double price;
  final int duration;

  @JsonKey(name: 'tier_type')
  final String tierType;

  WarrantyDetails({
    required this.productMrp,
    required this.price,
    required this.duration,
    required this.tierType,
  });

  factory WarrantyDetails.fromJson(Map<String, dynamic> json) =>
      _$WarrantyDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$WarrantyDetailsToJson(this);
}
