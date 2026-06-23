import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:baltra/core/utils/constants.dart';
import 'package:baltra/features/applicationCare/data/productRepository.dart';
import 'package:baltra/features/authetication/presentation/pages/buttomNavbar.dart';
import 'package:baltra/features/authetication/presentation/widgets/textform.dart';
import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/myProductController.dart';

// Custom Result Dialog
class CustomResultDialog extends StatelessWidget {
  final String title;
  final String message;
  final bool isSuccess;
  final VoidCallback onConfirm;

  const CustomResultDialog({
    super.key,
    required this.title,
    required this.message,
    required this.isSuccess,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB((0.2 * 255).round(), 0, 0, 0),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
              size: 50,
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess ? Colors.green : Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool _hasCameraPermission = false;
  bool _isProcessing = false;
  bool _isSimulator = false;
  StreamSubscription<Barcode>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _checkIfSimulator().then((_) => _checkCameraPermission());
  }

  Future<void> _checkIfSimulator() async {
    if (kIsWeb) {
      _isSimulator = true;
      setState(() {});
      return;
    }
    if (Platform.isIOS) {
      final deviceInfo = await DeviceInfoPlugin().iosInfo;
      _isSimulator = !deviceInfo.isPhysicalDevice;
    } else {
      _isSimulator = false; // Assume Android devices are physical
    }
    log('Simulator check: _isSimulator = $_isSimulator');
    setState(() {});
  }

  Future<void> _checkCameraPermission() async {
    log('=== CAMERA PERMISSION CHECK START ===');

    // Skip permission check for iOS simulator
    if (_isSimulator && Platform.isIOS) {
      log('Running on iOS Simulator - Camera not available');
      setState(() {
        _hasCameraPermission = false;
      });
      return;
    }

    try {
      // Check current permission status
      var cameraStatus = await Permission.camera.status;
      log('Initial camera permission status: $cameraStatus');

      // Force permission request if not granted or limited
      if (!cameraStatus.isGranted && !cameraStatus.isLimited) {
        log('Requesting camera permission...');
        cameraStatus = await Permission.camera.request();
        log('New camera permission status: $cameraStatus');
      }

      if (cameraStatus.isGranted || cameraStatus.isLimited) {
        setState(() {
          _hasCameraPermission = true;
        });
        log('Camera permission granted');
        controller?.resumeCamera();
      } else if (cameraStatus.isDenied) {
        log('Camera permission denied');
        if (mounted) {
          _showPermissionSnackBar(
              'Camera permission is required to scan QR codes. Please try again.');
        }
      } else if (cameraStatus.isPermanentlyDenied ||
          cameraStatus.isRestricted) {
        log('Camera permission permanently denied or restricted');
        if (mounted) {
          _showSettingsDialog();
        }
      } else {
        log('Unexpected camera permission status: $cameraStatus');
        if (mounted) {
          _showPermissionSnackBar(
              'Unexpected permission status. Please try again or check device settings.');
        }
      }
    } catch (e) {
      log('Error checking camera permission: $e');
      if (mounted) {
        _showPermissionSnackBar('Error checking camera permission: $e');
      }
    }

    log('=== CAMERA PERMISSION CHECK END ===');
  }

  void _showPermissionSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => _checkCameraPermission(),
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
          'Camera permission is needed to scan QR codes. Please enable it in your device settings.\n\n'
          'If you don\'t see the camera permission option:\n'
          '- On iOS: Go to Settings > General > Reset > Reset Location & Privacy, then reinstall the app.\n'
          '- On Android: Go to Settings > Apps > [Your App Name] > Storage > Clear Data, or reinstall the app.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final opened = await openAppSettings();
              log('App settings opened for camera: $opened');
              Future.delayed(const Duration(milliseconds: 500), () {
                _checkCameraPermission();
              });
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // TEST METHOD FOR SIMULATOR - Remove in production
  void _simulateQRScan() {
    if (!_isSimulator) return;

    const testQRData =
        'https://example.com?model_name=TestModel&model_number=TM123&serial_number=SN456789';

    try {
      Uri uri = Uri.parse(testQRData);
      Map<String, String> queryParams = uri.queryParameters;

      if (queryParams.containsKey('model_name') &&
          queryParams.containsKey('model_number') &&
          queryParams.containsKey('serial_number')) {
        String? param1 = queryParams['model_name'];
        String? param2 = queryParams['model_number'];
        String? param3 = queryParams['serial_number'];

        log('Simulated QR scan - model_name: $param1, model_number: $param2, serial_number: $param3');
        _navigateToResultScreen(param1, param2, param3);
      }
    } catch (e) {
      log('Simulation error: $e');
      _showError('Simulation failed: $e');
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    // controller?.dispose() removed — QRViewController self-disposes when QRView is unmounted
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            const AppBarWithSVG(
              backbutton: true,
              subtitle: 'Scan the QR code from package to add product',
              title: 'Scan to Add',
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildCameraView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    // Show simulator message
    if (_isSimulator && Platform.isIOS) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.phone_iphone,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              'iOS Simulator Detected',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Camera is not available in iOS Simulator.\nPlease test on a real iOS device.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _simulateQRScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text(
                'Simulate QR Scan (Test Only)',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'This button is for testing only\nand will be removed in production',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        ),
      );
    }

    // Show permission denied or checking state
    if (!_hasCameraPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              'Camera Permission Required',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please grant camera permission to scan QR codes.\nIf the permission option is missing, try reinstalling the app or resetting permissions in device settings.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkCameraPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text(
                'Request Permission',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    // Show camera view
    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        width: MediaQuery.of(context).size.width * 0.8,
        child: QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
            borderColor: Theme.of(context).primaryColor,
            borderRadius: 10,
            borderLength: 30,
            borderWidth: 10,
            cutOutSize: MediaQuery.of(context).size.width * 0.7,
          ),
          onPermissionSet: (controller, hasPermission) {
            log('QR View permission set: $hasPermission');
            if (!hasPermission) {
              setState(() {
                _hasCameraPermission = false;
              });
              _checkCameraPermission();
            }
          },
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    log('QR View created successfully');

    // Ensure camera is paused if permission is not granted
    if (!_hasCameraPermission) {
      controller.pauseCamera();
      _checkCameraPermission();
      return;
    }

    _scanSubscription = controller.scannedDataStream.listen((scanData) {
      if (_isProcessing || !mounted) return;

      setState(() {
        result = scanData;
        _isProcessing = true;
        log('QR DATA SCANNED: ${result!.code.toString()}');
      });

      String scannedUrl = scanData.code ?? '';

      if (scannedUrl.isNotEmpty) {
        try {
          Uri uri = Uri.parse(scannedUrl);
          Map<String, String> queryParams = uri.queryParameters;

          if (queryParams.containsKey('model_name') &&
              queryParams.containsKey('model_number') &&
              queryParams.containsKey('serial_number')) {
            String? param1 = queryParams['model_name'];
            String? param2 = queryParams['model_number'];
            String? param3 = queryParams['serial_number'];

            log('Extracted params - model_name: $param1, model_number: $param2, serial_number: $param3');

            controller.pauseCamera();
            Navigator.pop(context);
            _navigateToResultScreen(param1, param2, param3);
          } else {
            throw FormatException("Missing required parameters in QR code.");
          }
        } catch (e) {
          log('QR parsing error: $e');
          _showError(
              "Invalid QR Code format. Please scan a valid Baltra product QR code.");
          _resetProcessing();
        }
      } else {
        _showError("QR Code is empty. Please try again.");
        _resetProcessing();
      }
    });

    // Resume camera if permission is granted
    if (_hasCameraPermission) {
      controller.resumeCamera();
    }
  }

  void _resetProcessing() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        controller?.resumeCamera();
      }
    });
  }

  void _navigateToResultScreen(String? param1, String? param2, String? param3) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          model_name: param1,
          model_num: param2,
          serial_number: param3,
        ),
      ),
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

