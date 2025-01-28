import 'dart:convert';
import 'dart:io';
import 'package:baltra/core/utils/constants.dart';
import 'package:baltra/features/applicationCare/presentation/ui/application_care_page.dart';
import 'package:baltra/features/authetication/presentation/pages/buttomNavbar.dart';
import 'package:baltra/features/authetication/presentation/widgets/textform.dart';
import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

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

  // load customer detail from SharedPreferences
  Future<void> _loadCustomerDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      String firstName = prefs.getString('firstname') ?? '';
      String lastName = prefs.getString('lastname') ?? '';
      customerName = "$firstName $lastName".trim().isEmpty ? 'Unknown' : "$firstName $lastName";
      customerContact = prefs.getString('contact') ?? 'Not Available';
      email = prefs.getString('email') ?? 'Not Available';
    });
    print('Customer Name: $customerName');
    print('Customer Contact: $customerContact');
    print('Email: $email');
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

  Future<void> _pickVideo() async {
    final pickedFile =
    await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _problemVideo = File(pickedFile.path);
      });
    }
  }


  Future<void> submitForm() async {
    try {
      await _loadCustomerDetails();
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

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
            'damaged_video', _problemVideo!.path));
      }

      request.fields['model_name'] = widget.modelName;
      request.fields['model_number'] = widget.modelNo;
      request.fields['serial_number'] = widget.serialNo;
      request.fields['problem_type'] = _problemTypeController.text;
      request.fields['problem_description'] =
          _problemDescriptionController.text;

      // customer details
      request.fields['customerName'] = customerName ?? 'Unknown';
      request.fields['customerContact'] = customerContact ?? 'Not Available';
      request.fields['email'] = email ?? 'Not Available';

      if (selectedZone != null) {
        request.fields['zone'] = selectedZone!;
      }
      if (selectedArea != null) {
        request.fields['area'] = selectedArea!;
      }

      request.headers['Authorization'] = 'Bearer $token';

      var response = await request.send();

      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ButtomNavBar(pageno: 2,),
          ),
        );
      } else {
        throw Exception('Failed to submit data : ${response.statusCode}');
      }
    } catch (error) {
      // Handle general errors
      print('Error: $error');
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
                          child: Text('Select Zone',style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),),
                        ),
                        ...zones.map((zone) => DropdownMenuItem<String>(
                          value: zone['zoneName'],
                          child: Text(zone['zoneName'],style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),),
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
                          child: Text('Select Area', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),),
                        ),
                        ...availableAreas.map((area) => DropdownMenuItem<String>(
                          value: area['areaName'],
                          child: Text(area['areaName'],style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),),
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
                      onTap: _pickVideo,
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
                      onTap: widget.status == 'Pending'
                          ? showSnackBar
                          : submitForm,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        color: Theme.of(context).primaryColor,
                        child: const Text(
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
