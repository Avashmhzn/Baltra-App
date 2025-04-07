import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  int? id;
  String? name;
  String? sub_heading;
  int? price;
  String? power;
  int? warranty;
  int? reward_points;
  String? model_name;
  String? model_num;
  String? serial_number;
  String? packaging;
  String? sizing;
  String? specification;
  List<String>? color_styles;
  String? usage;
  List<ImageModel>? images;
  List<String>? sizes;
  String? product_video;
  String? main_image;
  List<ImageModel>? specification_images;
  String? warranty_icon;
  List<ImageModel>? usage_images;
  List<ImageModel>? sizing_images;
  String? galleryimagetwo;
  String? galleryimageone;
  Map<String, dynamic>? category;
  Map<String, dynamic>? sub_category;


  Product({
    this.id,
    this.name,
    this.sub_heading,
    this.price,
    this.power,
    this.warranty,
    this.reward_points,
    this.model_name,
    this.model_num,
    this.serial_number,
    this.packaging,
    this.specification,
    this.sizing,
    this.usage,
    this.color_styles,
    this.sizes,
    this.images,
    this.main_image,
    this.product_video,
    this.warranty_icon,
    this.specification_images,
    this.sizing_images,
    this.usage_images,
    this.galleryimagetwo,
    this.galleryimageone,
    this.category,
    this.sub_category,

  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

@JsonSerializable()
class ImageModel {
  String? image_url;

  ImageModel({this.image_url});

  factory ImageModel.fromJson(Map<String, dynamic> json) =>
      _$ImageModelFromJson(json);
}

/*

"id": 1,
        "name": "Blender: Crush 3",
        "sub_heading": "Effortless Blending for Every Kitchen",
        "price": 3000,
        "power": "50KW",
        "warranty": "12 Months Warranty",
        "reward_points": 200,
        "model_name": "Blender",
        "model_num": "BMG 174",
        "serial_number": "BMG174",
        "packaging": "Box Packaging",
        "date_joined": "2024-08-02",
        "specification": "The Blender: Crush 3 is a high-performance kitchen appliance designed for both amateur and professional cooks. This versatile blender effortlessly handles a wide range of blending tasks, from crushing ice and blending smoothies to creating soups and sauces. With its powerful motor and durable construction, the Crush 3 ensures consistent, high-quality results every time.Product SpecificationsMotor Power: 1500 wattsBlending Speeds: 10 variable speeds plus pulse functionBlade Material: Stainless steel, 6-blade systemJar Capacity: 64 ounces (1.9 liters)Jar Material: BPA-free Tritan plasticControl Panel: Digital touchpad with LED displayPre-programmed Settings: Smoothie, Ice Crush, Soup, and Nut ButterNoise Reduction: Built-in noise dampening technologySafety Features: Overheat protection, non-slip base, secure locking lidAccessories: Tamper tool, recipe book, cleaning brushDimensions: 8.5 x 9 x 18 inches (21.6 x 22.9 x 45.7 cm)Weight: 10 pounds (4.5 kg)Warranty: 3-year limited warranty",
        "sizing": "Height: 18 inches (45.7 cm)&nbsp; &nbsp; &nbsp; &nbsp;Provides ample space for blending large quantities while still fitting under most kitchen cabinets.Width: 8.5 inches (21.6 cm)&nbsp; &nbsp; &nbsp; &nbsp;Compact enough to save counter space, making it ideal for both small and large kitchens.Depth: 9 inches (22.9 cm)&nbsp; &nbsp; &nbsp; &nbsp;Balanced depth ensures stability during operation and easy placement alongside other appliances.Weight: 10 pounds (4.5 kg)&nbsp; &nbsp; &nbsp; &nbsp; Lightweight enough for easy maneuverability and storage, yet heavy enough to stay stable during intense blending tasks.&nbsp;",
        "usage": "Unpacking and SetupBegin by unboxing your Blender: Crush 3 and its components. Clean the blending jar, lid, and tamper tool with warm, &nbsp;soapy water. Wipe the motor base with a damp cloth.AssemblyPlace the motor base on a flat surface near an electrical outlet. Secure the blending jar onto the base until it clicks. Fit the lid onto the jar, and insert the tamper tool through the lid’s center hole if needed.",
        "stocks": 5,
        "category": {
            "category_id": 1,
            "category_name": "Kitchen Essentials"
        },
        "sub_category": {
            "sub_category_id": 10,
            "sub_category_name": "Mixer Grinder"
        },
        "color_styles": [
            "#d32f2f",
            "#000000"
        ],
        "sizes": [
            "M",
            "L",
            "XS"
        ],
        "images": [
            {
                "image_url": "http://192.168.1.215:8000/media/product_images/Frame_1000001765_l8bfAjg.png"
            },
            {
                "image_url": "http://192.168.1.215:8000/media/product_images/Frame_1000001766_NRaUVrc.png"
            },
            {
                "image_url": "http://192.168.1.215:8000/media/product_images/Frame_1000001767_cW8jUmo.png"
            },
            {
                "image_url": "http://192.168.1.215:8000/media/product_images/Frame_1000001768_xJVEd0l.png"
            },
            {
                "image_url": "http://192.168.1.215:8000/media/product_images/WhatsApp_Image_2024-05-27_at_12.54_6_Qs1Gvgq.png"
            }
        ],
        "main_image": "http://192.168.1.215:8000/media/product_images/WhatsApp_Image_2024-05-27_at_12.54_6_Qs1Gvgq.png",
        "product_video": "http://192.168.1.215:8000/media/product_videos/Untitled_video_-_Made_with_Clipchamp_1_eJZem9t.mp4",
        "warranty_icon": "http://192.168.1.215:8000/media/warranty_icons/12m_1_yyKxT1k.png",
        "specification_images": [
            {
                "image_url": "http://192.168.1.215:8000/media/specification_images/WhatsApp_Image_2024-05-27_at_12.54_1_5zdxAZC.png"
            },
            {
                "image_url": "http://192.168.1.215:8000/media/specification_images/WhatsApp_Image_2024-05-27_at_12.54_2_gHrcCsZ.png"
            },
            {
                "image_url": "http://192.168.1.215:8000/media/specification_images/WhatsApp_Image_2024-05-27_at_12.54_4_GyM6GiH.png"
            }
        ],
        "sizing_images": [
            {
                "image_url": "http://192.168.1.215:8000/media/sizing_images/Group_1077237207_VVWAZjg.png"
            },
            {
                "image_url": "http://192.168.1.215:8000/media/sizing_images/WhatsApp_Image_2024-05-27_at_11.36_1_yd3TOtg.png"
            }
        ],
        "usage_images": [
            {
                "image_url": "http://192.168.1.215:8000/media/usage_images/WhatsApp_Image_2024-05-27_at_12.54_4_0enyp3t.png"
            }
        ],
        "galleryimageone": "http://192.168.1.215:8000/media/gallery_images/image_1265_Md6XehU.png",
        "galleryimagetwo": "http://192.168.1.215:8000/media/gallery_images/image_1265_ORJwR2q.png"
    },

*/