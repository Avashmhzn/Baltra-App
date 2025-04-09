import 'package:json_annotation/json_annotation.dart';

part 'loyaltyRedeem.g.dart';

@JsonSerializable()
class LoyaltyRedeem {
  final int reward_points;
  final String tier_status;

  LoyaltyRedeem({
    required this.reward_points,
    required this.tier_status,
  });

  factory LoyaltyRedeem.fromJson(Map<String, dynamic> json) =>
      _$LoyaltyRedeemFromJson(json);

  Map<String, dynamic> toJson() => _$LoyaltyRedeemToJson(this);
}

//  "reward_points": 400,
//         "tier_status": "Silver Tier"
