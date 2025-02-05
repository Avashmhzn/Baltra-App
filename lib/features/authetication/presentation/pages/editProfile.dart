import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:baltra/core/utils/constants.dart';
import 'package:baltra/features/authetication/models/user.dart';
import 'package:baltra/features/authetication/presentation/pages/changepassword.dart';
import 'package:baltra/features/authetication/presentation/pages/profile_page.dart';
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
  String? _Address;

  @override
  void initState() {
    super.initState();
    _phone = widget.data.contact.toString();
    _fullNameController.text = "${widget.data.firstname} ${widget.data.lastname}";
    _emailController.text = widget.data.email;
    _gender = widget.data.gender;
    if (widget.data.dob != null && widget.data.dob!.isNotEmpty) {
      _dobController.text = DateTime.tryParse(widget.data.dob!) != null
          ? '${DateTime.parse(widget.data.dob!).month}/${DateTime.parse(widget.data.dob!).day}/${DateTime.parse(widget.data.dob!).year}'
          : '';
      _dob = DateTime.tryParse(widget.data.dob!);
    }
    _AddressController.text = widget.data.address ?? '';
    _districtController.text = widget.data.district ?? '';
    _cityController.text = widget.data.city ?? '';
    _loadProfileImage();
  }

  // load profile image from sharepreference
  Future<void> _loadProfileImage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profile_image_path') ?? widget.data.image_url;
    });
  }

  //pick image from galary
  /*Future<void> _pickImage() async{
    try{
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = pickedFile.name;
        final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');

        setState(() {
          _profileImagePath = savedImage.path;
        });

        // Save the path to SharedPreferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path', savedImage.path);

        log('Profile image saved at: ${savedImage.path}');
      }
    } catch (e){
      log('Error pickeing image: $e');
    }
  }*/

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

        // Save the path to SharedPreferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path', savedImage.path);

        // Upload the image to the server
        await _uploadImage(savedImage);
      }
    } catch (e) {
      log('Error picking image: $e');
    }
  }

  // Upload image using multipart/form-data
  /*Future<void> _uploadImage(File imageFile) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      log('Token: $token');  // Log the token to check if it's null
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Missing authentication token')),
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

        log('Response Data: $responseData');  // Log the complete response

        if (responseJson['success'] == true) {
          final imageUrl = responseJson['image_url'];
          log('Image URL from server: $imageUrl');  // Log the image URL

          if (imageUrl != null && imageUrl is String && Uri.tryParse(imageUrl)?.isAbsolute == true) {
            // Image URL is valid, proceed to save and update
            await prefs.setString('image_url', imageUrl);
            setState(() {
              widget.data.image_url = imageUrl;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile image updated successfully!')),
            );
          } else {
            // Handle invalid image URL
            log('Error: Image URL is null or invalid');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload image: Invalid image URL')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: ${responseJson['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      log('Error uploading image: $e');
    }
  }*/
  Future<void> _uploadImage(File imageFile) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      log('Token: $token');
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Missing authentication token')),
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

        // Log the entire response to see the structure
        log('Response Data: $responseData');
        log('Image URL from server: ${responseJson['image_url']}');

        // Adjust the image URL extraction based on the server response format
        final imageUrl = responseJson['data'] != null ? responseJson['data']['image_url'] : null;


        log('Image URL from server: $imageUrl');

        if (imageUrl != null && imageUrl is String && Uri.tryParse(imageUrl)?.isAbsolute == true) {

          await prefs.setString('image_url', imageUrl);
          setState(() {
            widget.data.image_url = imageUrl;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image updated successfully!')),
          );
        } else {

          log('Error: Image URL is null or invalid');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image: Invalid image URL')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      log('Error uploading image: $e');
    }
  }


  // Save profile data
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if form is invalid
    }


    _formKey.currentState!.save();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Missing authentication token')),
        );
        return;
      }

      // Split full name into first and last name
      final nameParts = _fullNameController.text.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      log('First Name: $firstName, Last Name: $lastName');

      // Prepare the updated profile data
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

      final encodedData = updatedData.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value ?? '')}').join('&');

      // API request to update the profile
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

          // Update widget.data with new data
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
            _AddressController.text = widget.data.address!;
            _districtController.text = widget.data.district ?? '';
            _cityController.text = widget.data.city ?? '';
          });


          await prefs.setString('firstname', widget.data.firstname);
          await prefs.setString('lastname', widget.data.lastname);
          await prefs.setString('email', widget.data.email);
          await prefs.setString('contact', widget.data.contact.toString());
          await prefs.setString('gender', widget.data.gender ?? '');
          await prefs.setString('dob', widget.data.dob ?? '');
          await prefs.setString('customerAddress', widget.data.address ?? '');
          await prefs.setString('district', widget.data.district ?? '');
          await prefs.setString('city', widget.data.city ?? '');


          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ButtomNavBar(pageno: 3,),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: ${responseData['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
                      ? FileImage(File(_profileImagePath!))
                      : const NetworkImage(
                    'https://t4.ftcdn.net/jpg/02/15/84/43/360_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg',
                  ) as ImageProvider,
                ),
              ),

              SizedBox(
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

                      // Phone Field
                      ProfileTextField(
                        initialValue: _phone.toString(),
                        title: 'Phone',
                        readonly: true,

                      ),

                      ProfileTextField(
                        title: 'Address',
                        controller: _AddressController,
                        onSaved: (value) {
                          _AddressController.text = value!;
                          _Address = value;
                          widget.data.address = value;
                        },
                      ),
                      ProfileTextField(
                        title: 'City',
                        initialValue: _cityController.text,
                        onSaved: (value) {
                          _cityController.text = value!;
                        },
                      ),
                      ProfileTextField(
                        title: 'District',
                        initialValue: _districtController.text,
                        onSaved: (value) {
                          _districtController.text = value!;
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
                                value: _gender,
                                dropdownColor: Colors.white,
                                items: ['Male', 'Female'].map((gender) {
                                  return DropdownMenuItem(
                                    value: gender,
                                    child: Text(
                                      gender,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) => setState(() => _gender = value),
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
                                    widget.data.dob =
                                    pickedDate.toLocal().toString().split(' ')[0];
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

                      // ResetPassword
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangePasswordPage(
                                  phone: 9861490173,
                                ),
                              ));
                        },
                        child: const ProfileDetailCard(
                          detail: "Password",
                          title: 'Change Password',
                        ),
                      ),
                      // Save Button
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