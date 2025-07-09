import 'dart:developer';

import 'package:baltra/features/authetication/data/authRepository.dart';
import 'package:baltra/features/authetication/presentation/pages/loginPage.dart';
import 'package:baltra/features/authetication/presentation/widgets/obsecuretextform.dart';
import 'package:flutter/material.dart';

class Resetpassword extends StatelessWidget {
  Resetpassword({super.key, this.phone});
  final int? phone;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final TextEditingController password = TextEditingController();
    final TextEditingController confirmPassword = TextEditingController();

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/images/doodle.png'),
                ),
              ),
              child: Center(
                child: Container(
                  color: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Reset password!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff1A1A1A),
                          ),
                        ),
                        const Text(
                          'Remember keeping your password secure is important to us. Make sure to choose a strong password.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ObsecureTextField(
                          type: TextInputType.visiblePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            if (!RegExp(
                                r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$&*]).{8,}$')
                                .hasMatch(value)) {
                              return 'Password must contain at least one uppercase letter, one lowercase letter, one digit, and one special character';
                            }
                            return null;
                          },
                          title: 'Password',
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
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                int status =
                                await Authrepository().resetpassword(
                                  phone!,
                                  password.text.trim(),
                                  confirmPassword.text.trim(),
                                );

                                if (status == 200) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                      Text('Password reset successful.'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Loginpage(),
                                    ),
                                  );
                                } else {
                                  throw Exception(
                                      'Failed to reset password. Status code: $status');
                                }
                              } catch (e) {
                                log('Error during password reset: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 15),
                            width: double.infinity,
                            height: 50,
                            color: Theme.of(context).primaryColor,
                            child: const Center(
                              child: Text(
                                'Proceed',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

