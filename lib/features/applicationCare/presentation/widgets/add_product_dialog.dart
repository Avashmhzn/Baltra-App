import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:baltra/core/utils/constants.dart';
import 'package:baltra/features/applicationCare/data/productRepository.dart';
import 'package:baltra/features/applicationCare/presentation/ui/application_care_page.dart';
import 'package:baltra/features/authetication/presentation/pages/buttomNavbar.dart';
import 'package:baltra/features/authetication/presentation/widgets/textform.dart';
import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/myProductController.dart';

// Custom Result Dialog (Adapted from CustomDeleteDialog)
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
        width: 350, // Increased width from CustomDeleteDialog
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
              size: 50,
            ),
            const SizedBox(height: 15),
            // Title
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
            // Message
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Buttons (Adapted from CustomDeleteDialog)
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
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
  StreamSubscription<Barcode>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() {
        _hasCameraPermission = true;
      });
    } else {
      final newStatus = await Permission.camera.request();
      if (newStatus.isGranted || newStatus.isLimited) {
        setState(() {
          _hasCameraPermission = true;
        });
      } else if (newStatus.isDenied) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera permission is required to scan QR codes.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else if (newStatus.isPermanentlyDenied) {
        if (mounted) {
          _showSettingsDialog();
        }
      }
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Denied'),
        content: const Text(
            'Camera permission is required to scan QR codes. Please enable it in your device settings.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await openAppSettings();
              final status = await Permission.camera.status;
              if (status.isGranted || status.isLimited) {
                setState(() {
                  _hasCameraPermission = true;
                });
              } else {
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Camera permission is required to scan QR codes.'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        body: _hasCameraPermission
            ? Column(
          children: [
            const AppBarWithSVG(
              backbutton: true,
              subtitle: 'Scan the QR code from package to add product',
              title: ' Scan to Add',
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width * 0.7,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: Theme.of(context).primaryColor,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: 700,
                  ),
                ),
              ),
            ),
          ],
        )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    _scanSubscription = controller.scannedDataStream.listen((scanData) {
      if (_isProcessing || !mounted) return;

      setState(() {
        result = scanData;
        _isProcessing = true;
        log('DATAAAAAA:::::${result!.code.toString()}');
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

            log('param1: $param1');
            log('param2: $param2');
            log('param3: $param3');

            controller.pauseCamera();
            Navigator.pop(context);
            _navigateToResultScreen(param1, param2, param3);
          } else {
            throw FormatException("Missing one or more required keys.");
          }
        } catch (e) {
          log('QR Error: $e');
          _showError("Invalid QR Code. Required data is missing.");
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _isProcessing = false;
              });
            }
          });
        }
      } else {
        _showError("QR Code is empty. Please try again.");
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isProcessing = false;
            });
          }
        });
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

  Future<void> _openImagePicker(int index) async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _images[index] = File(pickedImage.path);
      });
    }
  }

  @override
  void initState() {
    modelNumController.text = widget.model_num ?? '';
    modelNameController.text = widget.model_name ?? '';
    serialNumberController.text = widget.serial_number ?? '';
    super.initState();
  }

  final Myproductcontroller myproductcontroller =
  Get.put(Myproductcontroller(productRepository: MyProductRepository()));

  Future<void> submitForm() async {
    log("adding product.....");
    log(_purchaseDateController.text);
    log(modelNameController.text);
    log(modelNumController.text);
    log(serialNumberController.text);
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    var request = http.MultipartRequest('POST', Uri.parse('$URL/stocks/myproduct'));

    if (_images[0] != null) {
      var productImage = await http.MultipartFile.fromPath('product_image', _images[0]!.path);
      request.files.add(productImage);
    }
    if (_images[1] != null) {
      var warrantyImage = await http.MultipartFile.fromPath('warranty_image', _images[1]!.path);
      request.files.add(warrantyImage);
    }
    if (_images[2] != null) {
      var billImage = await http.MultipartFile.fromPath('bill_image_one', _images[2]!.path);
      request.files.add(billImage);
    }

    request.fields['store_name'] = storeName.text;
    request.fields['store_location'] = storeLocation.text;
    request.fields['store_number'] = storePhone.text;
    request.fields['model_num'] = modelNumController.text;
    request.fields['model_name'] = modelNameController.text;
    request.fields['serial_number'] = serialNumberController.text;
    request.fields['purchase_date'] = _purchaseDateController.text;
    request.fields['warranty_issue'] = _warrantyIssueDateController.text;
    request.fields['warranty_expiry'] = _warrantyExpireDateController.text;

    log('Token:$token');
    request.headers['Authorization'] = 'Bearer $token';
    log('Request:$request');
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    log('RESPONSE: ***********88$responseBody');
    log(response.statusCode.toString());

    final data = jsonDecode(responseBody);
    if (response.statusCode == 200) {
      // Show custom success dialog with CustomDeleteDialog design
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CustomResultDialog(
          title: 'Success!',
          message: 'Your product has been added successfully.',
          isSuccess: true,
          onConfirm: () {
            myproductcontroller.fetchMyProduct();
            Navigator.pop(context); // Close the dialog
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const ButtomNavBar(pageno: 2)),
                  (Route<dynamic> route) => false,
            );
          },
        ),
      );
    } else {
      // Show custom failure dialog with CustomDeleteDialog design
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CustomResultDialog(
          title: 'Failed!',
          message: data['message'] ==
              '{\'serial_number\': [ErrorDetail(string=\'stock with this serial number already exists.\', code=\'unique\')]}'
              ? "This product is already registered by another customer"
              : data['message'],
          isSuccess: false,
          onConfirm: () {
            Navigator.pop(context); // Close the dialog
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const ButtomNavBar(pageno: 2)),
                  (Route<dynamic> route) => false,
            );
          },
        ),
      );
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
                title: ' Add product'),
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
                            hint: 'Store Name',
                            title: 'Store Name',
                            type: TextInputType.name,
                            controller: storeName,
                          );
                        },
                      ),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: storeLocation,
                        builder: (context, value, child) {
                          return NormalTextField(
                            hint: 'Store Location',
                            title: 'Store Location',
                            type: TextInputType.name,
                            controller: storeLocation,
                          );
                        },
                      ),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: storePhone,
                        builder: (context, value, child) {
                          return NormalTextField(
                            hint: 'Store Phone',
                            title: 'Store Phone',
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
                              title: 'Purchase Date',
                              hint: 'Select purchase date',
                              controller: _purchaseDateController,
                            );
                          }),
                      const Text('Product Image'),
                      GestureDetector(
                        onTap: () => _openImagePicker(0),
                        child: Container(
                          margin: const EdgeInsets.only(top: 10),
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[300],
                          child: _images[0] != null
                              ? Image.file(_images[0]!, fit: BoxFit.cover)
                              : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Upload Product Image',
                                  style: TextStyle(color: Colors.grey)),
                              Icon(Icons.add_a_photo),
                            ],
                          ),
                        ),
                      ),
                      const Text('Warranty Card Image'),
                      GestureDetector(
                        onTap: () => _openImagePicker(1),
                        child: Container(
                          margin: const EdgeInsets.only(top: 10),
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[300],
                          child: _images[1] != null
                              ? Image.file(_images[1]!, fit: BoxFit.cover)
                              : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Upload Warranty Card Image',
                                  style: TextStyle(color: Colors.grey)),
                              Icon(Icons.add_a_photo),
                            ],
                          ),
                        ),
                      ),
                      const Text('Bill Image'),
                      GestureDetector(
                        onTap: () => _openImagePicker(2),
                        child: Container(
                          margin: const EdgeInsets.only(top: 10),
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[300],
                          child: _images[2] != null
                              ? Image.file(_images[2]!, fit: BoxFit.cover)
                              : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Upload Bill Image',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Icon(Icons.add_a_photo),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await submitForm();
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 15),
                          width: double.infinity,
                          height: 50,
                          color: Theme.of(context).primaryColor,
                          child: const Center(
                            child: Text(
                              'Add product',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
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