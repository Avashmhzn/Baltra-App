// import 'package:baltra/core/utils/network_service.dart';
// import 'package:baltra/core/utils/sessionController.dart';
// import 'package:baltra/core/utils/splashScreen.dart';
// import 'package:baltra/features/applicationCare/controller/crmController.dart';
// import 'package:baltra/features/applicationCare/data/crm.dart';
// import 'package:baltra/features/products/controller/reviewController.dart';
// import 'package:baltra/features/products/presentation/screens/product_detail_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io' as io;

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   Get.put(NetworkService(), permanent: true); // ← WiFi/Data monitor
//   Get.put(SessionController());
//   Get.put(CrmServices());
//   Get.put(CrmController(crmService: CrmServices()), permanent: true);
//   Get.put(ReviewController());

//   // Configure a custom cache manager for CachedNetworkImage
//   final cacheManager = CacheManager(
//     Config(
//       'customCacheKey',
//       stalePeriod: const Duration(days: 7), // Cache images for 7 days
//       maxNrOfCacheObjects: 100, // Maximum number of cached objects
//     ),
//   );

//   // Initialize SharedPreferences first
//   final prefs = await SharedPreferences.getInstance();
//   final userImageUrl = prefs.getString('image_url');

//   // Try to preload images, but don't wait for completion or block app startup if it fails
//   try {
//     // Preload fallback image
//     cacheManager
//         .downloadFile(
//       'https://t4.ftcdn.net/jpg/02/15/84/43/360_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg',
//     )
//         .catchError((e) async {
//       // Silently handle network errors
//       debugPrint('Failed to preload fallback image: $e');
//       // Try to get the file from cache as a fallback
//       final cachedFileInfo = await cacheManager.getFileFromCache(
//         'https://t4.ftcdn.net/jpg/02/15/84/43/360_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg',
//       );
//       if (cachedFileInfo != null) {
//         return cachedFileInfo;
//       }
//       // Create a placeholder FileInfo with a temporary file
//       final tempDir = await getTemporaryDirectory();
//       final tempFile = io.File('${tempDir.path}/dummy.jpg');
//       // Ensure the file exists (create an empty file)
//       if (!await tempFile.exists()) {
//         await tempFile.create();
//       }
//       // Convert to file_pkg.File using getSingleFile
//       final file = await cacheManager.getSingleFile(tempFile.path);
//       return FileInfo(
//         file,
//         FileSource.Cache,
//         DateTime.now().add(const Duration(days: 7)),
//         'https://t4.ftcdn.net/jpg/02/15/84/43/360_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg',
//       );
//     });

//     if (userImageUrl != null && userImageUrl.isNotEmpty) {
//       cacheManager.downloadFile(userImageUrl).catchError((e) async {
//         // Silently handle network errors
//         debugPrint('Failed to preload user image: $e');
//         // Try to get the file from cache as a fallback
//         final cachedFileInfo =
//             await cacheManager.getFileFromCache(userImageUrl);
//         if (cachedFileInfo != null) {
//           return cachedFileInfo;
//         }
//         // Create a placeholder FileInfo with a temporary file
//         final tempDir = await getTemporaryDirectory();
//         final tempFile = io.File('${tempDir.path}/dummy.jpg');
//         // Ensure the file exists (create an empty file)
//         if (!await tempFile.exists()) {
//           await tempFile.create();
//         }
//         // Convert to file_pkg.File using getSingleFile
//         final file = await cacheManager.getSingleFile(tempFile.path);
//         return FileInfo(
//           file,
//           FileSource.Cache,
//           DateTime.now().add(const Duration(days: 7)),
//           userImageUrl,
//         );
//       });
//     }
//   } catch (e) {
//     // Catch any unexpected exceptions to prevent app from crashing during startup
//     debugPrint('Error during image preloading: $e');
//   }

//   // Run the app directly without Sentry
//   runApp(const Zero());
// }

// class Zero extends StatelessWidget {
//   const Zero({super.key});

//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);

