// import 'dart:async';
// import 'package:baltra/features/authetication/presentation/pages/buttomNavbar.dart';
// import 'package:baltra/features/authetication/presentation/pages/loginPage.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {

//   @override
//   void initState() {
//     super.initState();
//     _navigateToNextPage();
//   }

//   Future<void> _navigateToNextPage() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       bool isFirstTimeUser = prefs.getBool('logedin') ?? false;

//       /*Timer(
//         const Duration(seconds: 2),
//             () {
//           if (mounted) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => isFirstTimeUser
//                     ? const ButtomNavBar(
//                   pageno: 0,
//                 )
//                     : const Loginpage(),
//               ),
//             );
//           }
//         },
//       );*/
//       Timer(
//         const Duration(seconds: 2),
//             () {
//           if (mounted) {
//             print('Navigating to: ${isFirstTimeUser ? "ButtomNavBar" : "Loginpage"}');
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => isFirstTimeUser
//                     ? const ButtomNavBar(pageno: 0)
//                     : const Loginpage(),
//               ),
//             );
//           }
//         },
//       );
//     } catch (e) {
//       // Handle any errors during navigation
//       debugPrint('Error during navigation: $e');
//       // Still navigate to login page as fallback
//       if (mounted) {
//         Timer(
//           const Duration(seconds: 2),
//               () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const Loginpage(),
//               ),
//             );
//           },
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Lottie.asset(
//           'assets/BSC.json',
//           fit: BoxFit.cover,
//           width: double.infinity,
//           height: double.infinity,
//           repeat: false,
//           errorBuilder: (context, error, stackTrace) {
//             // Fallback widget when Lottie fails to load
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Image.asset(
//                     'assets/app_icon.png', // Assuming you have a static image as fallback
//                     width: 100,
//                     height: 100,
//                     errorBuilder: (context, error, stackTrace) {
//                       // If even the fallback image fails, show text
//                       return const Text(
//                         'Welcome to Baltra',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   const CircularProgressIndicator(),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';

// ✅ ADDED: import SessionController
import 'package:baltra/core/utils/sessionController.dart';
import 'package:baltra/features/authetication/presentation/pages/buttomNavbar.dart';
import 'package:baltra/features/authetication/presentation/pages/loginPage.dart';
import 'package:flutter/material.dart';
// ✅ ADDED: import GetX
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
// ✅ REMOVED: import 'package:shared_preferences/shared_preferences.dart';
//    (no longer needed here — session logic lives in SessionController)

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextPage();
  }

  Future<void> _navigateToNextPage() async {
    // ✅ CHANGED: Run splash delay and session check simultaneously.
    //    Old code: read prefs.getBool('logedin') which never expired.
    //    New code: SessionController.checkLoginStatus() enforces 1-day limit.
    await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      _checkSession(),
    ]);

    if (!mounted) return;

    final sessionController = Get.find<SessionController>();
    final isLoggedIn = sessionController.isLoggedIn.value;

    debugPrint('Splash: isLoggedIn=$isLoggedIn, '
        'isSessionExpired=${sessionController.isSessionExpired}');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            isLoggedIn ? const ButtomNavBar(pageno: 0) : const Loginpage(),
      ),
    );
  }

  Future<void> _checkSession() async {
    try {
      final sessionController = Get.find<SessionController>();
      // checkLoginStatus() already runs in onInit, but we await it explicitly
      // here so isLoggedIn.value is guaranteed to be set before we route.
      await sessionController.checkLoginStatus();
    } catch (e) {
      debugPrint('Splash: SessionController not found — $e');
      // Falls through: isLoggedIn defaults to false → goes to login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/BSC.json',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          repeat: false,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/app_icon.png',
                    width: 100,
                    height: 100,
                    errorBuilder: (_, __, ___) => const Text(
                      'Welcome to Baltra',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
