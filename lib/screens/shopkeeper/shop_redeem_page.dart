// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
//
// class ShopRedeemScreen extends StatefulWidget {
//   const ShopRedeemScreen({super.key});
//   @override
//   State<ShopRedeemScreen> createState() => _ShopRedeemScreenState();
// }
//
// class _ShopRedeemScreenState extends State<ShopRedeemScreen> {
//   final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
//   late QRViewController _controller;
//   bool _hasScanned = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Redeem Code Section'),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             flex: 8,
//             child: QRView(
//               key: _qrKey,
//               onQRViewCreated: _onQRViewCreated,
//             ),
//           ),
//           Expanded(
//             flex: 1,
//             child: Center(
//               child: const Text(
//                 "Scan QR code",
//                 style: TextStyle(fontSize: 20),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Function to handle QR view creation
//   void _onQRViewCreated(QRViewController controller) {
//     _controller = controller;
//     controller.scannedDataStream.listen((scanData) async {
//       if (_hasScanned) return; // Prevent multiple scans
//       _hasScanned = true;
//
//       debugPrint("[DEBUG] Scanned QR Code: ${scanData.code}");
//
//       try {
//         final qrData = jsonDecode(scanData.code ?? "{}");
//         final uniqueCode = qrData['unique_code'] ?? "";
//         final phoneNumber = qrData['phone_number'] ?? "";
//
//         debugPrint("[DEBUG] Extracted unique_code: $uniqueCode");
//         debugPrint("[DEBUG] Extracted phone_number: $phoneNumber");
//
//         // Display scanned data in a dialog
//         await showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text("Scanned QR Code"),
//             content: Text("Unique Code: $uniqueCode\nPhone Number: $phoneNumber"),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   _sendDataToApi(uniqueCode, phoneNumber); // Trigger API call after dialog dismissal
//                 },
//                 child: const Text("OK"),
//               ),
//             ],
//           ),
//         );
//       } catch (e) {
//         debugPrint("[ERROR] Failed to parse QR code: $e");
//         Fluttertoast.showToast(msg: "Invalid QR code");
//         _hasScanned = false; // Reset for next scan
//       }
//     });
//   }
//
//   // Function to send data to API
//   Future<void> _sendDataToApi(String uniqueCode, String phoneNumber) async {
//     final apiUrl = Uri.parse('https://syntaxium.in/DUSTBIN_API/shop_redeem_code.php');
//
//     debugPrint("[DEBUG] Sending data to API: {unique_code: $uniqueCode, phone_number: $phoneNumber}");
//
//     try {
//       final response = await http.post(
//         apiUrl,
//         headers: {
//           'Content-Type': 'application/x-www-form-urlencoded',
//         },
//         body: {
//           'unique_code': uniqueCode,
//           'phone_number': phoneNumber,
//         },
//       );
//
//       debugPrint("[DEBUG] API Request Body: unique_code=$uniqueCode&phone_number=$phoneNumber");
//       debugPrint("[DEBUG] API Response: ${response.statusCode} ${response.body}");
//
//       if (response.statusCode == 200) {
//         Fluttertoast.showToast(msg: response.body);
//       } else {
//         Fluttertoast.showToast(msg: "Redeem failed: ${response.statusCode}");
//       }
//     } catch (e) {
//       debugPrint("[ERROR] API request failed: $e");
//       Fluttertoast.showToast(msg: "Network error");
//     } finally {
//       _hasScanned = false; // Reset for next scan
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class ShopRedeemScreen extends StatefulWidget {
  const ShopRedeemScreen({super.key});
  @override
  State<ShopRedeemScreen> createState() => _ShopRedeemScreenState();
}

class _ShopRedeemScreenState extends State<ShopRedeemScreen> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController _controller;
  bool _hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Redeem Code Section'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 8,
            child: QRView(
              key: _qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: const Text(
                "Scan QR code",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to handle QR view creation
  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (_hasScanned) return; // Prevent multiple scans
      _hasScanned = true;

      debugPrint("[DEBUG] Scanned QR Code: ${scanData.code}");

      try {
        final qrData = jsonDecode(scanData.code ?? "{}");
        final uniqueCode = qrData['unique_code'] ?? "";
        final phoneNumber = qrData['phone_number'] ?? "";

        debugPrint("[DEBUG] Extracted unique_code: $uniqueCode");
        debugPrint("[DEBUG] Extracted phone_number: $phoneNumber");

        _controller.dispose();
        super.dispose();


        // Navigate to product details page and pass the unique code and phone number
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
              uniqueCode: uniqueCode,
              phoneNumber: phoneNumber,
            ),
          ),
        );
      } catch (e) {
        debugPrint("[ERROR] Failed to parse QR code: $e");
        Fluttertoast.showToast(msg: "Invalid QR code");
        _hasScanned = false; // Reset for next scan
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}


