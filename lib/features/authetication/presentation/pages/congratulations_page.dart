import 'package:baltra/features/authetication/presentation/pages/signup_page.dart';
import 'package:baltra/features/authetication/presentation/widgets/appbar.dart';
import 'package:flutter/material.dart';

class CongratulationsPage extends StatefulWidget {
  const CongratulationsPage({Key? key, required this.phone}) : super(key: key);
  final int phone;

  @override
  _CongratulationsPageState createState() => _CongratulationsPageState();
}

class _CongratulationsPageState extends State<CongratulationsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();

    // Automatically navigate to SignupPage after 5 seconds
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SignupPage(phone: widget.phone)),
              (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0), // Adjust height to minimize gap
        child: CustomAppbar(),
      ),
      body: SafeArea(
        top: false, // Prevent extra padding at the top
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Align content closer to top
              children: [
                const SizedBox(height: 8), // Small padding to avoid touching app bar
                Image.asset(
                  'assets/images/congratulation.gif',
                  height: 300,
                  width: 300,
                  fit: BoxFit.cover, // Ensure no transparency in scaling
                ),
                const SizedBox(height: 8),
                Text(
                  'CONGRATULATIONS!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your account has been created successfully.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}