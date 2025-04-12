// import 'package:baltra/core/router/router.dart';
import 'package:baltra/core/utils/sessionController.dart';
import 'package:baltra/core/utils/splashScreen.dart';
import 'package:baltra/features/applicationCare/controller/crmController.dart';
import 'package:baltra/features/applicationCare/data/crm.dart';
import 'package:baltra/features/products/controller/reviewController.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart'; // Add this import

void main() async {
  // await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(SessionController());
  Get.put(CrmServices());
  Get.put(CrmController(crmService: CrmServices()), permanent: true);
  Get.put(ReviewController());

  // Configure a custom cache manager for CachedNetworkImage
  final cacheManager = CacheManager(
    Config(
      'customCacheKey',
      stalePeriod: const Duration(days: 7), // Cache images for 7 days
      maxNrOfCacheObjects: 100, // Maximum number of cached objects
    ),
  );

  // Preload the fallback image and user's image_url
  final prefs = await SharedPreferences.getInstance();
  final userImageUrl = prefs.getString('image_url');

  // Use the custom cache manager to preload the images
  await cacheManager.downloadFile(
    'https://t4.ftcdn.net/jpg/02/15/84/43/360_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg',
  );

  if (userImageUrl != null && userImageUrl.isNotEmpty) {
    await cacheManager.downloadFile(userImageUrl);
  }

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
          displaySmall: TextStyle(color: Color(0xff77777E), fontSize: 10),
        ),
        primaryColor: const Color(0xffED1C24),
      ),
      home: const SplashScreen(),
    );
  }
}