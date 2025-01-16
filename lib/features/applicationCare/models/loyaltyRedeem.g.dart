// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loyaltyRedeem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoyaltyRedeem _$LoyaltyRedeemFromJson(Map<String, dynamic> json) =>
    LoyaltyRedeem(
      reward_points: (json['reward_points'] as num).toInt(),
      tier_status: json['tier_status'] as String,
    );

Map<String, dynamic> _$LoyaltyRedeemToJson(LoyaltyRedeem instance) =>
    <String, dynamic>{
      'reward_points': instance.reward_points,
      'tier_status': instance.tier_status,
    };
