// import 'package:baltra/features/authetication/data/authRepository.dart';
// import 'package:baltra/features/authetication/presentation/pages/congratulations_page.dart';
// import 'package:baltra/features/authetication/presentation/pages/resetPassowrd.dart';
// import 'package:baltra/features/authetication/presentation/widgets/appbar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';

// class OtpPage extends StatefulWidget {
//   const OtpPage({super.key, required this.phone, required this.reset});
//   final int phone;
//   final bool reset;

//   @override
//   State<OtpPage> createState() => _OtpPageState();
// }

// class _OtpPageState extends State<OtpPage> {
//   List<TextEditingController> controllers =
//       List.generate(6, (index) => TextEditingController());
//   List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
//   final TextEditingController _pasteController = TextEditingController();
//   final FocusNode _pasteFocusNode = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//     // Listen for paste in hidden TextField
//     _pasteController.addListener(() {
//       final text = _pasteController.text.trim();
//       if (text.length == 6 && RegExp(r'^\d{6}$').hasMatch(text)) {
//         for (int i = 0; i < 6; i++) {
//           controllers[i].text = text[i];
//         }
//         FocusScope.of(context).requestFocus(focusNodes[5]);
//         setState(() {});
//         print('Pasted OTP: $text');
//       } else if (text.isNotEmpty) {
//         print('Invalid pasted OTP: "$text"');
//       }
//     });
//   }

//   void verifyOTP() async {
//     String otp = controllers.map((controller) => controller.text).join();
//     if (otp.length != 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter a complete 6-digit OTP')),
//       );
//       return;
//     }

//     try {
//       int status;
//       if (widget.reset) {
//         status =
//             await Authrepository().resetverifyOTP(widget.phone, int.parse(otp));
//       } else {
//         status = await Authrepository().verifyOTP(widget.phone, int.parse(otp));
//       }

//       if (status == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('OTP verification successful. Status code: $status'),
//             duration: const Duration(seconds: 2),
//           ),
//         );
//         if (widget.reset) {
//           Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(
//               builder: (context) => Resetpassword(phone: widget.phone),
//             ),
//             (route) => false,
//           );
//         } else {
//           Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => CongratulationsPage(phone: widget.phone)),
//             (route) => false,
//           );
//         }
//       } else {
//         throw Exception('Failed to verify OTP. Error: $status');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: $e'),
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   final loginController = Get.put(Authrepository());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CustomAppbar(),
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Enter the OTP code',
//                     style: Theme.of(context).textTheme.titleMedium,
//                   ),
//                   Text(
//                     'Enter the OTP code below to get verified.',
//                     style: Theme.of(context).textTheme.bodySmall,
//                   ),
//                   const SizedBox(height: 20.0),
//                   // Hidden TextField for pasting
//                   Offstage(
//                     offstage: true,
//                     child: TextField(
//                       controller: _pasteController,
//                       focusNode: _pasteFocusNode,
//                       keyboardType: TextInputType.number,
//                       inputFormatters: [
//                         FilteringTextInputFormatter.digitsOnly,
//                         LengthLimitingTextInputFormatter(6),
//                       ],
//                     ),
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: List.generate(
//                       6,
//                       (index) => SizedBox(
//                         width: 40,
//                         child: TextField(
//                           controller: controllers[index],
//                           focusNode: focusNodes[index],
//                           textAlign: TextAlign.center,
//                           keyboardType: TextInputType.number,
//                           inputFormatters: [
//                             LengthLimitingTextInputFormatter(1),
//                             FilteringTextInputFormatter.digitsOnly,
//                           ],
//                           decoration: const InputDecoration(
//                             counterText: '',
//                             border: OutlineInputBorder(),
//                           ),
//                           onChanged: (value) {
//                             if (value.length == 1 && index < 5) {
//                               FocusScope.of(context)
//                                   .requestFocus(focusNodes[index + 1]);
//                             }
//                           },
//                           onTap: () {
//                             FocusScope.of(context)
//                                 .requestFocus(_pasteFocusNode);
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       const Text(
//                         'Didn\'t Receive code?',
//                         style: TextStyle(fontSize: 14),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           // Implement resend code functionality
//                         },
//                         style: const ButtonStyle(
//                           padding: WidgetStatePropertyAll(EdgeInsets.zero),
//                           foregroundColor:
//                               WidgetStatePropertyAll(Color(0xff4f4f4f)),
//                         ),
//                         child: const Text(
//                           'Resend Code',
//                           style: TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                     ],
//                   ),
//                   GestureDetector(
//                     onTap: verifyOTP,
//                     child: Obx(() {
//                       return Container(
//                         margin: const EdgeInsets.symmetric(vertical: 15),
//                         width: double.infinity,
//                         height: 50,
//                         color: Theme.of(context).primaryColor,
//                         child: Center(
//                           child: loginController.isLoading.value
//                               ? const CircularProgressIndicator(
//                                   strokeWidth: 3,
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                       Colors.white),
//                                 )
//                               : const Text(
//                                   'Proceed',
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                         ),
//                       );
//                     }),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     for (var controller in controllers) {
//       controller.dispose();
//     }
//     for (var focusNode in focusNodes) {
//       focusNode.dispose();
//     }
//     _pasteController.dispose();
//     _pasteFocusNode.dispose();
//     super.dispose();
//   }
// }

