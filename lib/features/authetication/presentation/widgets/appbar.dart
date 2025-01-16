import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget {
  const CustomAppbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 100,
      decoration: const BoxDecoration(
          gradient:
              LinearGradient(colors: [Color(0xffE91C1C), Color(0xff831010)])),
      child: Image.asset('assets/images/logo_white.png'),
    );
  }
}
