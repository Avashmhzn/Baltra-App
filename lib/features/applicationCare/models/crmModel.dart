import 'dart:convert';

CustomerProductResponse customerProductResponseFromJson(String str) => 
    CustomerProductResponse.fromJson(json.decode(str));

String customerProductResponseToJson(CustomerProductResponse data) => 
    json.encode(data.toJson());

class CustomerProductResponse {
  final CustomerProduct? data;
  final bool success;
  final String message;

  CustomerProductResponse({
    required this.data,
    required this.success,
    required this.message,
  });

  factory CustomerProductResponse.fromJson(Map<String, dynamic> json) =>
      CustomerProductResponse(
        data: json["data"] != null ? CustomerProduct.fromJson(json["data"]) : null,
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "success": success,
        "message": message,
      };
}

class CustomerProduct {
  final int id;
  final String serialNumber;
  final String warrantyIssue;
  final String warrantyExpiry;
  final String warrantyImage;
  final String storeName;
  final String storeLocation;
  final String storeNumber;
  final String modelNum;
  final String modelName;
  final String billImageOne;
  final String warrantyCard;
  final String productImage;
  final String status;
  final bool isVerified;
  final String createdAt;
  final String purchaseDate;
  final int tempReward;
  final String customer;
  final int product;
  final String extendedWarranty;
  final int complaintId;
  final String problemType;
  final String problemDescription;
  final String jobNo;
  final String dateJoined;
  final String damagedImage;
  final String damagedVideo;
  final List<Map<String, dynamic>> stepper;

  CustomerProduct({
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
    required this.billImageOne,
    required this.warrantyCard,
    required this.productImage,
    required this.status,
    required this.isVerified,
    required this.createdAt,
    required this.purchaseDate,
    required this.tempReward,
    required this.customer,
    required this.product,
    required this.extendedWarranty,
    required this.complaintId,
    required this.problemType,
    required this.problemDescription,
    required this.jobNo,
    required this.dateJoined,
    required this.damagedImage,
    required this.damagedVideo,
    required this.stepper,
  });

  factory CustomerProduct.fromJson(Map<String, dynamic> json) => CustomerProduct(
    id: json["id"] ?? 0,
    serialNumber: json["serial_number"] ?? "",
    warrantyIssue: json["warranty_issue"] ?? "",
    warrantyExpiry: json["warranty_expiry"] ?? "",
    warrantyImage: json["warranty_image"] ?? "",
    storeName: json["store_name"] ?? "",
    storeLocation: json["store_location"] ?? "",
    storeNumber: json["store_number"] ?? "",
    modelNum: json["model_num"] ?? "",
    modelName: json["model_name"] ?? "",
    billImageOne: json["bill_image_one"] ?? "",
    warrantyCard: json["warranty_card"] ?? "",
    productImage: json["product_image"] ?? "",
    status: json["status"] ?? "",
    isVerified: json["is_verified"] ?? false,
    createdAt: json["created_at"] ?? "",
    purchaseDate: json["purchase_date"] ?? "",
    tempReward: json["temp_reward"] ?? 0,
    customer: json["customer"] ?? "",
    product: json["product"] ?? 0,
    extendedWarranty: json["extended_warranty"] ?? "",
    complaintId: json["complaint_id"] ?? 0,
    problemType: json["problem_type"] ?? "",
    problemDescription: json["problem_description"] ?? "Not Available",
    jobNo: json["job_no"] ?? "Not Available",
    dateJoined: json["date_joined"] ?? "",
    damagedImage: json["damaged_image"] ?? "",
    damagedVideo: json["damaged_video"] ?? "",
    stepper: List<Map<String, dynamic>>.from(json["stepper"] ?? []),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "serial_number": serialNumber,
    "warranty_issue": warrantyIssue,
    "warranty_expiry": warrantyExpiry,
    "warranty_image": warrantyImage,
    "store_name": storeName,
    "store_location": storeLocation,
    "store_number": storeNumber,
    "model_num": modelNum,
    "model_name": modelName,
    "bill_image_one": billImageOne,
    "warranty_card": warrantyCard,
    "product_image": productImage,
    "status": status,
    "is_verified": isVerified,
    "created_at": createdAt,
    "purchase_date": purchaseDate,
    "temp_reward": tempReward,
    "customer": customer,
    "product": product,
    "extended_warranty": extendedWarranty,
    "complaint_id": complaintId,
    "problem_type": problemType,
    "problem_description": problemDescription,
    "job_no": jobNo,
    "date_joined": dateJoined,
    "damaged_image": damagedImage,
    "damaged_video": damagedVideo,
    "tracking_steps": stepper,
  };
}
