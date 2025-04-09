import 'package:baltra/features/authetication/data/authRepository.dart';
import 'package:baltra/features/authetication/presentation/pages/buttomNavbar.dart';
import 'package:baltra/features/authetication/presentation/pages/loginPage.dart';
import 'package:baltra/features/authetication/presentation/widgets/appbar.dart';
import 'package:baltra/features/authetication/presentation/widgets/obsecuretextform.dart';
import 'package:baltra/features/authetication/presentation/widgets/textform.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key, required this.phone});
  final int phone;

  @override
  State<SignupPage> createState() => _SignupPageState();
}

final TextEditingController firstName = TextEditingController();
final TextEditingController lastName = TextEditingController();
final TextEditingController email = TextEditingController();

final TextEditingController password = TextEditingController();
final TextEditingController confirmPassword = TextEditingController();
final TextEditingController dob = TextEditingController();

final loginController = Get.put(Authrepository());

// global form key
final _formKey = GlobalKey<FormState>();

class _SignupPageState extends State<SignupPage> {
  final bool rememberMe = false;
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
                    padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Welcome!',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700)),
                        const Text(
                          'Sign up to explore our exclusive range!',
                          style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
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
                                      // Check for at least one digit, one uppercase letter, one lowercase letter, and one special character
                                      if (!RegExp(
                                          r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$&*]).{8,}$')
                                          .hasMatch(value)) {
                                        return 'Password must contain at least one uppercase letter, one\n lowercase letter,one digit, and one special character';
                                      }
                                      return null;
                                    },
                                    title: 'Password',
                                    controller: password),
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
                                    title: 'Confirm Password'),
                              ],
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: loginController.isLoading.value
                              ? null // Disable the button when loading
                              : () async {
                            if (_formKey.currentState!.validate()) {
                              // Set isLoading to true to show the loading indicator
                              loginController.isLoading.value = true;
                              try {
                                int status = await Authrepository()
                                    .registerCustomer(
                                    firstName.text.trim(),
                                    lastName.text.trim(),
                                    email.text.trim(),
                                    password.text.trim(),
                                    widget.phone);

                                print('Registration status: $status'); // Debug print

                                // Since the status is -1 but the API logs show 200, check if errorMessage is empty to determine success
                                if (status == 200 || loginController.errorMessage.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.green[300],
                                      content: const Text(
                                          'User logged in successfully!'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                      const ButtomNavBar(pageno: 0),
                                    ),
                                        (route) => false,
                                  );
                                } else if (loginController
                                    .errorMessage.isNotEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor:
                                      Theme.of(context).primaryColor,
                                      content: Text(
                                          'Error: ${loginController.errorMessage.value}'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } catch (e) {
                                print('Error during registration: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor:
                                    Theme.of(context).primaryColor,
                                    content: Text('Error: $e'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              } finally {
                                // Reset isLoading after the API call completes
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                                    : const Text(
                                  'Proceed',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Loginpage(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}