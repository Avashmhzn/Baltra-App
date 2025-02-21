// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
      data: User.fromJson(json['data'] as Map<String, dynamic>),
      token: json['token'] as String,
    );

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'data': instance.data,
      'token': instance.token,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
      email: json['email'] as String,
      contact: (json['contact'] as num).toInt(),
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      dob: json['dob'] as String?,
      district: json['district'] as String?,
      city: json['city'] as String?,
      image_url: json['image_url'] as String?,
      reward_points: (json['reward_points'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'firstname': instance.firstname,
      'lastname': instance.lastname,
      'email': instance.email,
      'contact': instance.contact,
      'image_url': instance.image_url,
      'gender': instance.gender,
      'reward_points': instance.reward_points,
      'dob': instance.dob,
      'address': instance.address,
      'district': instance.district,
      'city': instance.city,
    };
