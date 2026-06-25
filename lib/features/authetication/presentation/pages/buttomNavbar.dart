// import 'package:baltra/features/applicationCare/presentation/ui/application_care_page.dart';
// import 'package:baltra/features/applicationCare/presentation/widgets/add_product_dialog.dart';
// import 'package:baltra/features/authetication/presentation/pages/profile_page.dart';
// import 'package:baltra/features/products/presentation/screens/category_page.dart';
// import 'package:baltra/features/products/presentation/screens/home_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import '../../../applicationCare/presentation/ui/myProduct_page.dart';
// import 'dart:io'; // Added for SystemNavigator

// class ButtomNavBar extends StatefulWidget {
//   const ButtomNavBar({super.key, required this.pageno});
//   final int pageno;

//   @override
//   _ButtomNavBarState createState() => _ButtomNavBarState();
// }

// class _ButtomNavBarState extends State<ButtomNavBar>
//     with TickerProviderStateMixin {
//   int _selectedIndex = 0;
//   late AnimationController _animationController;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _selectedIndex = widget.pageno;
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 200),
//     );
//     _animation =
//         Tween<double>(begin: 1.0, end: 1.3).animate(_animationController);
//   }

//   void _onItemTapped(int index) {
//     print('Tapped index: $index');
//     setState(() {
//       _selectedIndex = index;
//       if (index == _selectedIndex) {
//         _animationController
//             .forward()
//             .then((_) => _animationController.reverse());
//       }
//     });
//   }

//   final screens = [
//     const HomePage(),
//     const CategoryPage(),
//     const ApplicationCarePage(),
//     const ProfilePage(),
//   ];

//   // Handle back button press
//   Future<bool> _onWillPop() async {
//     if (_selectedIndex == 0) {
//       // On HomePage (index 0), exit the app
//       if (Platform.isAndroid) {
//         await SystemNavigator.pop(); // Closes the app on Android
//       } else if (Platform.isIOS) {
//         exit(0);
//       }
//       return false; // Prevent default pop behavior
//     } else {
//       // On other pages, navigate to HomePage (index 0)
//       setState(() {
//         _selectedIndex = 0;
//         _animationController
//             .forward()
//             .then((_) => _animationController.reverse());
//       });
//       return false; // Prevent default pop behavior
//     }
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false, // Prevent default pop behavior to mimic custom handling
//       onPopInvokedWithResult: (didPop, result) async {
//         if (!didPop) {
//           bool shouldPop =
//               await _onWillPop(); // Call existing _onWillPop method
//           if (shouldPop && mounted) {
//             Navigator.of(context).pop();
//           }
//         }
//       },
//       child: Scaffold(
//         resizeToAvoidBottomInset: false,
//         body: SafeArea(
//           child: Stack(
//             children: [
//               Positioned.fill(
//                 child: screens[_selectedIndex],
//               ),
//             ],
//           ),
//         ),
//         floatingActionButton: GestureDetector(
//           onTap: () async {
//             await showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 return QRScannerScreen();
//               },
//             );
//             myproductcontroller.fetchMyProduct();
//           },
//           child: Container(
//             width: 60.0,
//             height: 60.0,
//             decoration: const BoxDecoration(
//               color: Colors.red,
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(Icons.qr_code, color: Colors.white, size: 40),
//           ),
//         ),
//         floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//         bottomNavigationBar: SizedBox(
//           height: 55.0,
//           child: CustomBottomAppBar(
//             height: 50.0,
//             curveHeight: 30.0,
//             selectedIndex: _selectedIndex,
//             onItemTapped: _onItemTapped,
//             animation: _animation,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class CustomBottomAppBar extends StatelessWidget {
//   final double height;
//   final double curveHeight;
//   final int selectedIndex;
//   final Function(int) onItemTapped;
//   final Animation<double> animation;

//   const CustomBottomAppBar({
//     super.key,
//     required this.height,
//     required this.curveHeight,
//     required this.selectedIndex,
//     required this.onItemTapped,
//     required this.animation,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: height,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(curveHeight)),
//         boxShadow: [
//           BoxShadow(
//             color: Color.fromRGBO(158, 158, 158, 0.1),
//             spreadRadius: 8,
//             blurRadius: 1,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           Expanded(
//               child: _buildNavItem(0, 'assets/icons/home_inactive.svg',
//                   'assets/icons/home_active.svg')),
//           Expanded(
//               child: _buildNavItem(1, 'assets/icons/Product_inactive.svg',
//                   'assets/icons/Product_active.svg')),
//           const SizedBox(width: 60), // Space for QR button
//           Expanded(
//               child: _buildNavItem(2, 'assets/icons/ac_incative.svg',
//                   'assets/icons/ac_active.svg')),
//           Expanded(
//               child: _buildNavItem(3, 'assets/icons/profile_inactive.svg',
//                   'assets/icons/Profile_active.svg')),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavItem(int index, String inactiveIcon, String activeIcon) {
//     return GestureDetector(
//       onTap: () => onItemTapped(index),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         width: selectedIndex == index ? 120 : 80,
//         child: ScaleTransition(
//           scale: selectedIndex == index
//               ? animation
//               : Tween<double>(begin: 1.0, end: 1.0).animate(
//                   AnimationController(
//                     vsync: const _NoopTickerProvider(),
//                     duration: Duration.zero,
//                   ),
//                 ),
//           child: SvgPicture.asset(
//             selectedIndex == index ? activeIcon : inactiveIcon,
//             fit: BoxFit.contain,
//             height: selectedIndex == index ? 45 : 40,
//             width: selectedIndex == index ? 45 : 40,
//             placeholderBuilder: (BuildContext context) => const Icon(
//               Icons.error,
//               size: 40,
//               color: Colors.red,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _NoopTickerProvider extends TickerProvider {
//   const _NoopTickerProvider();

