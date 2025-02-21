// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subcategoryProduct.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subcategoryproduct _$SubcategoryproductFromJson(Map<String, dynamic> json) =>
    Subcategoryproduct(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      main_image_url: json['main_image_url'] as String,
      warranty: (json['warranty'] as num).toInt(),
      power: json['power'] as String,
      model_no: json['model_num'] as String,
      model_name: json['model_name'] as String,
      price: (json['price'] as num?)?.toInt(),
      sub_category: json['sub_category'] as String,
    );

Map<String, dynamic> _$SubcategoryproductToJson(Subcategoryproduct instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'main_image_url': instance.main_image_url,
      'warranty': instance.warranty,
      'power': instance.power,
      'model_num': instance.model_no,
      'model_name': instance.model_name,
      'price': instance.price,
      'sub_category': instance.sub_category,
    };
