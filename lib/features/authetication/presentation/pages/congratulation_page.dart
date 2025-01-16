import 'package:baltra/features/products/presentation/screens/home_page.dart';
import 'package:baltra/features/authetication/presentation/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CongratulationPage extends StatelessWidget {
  const CongratulationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomAppbar(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                SizedBox(
                  height: 218,
                  width: 332,
                  child: Lottie.network(
                      'https://lottiefiles.com/animations/celebrate-EYvzG4sFg9'),
                ),
                Text(
                  'Congratulations',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Your account have been created successfully',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(
                  height: 50,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => const HomePage()));
                  },
                  child: Container(
                    // padding: EdgeInsets.symmetric(vertical: 5),
                    width: double.infinity,
                    height: 50,
                    color: Theme.of(context).primaryColor,
                    child: const Center(
                      child: Text(
                        'Explore Baltra app',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