//   @override
//   Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
// }

import 'package:baltra/features/applicationCare/presentation/ui/application_care_page.dart';
import 'package:baltra/features/applicationCare/presentation/widgets/add_product_dialog.dart';
import 'package:baltra/features/authetication/presentation/pages/profile_page.dart';
import 'package:baltra/features/products/presentation/screens/category_page.dart';
import 'package:baltra/features/products/presentation/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../applicationCare/presentation/ui/myProduct_page.dart';
import 'dart:io';

import 'package:get/get.dart';
import 'package:baltra/core/utils/sessionController.dart'; // ← Added for session check

class ButtomNavBar extends StatefulWidget {
  const ButtomNavBar({super.key, required this.pageno});
  final int pageno;

  @override
  _ButtomNavBarState createState() => _ButtomNavBarState();
}

class _ButtomNavBarState extends State<ButtomNavBar>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // ← Added WidgetsBindingObserver

  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ← Added for app resume check

    _selectedIndex = widget.pageno;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation =
        Tween<double>(begin: 1.0, end: 1.3).animate(_animationController);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Check session every time app comes back to foreground (important for 8-hour expiry)
      Get.find<SessionController>().checkLoginStatus();
    }
  }

  void _onItemTapped(int index) {
    print('Tapped index: $index');
    setState(() {
      _selectedIndex = index;
      if (index == _selectedIndex) {
        _animationController
            .forward()
            .then((_) => _animationController.reverse());
      }
    });
  }

  final screens = [
    const HomePage(),
    const CategoryPage(),
    const ApplicationCarePage(),
    const ProfilePage(),
  ];

  // Handle back button press
  Future<bool> _onWillPop() async {
    if (_selectedIndex == 0) {
      // On HomePage (index 0), exit the app
      if (Platform.isAndroid) {
        await SystemNavigator.pop(); // Closes the app on Android
      } else if (Platform.isIOS) {
        exit(0);
      }
      return false; // Prevent default pop behavior
    } else {
      // On other pages, navigate to HomePage (index 0)
      setState(() {
        _selectedIndex = 0;
        _animationController
            .forward()
            .then((_) => _animationController.reverse());
      });
      return false; // Prevent default pop behavior
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // ← Clean up observer
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent default pop behavior to mimic custom handling
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          bool shouldPop =
              await _onWillPop(); // Call existing _onWillPop method
          if (shouldPop && mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: screens[_selectedIndex],
              ),
            ],
          ),
        ),
        floatingActionButton: GestureDetector(
          onTap: () async {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return QRScannerScreen();
              },
            );
            myproductcontroller.fetchMyProduct();
          },
          child: Container(
            width: 60.0,
            height: 60.0,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.qr_code, color: Colors.white, size: 40),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: SizedBox(
          height: 55.0,
          child: CustomBottomAppBar(
            height: 50.0,
            curveHeight: 30.0,
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
            animation: _animation,
          ),
        ),
      ),
    );
  }
}

class CustomBottomAppBar extends StatelessWidget {
  final double height;
  final double curveHeight;
  final int selectedIndex;
  final Function(int) onItemTapped;
  final Animation<double> animation;

  const CustomBottomAppBar({
    super.key,
    required this.height,
    required this.curveHeight,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(curveHeight)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(158, 158, 158, 0.1),
            spreadRadius: 8,
            blurRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
              child: _buildNavItem(0, 'assets/icons/home_inactive.svg',
                  'assets/icons/home_active.svg')),
          Expanded(
              child: _buildNavItem(1, 'assets/icons/Product_inactive.svg',
                  'assets/icons/Product_active.svg')),
          const SizedBox(width: 60), // Space for QR button
          Expanded(
              child: _buildNavItem(2, 'assets/icons/ac_incative.svg',
                  'assets/icons/ac_active.svg')),
          Expanded(
              child: _buildNavItem(3, 'assets/icons/profile_inactive.svg',
                  'assets/icons/Profile_active.svg')),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String inactiveIcon, String activeIcon) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: selectedIndex == index ? 120 : 80,
        child: ScaleTransition(
          scale: selectedIndex == index
              ? animation
              : Tween<double>(begin: 1.0, end: 1.0).animate(
                  AnimationController(
                    vsync: const _NoopTickerProvider(),
                    duration: Duration.zero,
                  ),
                ),
          child: SvgPicture.asset(
            selectedIndex == index ? activeIcon : inactiveIcon,
            fit: BoxFit.contain,
            height: selectedIndex == index ? 45 : 40,
            width: selectedIndex == index ? 45 : 40,
            placeholderBuilder: (BuildContext context) => const Icon(
              Icons.error,
              size: 40,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}

class _NoopTickerProvider extends TickerProvider {
  const _NoopTickerProvider();

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
