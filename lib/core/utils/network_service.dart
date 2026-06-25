// import 'dart:async';

// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';

// class NetworkService extends GetxService {
//   final RxBool isConnected = true.obs;

//   StreamSubscription<List<ConnectivityResult>>? _subscription;

//   // Tracks whether the no-internet dialog is currently showing
//   bool _dialogShowing = false;

//   @override
//   void onInit() {
//     super.onInit();
//     _checkInitialConnection();
//     _listenToConnectivityChanges();
//   }

//   @override
//   void onClose() {
//     _subscription?.cancel();
//     super.onClose();
//   }

//   // ─── Check current connectivity once on startup ───────────────────────────
//   Future<void> _checkInitialConnection() async {
//     try {
//       final result = await Connectivity().checkConnectivity();
//       final connected = _isOnline(result);
//       isConnected.value = connected;
//       if (!connected) {
//         // Delay slightly so the UI is fully ready before showing dialog
//         Future.delayed(const Duration(milliseconds: 500), _showNoInternetDialog);
//       }
//     } catch (_) {
//       // If we can't even check, assume connected
//     }
//   }

//   // ─── Listen for real-time connectivity changes ────────────────────────────
//   void _listenToConnectivityChanges() {
//     _subscription = Connectivity()
//         .onConnectivityChanged
//         .listen((List<ConnectivityResult> results) {
//       final connected = _isOnline(results);

//       if (connected && !isConnected.value) {
//         // Came back online
//         isConnected.value = true;
//         _dismissDialog();
//       } else if (!connected && isConnected.value) {
//         // Went offline
//         isConnected.value = false;
//         _showNoInternetDialog();
//       }
//     });
//   }

//   bool _isOnline(List<ConnectivityResult> results) {
//     return results.any((r) =>
//         r == ConnectivityResult.wifi ||
//         r == ConnectivityResult.mobile ||
//         r == ConnectivityResult.ethernet);
//   }

//   // ─── Dismiss the dialog if it is open ────────────────────────────────────
//   void _dismissDialog() {
//     if (_dialogShowing && Get.isDialogOpen == true) {
//       Get.back();
//       _dialogShowing = false;
//     }
//   }

//   // ─── Show the styled no-internet dialog ──────────────────────────────────
//   void _showNoInternetDialog() {
//     if (_dialogShowing) return;
//     _dialogShowing = true;

//     Get.dialog(
//       barrierDismissible: false,
//       PopScope(
//         // Prevent back-button dismissal
//         canPop: false,
//         child: Dialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           elevation: 0,
//           backgroundColor: Colors.transparent,
//           child: _NoInternetDialogContent(
//             onRetry: () async {
//               final result = await Connectivity().checkConnectivity();
//               if (_isOnline(result)) {
//                 isConnected.value = true;
//                 _dialogShowing = false;
//                 Get.back();
//               }
//             },
//             onOpenSettings: () {
//               // Opens the device Wi-Fi / network settings page
//               SystemChannels.platform
//                   .invokeMethod('SystemNavigator.routeInformationUpdated');
//               // Use AppSettings via platform channel equivalent
//               _openWifiSettings();
//             },
//           ),
//         ),
//       ),
//     ).then<void>((_) {
//       // Called when dialog is closed (e.g. auto-dismissed on reconnect)
//       _dialogShowing = false;
//     });
//   }

//   void _openWifiSettings() {
//     // connectivity_plus doesn't bundle a settings launcher, so we use the
//     // platform channel that opens the system wireless settings.
//     const MethodChannel channel = MethodChannel('baltra/settings');
//     try {
//       channel.invokeMethod('openWifiSettings');
//     } catch (_) {
//       // Fallback: open general settings via url_launcher-style intent
//       // If the channel is not implemented on the native side, we show a snack.
//       Get.snackbar(
//         'Open Settings',
//         'Please go to Settings → Wi-Fi / Mobile Data and enable your connection.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: const Color(0xffED1C24),
//         colorText: Colors.white,
//         duration: const Duration(seconds: 4),
//         margin: const EdgeInsets.all(12),
//         borderRadius: 12,
//         icon: const Icon(Icons.wifi_off, color: Colors.white),
//       );
//     }
//   }
// }

// // ─── Dialog Widget ────────────────────────────────────────────────────────────

// class _NoInternetDialogContent extends StatefulWidget {
//   final Future<void> Function() onRetry;
//   final VoidCallback onOpenSettings;

//   const _NoInternetDialogContent({
//     required this.onRetry,
//     required this.onOpenSettings,
//   });

//   @override
//   State<_NoInternetDialogContent> createState() =>
//       _NoInternetDialogContentState();
// }

// class _NoInternetDialogContentState extends State<_NoInternetDialogContent>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _pulseController;
//   late Animation<double> _pulseAnimation;
//   bool _isRetrying = false;

//   @override
//   void initState() {
//     super.initState();
//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     )..repeat(reverse: true);

//     _pulseAnimation =
//         Tween<double>(begin: 0.9, end: 1.05).animate(CurvedAnimation(
//       parent: _pulseController,
//       curve: Curves.easeInOut,
//     ));
//   }

