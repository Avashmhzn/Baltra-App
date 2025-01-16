import 'dart:io';
import 'package:baltra/core/utils/constants.dart';
import 'package:baltra/features/applicationCare/presentation/ui/application_care_page.dart';
import 'package:baltra/features/authetication/presentation/widgets/textform.dart';
import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class ComplaintRegistrationPage extends StatefulWidget {
  const ComplaintRegistrationPage({
    super.key,
    required this.productId,
    required this.serialNo,
    required this.status,
  });

  final int productId;
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
  VideoPlayerController? _videoController;
  final TextEditingController _problemTypeController = TextEditingController();
  final TextEditingController _problemDescriptionController =
      TextEditingController();

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

      request.fields['serial_number'] = widget.serialNo;
      request.fields['problem_type'] = _problemTypeController.text;
      request.fields['problem_description'] =
          _problemDescriptionController.text;

      request.headers['Authorization'] = 'Bearer $token';

      var response = await request.send();

      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ApplicationCarePage()),
        );
      } else {
        throw Exception('Failed to submit data');
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
                      'Product Image',
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
                                  'Add Product Image',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Warranty Card',
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
                                  'Warranty Card Image',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
