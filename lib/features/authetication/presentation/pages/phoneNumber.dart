import 'package:baltra/features/authetication/data/authRepository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Phonenumber extends StatelessWidget {
  Phonenumber({super.key});

  final loginController = Get.put(Authrepository());

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Enter Phone Number',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff1A1A1A)),
                      ),
                      const Text(
                        'Enter the phone number to get OTP',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff1A1A1A)),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TextFormField(
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                cursorColor: Theme.of(context).primaryColor,
                                style: const TextStyle(fontSize: 16),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your phone';
                                  }
                                  return null;
                                },
                                controller: phoneController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Enter Phone Number',
                                  hintStyle: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xff828282),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xffC2C2C2))),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 408218
                      GestureDetector(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            await loginController.requestOTP(
                                int.parse(phoneController.text.trim()));
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