//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         scaffoldBackgroundColor: const Color(0xffF6F8FA),
//         fontFamily: 'Gotham',
//         textTheme: const TextTheme(
//           titleLarge: TextStyle(
//             color: Color(0xff1a1a1a),
//             fontSize: 24,
//             fontWeight: FontWeight.w700,
//             fontFamily: 'Gotham',
//           ),
//           titleMedium: TextStyle(
//             color: Colors.black,
//             fontSize: 20,
//             fontWeight: FontWeight.w700,
//             fontFamily: 'Gotham',
//           ),
//           titleSmall: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.normal,
//             color: Color(0xff4F4F4F),
//             fontFamily: 'Gotham',
//           ),
//           bodyMedium: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Color(0xff131315),
//             fontFamily: 'Gotham',
//           ),
//           bodySmall: TextStyle(
//             fontSize: 14,
//             color: Color(0xff4F4F4F),
//           ),
//           displaySmall: TextStyle(color: Color(0xff77777E), fontSize: 10),
//         ),
//         primaryColor: const Color(0xffED1C24),
//       ),
//       getPages: [
//         GetPage(
//           name: '/product/:id',
//           page: () {
//             final args = Get.arguments ?? {};
//             return ProductDetailPage(
//               key: ValueKey(Get.parameters['key']),
//               product: args['product'],
//               relatedProducts: args['relatedProducts'],
//             );
//           },
//         ),
//         GetPage(
//           name: '/home',
//           page: () => const SplashScreen(),
//         ),
//       ],
//       initialRoute: '/home',
//       onUnknownRoute: (settings) => MaterialPageRoute(
//         builder: (_) => Scaffold(
//           body: Center(child: Text('Page not found: ${settings.name}')),
//         ),
//       ),
//       home: const SplashScreen(),
//     );
//   }
// }

import 'package:baltra/core/utils/network_service.dart';
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
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Session FIRST — validates timestamp + endpoint match ──────────────
  // Must be awaited so SplashScreen can immediately read isLoggedIn correctly.
  final session = SessionController();
  await session.checkLoginStatus(); // clears stale/wrong-endpoint sessions
  Get.put(session, permanent: true);

  // ── 2. Network monitor ────────────────────────────────────────────────────
  Get.put(NetworkService(), permanent: true);

  // ── 3. Other services ─────────────────────────────────────────────────────
  Get.put(CrmServices());
  Get.put(CrmController(crmService: CrmServices()), permanent: true);
  Get.put(ReviewController());

  // ── 4. Image preloading (unchanged) ───────────────────────────────────────
  final cacheManager = CacheManager(
    Config(
      'customCacheKey',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final userImageUrl = prefs.getString('image_url');

  try {
    cacheManager
        .downloadFile(
      'https://t4.ftcdn.net/jpg/02/15/84/43/360_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg',
    )
        .catchError((e) async {
      debugPrint('Failed to preload fallback image: $e');
      final cachedFileInfo = await cacheManager.getFileFromCache(
        'https://t4.ftcdn.net/jpg/02/15/84/43/360_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg',
      );
      if (cachedFileInfo != null) return cachedFileInfo;
      final tempDir = await getTemporaryDirectory();
      final tempFile = io.File('${tempDir.path}/dummy.jpg');
      if (!await tempFile.exists()) await tempFile.create();
      final file = await cacheManager.getSingleFile(tempFile.path);
      return FileInfo(
        file,
        FileSource.Cache,
        DateTime.now().add(const Duration(days: 7)),
        'https://t4.ftcdn.net/jpg/02/15/84/43/360_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg',
      );
    });

    if (userImageUrl != null && userImageUrl.isNotEmpty) {
      cacheManager.downloadFile(userImageUrl).catchError((e) async {
        debugPrint('Failed to preload user image: $e');
        final cachedFileInfo =
            await cacheManager.getFileFromCache(userImageUrl);
        if (cachedFileInfo != null) return cachedFileInfo;
        final tempDir = await getTemporaryDirectory();
        final tempFile = io.File('${tempDir.path}/dummy.jpg');
        if (!await tempFile.exists()) await tempFile.create();
        final file = await cacheManager.getSingleFile(tempFile.path);
        return FileInfo(
          file,
          FileSource.Cache,
          DateTime.now().add(const Duration(days: 7)),
          userImageUrl,
        );
      });
    }
  } catch (e) {
    debugPrint('Error during image preloading: $e');
  }

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
        GetPage(
          name: '/home',
          page: () => const SplashScreen(),
        ),
      ],
      initialRoute: '/home',
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(child: Text('Page not found: ${settings.name}')),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