//   @override
//   void dispose() {
//     _pulseController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleRetry() async {
//     setState(() => _isRetrying = true);
//     await widget.onRetry();
//     if (mounted) setState(() => _isRetrying = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Color.fromRGBO(0, 0, 0, 0.15),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // ── Animated icon ──
//           ScaleTransition(
//             scale: _pulseAnimation,
//             child: Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: const Color(0xffED1C24).withValues(alpha: 0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.wifi_off_rounded,
//                 size: 44,
//                 color: Color(0xffED1C24),
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),

//           // ── Title ──
//           const Text(
//             'No Internet Connection',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//               color: Color(0xff1A1A1A),
//               fontFamily: 'Gotham',
//             ),
//           ),
//           const SizedBox(height: 10),

//           // ── Subtitle ──
//           const Text(
//             'Please check your Wi-Fi or mobile data\nand try again.',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 13,
//               color: Color(0xff77777E),
//               height: 1.5,
//               fontFamily: 'Gotham',
//             ),
//           ),
//           const SizedBox(height: 28),

//           // ── Open Wi-Fi Settings button ──
//           SizedBox(
//             width: double.infinity,
//             height: 48,
//             child: ElevatedButton.icon(
//               onPressed: widget.onOpenSettings,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xffED1C24),
//                 foregroundColor: Colors.white,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               icon: const Icon(Icons.settings_rounded, size: 18),
//               label: const Text(
//                 'Open Wi-Fi Settings',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   fontFamily: 'Gotham',
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),

//           // ── Retry button ──
//           SizedBox(
//             width: double.infinity,
//             height: 48,
//             child: OutlinedButton.icon(
//               onPressed: _isRetrying ? null : _handleRetry,
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: const Color(0xffED1C24),
//                 side: const BorderSide(color: Color(0xffED1C24), width: 1.5),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               icon: _isRetrying
//                   ? const SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Color(0xffED1C24),
//                       ),
//                     )
//                   : const Icon(Icons.refresh_rounded, size: 18),
//               label: Text(
//                 _isRetrying ? 'Checking...' : 'Retry',
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   fontFamily: 'Gotham',
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NetworkService extends GetxService {
  final RxBool isConnected = true.obs;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _dialogShowing = false;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _listenToConnectivityChanges();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<void> _checkInitialConnection() async {
    try {
      final result = await Connectivity().checkConnectivity();
      final connected = _isOnline(result);
      isConnected.value = connected;
      if (!connected) {
        Future.delayed(
            const Duration(milliseconds: 500), _showNoInternetDialog);
      }
    } catch (_) {
      // If we can't even check, assume connected
    }
  }

  void _listenToConnectivityChanges() {
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final connected = _isOnline(results);

      if (connected && !isConnected.value) {
        isConnected.value = true;
        _dismissDialog();
      } else if (!connected && isConnected.value) {
        isConnected.value = false;
        _showNoInternetDialog();
      }
    });
  }

  bool _isOnline(List<ConnectivityResult> results) {
    return results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);
  }

  void _dismissDialog() {
    if (_dialogShowing && Get.isDialogOpen == true) {
      Get.back();
      _dialogShowing = false;
    }
  }

  void _showNoInternetDialog() {
    if (_dialogShowing) return;
    _dialogShowing = true;

    Get.dialog(
      barrierDismissible: false,
      PopScope(
        canPop: false,
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: _NoInternetDialogContent(
            onRetry: () async {
              final result = await Connectivity().checkConnectivity();
              if (_isOnline(result)) {
                isConnected.value = true;
                _dialogShowing = false;
                Get.back();
              }
            },
            onOpenSettings: () {
              _openWifiSettings();
            },
          ),
        ),
      ),
    ).then<void>((_) {
      _dialogShowing = false;
    });
  }

  void _openWifiSettings() {
    const MethodChannel channel = MethodChannel('baltra/settings');
    try {
      channel.invokeMethod('openWifiSettings');
    } catch (_) {
      Get.snackbar(
        'Open Settings',
        'Please go to Settings → Wi-Fi / Mobile Data and enable your connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xffED1C24),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        icon: const Icon(Icons.wifi_off, color: Colors.white),
      );
    }
  }
}

class _NoInternetDialogContent extends StatefulWidget {
  final Future<void> Function() onRetry;
  final VoidCallback onOpenSettings;

  const _NoInternetDialogContent({
    required this.onRetry,
    required this.onOpenSettings,
  });

  @override
  State<_NoInternetDialogContent> createState() =>
      _NoInternetDialogContentState();
}

class _NoInternetDialogContentState extends State<_NoInternetDialogContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation =
        Tween<double>(begin: 0.9, end: 1.05).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleRetry() async {
    setState(() => _isRetrying = true);
    await widget.onRetry();
    if (mounted) setState(() => _isRetrying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xffED1C24).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 44,
                color: Color(0xffED1C24),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Internet Connection',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xff1A1A1A),
              fontFamily: 'Gotham',
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Please check your Wi-Fi or mobile data\nand try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xff77777E),
              height: 1.5,
              fontFamily: 'Gotham',
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: widget.onOpenSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffED1C24),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.settings_rounded, size: 18),
              label: const Text(
                'Open Wi-Fi Settings',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Gotham',
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _isRetrying ? null : _handleRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xffED1C24),
                side: const BorderSide(color: Color(0xffED1C24), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isRetrying
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xffED1C24),
                      ),
                    )
                  : const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                _isRetrying ? 'Checking...' : 'Retry',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Gotham',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
