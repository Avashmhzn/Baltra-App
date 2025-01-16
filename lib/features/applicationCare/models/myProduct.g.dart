// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'myProduct.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Myproduct _$MyproductFromJson(Map<String, dynamic> json) => Myproduct(
      id: (json['id'] as num).toInt(),
      serial_number: json['serial_number'] as String,
      warranty_issue: json['warranty_issue'] as String,
      warranty_expiry: json['warranty_expiry'] as String?,
      warranty_image: json['warranty_image'] as String,
      store_name: json['store_name'] as String,
      store_location: json['store_location'] as String,
      store_number: json['store_number'] as String,
      model_num: json['model_num'] as String,
      model_name: json['model_name'] as String,
      bill_image_one: json['bill_image_one'] as String,
      warranty_card: json['warranty_card'] as String?,
      product_image: json['product_image'] as String,
      status: json['status'] as String,
      is_verified: json['is_verified'] as bool,
      created_at: json['created_at'] as String,
      purchase_date: json['purchase_date'] as String,
      customer: json['customer'] as String,
      product: (json['product'] as num).toInt(),
      extended_warranty: json['extended_warranty'] as String?,
    );

Map<String, dynamic> _$MyproductToJson(Myproduct instance) => <String, dynamic>{
      'id': instance.id,
      'serial_number': instance.serial_number,
      'warranty_issue': instance.warranty_issue,
      'warranty_expiry': instance.warranty_expiry,
      'warranty_image': instance.warranty_image,
      'store_name': instance.store_name,
      'store_location': instance.store_location,
      'store_number': instance.store_number,
      'model_num': instance.model_num,
      'model_name': instance.model_name,
      'bill_image_one': instance.bill_image_one,
      'warranty_card': instance.warranty_card,
      'product_image': instance.product_image,
      'status': instance.status,
      'is_verified': instance.is_verified,
      'created_at': instance.created_at,
      'purchase_date': instance.purchase_date,
      'customer': instance.customer,
      'product': instance.product,
      'extended_warranty': instance.extended_warranty,
    };
