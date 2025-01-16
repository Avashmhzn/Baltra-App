// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:baltra/features/applicationCare/presentation/ui/application_care_page.dart';
// import 'package:baltra/features/applicationCare/presentation/ui/extend_warranty_page.dart';
// import 'package:baltra/features/applicationCare/presentation/ui/myProduct_page.dart';
// import 'package:baltra/features/applicationCare/presentation/ui/product_maintainance_page.dart';
// import 'package:baltra/features/applicationCare/presentation/ui/product_tracking_page.dart';
// import 'package:baltra/features/applicationCare/presentation/ui/register_complaint_page.dart';
// import 'package:baltra/features/authetication/presentation/pages/buttomNavbar.dart';
// import 'package:baltra/features/authetication/presentation/pages/congratulation_page.dart';
// import 'package:baltra/features/authetication/presentation/pages/otp_page.dart';
// import 'package:baltra/features/authetication/presentation/pages/signup_page.dart';
// import 'package:baltra/features/products/presentation/screens/category_page.dart';
// import 'package:baltra/features/products/presentation/screens/product_detail_page.dart';
// import 'package:baltra/features/products/presentation/screens/product_page.dart';
// import 'package:baltra/features/authetication/presentation/pages/profile_page.dart';
// import 'package:baltra/features/products/presentation/screens/reward_point_page.dart';

// Future<bool> isLoggedIn() async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getString('auth_token') != null;
// }

// final router = GoRouter(
//   initialLocation: '/',
//   routes: [
//     GoRoute(
//       name: 'home',
//       path: '/',
//       builder: (context, state) => const ButtomNavBar(
//         pageno: 0,
//       ),
//     ),
//     GoRoute(
//       name: 'signup',
//       path: '/signup',
//       builder: (context, state) => const SignupPage(),
//     ),
//     GoRoute(
//       name: 'otpPage',
//       path: '/otp',
//       builder: (context, state) => const OtpPage(),
//     ),
//     GoRoute(
//       name: 'signupsuccess',
//       path: '/signup-success',
//       builder: (context, state) => const CongratulationPage(),
//     ),
//     GoRoute(
//       name: 'yourProduct',
//       path: '/your-product',
//       builder: (context, state) => const MyProductPage(),
//     ),
//     GoRoute(
//       name: 'complain-registration',
//       path: '/complain-registration',
//       builder: (context, state) => const ComplaintRegistrationPage(),
//     ),
//     GoRoute(
//       name: 'track-product',
//       path: '/track-product',
//       builder: (context, state) => const TrackingPage(),
//     ),
//     GoRoute(
//       name: 'product-maintainance',
//       path: '/product-maintainance',
//       builder: (context, state) => const ProductMaintainancePage(),
//     ),
//     GoRoute(
//       name: 'application-care',
//       path: '/application-care',
//       builder: (context, state) => const ApplicationCarePage(),
//     ),
//     GoRoute(
//       name: 'extend-warranty',
//       path: '/extend-warranty',
//       builder: (context, state) => const ExtendWarrantyPage(),
//     ),
//     GoRoute(
//       name: 'reward',
//       path: '/reward',
//       builder: (context, state) => const RewardsPage(),
//     ),
//     GoRoute(
//       name: 'category',
//       path: '/product-category',
//       builder: (context, state) => const CategoryPage(),
//     ),
//     GoRoute(
//       name: 'profile',
//       path: '/profile',
//       builder: (context, state) => const ProfilePage(),
//     ),
//     GoRoute(
//       name: 'all-products',
//       path: '/all-products',
//       builder: (context, state) => const ProductPage(),
//     ),
//   ],
//   redirect: (BuildContext context, GoRouterState state) async {
//     final loggedIn = await isLoggedIn();

//     // Extracting the location using state.uri.path
//     final location = state.uri.toString();

//     // If user is not logged in and trying to access a protected route, redirect to login
//     if (!loggedIn &&
//         location != '/signup' &&
//         location != '/otp' &&
//         location != '/signup-success') {
//       return '/signup';
//     }

//     // If user is logged in and trying to access the login or signup page, redirect to home
//     if (loggedIn &&
//         (location == '/signup' ||
//             location == '/otp' ||
//             location == '/signup-success')) {
//       return '/';
//     }

//     // No redirection needed
//     return null;
//   },
// );
