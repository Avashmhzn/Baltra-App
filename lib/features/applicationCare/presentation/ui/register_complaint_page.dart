/*
import 'dart:convert';
import 'dart:io';
import 'package:baltra/core/utils/constants.dart';
import 'package:baltra/features/authetication/controller/profileController.dart';
import 'package:baltra/features/authetication/models/user.dart';
import 'package:baltra/features/authetication/presentation/pages/buttomNavbar.dart';
import 'package:baltra/features/authetication/presentation/widgets/textform.dart';
import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class ComplaintRegistrationPage extends StatefulWidget {
  ComplaintRegistrationPage({
    super.key,
    required this.productId,
    required this.modelName,
    required this.modelNo,
    required this.serialNo,
    required this.status,
  });

  final int productId;
  final String modelName;
  final String modelNo;
  final String serialNo;
  final String status;

  @override
  State<ComplaintRegistrationPage> createState() =>
      _ComplaintRegistrationPageState();
}

class _ComplaintRegistrationPageState extends State<ComplaintRegistrationPage> {
  File? _productImage;
  File? _warrantyImage;
  File? _problemVideo;
  final TextEditingController _problemTypeController = TextEditingController();
  final TextEditingController _problemDescriptionController =
  TextEditingController();

  List<Map<String, dynamic>> zones = [];
  String? selectedZone = null;
  String? selectedArea;

  String? customerName;
  String? customerContact;
  String? email;

  bool _isLoading = false; // Add loading state

  // Method to load zones from the assets
  Future<void> loadZones() async {
    final String response = await rootBundle.loadString('assets/zones.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      zones = data.cast<Map<String, dynamic>>();
      if (zones.isNotEmpty && selectedZone == null) {
        selectedZone = null;
        selectedArea = null;
      }
    });
  }

  List<Map<String, dynamic>> get availableAreas {
    if (selectedZone == null) return [];
    return zones
        .firstWhere((zone) => zone['zoneName'] == selectedZone)['zoneArea']
        .cast<Map<String, dynamic>>();
  }

  // Load customer details from ProfileController
  Future<void> _loadCustomerDetails() async {
    try {
      // Initialize or find ProfileController
      final ProfileController profileController = Get.put(ProfileController());

      // Fetch user data if not already loaded
      if (profileController.userData.value == null) {
        await profileController.fetchUserData();
      }

      // Access user data
      final User? user = profileController.userData.value;
      if (user != null) {
        setState(() {
          customerName = '${user.firstname} ${user.lastname}';
          customerContact = user.contact.toString();
          email = user.email;
        });
      } else {
        // Fallback to SharedPreferences if user data is unavailable
        final prefs = await SharedPreferences.getInstance();
        setState(() {
          customerName = prefs.getString('name') ?? 'Unknown';
          final contact = prefs.get('contact');
          customerContact = contact != null
              ? (contact is int ? contact.toString() : contact.toString())
              : 'Not Available';
          email = prefs.getString('email') ?? 'Not Available';
        });
      }

      print('Customer Name: $customerName');
      print('Customer Contact: $customerContact');
      print('Email: $email');
    } catch (e) {
      print('Error loading customer details: $e');
      // Fallback to SharedPreferences in case of error
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        customerName = prefs.getString('name') ?? 'Unknown';
        final contact = prefs.get('contact');
        customerContact = contact != null
            ? (contact is int ? contact.toString() : contact.toString())
            : 'Not Available';
        email = prefs.getString('email') ?? 'Not Available';
      });
      print('Customer Name (Fallback): $customerName');
      print('Customer Contact (Fallback): $customerContact');
      print('Email (Fallback): $email');
    }
  }

  Future<void> _pickImage(ImageSource source, bool isProductImage) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isProductImage) {
          _productImage = File(pickedFile.path);
        } else {
          _warrantyImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _pickVideo(ImageSource source, bool isProblemVideo) async {
    final pickedFile = await ImagePicker().pickVideo(source: source);
    if (pickedFile != null) {
      setState(() {
        _problemVideo = File(pickedFile.path);
      });
    }
  }

  Future<void> submitForm() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      await _loadCustomerDetails(); // Ensure latest customer details
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (customerName == 'Unknown' ||
          customerContact == 'Not Available' ||
          email == 'Not Available') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer details are incomplete.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {
          _isLoading = false; // Stop loading
        });
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$URL/stocks/registercomplaint/${widget.productId}'),
      );

      if (_productImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'damaged_image', _productImage!.path));
      }
      if (_warrantyImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'warranty_image', _warrantyImage!.path));
      }
      if (_problemVideo != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'damaged_Video', _problemVideo!.path));
      }

      request.fields['model_name'] = widget.modelName;
      request.fields['model_number'] = widget.modelNo;
      request.fields['serial_number'] = widget.serialNo;
      request.fields['problem_type'] = _problemTypeController.text;
      request.fields['problem_description'] =
          _problemDescriptionController.text;

      // Customer details - Use correct field names
      request.fields['customerName'] = customerName!;
      request.fields['customerContact'] = customerContact!; // Changed from 'contact' to 'customerContact'
      request.fields['email'] = email!;

      if (selectedZone != null) {
        request.fields['zone'] = selectedZone!;
      }
      if (selectedArea != null) {
        request.fields['area'] = selectedArea!;
      }

      request.headers['Authorization'] = 'Bearer $token';

      // Debug: Print request fields
      print('Request Fields: ${request.fields}');

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print('Response Body: $responseBody');

      if (response.statusCode == 201) {
        setState(() {
          _isLoading = false; // Stop loading
        });
        // Show custom success dialog
        showDialog(
          context: context,
          builder: (context) => CustomSuccessDialog(
            productName: widget.modelName,
            onConfirm: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => ButtomNavBar(pageno: 2)),
                    (Route<dynamic> route) => false, // Removes all previous routes
              );
            },
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit complaint: ${response.statusCode}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {
          _isLoading = false; // Stop loading
        });
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting complaint: $error'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  void showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Complain can be placed only for verified products')));
  }

  @override
  void initState() {
    super.initState();
    loadZones();
    _loadCustomerDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AppBarWithSVG(
                subtitle: 'Add a complaint about your Baltra Product',
                title: 'Register a Complaint',
                backbutton: true,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Damaged Image',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    GestureDetector(
                      onTap: () => _pickImage(ImageSource.gallery, true),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: _productImage != null
                            ? Image.file(_productImage!, fit: BoxFit.cover)
                            : const Center(
                          child: Text(
                            'Upload a picture of your damaged product',
                            style: TextStyle(
                                fontSize: 14, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Warranty Card Image',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    GestureDetector(
                      onTap: () => _pickImage(ImageSource.gallery, false),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: _warrantyImage != null
                            ? Image.file(_warrantyImage!, fit: BoxFit.cover)
                            : const Center(
                          child: Text(
                            'Upload a picture of your warranty card',
                            style: TextStyle(
                                fontSize: 14, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Select Zone Dropdown
                    const Text('Select Zone'),
                    DropdownButton<String>(
                      value: selectedZone,
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            'Select Zone',
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 14),
                          ),
                        ),
                        ...zones.map((zone) => DropdownMenuItem<String>(
                          value: zone['zoneName'],
                          child: Text(
                            zone['zoneName'],
                            style: const TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 14),
                          ),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedZone = value;
                          selectedArea = null;
                        });
                      },
                      hint: const Text('Choose a zone'),
                    ),
                    const SizedBox(height: 16),
                    // Select Area Dropdown
                    const Text('Select Area'),
                    DropdownButton<String>(
                      value: selectedArea,
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            'Select Area',
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 14),
                          ),
                        ),
                        ...availableAreas.map((area) => DropdownMenuItem<String>(
                          value: area['areaName'],
                          child: Text(
                            area['areaName'],
                            style: const TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 14),
                          ),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedArea = value;
                        });
                      },
                      hint: const Text('Choose an area'),
                    ),
                    const SizedBox(height: 16),
                    NormalTextField(
                      hint: 'Model Name.',
                      title: 'Model Name.',
                      type: TextInputType.name,
                      readonly: true,
                      initial: widget.modelName,
                    ),
                    NormalTextField(
                      hint: 'Model Name.',
                      title: 'Model Name.',
                      type: TextInputType.name,
                      readonly: true,
                      initial: widget.modelNo,
                    ),
                    NormalTextField(
                      hint: 'Product Serial No.',
                      title: 'Product Serial No.',
                      type: TextInputType.name,
                      readonly: true,
                      initial: widget.serialNo,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0, top: 5),
                      child: Text('Problem'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _problemTypeController,
                        maxLines: 1,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0, top: 5),
                      child: Text('Problem Description'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _problemDescriptionController,
                        maxLines: 8,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 100,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Problem Video',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    GestureDetector(
                      onTap: () => _pickVideo(ImageSource.gallery, false),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: _problemVideo != null
                            ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_file,
                                size: 50, color: Colors.blue),
                            SizedBox(height: 10),
                            Text(
                              'Video Selected',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black),
                            ),
                          ],
                        )
                            : const Center(
                          child: Text(
                            'Select the video',
                            style: TextStyle(
                                fontSize: 14, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (widget.status == 'Pending' || _isLoading)
                          ? null // Disable button when loading or status is Pending
                          : submitForm,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        color: _isLoading
                            ? Colors.grey // Grey out when loading
                            : Theme.of(context).primaryColor,
                        child: _isLoading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Success Dialog
class CustomSuccessDialog extends StatelessWidget {
  final String productName;
  final VoidCallback onConfirm;

  const CustomSuccessDialog({
    super.key,
    required this.productName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 50,
            ),
            const SizedBox(height: 15),
            const Text(
              'Complaint Registered',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Your complaint for "$productName" has been successfully registered.',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                onConfirm(); // Navigate to home or other action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
import 'dart:convert';
import 'dart:io';
import 'package:baltra/core/utils/constants.dart';
import 'package:baltra/features/authetication/controller/profileController.dart';
import 'package:baltra/features/authetication/models/user.dart';
import 'package:baltra/features/authetication/presentation/pages/buttomNavbar.dart';
import 'package:baltra/features/authetication/presentation/widgets/textform.dart';
import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class ComplaintRegistrationPage extends StatefulWidget {
  ComplaintRegistrationPage({
    super.key,
    required this.productId,
    required this.modelName,
    required this.modelNo,
    required this.serialNo,
    required this.status,
  });

  final int productId;
  final String modelName;
  final String modelNo;
  final String serialNo;
  final String status;

  @override
  State<ComplaintRegistrationPage> createState() =>
      _ComplaintRegistrationPageState();
}

class _ComplaintRegistrationPageState extends State<ComplaintRegistrationPage> {
  File? _productImage;
  File? _warrantyImage;
  File? _problemVideo;
  final TextEditingController _problemTypeController = TextEditingController();
  final TextEditingController _problemDescriptionController =
  TextEditingController();

  List<Map<String, dynamic>> zones = [];
  String? selectedZone = null;
  String? selectedArea;

  String? customerName;
  String? customerContact;
  String? email;

  bool _isLoading = false; // Add loading state

  // Method to load zones from the assets
  Future<void> loadZones() async {
    final String response = await rootBundle.loadString('assets/zones.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      zones = data.cast<Map<String, dynamic>>();
      if (zones.isNotEmpty && selectedZone == null) {
        selectedZone = null;
        selectedArea = null;
      }
    });
  }

  List<Map<String, dynamic>> get availableAreas {
    if (selectedZone == null) return [];
    return zones
        .firstWhere((zone) => zone['zoneName'] == selectedZone)['zoneArea']
        .cast<Map<String, dynamic>>();
  }

  // Load customer details from ProfileController
  Future<void> _loadCustomerDetails() async {
    try {
      // Initialize or find ProfileController
      final ProfileController profileController = Get.put(ProfileController());

      // Fetch user data if not already loaded
      if (profileController.userData.value == null) {
        await profileController.fetchUserData();
      }

      // Access user data
      final User? user = profileController.userData.value;
      if (user != null) {
        setState(() {
          customerName = '${user.firstname} ${user.lastname}';
          customerContact = user.contact.toString();
          email = user.email;
        });
      } else {
        // Fallback to SharedPreferences if user data is unavailable
        final prefs = await SharedPreferences.getInstance();
        setState(() {
          customerName = prefs.getString('name') ?? 'Unknown';
          final contact = prefs.get('contact');
          customerContact = contact != null
              ? (contact is int ? contact.toString() : contact.toString())
              : 'Not Available';
          email = prefs.getString('email') ?? 'Not Available';
        });
      }

      print('Customer Name: $customerName');
      print('Customer Contact: $customerContact');
      print('Email: $email');
    } catch (e) {
      print('Error loading customer details: $e');
      // Fallback to SharedPreferences in case of error
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        customerName = prefs.getString('name') ?? 'Unknown';
        final contact = prefs.get('contact');
        customerContact = contact != null
            ? (contact is int ? contact.toString() : contact.toString())
            : 'Not Available';
        email = prefs.getString('email') ?? 'Not Available';
      });
      print('Customer Name (Fallback): $customerName');
      print('Customer Contact (Fallback): $customerContact');
      print('Email (Fallback): $email');
    }
  }

  Future<void> _pickImage(ImageSource source, bool isProductImage) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isProductImage) {
          _productImage = File(pickedFile.path);
        } else {
          _warrantyImage = File(pickedFile.path);
        }
      });
    }
  }

  // Redesigned method with SessionManager dialog styling
  void _showImageSourceDialog(bool isProductImage)   {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              titlePadding: EdgeInsets.only(left: 16, top: 16, right: 8),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.image, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Select Image Source',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  // Close (X) button
                  AnimatedOpacity(
                    opacity: 1.0,
                    duration: Duration(milliseconds: 500),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Choose where to pick the image from:',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  // Gallery button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery, isProductImage);
                      },
                      child: Text('Gallery', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  SizedBox(height: 8),
                  // Camera button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera, isProductImage);
                      },
                      child: Text('Camera', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  Future<void> _pickVideo(ImageSource source, bool isProblemVideo) async {
    final pickedFile = await ImagePicker().pickVideo(source: source);
    if (pickedFile != null) {
      setState(() {
        _problemVideo = File(pickedFile.path);
      });
    }
  }

  Future<void> submitForm() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      await _loadCustomerDetails(); // Ensure latest customer details
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (customerName == 'Unknown' ||
          customerContact == 'Not Available' ||
          email == 'Not Available') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer details are incomplete.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {
          _isLoading = false; // Stop loading
        });
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$URL/stocks/registercomplaint/${widget.productId}'),
      );

      if (_productImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'damaged_image', _productImage!.path));
      }
      if (_warrantyImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'warranty_image', _warrantyImage!.path));
      }
      if (_problemVideo != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'damaged_Video', _problemVideo!.path));
      }

      request.fields['model_name'] = widget.modelName;
      request.fields['model_number'] = widget.modelNo;
      request.fields['serial_number'] = widget.serialNo;
      request.fields['problem_type'] = _problemTypeController.text;
      request.fields['problem_description'] =
          _problemDescriptionController.text;

      // Customer details - Use correct field names
      request.fields['customerName'] = customerName!;
      request.fields['customerContact'] = customerContact!; // Changed from 'contact' to 'customerContact'
      request.fields['email'] = email!;

      if (selectedZone != null) {
        request.fields['zone'] = selectedZone!;
      }
      if (selectedArea != null) {
        request.fields['area'] = selectedArea!;
      }

      request.headers['Authorization'] = 'Bearer $token';

      // Debug: Print request fields
      print('Request Fields: ${request.fields}');

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print('Response Body: $responseBody');

      if (response.statusCode == 201) {
        setState(() {
          _isLoading = false; // Stop loading
        });
        // Show custom success dialog
        showDialog(
          context: context,
          builder: (context) => CustomSuccessDialog(
            productName: widget.modelName,
            onConfirm: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => ButtomNavBar(pageno: 2)),
                    (Route<dynamic> route) => false, // Removes all previous routes
              );
            },
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit complaint: ${response.statusCode}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {
          _isLoading = false; // Stop loading
        });
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting complaint: $error'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  void showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Complain can be placed only for verified products')));
  }

  @override
  void initState() {
    super.initState();
    loadZones();
    _loadCustomerDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AppBarWithSVG(
                subtitle: 'Add a complaint about your Baltra Product',
                title: 'Register a Complaint',
                backbutton: true,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Damaged Image',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    GestureDetector(
                      onTap: () => _showImageSourceDialog(true), // Updated
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: _productImage != null
                            ? Image.file(_productImage!, fit: BoxFit.cover)
                            : const Center(
                          child: Text(
                            'Upload a picture of your damaged product',
                            style: TextStyle(
                                fontSize: 14, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Warranty Card Image',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    GestureDetector(
                      onTap: () => _showImageSourceDialog(false), // Updated
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: _warrantyImage != null
                            ? Image.file(_warrantyImage!, fit: BoxFit.cover)
                            : const Center(
                          child: Text(
                            'Upload a picture of your warranty card',
                            style: TextStyle(
                                fontSize: 14, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Select Zone Dropdown
                    const Text('Select Zone'),
                    DropdownButton<String>(
                      value: selectedZone,
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            'Select Zone',
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 14),
                          ),
                        ),
                        ...zones.map((zone) => DropdownMenuItem<String>(
                          value: zone['zoneName'],
                          child: Text(
                            zone['zoneName'],
                            style: const TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 14),
                          ),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedZone = value;
                          selectedArea = null;
                        });
                      },
                      hint: const Text('Choose a zone'),
                    ),
                    const SizedBox(height: 16),
                    // Select Area Dropdown
                    const Text('Select Area'),
                    DropdownButton<String>(
                      value: selectedArea,
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            'Select Area',
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 14),
                          ),
                        ),
                        ...availableAreas.map((area) => DropdownMenuItem<String>(
                          value: area['areaName'],
                          child: Text(
                            area['areaName'],
                            style: const TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 14),
                          ),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedArea = value;
                        });
                      },
                      hint: const Text('Choose an area'),
                    ),
                    const SizedBox(height: 16),
                    NormalTextField(
                      hint: 'Model Name.',
                      title: 'Model Name.',
                      type: TextInputType.name,
                      readonly: true,
                      initial: widget.modelName,
                    ),
                    NormalTextField(
                      hint: 'Model Name.',
                      title: 'Model Name.',
                      type: TextInputType.name,
                      readonly: true,
                      initial: widget.modelNo,
                    ),
                    NormalTextField(
                      hint: 'Product Serial No.',
                      title: 'Product Serial No.',
                      type: TextInputType.name,
                      readonly: true,
                      initial: widget.serialNo,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0, top: 5),
                      child: Text('Problem'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _problemTypeController,
                        maxLines: 1,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0, top: 5),
                      child: Text('Problem Description'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _problemDescriptionController,
                        maxLines: 8,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 100,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Problem Video',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    GestureDetector(
                      onTap: () => _pickVideo(ImageSource.gallery, false),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: _problemVideo != null
                            ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_file,
                                size: 50, color: Colors.blue),
                            SizedBox(height: 10),
                            Text(
                              'Video Selected',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black),
                            ),
                          ],
                        )
                            : const Center(
                          child: Text(
                            'Select the video',
                            style: TextStyle(
                                fontSize: 14, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (widget.status == 'Pending' || _isLoading)
                          ? null // Disable button when loading or status is Pending
                          : submitForm,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        color: _isLoading
                            ? Colors.grey // Grey out when loading
                            : Theme.of(context).primaryColor,
                        child: _isLoading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Success Dialog
class CustomSuccessDialog extends StatelessWidget {
  final String productName;
  final VoidCallback onConfirm;

  const CustomSuccessDialog({
    super.key,
    required this.productName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 50,
            ),
            const SizedBox(height: 15),
            const Text(
              'Complaint Registered',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Your complaint for "$productName" has been successfully registered.',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                onConfirm(); // Navigate to home or other action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}