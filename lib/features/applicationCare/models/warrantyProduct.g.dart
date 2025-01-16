// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warrantyProduct.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      stockDetails:
          StockDetails.fromJson(json['stock_details'] as Map<String, dynamic>),
      warrantyDetails: WarrantyDetails.fromJson(
          json['warranty_details'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'stock_details': instance.stockDetails.toJson(),
      'warranty_details': instance.warrantyDetails.toJson(),
    };

StockDetails _$StockDetailsFromJson(Map<String, dynamic> json) => StockDetails(
      id: (json['id'] as num).toInt(),
      serialNumber: json['serial_number'] as String,
      warrantyIssue: json['warranty_issue'] as String,
      warrantyExpiry: json['warranty_expiry'] as String,
      warrantyImage: json['warranty_image'] as String,
      storeName: json['store_name'] as String,
      storeLocation: json['store_location'] as String,
      storeNumber: json['store_number'] as String,
      modelNum: json['model_num'] as String,
      modelName: json['model_name'] as String,
      billImageOne: json['bill_image_one'] as String?,
      warrantyCard: json['warranty_card'] as String?,
      productImage: json['product_image'] as String,
      status: json['status'] as String,
      isVerified: json['is_verified'] as bool,
      createdAt: json['created_at'] as String,
      purchaseDate: json['purchase_date'] as String,
      tempReward: (json['temp_reward'] as num).toInt(),
      customer: json['customer'] as String,
      product: (json['product'] as num).toInt(),
      extendedWarranty: json['extended_warranty'] as String?,
    );

Map<String, dynamic> _$StockDetailsToJson(StockDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serial_number': instance.serialNumber,
      'warranty_issue': instance.warrantyIssue,
      'warranty_expiry': instance.warrantyExpiry,
      'warranty_image': instance.warrantyImage,
      'store_name': instance.storeName,
      'store_location': instance.storeLocation,
      'store_number': instance.storeNumber,
      'model_num': instance.modelNum,
      'model_name': instance.modelName,
      'bill_image_one': instance.billImageOne,
      'warranty_card': instance.warrantyCard,
      'product_image': instance.productImage,
      'status': instance.status,
      'is_verified': instance.isVerified,
      'created_at': instance.createdAt,
      'purchase_date': instance.purchaseDate,
      'temp_reward': instance.tempReward,
      'customer': instance.customer,
      'product': instance.product,
      'extended_warranty': instance.extendedWarranty,
    };

WarrantyDetails _$WarrantyDetailsFromJson(Map<String, dynamic> json) =>
    WarrantyDetails(
      productMrp: (json['product_mrp'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      duration: (json['duration'] as num).toInt(),
      tierType: json['tier_type'] as String,
    );

Map<String, dynamic> _$WarrantyDetailsToJson(WarrantyDetails instance) =>
    <String, dynamic>{
      'product_mrp': instance.productMrp,
      'price': instance.price,
      'duration': instance.duration,
      'tier_type': instance.tierType,
    };
