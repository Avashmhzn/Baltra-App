import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:baltra/core/utils/constants.dart';
import 'package:baltra/features/authetication/models/user.dart';
import 'package:baltra/features/authetication/presentation/widgets/profileText.dart';
import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'buttomNavbar.dart';

class EditProfile extends StatefulWidget {
  final User data;

  const EditProfile({required this.data, Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _AddressController = TextEditingController();
  TextEditingController _districtController = TextEditingController();
  TextEditingController _cityController = TextEditingController();

  String? _phone;
  String? _profileImagePath;
  String? _gender;
  DateTime? _dob;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _saveInitialProfileData();
    _loadProfileImage();
    _fetchProfileData();
  }

  void _initializeData() {
    _phone = widget.data.contact.toString();
    _fullNameController.text = "${widget.data.firstname} ${widget.data.lastname}";
    _emailController.text = widget.data.email;

    // Normalize the gender value to match the DropdownMenuItem values (capitalize first letter)
    if (widget.data.gender != null && widget.data.gender!.isNotEmpty) {
      _gender = widget.data.gender!.toLowerCase() == 'male' ? 'Male' : 'Female';
    } else {
      _gender = null; // Set to null if gender is empty or null
    }
    log('Initialized gender: $_gender'); // Debug log to verify the value

    if (widget.data.dob != null && widget.data.dob!.isNotEmpty) {
      final parsedDate = DateTime.tryParse(widget.data.dob!);
      if (parsedDate != null) {
        _dobController.text = '${parsedDate.month}/${parsedDate.day}/${parsedDate.year}';
        _dob = parsedDate;
      }
    }

    _AddressController.text = widget.data.address ?? '';
    _districtController.text = widget.data.district ?? '';
    _cityController.text = widget.data.city ?? '';
  }

  Future<void> _saveInitialProfileData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', widget.data.firstname);
    await prefs.setString('lastName', widget.data.lastname);
    await prefs.setString('email', widget.data.email);
    await prefs.setString('contact', widget.data.contact.toString());
    await prefs.setString('gender', widget.data.gender ?? '');
    await prefs.setString('dob', widget.data.dob ?? '');
    await prefs.setString('customerAddress', widget.data.address ?? '');
    await prefs.setString('district', widget.data.district ?? '');
    await prefs.setString('city', widget.data.city ?? '');
    log('Initial profile data saved to SharedPreferences');
  }

  Future<void> _fetchProfileData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');
      if (token == null) {
        log('Error: Missing authentication token');
        return;
      }

