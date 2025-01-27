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
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/myProductController.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppBarWithSVG(
              backbutton: true,
              subtitle: 'Scan the QR code from package to add product',
              title: ' Scan to Add'),
          const SizedBox(
            height: 20,
          ),
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
      ),
    );
  }
  // TODO: changing qr data format

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        log('DATAAAAAA:::::${result!.code.toString()}');
        Navigator.pop(context);
      });
  String scannedUrl = scanData.code ?? '';
   if (scannedUrl.isNotEmpty) {
      Uri uri = Uri.parse(scannedUrl);
       var queryParams = uri.queryParameters;
      
      // Example: Extract specific query parameters
      String? param1 = queryParams['model_name']; // Example parameter
      String? param2 = queryParams['model_number']; // Another parameter
      String? param3 = queryParams['serial_number']; // Another parameter
      // Log or use the query parameters
      log('param1: $param1');
      log('param2: $param2');
      log('param3: $param3');

      _navigateToResultScreen(param1,param2,param3);
  }});
  }

  void _navigateToResultScreen(String? param1,String? param2,String? param3) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen( model_name:  param1, model_num:  param2, serial_number: param3),
      ),
    );
  }
}

class ResultScreen extends StatefulWidget {
  final String? model_name;
  final String? model_num;
  final String? serial_number;

  const ResultScreen({super.key, required this.model_name, required this.model_num, required this.serial_number, });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _purchaseDateController = TextEditingController();
  final _warrantyIssueDateController = TextEditingController();
  final _warrantyExpireDateController = TextEditingController();
  final TextEditingController storeName = TextEditingController();
  final TextEditingController storeLocation = TextEditingController();
  final TextEditingController stroePhone = TextEditingController();
  final TextEditingController model_nameController = TextEditingController();
  final TextEditingController model_numController = TextEditingController();
  final TextEditingController serial_numberController = TextEditingController();
  final _picker = ImagePicker();

  final List<File?> _images = List.filled(3, null);

  Future<void> _openImagePicker(int index) async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _images[index] = File(pickedImage.path);
      });
    }
  }
@override
  void initState() {
      model_numController.text = widget.model_num ?? '';
    model_nameController.text = widget.model_name ?? '';
    serial_numberController.text = widget.serial_number ?? '';
    super.initState();
  }
  final Myproductcontroller myproductcontroller =
      Get.put(Myproductcontroller(productRepository: MyProductRepository()));

  @override
  Widget build(BuildContext context) {
 
    Future<void> submitForm() async {
      log("addding product.....");
      log(_purchaseDateController.text);
          log(model_nameController.text);
    log(model_numController.text);
    log(serial_numberController.text);
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      var request =
          http.MultipartRequest('POST', Uri.parse('$URL/stocks/myproduct'));

      var productImage =
          await http.MultipartFile.fromPath('product_image', _images[0]!.path);
      var warrantyImage =
          await http.MultipartFile.fromPath('warranty_image', _images[1]!.path);

      var billImage =
          await http.MultipartFile.fromPath('bill_image_one', _images[2]!.path);

      // Add other fields
      request.fields['store_name'] = storeName.text;
      request.fields['store_location'] = storeLocation.text;
      request.fields['store_number'] = stroePhone.text;
      request.fields['model_num'] = model_numController.text;
      request.fields['model_name'] =model_nameController.text;
      request.fields['serial_number'] = serial_numberController.text;
      request.fields['purchase_date'] = _purchaseDateController.text;
      request.fields['warranty_issue'] = _warrantyIssueDateController.text;
      request.fields['warranty_expiry'] = _warrantyExpireDateController.text;
      request.files.add(billImage);
      request.files.add(warrantyImage);
      request.files.add(productImage);
      log('Token:$token');
      request.headers['Authorization'] = 'Bearer $token';
      log('Request:$request');
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      log('RESPONSE: ***********88$responseBody');
      log(response.statusCode.toString());

      // var responseString = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);
      if (response.statusCode == 200) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return const ButtomNavBar(
            pageno: 2,
          );
        }));

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success!'),
            content: const Text('Your product has been added successfully.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  myproductcontroller.fetchMyProduct();
                  Navigator.pop(context);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return const ApplicationCarePage();
                  }));
                },
                child: const Text('Go to Application Care'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Failed!'),
            content: Text(data['message'] ==
                    '{\'serial_number\': [ErrorDetail(string=\'stock with this serial number already exists.\', code=\'unique\')]}'
                ? "This product is already registed by another customer"
                : data['message']),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return const ApplicationCarePage();
                  }));
                },
                child: const Text('Go to Application Care'),
              ),
            ],
          ),
        );
      }
    }

    @override
    void dispose() {
      storeName.dispose();
      storeLocation.dispose();
      stroePhone.dispose();
      _purchaseDateController.dispose();
      _warrantyIssueDateController.dispose();
      _warrantyExpireDateController.dispose();
      super.dispose();
    }

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            
            const AppBarWithSVG(
                backbutton: true,
                subtitle: 'Add the Baltra products by filling out the form',
                title: ' Add product'),
            const SizedBox(
              height: 20,
            ),
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
                        valueListenable: stroePhone,
                        builder: (context, value, child) {
                          return NormalTextField(
                            hint: 'Store Phone',
                            title: 'Store Phone',
                            type: TextInputType.name,
                            controller: stroePhone,
                          );
                        },
                      ),
                       ValueListenableBuilder<TextEditingValue>(
                        valueListenable: serial_numberController,
                        builder: (context, value, child) {
                          return NormalTextField(
                            hint: 'Serial number',
                            title: 'Serial number',
                            type: TextInputType.name,
                            controller: serial_numberController,
                          );
                        },
                      ),
                        ValueListenableBuilder<TextEditingValue>(
                        valueListenable: model_nameController,
                        builder: (context, value, child) {
                          return NormalTextField(
                            hint: 'Model name',
                            title: 'Model name',
                            type: TextInputType.name,
                            controller: model_nameController,
                          );
                        },
                      ),
                          ValueListenableBuilder<TextEditingValue>(
                        valueListenable: model_numController,
                        builder: (context, value, child) {
                          return NormalTextField(
                            hint: 'Model number',
                            title: 'Model number',
                            type: TextInputType.name,
                            controller: model_numController,
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
                          margin: const EdgeInsets.only(bottom: 10),
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
                          margin: const EdgeInsets.only(bottom: 10),
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
                          margin: const EdgeInsets.only(bottom: 10),
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

// 