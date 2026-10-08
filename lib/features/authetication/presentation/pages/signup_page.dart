import 'package:baltra/features/authetication/data/authRepository.dart';
import 'package:baltra/features/authetication/presentation/pages/buttomNavbar.dart';
import 'package:baltra/features/authetication/presentation/pages/loginPage.dart';
import 'package:baltra/features/authetication/presentation/widgets/appbar.dart';
import 'package:baltra/features/authetication/presentation/widgets/obsecuretextform.dart';
import 'package:baltra/features/authetication/presentation/widgets/textform.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For date formatting

class SignupPage extends StatefulWidget {
  const SignupPage({super.key, required this.phone});
  final int phone;

  @override
  State<SignupPage> createState() => _SignupPageState();
}

final TextEditingController firstName = TextEditingController();
final TextEditingController lastName = TextEditingController();
final TextEditingController email = TextEditingController();
final TextEditingController district = TextEditingController();
final TextEditingController address = TextEditingController();
final TextEditingController city = TextEditingController();
final TextEditingController password = TextEditingController();
final TextEditingController confirmPassword = TextEditingController();
final TextEditingController dob = TextEditingController();

final loginController = Get.put(Authrepository());

// Global form key
final _formKey = GlobalKey<FormState>();

class _SignupPageState extends State<SignupPage> {
  final bool rememberMe = false;
  String? selectedGender;

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dob.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    district.dispose();
    address.dispose();
    city.dispose();
    password.dispose();
    confirmPassword.dispose();
    dob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppbar(),
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20), // Increased horizontal padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Welcome!',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const Text(
                        'Sign up to explore our exclusive range!',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 15),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            NormalTextField(
                              controller: firstName,
                              hint: "Enter your First name",
                              title: 'First Name',
                              type: TextInputType.name,
                            ),
                            NormalTextField(
                              controller: lastName,
                              hint: "Enter your last name",
                              title: 'Last Name',
                              type: TextInputType.name,
                            ),
                            NormalTextField(
                              controller: email,
                              hint: "abc123@gmail.com",
                              title: 'Email',
                              type: TextInputType.emailAddress,
                            ),
                            NormalTextField(
                              initial: widget.phone.toString(),
                              hint: "+977- 9870011244",
                              title: 'Phone',
                              readonly: true,
                              type: TextInputType.phone,
                            ),
                            ObsecureTextField(
                              type: TextInputType.visiblePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$&*]).{8,}$').hasMatch(value)) {
                                  return 'Password must contain at least one uppercase letter, one\n lowercase letter, one digit, and one special character';
                                }
                                return null;
                              },
                              title: 'Password',
                              hintText: 'Enter your password',
                              controller: password,
                            ),
                            ObsecureTextField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != password.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                              controller: confirmPassword,
                              type: TextInputType.visiblePassword,
                              title: 'Confirm Password',
                              hintText: 'Enter your  confirm password',
                            ),
                            NormalTextField(
                              controller: address,
                              hint: "Enter your Address",
                              title: 'Address',
                              type: TextInputType.text,
                            ),
                            NormalTextField(
                              controller: city,
                              hint: "Enter your City",
                              title: 'City',
                              type: TextInputType.text,
                            ),
                            NormalTextField(
                              controller: district,
                              hint: "Enter your District",
                              title: 'District',
                              type: TextInputType.text,
                            ),
                            NormalTextField(
                              controller: dob,
                              hint: "YYYY-MM-DD",
                              title: 'Date of Birth',
                              type: TextInputType.datetime,
                              readonly: true,
                              onTap: () => _selectDate(context),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Date of Birth is required';
                                }
                                return null;
                              },
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Gender',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: DropdownButton<String>(
                                    value: selectedGender,
                                    focusColor: Colors.red,
                                    hint: const Text('Select Gender',style: TextStyle(fontSize: 14),),
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    items: ['Male', 'Female', 'Other'].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value, style: const TextStyle(fontSize: 14)),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedGender = newValue;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20), // Increased spacing for better look
                      GestureDetector(
                        onTap: loginController.isLoading.value
                            ? null // Disable the button when loading
                            : () async {
                          if (_formKey.currentState!.validate()) {
                            loginController.isLoading.value = true;
                            try {
                              int status = await loginController.registerCustomer(
                                firstName.text.trim(),
                                lastName.text.trim(),
                                email.text.trim(),
                                password.text.trim(),
                                widget.phone,
                                gender: selectedGender,
                                customerAddress: address.text.trim(),
                                city: city.text.trim(),
                                district: district.text.trim(),
                                dob: dob.text.trim(),
                              );

                              print('Registration status: $status');

                              if (status == 200 || loginController.errorMessage.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.green[300],
                                    content: const Text('User registered successfully!'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ButtomNavBar(pageno: 0),
                                  ),
                                      (route) => false,
                                );
                              } else if (loginController.errorMessage.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    content: Text('Error: ${loginController.errorMessage.value}'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            } catch (e) {
                              print('Error during registration: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  content: Text('Error: $e'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } finally {
                              loginController.isLoading.value = false;
                            }
                          }
                        },
                        child: Obx(() {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 15),
                            width: double.infinity,
                            height: 50,
                            color: Theme.of(context).primaryColor,
                            child: Center(
                              child: loginController.isLoading.value
                                  ? const CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                                  : const Text(
                                'Proceed',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 5),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Loginpage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20), // Added bottom padding
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