      final response = await http.put(
        Uri.parse('$URL/customer/updateprofile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      log('Fetch Profile Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final data = responseData['data'];

          setState(() {
            widget.data.firstname = data['firstname'];
            widget.data.lastname = data['lastname'];
            widget.data.email = data['email'];
            // Normalize the fetched gender value
            widget.data.gender = data['gender'] != null && data['gender'].isNotEmpty
                ? (data['gender'].toLowerCase() == 'male' ? 'Male' : 'Female')
                : null;
            widget.data.dob = data['dob'];
            widget.data.address = data['customerAddress'];
            widget.data.district = data['district'];
            widget.data.city = data['city'];

            _fullNameController.text = "${widget.data.firstname} ${widget.data.lastname}";
            _emailController.text = widget.data.email;
            _dobController.text = widget.data.dob ?? '';
            _AddressController.text = widget.data.address ?? '';
            _districtController.text = widget.data.district ?? '';
            _cityController.text = widget.data.city ?? '';
            _gender = widget.data.gender; // Update _gender with normalized value
          });
        } else {
          log('Failed to fetch profile: ${responseData['message']}');
        }
      } else {
        log('Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching profile: $e');
    }
  }

  Future<void> _loadProfileImage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profile_image_path') ?? widget.data.image_url;
    });
    log('Loaded profile image path: $_profileImagePath');
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = pickedFile.name;
        final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');

        setState(() {
          _profileImagePath = savedImage.path;
        });

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path', savedImage.path);

        await _uploadImage(savedImage);
      }
    } catch (e) {
      log('Error picking image: $e');
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      log('Token: $token');
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: Missing authentication token',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$URL/customer/updateprofile'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final responseJson = json.decode(responseData);

        log('Response Data: $responseData');
        log('Image URL from server: ${responseJson['image_url']}');

        final imageUrl = responseJson['data'] != null ? responseJson['data']['image_url'] : null;

        log('Image URL from server: $imageUrl');

        if (imageUrl != null && imageUrl is String && Uri.tryParse(imageUrl)?.isAbsolute == true) {
          await prefs.setString('image_url', imageUrl);
          setState(() {
            widget.data.image_url = imageUrl;
          });
        } else {
          log('Error: Image URL is null or invalid');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to upload image: Invalid image URL',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to upload image: ${response.statusCode}',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      log('Error uploading image: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Error: Missing authentication token',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      final nameParts = _fullNameController.text.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      log('First Name: $firstName, Last Name: $lastName');

      final updatedData = {
        'firstname': firstName,
        'lastname': lastName,
        'email': _emailController.text,
        'contact': widget.data.contact.toString(),
        'gender': _gender,
        'dob': _dob != null ? _dob!.toIso8601String().split('T')[0] : '',
        'customerAddress': _AddressController.text,
        'district': _districtController.text,
        'city': _cityController.text,
      };

      log('Sending request to update profile with data: $updatedData');

      final encodedData = updatedData.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value ?? '')}')
          .join('&');

      final response = await http.put(
        Uri.parse('$URL/customer/updateprofile'),
        body: encodedData,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      log('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final updatedUserData = responseData['data'];

          setState(() {
            widget.data.firstname = updatedUserData['firstname'];
            widget.data.lastname = updatedUserData['lastname'];
            widget.data.email = updatedUserData['email'];
            widget.data.gender = updatedUserData['gender'];
            widget.data.dob = updatedUserData['dob'];
            widget.data.address = updatedUserData['customerAddress'];
            widget.data.district = updatedUserData['district'];
            widget.data.city = updatedUserData['city'];

            _fullNameController.text = "${widget.data.firstname} ${widget.data.lastname}";
            _emailController.text = widget.data.email;
            _dobController.text = widget.data.dob ?? '';
            _AddressController.text = widget.data.address ?? '';
            _districtController.text = widget.data.district ?? '';
            _cityController.text = widget.data.city ?? '';
          });

          await prefs.setString('firstName', widget.data.firstname);
          await prefs.setString('lastName', widget.data.lastname);
          await prefs.setString('email', widget.data.email);
          await prefs.setString('contact', widget.data.contact.toString());
          await prefs.setString('gender', widget.data.gender ?? '');
          await prefs.setString('dob', widget.data.dob ?? '');
          await prefs.setString('customerAddress', widget.data.address ?? '');
          await prefs.setString('district', widget.data.district ?? '');
          await prefs.setString('city', widget.data.city ?? '');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Profile updated successfully!',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 2),
            ),
          );

          // Replace Navigator.pushReplacement with Navigator.pushAndRemoveUntil
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => ButtomNavBar(
                pageno: 3,
              ),
            ),
                (Route<dynamic> route) => false, // This removes all previous routes
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to update profile: ${responseData['message']}',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update profile: ${response.body}',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      log('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    log('Current User Data: ${widget.data.firstname} ${widget.data.lastname}');
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AppBarWithSVG(
                  subtitle: 'Edit your profile',
                  title: 'My Profile',
                  backbutton: true),
              const SizedBox(
                height: 18,
              ),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  foregroundImage: _profileImagePath != null
                      ? (_profileImagePath!.startsWith('http')
                      ? NetworkImage(_profileImagePath!)
                      : FileImage(File(_profileImagePath!)) as ImageProvider)
                      : const NetworkImage(
                    'https://t4.ftcdn.net/jpg/02/15/84/43/360_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg',
                  ),
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      ProfileTextField(
                        title: "Full Name",
                        controller: _fullNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          final nameParts = value?.split(' ');
                          if (nameParts != null && nameParts.isNotEmpty) {
                            widget.data.firstname = nameParts.first;
                            widget.data.lastname = nameParts.length > 1
                                ? nameParts.sublist(1).join(' ')
                                : '';
                          }
                        },
                      ),
                      ProfileTextField(
                        title: "Email",
                        controller: _emailController,
                        readonly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          widget.data.email = value ?? '';
                        },
                      ),
                      ProfileTextField(
                        initialValue: _phone.toString(),
                        title: 'Phone',
                        readonly: true,
                      ),
                      ProfileTextField(
                        title: 'Address',
                        controller: _AddressController,
                        onSaved: (value) {
                          widget.data.address = value ?? 'N/A';
                        },
                      ),
                      ProfileTextField(
                        title: 'City',
                        controller: _cityController,
                        onSaved: (value) {
                          widget.data.city = value ?? 'N/A';
                        },
                      ),
                      ProfileTextField(
                        title: 'District',
                        controller: _districtController,
                        onSaved: (value) {
                          widget.data.district = value ?? 'N/A';
                        },
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gender',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Container(
                            height: 45,
                            margin: const EdgeInsets.only(bottom: 15, top: 10),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20, left: 10),
                              child: DropdownButtonFormField<String>(
                                value: _gender, // _gender is now either null, "Male", or "Female"
                                dropdownColor: Colors.white,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Male',
                                    child: Text(
                                      'Male',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Female',
                                    child: Text(
                                      'Female',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _gender = value;
                                    widget.data.gender = value; // Update the User model
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                                validator: (value) => value == null ? 'Please select an option' : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date of Birth',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.normal,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Container(
                            height: 45,
                            margin: const EdgeInsets.only(bottom: 15, top: 10),
                            child: TextFormField(
                              controller: _dobController,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: 'Date of Birth',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 12.0,
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: () async {
                                    FocusScope.of(context).requestFocus(FocusNode());
                                    final DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: _dob ?? DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                    );
                                    if (pickedDate != null) {
                                      setState(() {
                                        _dob = pickedDate;
                                        _dobController.text =
                                        '${pickedDate.month}/${pickedDate.day}/${pickedDate.year}';
                                        widget.data.dob = pickedDate.toIso8601String().split('T')[0];
                                      });
                                    }
                                  },
                                  child: Icon(Icons.edit_calendar, color: Colors.grey),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your date of birth';
                                }
                                return null;
                              },
                              onTap: () async {
                                FocusScope.of(context).requestFocus(FocusNode());
                                final DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: _dob ?? DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (pickedDate != null) {
                                  setState(() {
                                    _dobController.text =
                                    '${pickedDate.month}/${pickedDate.day}/${pickedDate.year}';
                                    widget.data.dob = pickedDate.toLocal().toString().split(' ')[0];
                                  });
                                }
                              },
                              onSaved: (value) {
                                widget.data.dob = value ?? '';
                              },
                            ),
                          ),
                          SizedBox(height: 15),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: _saveProfile,
                          child: Container(
                            height: 35,
                            width: 95,
                            color: const Color(0xff202D31),
                            padding: const EdgeInsets.all(8),
                            child: const Text(
                              'Save Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 64,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}