class CompletedComplaint {
  final int id;
  final int stock;
  final String modelName;
  final String modelNum;
  final String serialNumber;
  final String problemType;
  final String problemDescription;
  final String damagedImage;
  final String warrantyImage;
  final String damagedVideo;
  final String customerName;
  final String dateJoined;
  final String damagedImageUrl;
  final String warrantyImageUrl;
  final String damagedVideoUrl;
  final int customerContact;
  final String email;
  final String customerAddress;
  final String zone;
  final String area;
  final String customer;
  final String status;
  final String purchaseDate;
  final String jobNo;
  final String jobClosingDate;

  CompletedComplaint({
    required this.id,
    required this.stock,
    required this.modelName,
    required this.modelNum,
    required this.serialNumber,
    required this.problemType,
    required this.problemDescription,
    required this.damagedImage,
    required this.warrantyImage,
    required this.damagedVideo,
    required this.customerName,
    required this.dateJoined,
    required this.damagedImageUrl,
    required this.warrantyImageUrl,
    required this.damagedVideoUrl,
    required this.customerContact,
    required this.email,
    required this.customerAddress,
    required this.zone,
    required this.area,
    required this.customer,
    required this.status,
    required this.purchaseDate,
    required this.jobNo,
    required this.jobClosingDate,
  });

  factory CompletedComplaint.fromJson(Map<String, dynamic> json) {
    return CompletedComplaint(
      id: json['id'] ?? 0,
      stock: json['stock'] ?? 0,
      modelName: json['model_name'] ?? '',
      modelNum: json['model_num'] ?? '',
      serialNumber: json['serial_number'] ?? '',
      problemType: json['problem_type'] ?? '',
      problemDescription: json['problem_description'] ?? '',
      damagedImage: json['damaged_image'] ?? '',
      warrantyImage: json['warranty_image'] ?? '',
      damagedVideo: json['damaged_video'] ?? '',
      customerName: json['customer_name'] ?? '',
      dateJoined: json['date_joined'] ?? '',
      damagedImageUrl: json['damaged_image_url'] ?? '',
      warrantyImageUrl: json['warranty_image_url'] ?? '',
      damagedVideoUrl: json['damaged_video_url'] ?? '',
      customerContact: json['customerContact'] ?? 0,
      email: json['email'] ?? '',
      customerAddress: json['customerAddress'] ?? '',
      zone: json['zone'] ?? '',
      area: json['area'] ?? '',
      customer: json['customer'] ?? '',
      status: json['status'] ?? '',
      purchaseDate: json['purchase_date'] ?? '',
      jobNo: json['job_no'] ?? '',
      jobClosingDate: json['job_closing_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stock': stock,
      'model_name': modelName,
      'model_num': modelNum,
      'serial_number': serialNumber,
      'problem_type': problemType,
      'problem_description': problemDescription,
      'damaged_image': damagedImage,
      'warranty_image': warrantyImage,
      'damaged_video': damagedVideo,
      'customer_name': customerName,
      'date_joined': dateJoined,
      'damaged_image_url': damagedImageUrl,
      'warranty_image_url': warrantyImageUrl,
      'damaged_video_url': damagedVideoUrl,
      'customerContact': customerContact,
      'email': email,
      'customerAddress': customerAddress,
      'zone': zone,
      'area': area,
      'customer': customer,
      'status': status,
      'purchase_date': purchaseDate,
      'job_no': jobNo,
      'job_closing_date': jobClosingDate,
    };
  }
}