import 'package:baltra/features/authetication/data/authRepository.dart';
import 'package:baltra/features/authetication/presentation/pages/congratulations_page.dart';
import 'package:baltra/features/authetication/presentation/pages/resetPassowrd.dart';
import 'package:baltra/features/authetication/presentation/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_auth/smart_auth.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key, required this.phone, required this.reset});
  final int phone;
  final bool reset;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final loginController = Get.put(Authrepository());

  // ── SMS auto-read (Android only) ─────────────────────────────────────────
  final SmartAuth _smartAuth = SmartAuth.instance;
  bool _autoFilled = false;

  @override
  void initState() {
    super.initState();
    _startSmsListener();
  }

  @override
  void dispose() {
    _smartAuth.removeUserConsentApiListener();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  // ── SMS listener ──────────────────────────────────────────────────────────

  void _startSmsListener() async {
    final result = await _smartAuth.getSmsWithUserConsentApi();

    if (!mounted) return;

    if (result.hasData && result.requireData.code != null) {
      _distribute(result.requireData.code!, 0);
      setState(() => _autoFilled = true);

      // brief pause so user sees boxes fill, then auto-verify
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) _verifyOTP();
    }
    // if result.isCanceled → user tapped Deny, manual typing still works
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String get _otp => _controllers.map((c) => c.text).join();

  void _distribute(String digits, int startIndex) {
    digits = digits.replaceAll(RegExp(r'\D'), '');
    for (int i = 0; i < digits.length && startIndex + i < 6; i++) {
      _controllers[startIndex + i].text = digits[i];
    }
    final nextEmpty = List.generate(6, (i) => i).firstWhere(
      (i) => i >= startIndex && _controllers[i].text.isEmpty,
      orElse: () => (startIndex + digits.length).clamp(0, 5),
    );
    FocusScope.of(context).requestFocus(_focusNodes[nextEmpty]);
    setState(() {});
  }

  void _verifyOTP() async {
    if (_otp.length != 6) {
      _showSnack('Please enter a complete 6-digit OTP');
      return;
    }
    try {
      final status = widget.reset
          ? await Authrepository().resetverifyOTP(widget.phone, int.parse(_otp))
          : await Authrepository().verifyOTP(widget.phone, int.parse(_otp));

      if (!mounted) return;

      if (status == 200) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => widget.reset
                ? Resetpassword(phone: widget.phone)
                : CongratulationsPage(phone: widget.phone),
          ),
          (_) => false,
        );
      } else {
        throw Exception('Verification failed. Code: $status');
      }
    } catch (e) {
      setState(() => _autoFilled = false);
      _showSnack('Error: $e');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── OTP box ───────────────────────────────────────────────────────────────

  Widget _buildBox(int index, double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (event is! RawKeyDownEvent) return;
          if (event.logicalKey == LogicalKeyboardKey.backspace) {
            if (_controllers[index].text.isNotEmpty) {
              _controllers[index].clear();
              setState(() {});
            } else if (index > 0) {
              _controllers[index - 1].clear();
              FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
              setState(() {});
            }
          }
        },
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          // iOS: triggers SMS suggestion banner above keyboard
          autofillHints: index == 0 ? const [AutofillHints.oneTimeCode] : null,
          style: TextStyle(
            fontSize: (width * 0.45).clamp(14.0, 24.0),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          onChanged: (value) {
            if (value.isEmpty) return;
            // handles paste or full-OTP SMS suggestion
            if (value.length > 1) {
              _distribute(value, index);
              return;
            }
            if (index < 5) {
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            }
            setState(() {});
          },
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppbar(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter the OTP code',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Enter the 6-digit code sent to your phone.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),

                  // ── Auto-fill badge ──────────────────────────────────────
                  if (_autoFilled)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'OTP filled from SMS',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ── OTP boxes (responsive) ───────────────────────────────
                  // AutofillGroup required for iOS oneTimeCode hint
                  AutofillGroup(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const double gap = 8.0;
                        final double boxWidth =
                            (constraints.maxWidth - (gap * 5)) / 6;
                        final double boxHeight = boxWidth * 1.2;

                        return Row(
                          children: List.generate(6, (index) {
                            return index == 0
                                ? _buildBox(index, boxWidth, boxHeight)
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(width: gap),
                                      _buildBox(index, boxWidth, boxHeight),
                                    ],
                                  );
                          }),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Resend row ───────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Didn't receive the code?",
                        style: TextStyle(fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: call your resend API here
                          setState(() => _autoFilled = false);
                          _startSmsListener();
                        },
                        style: const ButtonStyle(
                          padding: WidgetStatePropertyAll(EdgeInsets.zero),
                          foregroundColor:
                              WidgetStatePropertyAll(Color(0xff4f4f4f)),
                        ),
                        child: const Text(
                          'Resend',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),

                  // ── Proceed button ───────────────────────────────────────
                  GestureDetector(
                    onTap: _verifyOTP,
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
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
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
          ],
        ),
      ),
    );
  }
}