class ProductDetailsPage extends StatefulWidget {
  final String uniqueCode;
  final String phoneNumber;

  const ProductDetailsPage({super.key, required this.uniqueCode, required this.phoneNumber});

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late String productName;
  late String productBrand;
  late String productDescription;
  late String productPrice;
  late String productImagePath;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProductDetails(widget.uniqueCode);
  }

  Future<void> _fetchProductDetails(String uniqueCode) async {
    final apiUrl = Uri.parse(
        'https://syntaxium.in/DUSTBIN_API/shopkeeper_product_detail_qr_scan.php?unique_code=$uniqueCode');

    try {
      final response = await http.get(apiUrl);

      debugPrint("[DEBUG] Product Details API Response: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (!responseData['error']) {
          final productDetails = responseData['product_details'];
          setState(() {
            productName = productDetails['product_name'];
            productBrand = productDetails['product_brand'];
            productDescription = productDetails['product_description'];
            productPrice = productDetails['discounted_price'].toString();
            productImagePath = productDetails['product_photo_path'];
            isLoading = false;
          });
        } else {
          Fluttertoast.showToast(msg: "Failed to fetch product details.");
          setState(() {
            isLoading = false;
          });
        }
      } else {
        Fluttertoast.showToast(msg: "Failed to fetch product details: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("[ERROR] Product details fetch failed: $e");
      // Fluttertoast.showToast(msg: "Network error");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _redeemProduct() async {
    final apiUrl = Uri.parse('https://syntaxium.in/DUSTBIN_API/shop_redeem_code.php');

    try {
      final response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'unique_code': widget.uniqueCode,
          'phone_number': widget.phoneNumber,
        },
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Redeem Successful");
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(msg: "Redeem failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("[ERROR] API request failed: $e");
      Fluttertoast.showToast(msg: "Network error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        "Brand: $productBrand",
                        style: const TextStyle(fontSize: 18.0),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        productDescription,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        "Price: ₹$productPrice",
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: productImagePath.isNotEmpty
                              ? FadeInImage.assetNetwork(
                            placeholder: 'assets/placeholder.png', // Local placeholder image
                            image: 'https://syntaxium.in/$productImagePath',
                            width: 250,
                            height: 250,
                            fit: BoxFit.cover,
                            imageErrorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.broken_image,
                              size: 100,
                              color: Colors.green,
                            ),
                          )
                              : const Icon(
                            Icons.image_not_supported,
                            size: 100,
                            color: Colors.green,
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _redeemProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  'Redeem',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
// class ShopRedeemScreen extends StatefulWidget {
//   const ShopRedeemScreen({super.key});
//   @override
//   State<ShopRedeemScreen> createState() => _ShopRedeemScreenState();
// }
// class _ShopRedeemScreenState extends State<ShopRedeemScreen> {
//   final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
//   late QRViewController _controller;
//   bool _hasScanned = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Redeem Code Section'),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             flex: 8,
//             child: QRView(
//               key: _qrKey,
//               onQRViewCreated: _onQRViewCreated,
//             ),
//           ),
//           Expanded(
//             flex: 1,
//             child: Center(
//               child: const Text(
//                 "Scan QR code",
//                 style: TextStyle(fontSize: 20),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Function to handle QR view creation
//   void _onQRViewCreated(QRViewController controller) {
//     _controller = controller;
//     controller.scannedDataStream.listen((scanData) async {
//       if (_hasScanned) return; // Prevent multiple scans
//       _hasScanned = true;
//
//       debugPrint("[DEBUG] Scanned QR Code: ${scanData.code}");
//
//       try {
//         final qrData = jsonDecode(scanData.code ?? "{}");
//         final uniqueCode = qrData['unique_code'] ?? "";
//         final phoneNumber = qrData['phone_number'] ?? "";
//
//         debugPrint("[DEBUG] Extracted unique_code: $uniqueCode");
//         debugPrint("[DEBUG] Extracted phone_number: $phoneNumber");
//
//         // Display scanned data in a dialog
//         await showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text("Scanned QR Code"),
//             content: Text("Unique Code: $uniqueCode\nPhone Number: $phoneNumber"),
//             actions: [
//               TextButton(
//                 onPressed: () async {
//                   Navigator.of(context).pop();
//                   _sendDataToApi(uniqueCode, phoneNumber); // Trigger API call after dialog dismissal
//                   // Now, fetch product details using the unique code
//                   await _fetchProductDetails(uniqueCode);
//                 },
//                 child: const Text("OK"),
//               ),
//             ],
//           ),
//         );
//       } catch (e) {
//         debugPrint("[ERROR] Failed to parse QR code: $e");
//         Fluttertoast.showToast(msg: "Invalid QR code");
//         _hasScanned = false; // Reset for next scan
//       }
//     });
//   }
//
//   // Function to send data to the first API (shop_redeem_code.php)
//   Future<void> _sendDataToApi(String uniqueCode, String phoneNumber) async {
//     final apiUrl = Uri.parse('https://syntaxium.in/DUSTBIN_API/shop_redeem_code.php');
//
//     debugPrint("[DEBUG] Sending data to API: {unique_code: $uniqueCode, phone_number: $phoneNumber}");
//
//     try {
//       final response = await http.post(
//         apiUrl,
//         headers: {
//           'Content-Type': 'application/x-www-form-urlencoded',
//         },
//         body: {
//           'unique_code': uniqueCode,
//           'phone_number': phoneNumber,
//         },
//       );
//
//       debugPrint("[DEBUG] API Request Body: unique_code=$uniqueCode&phone_number=$phoneNumber");
//       debugPrint("[DEBUG] API Response: ${response.statusCode} ${response.body}");
//
//       if (response.statusCode == 200) {
//         // Show a dialog on successful API response
//         await showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text("Redeem Successful"),
//             content: Text(response.body),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: const Text("OK"),
//               ),
//             ],
//           ),
//         );
//
//         // // Now, fetch product details using the unique code
//         // await _fetchProductDetails(uniqueCode);
//       } else {
//         Fluttertoast.showToast(msg: "Redeem failed: ${response.statusCode}");
//       }
//     } catch (e) {
//       debugPrint("[ERROR] API request failed: $e");
//       Fluttertoast.showToast(msg: "Network error");
//     } finally {
//       _hasScanned = false; // Reset for next scan
//     }
//   }
//
//   // Function to fetch product details using the unique code
//   Future<void> _fetchProductDetails(String uniqueCode) async {
//     final apiUrl = Uri.parse('https://syntaxium.in/DUSTBIN_API/shopkeeper_product_detail_qr_scan.php?unique_code=$uniqueCode');
//
//     try {
//       final response = await http.get(apiUrl);
//
//       debugPrint("[DEBUG] Product Details API Response: ${response.statusCode} ${response.body}");
//
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         if (!responseData['error']) {
//           final productDetails = responseData['product_details'];
//           final productName = productDetails['product_name'];
//           final productBrand = productDetails['product_brand'];
//           final productDescription = productDetails['product_description'];
//           final productPrice = productDetails['discounted_price'];
//           final productImagePath = productDetails['product_photo_path'];
//
//           // Show product details in a dialog
//           await showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text("Product Details"),
//               content: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text("Product Name: $productName"),
//                   Text("Brand: $productBrand"),
//                   Text("Description: $productDescription"),
//                   Text("Price: ₹$productPrice"),
//                   SizedBox(
//                     height: 150,
//                     width: 150,
//                     child: Image.network('https://syntaxium.in/$productImagePath'), // Display image
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: const Text("OK"),
//                 ),
//               ],
//             ),
//           );
//         } else {
//           Fluttertoast.showToast(msg: "Failed to fetch product details.");
//         }
//       } else {
//         Fluttertoast.showToast(msg: "Failed to fetch product details: ${response.statusCode}");
//       }
//     } catch (e) {
//       debugPrint("[ERROR] Product details fetch failed: $e");
//       Fluttertoast.showToast(msg: "Network error");
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }
