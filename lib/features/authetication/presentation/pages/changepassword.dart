import 'package:baltra/features/authetication/data/authRepository.dart';
import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChangePasswordPage extends StatefulWidget {
  final int phone;
  const ChangePasswordPage({super.key, required this.phone});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool _oldPasswordVisible = false; // Toggle for old password visibility
  bool _newPasswordVisible = false; // Toggle for new password visibility
  bool _confirmPasswordVisible = false; // Toggle for confirm password visibility

  Future<void> _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      var response = await Authrepository().changePassword(
        widget.phone,
        _oldPasswordController.text.trim(),
        _newPasswordController.text.trim(),
        _confirmPasswordController.text.trim(),
      );

      setState(() {
        isLoading = false;
      });

      if (response['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Password changed successfully.',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Failed to change password',
              style: const TextStyle(color: Colors.white),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBarWithSVG(
                subtitle: 'Change Password',
                title: 'My Profile',
                backbutton: true,
              ),
              const SizedBox(height: 50),
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Old Password",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xff4F4F4F),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          obscureText: !_oldPasswordVisible,
                          cursorColor: Theme.of(context).primaryColor,
                          style: const TextStyle(fontSize: 16),
                          controller: _oldPasswordController,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: SvgPicture.asset(
                                _oldPasswordVisible
                                    ? 'assets/icons/eye_show.svg'
                                    : 'assets/icons/eye_hidden.svg',
                              ),
                              onPressed: () {
                                setState(() {
                                  _oldPasswordVisible = !_oldPasswordVisible;
                                });
                              },
                            ),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xffC2C2C2),
                              ),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xffC2C2C2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            hintText: 'Enter old password',
                            hintStyle: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your old password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        const Text(
                          "New Password",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xff4F4F4F),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          obscureText: !_newPasswordVisible,
                          cursorColor: Theme.of(context).primaryColor,
                          style: const TextStyle(fontSize: 16),
                          controller: _newPasswordController,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: SvgPicture.asset(
                                _newPasswordVisible
                                    ? 'assets/icons/eye_show.svg'
                                    : 'assets/icons/eye_hidden.svg',
                              ),
                              onPressed: () {
                                setState(() {
                                  _newPasswordVisible = !_newPasswordVisible;
                                });
                              },
                            ),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xffC2C2C2),
                              ),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xffC2C2C2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            hintText: 'Enter new password',
                            hintStyle: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a new password';
                            } else if (value.length < 8) {
                              return 'Password must be at least 8 characters long';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        const Text(
                          "Confirm Password",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xff4F4F4F),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          obscureText: !_confirmPasswordVisible,
                          cursorColor: Theme.of(context).primaryColor,
                          style: const TextStyle(fontSize: 16),
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: SvgPicture.asset(
                                _confirmPasswordVisible
                                    ? 'assets/icons/eye_show.svg'
                                    : 'assets/icons/eye_hidden.svg',
                              ),
                              onPressed: () {
                                setState(() {
                                  _confirmPasswordVisible = !_confirmPasswordVisible;
                                });
                              },
                            ),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xffC2C2C2),
                              ),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xffC2C2C2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            hintText: 'Confirm new password',
                            hintStyle: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your new password';
                            } else if (value != _newPasswordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24.0),
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 100.0,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleChangePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: isLoading
                                  ? const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.0,
                                  ),
                                ),
                              )
                                  : const Text(
                                'Submit',
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
            ],
          ),
        ),
      ),
    );
  }
}