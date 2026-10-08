import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {

  @override
  final Size preferredSize;

  CustomAppbar({super.key, double height = 56.0})
      : preferredSize = Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,  // Explicitly disable the back button
      toolbarHeight: 80.0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Theme.of(context).primaryColor,
              const Color(0xFF8B0000),
            ],
            center: Alignment.centerLeft,
            radius: 3.5,
          ),
        ),
      ),
      title: Center(
        child: Image.asset(
          'assets/images/logo_white.png',
          height: 35,
        ),
      ),
      backgroundColor: Colors.red,
      elevation: 0,
    );
  }
}
