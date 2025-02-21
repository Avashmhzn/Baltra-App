import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppBarWithSVG extends StatelessWidget {
  const AppBarWithSVG({
    super.key,
    required this.subtitle,
    required this.title,
    required this.backbutton,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final bool backbutton;
  final VoidCallback? onBack; // Added onBack callback

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 144,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffE91C1C), Color(0xff831010)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -10,
          right: -10,
          child: SvgPicture.asset('assets/icons/fan.svg'),
        ),
        Positioned(
          bottom: 10,
          left: -8,
          child: SvgPicture.asset('assets/icons/ricecooker_icon.svg'),
        ),
        if (backbutton)
          Positioned(
            top: 5,
            left: 6,
            child: IconButton(
              onPressed: onBack ?? () {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
      ],
    );
  }
}
