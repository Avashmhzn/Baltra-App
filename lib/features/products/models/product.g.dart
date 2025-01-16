// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      sub_heading: json['sub_heading'] as String?,
      price: (json['price'] as num?)?.toInt(),
      power: json['power'] as String?,
      warranty: (json['warranty'] as num?)?.toInt(),
      reward_points: (json['reward_points'] as num?)?.toInt(),
      model_name: json['model_name'] as String?,
      model_num: json['model_num'] as String?,
      serial_number: json['serial_number'] as String?,
      packaging: json['packaging'] as String?,
      specification: json['specification'] as String?,
      sizing: json['sizing'] as String?,
      usage: json['usage'] as String?,
      color_styles: (json['color_styles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      sizes:
          (json['sizes'] as List<dynamic>?)?.map((e) => e as String).toList(),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => ImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      main_image: json['main_image'] as String?,
      product_video: json['product_video'] as String?,
      warranty_icon: json['warranty_icon'] as String?,
      specification_images: (json['specification_images'] as List<dynamic>?)
          ?.map((e) => ImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      sizing_images: (json['sizing_images'] as List<dynamic>?)
          ?.map((e) => ImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      usage_images: (json['usage_images'] as List<dynamic>?)
          ?.map((e) => ImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      galleryimagetwo: json['galleryimagetwo'] as String?,
      galleryimageone: json['galleryimageone'] as String?,
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sub_heading': instance.sub_heading,
      'price': instance.price,
      'power': instance.power,
      'warranty': instance.warranty,
      'reward_points': instance.reward_points,
      'model_name': instance.model_name,
      'model_num': instance.model_num,
      'serial_number': instance.serial_number,
      'packaging': instance.packaging,
      'sizing': instance.sizing,
      'specification': instance.specification,
      'color_styles': instance.color_styles,
      'usage': instance.usage,
      'images': instance.images,
      'sizes': instance.sizes,
      'product_video': instance.product_video,
      'main_image': instance.main_image,
      'specification_images': instance.specification_images,
      'warranty_icon': instance.warranty_icon,
      'usage_images': instance.usage_images,
      'sizing_images': instance.sizing_images,
      'galleryimagetwo': instance.galleryimagetwo,
      'galleryimageone': instance.galleryimageone,
    };

ImageModel _$ImageModelFromJson(Map<String, dynamic> json) => ImageModel(
      image_url: json['image_url'] as String?,
    );

Map<String, dynamic> _$ImageModelToJson(ImageModel instance) =>
    <String, dynamic>{
      'image_url': instance.image_url,
    };
