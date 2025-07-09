import 'package:baltra/core/utils/sessionController.dart';
import 'package:baltra/core/utils/splashScreen.dart';
import 'package:baltra/features/applicationCare/controller/crmController.dart';
import 'package:baltra/features/applicationCare/data/crm.dart';
import 'package:baltra/features/products/controller/reviewController.dart';
import 'package:baltra/features/products/presentation/screens/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

void main() async {
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

  // Initialize SharedPreferences first
  final prefs = await SharedPreferences.getInstance();
  final userImageUrl = prefs.getString('image_url');

  // Try to preload images, but don't wait for completion or block app startup if it fails
  try {
    cacheManager.downloadFile(
      'https://t4.ftcdn.net/jpg/02/15/84/43/360_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg',
    ).catchError((e) {
      // Silently handle network errors
      debugPrint('Failed to preload fallback image: $e');
    });

    if (userImageUrl != null && userImageUrl.isNotEmpty) {
      cacheManager.downloadFile(userImageUrl).catchError((e) {
        // Silently handle network errors
        debugPrint('Failed to preload user image: $e');
      });
    }
  } catch (e) {
    // Catch any exceptions to prevent app from crashing during startup
    debugPrint('Error during image preloading: $e');
  }

  // Continue with app initialization regardless of image preloading status
  runApp(const Zero());
}

class Zero extends StatelessWidget {
  const Zero({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xffF6F8FA),
        fontFamily: 'Gotham',
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: Color(0xff1a1a1a),
            fontSize: 24,
            fontWeight: FontWeight.w700,
            fontFamily: 'Gotham',
          ),
          titleMedium: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Gotham',
          ),
          titleSmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Color(0xff4F4F4F),
            fontFamily: 'Gotham',
          ),
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
      getPages: [
        /*GetPage(
          name: '/product/:id',
          page: () {
            final args = Get.arguments as Map<String, dynamic>?;
            return ProductDetailPage(
              key: UniqueKey(),
              product: args?['product'] as Product?,
              relatedProducts: args?['relatedProducts'] as List<Subcategoryproduct>?,
            );
          },
        ),*/
        GetPage(
          name: '/product/:id',
          page: () {
            final args = Get.arguments ?? {};
            return ProductDetailPage(
              key: ValueKey(Get.parameters['key']),
              product: args['product'],
              relatedProducts: args['relatedProducts'],
            );
          },
        ),
        // Add other routes as needed (e.g., home, login, etc.)
        GetPage(
          name: '/home',
          page: () => const SplashScreen(),
        ),
      ],
      initialRoute: '/home', // Set initial route to SplashScreen or your home screen
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(child: Text('Page not found: ${settings.name}')),
        ),
      ),
      home: const SplashScreen(), // Default home screen
    );
  }
}