class ResultScreen extends StatefulWidget {
  final String? model_name;
  final String? model_num;
  final String? serial_number;

  const ResultScreen({
    super.key,
    required this.model_name,
    required this.model_num,
    required this.serial_number,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _purchaseDateController = TextEditingController();
  final _warrantyIssueDateController = TextEditingController();
  final _warrantyExpireDateController = TextEditingController();
  final TextEditingController storeName = TextEditingController();
  final TextEditingController storeLocation = TextEditingController();
  final TextEditingController storePhone = TextEditingController();
  final TextEditingController modelNameController = TextEditingController();
  final TextEditingController modelNumController = TextEditingController();
  final TextEditingController serialNumberController = TextEditingController();
  final _picker = ImagePicker();

  final List<File?> _images = List.filled(3, null);
  bool _isLoading = false;

  // Future<bool> _checkPhotoPermission() async {
  //   log('=== PHOTO PERMISSION CHECK START ===');
  //   try {
  //     var photoStatus = await Permission.photos.status;
  //     log('Initial photo permission status: $photoStatus');

  //     if (photoStatus.isGranted || photoStatus.isLimited) {
  //       log('Photo permission already granted');
  //       return true;
  //     } else {
  //       log('Requesting photo permission...');
  //       photoStatus = await Permission.photos.request();
  //       log('New photo permission status: $photoStatus');

  //       if (photoStatus.isGranted || photoStatus.isLimited) {
  //         log('Photo permission granted after request');
  //         return true;
  //       } else if (photoStatus.isDenied) {
  //         log('Photo permission denied');
  //         if (mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: const Text('Photo library access is required to upload images. Please try again.'),
  //               backgroundColor: Colors.red,
  //               behavior: SnackBarBehavior.floating,
  //               duration: const Duration(seconds: 5),
  //               action: SnackBarAction(
  //                 label: 'Retry',
  //                 textColor: Colors.white,
  //                 onPressed: () => _checkPhotoPermission(),
  //               ),
  //             ),
  //           );
  //         }
  //         return false;
  //       } else if (photoStatus.isPermanentlyDenied || photoStatus.isRestricted) {
  //         log('Photo permission permanently denied or restricted');
  //         if (mounted) {
  //           _showPhotoSettingsDialog();
  //         }
  //         return false;
  //       } else {
  //         log('Unexpected photo permission status: $photoStatus');
  //         if (mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: const Text('Unexpected permission status. Please try again or check device settings.'),
  //               backgroundColor: Colors.red,
  //               behavior: SnackBarBehavior.floating,
  //               duration: const Duration(seconds: 5),
  //             ),
  //           );
  //         }
  //         return false;
  //       }
  //     }
  //   } catch (e) {
  //     log('Error checking photo permission: $e');
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error checking photo permission: $e'),
  //           backgroundColor: Colors.red,
  //           behavior: SnackBarBehavior.floating,
  //           duration: const Duration(seconds: 5),
  //         ),
  //       );
  //     }
  //     return false;
  //   } finally {
  //     log('=== PHOTO PERMISSION CHECK END ===');
  //   }
  // }
  Future<bool> _checkPhotoPermission() async {
    log('=== PHOTO PERMISSION CHECK START ===');
    try {
      PermissionStatus photoStatus;
      if (Platform.isAndroid) {
        // For Android 13+, use Permission.photos; otherwise, use Permission.storage
        if (await DeviceInfoPlugin()
            .androidInfo
            .then((info) => info.version.sdkInt >= 33)) {
          photoStatus = await Permission.photos.status;
          log('Checking Permission.photos for Android 13+: $photoStatus');
          if (!photoStatus.isGranted && !photoStatus.isLimited) {
            photoStatus = await Permission.photos.request();
            log('Requested Permission.photos: $photoStatus');
          }
        } else {
          photoStatus = await Permission.storage.status;
          log('Checking Permission.storage for Android < 13: $photoStatus');
          if (!photoStatus.isGranted && !photoStatus.isLimited) {
            photoStatus = await Permission.storage.request();
            log('Requested Permission.storage: $photoStatus');
          }
        }
      } else {
        // iOS: Use Permission.photos
        photoStatus = await Permission.photos.status;
        log('Checking Permission.photos for iOS: $photoStatus');
        if (!photoStatus.isGranted && !photoStatus.isLimited) {
          photoStatus = await Permission.photos.request();
          log('Requested Permission.photos for iOS: $photoStatus');
        }
      }

      if (photoStatus.isGranted || photoStatus.isLimited) {
        log('Photo permission granted');
        return true;
      } else if (photoStatus.isDenied) {
        log('Photo permission denied');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Photo library access is required to upload images. Please try again.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => _checkPhotoPermission(),
              ),
            ),
          );
        }
        return false;
      } else if (photoStatus.isPermanentlyDenied || photoStatus.isRestricted) {
        log('Photo permission permanently denied or restricted');
        if (mounted) {
          _showPhotoSettingsDialog();
        }
        return false;
      } else {
        log('Unexpected photo permission status: $photoStatus');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Unexpected permission status. Please try again or check device settings.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return false;
      }
    } catch (e) {
      log('Error checking photo permission: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking photo permission: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return false;
    } finally {
      log('=== PHOTO PERMISSION CHECK END ===');
    }
  }

  void _showPhotoSettingsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Photo Library Permission Required'),
        content: const Text(
          'Photo library access is needed to upload images. Please enable it in your device settings.\n\n'
          'If you don\'t see the photo permission option:\n'
          '- On iOS: Go to Settings > General > Reset > Reset Location & Privacy, then reinstall the app.\n'
          '- On Android: Go to Settings > Apps > [Your App Name] > Storage > Clear Data, or reinstall the app.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final opened = await openAppSettings();
              log('App settings opened for photo permission: $opened');
              Future.delayed(const Duration(milliseconds: 500), () {
                _checkPhotoPermission();
              });
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _openImagePicker(int index, ImageSource source) async {
    // Check photo permission before picking image
    final hasPermission = await _checkPhotoPermission();
    if (!hasPermission) {
      log('Image picking aborted due to lack of photo permission');
      return;
    }

    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (pickedImage != null) {
        setState(() {
          _images[index] = File(pickedImage.path);
        });
        log('Image picked for index $index: ${pickedImage.path}');
      } else {
        log('No image selected');
      }
    } catch (e) {
      log('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showImageSourceDialogForIndex(int index) {
    if (Platform.isIOS) {
      showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: const Text('Select Image Source'),
          message: const Text('Choose Camera or Gallery'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _openImagePicker(index, ImageSource.camera);
              },
              child: const Text('Camera'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _openImagePicker(index, ImageSource.gallery);
              },
              child: const Text('Gallery'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Select Image Source',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose Camera or Gallery to upload the image.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _openImagePicker(index, ImageSource.camera);
                  },
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _openImagePicker(index, ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    modelNumController.text = widget.model_num ?? '';
    modelNameController.text = widget.model_name ?? '';
    serialNumberController.text = widget.serial_number ?? '';

    log('ResultScreen initialized with:');
    log('Model Name: ${widget.model_name}');
    log('Model Number: ${widget.model_num}');
    log('Serial Number: ${widget.serial_number}');
  }

  final Myproductcontroller myproductcontroller =
      Get.put(Myproductcontroller(productRepository: MyProductRepository()));

  Future<void> submitForm() async {
    // Validate required fields
    if (storeName.text.isEmpty ||
        storeLocation.text.isEmpty ||
        storePhone.text.isEmpty ||
        _purchaseDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      log("Submitting product form...");
      log('Store Name: ${storeName.text}');
      log('Store Location: ${storeLocation.text}');
      log('Store Phone: ${storePhone.text}');
      log('Purchase Date: ${_purchaseDateController.text}');
      log('Model Name: ${modelNameController.text}');
      log('Model Number: ${modelNumController.text}');
      log('Serial Number: ${serialNumberController.text}');

      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      var request =
          http.MultipartRequest('POST', Uri.parse('$URL/stocks/myproduct'));

      // Add images if selected
      if (_images[0] != null) {
        var productImage = await http.MultipartFile.fromPath(
            'product_image', _images[0]!.path);
        request.files.add(productImage);
        log('Product image added');
      }
      if (_images[1] != null) {
        var warrantyImage = await http.MultipartFile.fromPath(
            'warranty_image', _images[1]!.path);
        request.files.add(warrantyImage);
        log('Warranty image added');
      }
      if (_images[2] != null) {
        var billImage = await http.MultipartFile.fromPath(
            'bill_image_one', _images[2]!.path);
        request.files.add(billImage);
        log('Bill image added');
      }

      // Add form fields
      request.fields['store_name'] = storeName.text;
      request.fields['store_location'] = storeLocation.text;
      request.fields['store_number'] = storePhone.text;
      request.fields['model_num'] = modelNumController.text;
      request.fields['model_name'] = modelNameController.text;
      request.fields['serial_number'] = serialNumberController.text;
      request.fields['purchase_date'] = _purchaseDateController.text;
      request.fields['warranty_issue'] = _warrantyIssueDateController.text;
      request.fields['warranty_expiry'] = _warrantyExpireDateController.text;

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

      log('Sending request to: ${request.url}');
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      log('Response Status Code: ${response.statusCode}');
      log('Response Body: $responseBody');

      final data = jsonDecode(responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => CustomResultDialog(
              title: 'Success!',
              message: 'Your product has been added successfully.',
              isSuccess: true,
              onConfirm: () {
                myproductcontroller.fetchMyProduct();
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ButtomNavBar(pageno: 2)),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          );
        }
      } else {
        String errorMessage = 'Failed to add product';

        if (data != null && data['message'] != null) {
          String apiMessage = data['message'].toString();
          if (apiMessage.contains('serial_number') &&
              apiMessage.contains('already exists')) {
            errorMessage =
                "This product is already registered by another customer";
          } else {
            errorMessage = apiMessage;
          }
        }

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => CustomResultDialog(
              title: 'Failed!',
              message: errorMessage,
              isSuccess: false,
              onConfirm: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ButtomNavBar(pageno: 2)),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          );
        }
      }
    } catch (e) {
      log('Error submitting form: $e');
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => CustomResultDialog(
            title: 'Error!',
            message: 'An error occurred: ${e.toString()}',
            isSuccess: false,
            onConfirm: () {
              Navigator.pop(context);
            },
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    storeName.dispose();
    storeLocation.dispose();
    storePhone.dispose();
    _purchaseDateController.dispose();
    _warrantyIssueDateController.dispose();
    _warrantyExpireDateController.dispose();
    modelNameController.dispose();
    modelNumController.dispose();
    serialNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            const AppBarWithSVG(
              backbutton: true,
              subtitle: 'Add the Baltra products by filling out the form',
              title: 'Add product',
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: storeName,
                        builder: (context, value, child) {
                          return NormalTextField(
                            hint: 'Store Name*',
                            title: 'Store Name*',
                            type: TextInputType.name,
                            controller: storeName,
                          );
                        },
                      ),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: storeLocation,
                        builder: (context, value, child) {
                          return NormalTextField(
                            hint: 'Store Location*',
                            title: 'Store Location*',
                            type: TextInputType.name,
                            controller: storeLocation,
                          );
                        },
                      ),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: storePhone,
                        builder: (context, value, child) {
                          return NormalTextField(
                            hint: 'Store Phone*',
                            title: 'Store Phone*',
                            type: TextInputType.number,
                            controller: storePhone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                          );
                        },
                      ),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: serialNumberController,
                        builder: (context, value, child) {
                          return NormalTextField(
                            hint: 'Serial number',
                            title: 'Serial number',
                            type: TextInputType.name,
                            controller: serialNumberController,
                            readonly: true,
                          );
                        },
                      ),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: modelNameController,
                        builder: (context, value, child) {
                          return NormalTextField(
                            hint: 'Model name',
                            title: 'Model name',
                            type: TextInputType.name,
                            controller: modelNameController,
                            readonly: true,
                          );
                        },
                      ),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: modelNumController,
                        builder: (context, value, child) {
                          return NormalTextField(
                            hint: 'Model number',
                            title: 'Model number',
                            type: TextInputType.name,
                            controller: modelNumController,
                            readonly: true,
                          );
                        },
                      ),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _purchaseDateController,
                        builder: (context, value, child) {
                          return DatePickerField(
                            title: 'Purchase Date*',
                            hint: 'Select purchase date',
                            controller: _purchaseDateController,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text('Product Image (Optional)',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      GestureDetector(
                        onTap: () => _showImageSourceDialogForIndex(0),
                        child: Container(
                          margin: const EdgeInsets.only(top: 10),
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: _images[0] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(_images[0]!,
                                      fit: BoxFit.cover),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo,
                                        size: 40, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Upload Product Image',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 16)),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text('Warranty Card Image (Optional)',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      GestureDetector(
                        onTap: () => _showImageSourceDialogForIndex(1),
                        child: Container(
                          margin: const EdgeInsets.only(top: 10),
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: _images[1] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(_images[1]!,
                                      fit: BoxFit.cover),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo,
                                        size: 40, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Upload Warranty Card Image',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 16)),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text('Bill Image (Optional)',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      GestureDetector(
                        onTap: () => _showImageSourceDialogForIndex(2),
                        child: Container(
                          margin: const EdgeInsets.only(top: 10),
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: _images[2] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(_images[2]!,
                                      fit: BoxFit.cover),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo,
                                        size: 40, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Upload Bill Image',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 16)),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Submit Button
                      GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () async {
                                await submitForm();
                              },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 15),
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _isLoading
                                ? Colors.grey
                                : Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Add Product',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
