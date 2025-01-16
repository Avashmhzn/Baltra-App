// import 'package:baltra/core/router/router.dart';
import 'package:baltra/core/utils/sessionController.dart';
import 'package:baltra/core/utils/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void main() async {
  // await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(SessionController());

  runApp(const Zero());
}

class Zero extends StatelessWidget {
  const Zero({
    super.key,
    //  required this.loggedin,
  });
  // final bool loggedin;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return GetMaterialApp(
        // routerConfig: router,
        // navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xffF6F8FA),
          fontFamily: 'Gotham',
          textTheme: const TextTheme(
              titleLarge: TextStyle(
                  color: Color(0xff1a1a1a),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Gotham'),
              titleMedium: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Gotham'),
              titleSmall: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Color(0xff4F4F4F),
                  fontFamily: 'Gotham'),
              bodyMedium: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xff131315),
                fontFamily: 'Gotham',
              ),
              bodySmall: TextStyle(
                fontSize: 14,
                color: Color(0xff4F4F4F),
              ),
              displaySmall: TextStyle(color: Color(0xff77777E), fontSize: 10)),
          primaryColor: const Color(0xffED1C24),
        ),
        home: const SplashScreen());
  }
}
