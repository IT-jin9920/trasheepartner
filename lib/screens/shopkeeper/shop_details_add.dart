// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_approval_wait.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ShopDetailsAddScreen extends StatefulWidget {
  const ShopDetailsAddScreen({super.key});

  @override
  ShopDetailsAddScreenState createState() => ShopDetailsAddScreenState();
}

class ShopDetailsAddScreenState extends State<ShopDetailsAddScreen> {
  TextEditingController shopNameController = TextEditingController();
  TextEditingController shopGSTController = TextEditingController();
  TextEditingController shopAddressController = TextEditingController();
  TextEditingController shopPinCodeController = TextEditingController();
  File? shopPhoto;
  bool submitAttempted = false;
  bool isLoading = false;
  int ownerId = 0;
  int uniqueCode = DateTime.now().millisecondsSinceEpoch;
  final String addShopUrl =
      "https://syntaxium.in/DUSTBIN_API/add_shop_details.php";

  @override
  void initState() {
    super.initState();
    _getData();
  }

  final GlobalKey<FormState> shopNameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> shopGstFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> shopAddressFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> shopPinCodeFormKey = GlobalKey<FormState>();

  Future<void> _getData() async {
    var sharedPref = await SharedPreferences.getInstance();
    ownerId = sharedPref.getInt("owner_id")!; // Replace with your actual logic
  }

  Future<void> _takePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    _handleImageSelection(image);
  }

  Future<void> _selectPicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 800,
    );

    _handleImageSelection(image);
  }

  void _handleImageSelection(XFile? image) {
    if (image != null) {
      setState(() {
        shopPhoto = File(image.path);
      });
    }
  }

  String? _validateShopName(String? value) {
    if (submitAttempted && (value == null || value.isEmpty)) {
      return 'Please enter your business name';
    } else if (!RegExp(r'^[a-zA-Z]').hasMatch(value!)) {
      return 'Please enter your business name';
    }
    return null;
  }

  String? _validatePinCode(String? value) {
    if (submitAttempted && (value == null || value.isEmpty)) {
      return 'Please enter your pin code';
    } else if (!RegExp(r'^[1-9]\d{5}$').hasMatch(value!)) {
      return 'Please enter a valid pin code of 6 digits';
    }
    return null;
  }

  String? _validateShopGst(String? value) {
    if (submitAttempted && (value == null || value.isEmpty)) {
      return 'Please enter your gst number';
    }
    return null;
  }

  String? _validateShopAddress(String? value) {
    if (submitAttempted && (value == null || value.isEmpty)) {
      return 'Please enter your shop address';
    } else if (!RegExp(r'^[\s\S]{20,150}$').hasMatch(value!)) {
      return 'Please enter atleast some part of address';
    }
    return null;
  }

  Future<void> _submitShopForm() async {
    setState(() {
      isLoading = true;
    });
    if ((shopNameFormKey.currentState?.validate() ?? false) &&
        (shopGstFormKey.currentState?.validate() ?? false) &&
        (shopAddressFormKey.currentState?.validate() ?? false) &&
        (shopPinCodeFormKey.currentState?.validate() ?? false)) {
      try {
        var request = http.MultipartRequest('POST', Uri.parse(addShopUrl))
          ..headers['Accept'] = 'application/json'
          ..headers["Content-type"] = 'application/x-www-form-urlencoded'
          ..headers["Content-type"] = 'application/form-mulipart';

        request.fields['owner_id'] = ownerId.toString();
        request.fields['shop_name'] = shopNameController.text.toString();
        request.fields['shop_gst'] =
            shopGSTController.text.toString().trim().toUpperCase();
        request.fields['shop_address'] = shopAddressController.text.toString();
        request.fields['shop_unique_code'] = uniqueCode.toString();
        request.fields['pin_code'] = shopPinCodeController.text.toString();
        if (shopPhoto != null) {
          List<int> imageBytes = await shopPhoto!.readAsBytes();

          // Get the file name and content type from the image file
          String fileName = shopPhoto!.path.split('/').last;
          request.files.add(http.MultipartFile.fromBytes(
              'shop_photo', imageBytes,
              filename: fileName,
              // contentType: mediaType,
              contentType: MediaType.parse(lookupMimeType(shopPhoto!.path)!)));
        }

        var response = await request.send();
        var result = jsonDecode(await response.stream.bytesToString());
        if (response.statusCode == 200 && !result["error"]) {
          Fluttertoast.showToast(
            msg: result["message"].toString(),
          );
          // Navigator.pushReplacement(context,
          //     MaterialPageRoute(builder: (context) => const ShopWaitingScreen()));
          Get.offAll(() => const ShopWaitingScreen());
          Future.delayed(const Duration(seconds: 5));

          var sharedPref = await SharedPreferences.getInstance();
          sharedPref.clear();
          Fluttertoast.showToast(msg: "Log Out Successfully");
          Future.delayed(const Duration(seconds: 2));
          Get.offAll(() => const ShopLoginScreen());
        } else {
          Fluttertoast.showToast(
            msg: result["message"].toString(),
          );
          debugPrint(
              'Error during adding shop in else part: ${response.reasonPhrase}');
        }
      } on SocketException catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            debugPrint("Error: $e");
            return AlertDialog(
              title: const Text('Error'),
              content: const Text(
                  'A network error occurred.\nMake sure that your internet is working.'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = false;
                    });
                    Future.delayed(const Duration(seconds: 2));
                    Get.back();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      } catch (error) {
        debugPrint('Error during adding shop in catch: $error');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partnership Signup'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Form(
                onChanged: () {
                  setState(() {
                    isLoading = false;
                  });
                },
                key: shopNameFormKey,
                autovalidateMode: submitAttempted
                    ? AutovalidateMode.always
                    : AutovalidateMode.onUserInteraction,
                child: TextFormField(
                  controller: shopNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                      labelText: 'Business Name',
                      prefixIcon: Icon(Icons.person_add_rounded),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(4.0)))),
                  validator: _validateShopName,
                ),
              ),
              const SizedBox(height: 16),
              Form(
                onChanged: () {
                  setState(() {
                    isLoading = false;
                  });
                },
                key: shopGstFormKey,
                autovalidateMode: submitAttempted
                    ? AutovalidateMode.always
                    : AutovalidateMode.onUserInteraction,
                child: TextFormField(
                  maxLength: 15,
                  controller: shopGSTController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                      labelText: 'Business Gst',
                      prefixIcon: Icon(Icons.person_add_rounded),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(4.0)))),
                  validator: _validateShopGst,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^[0-9A-Z]{0,15}$')), // Restricts input to GST format
                    LengthLimitingTextInputFormatter(15), // Ensures max 15 characters
                    UpperCaseTextFormatter(), // Auto-uppercase input
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Form(
                onChanged: () {
                  setState(() {
                    isLoading = false;
                  });
                },
                key: shopAddressFormKey,
                autovalidateMode: submitAttempted
                    ? AutovalidateMode.always
                    : AutovalidateMode.onUserInteraction,
                child: TextFormField(
                  minLines: 3,
                  maxLines: 5,
                  controller: shopAddressController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                      labelText: 'Business Address',
                      prefixIcon: Icon(Icons.add_location_rounded),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(4.0)))),
                  validator: _validateShopAddress,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Form(
                onChanged: () {
                  setState(() {
                    isLoading = false;
                  });
                },
                key: shopPinCodeFormKey,
                autovalidateMode: submitAttempted
                    ? AutovalidateMode.always
                    : AutovalidateMode.onUserInteraction,
                child: TextFormField(
                  maxLength: 6,
                  controller: shopPinCodeController,
                  decoration: const InputDecoration(
                      labelText: 'Pin Code',
                      prefixIcon: Icon(Icons.pin_drop),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(4.0)))),
                  keyboardType: TextInputType.number,
                  validator: _validatePinCode,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _takePicture,
                    child: const Text('Take Picture'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _selectPicture,
                    child: const Text('Select Picture'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (shopPhoto != null)
                Image.file(
                  shopPhoto!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading ? null : _submitShopForm,
                child: const Text('Submit'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  var sharedPref = await SharedPreferences.getInstance();
                  sharedPref.clear();
                  Fluttertoast.showToast(msg: "Log Out Successfully");
                  Future.delayed(const Duration(seconds: 2));
                  Get.offAll(() => const ShopLoginScreen());
                },
                child: const Text('Logout'),
              ),
              const SizedBox(height: 16),
              if (isLoading) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Convert the text to uppercase
    String newText = newValue.text.toUpperCase();
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}


// import 'dart:convert';
// import 'dart:io';
// import 'package:get/get.dart';
// import 'package:trasheepartner/screens/shopkeeper/shop_approval_wait.dart';
// import 'package:trasheepartner/screens/shopkeeper/shop_login_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:mime/mime.dart';
//
// class ShopDetailsAddScreen extends StatefulWidget {
//   const ShopDetailsAddScreen({super.key});
//
//   @override
//   ShopDetailsAddScreenState createState() => ShopDetailsAddScreenState();
// }
//
// class ShopDetailsAddScreenState extends State<ShopDetailsAddScreen> {
//   TextEditingController shopNameController = TextEditingController();
//   TextEditingController shopGSTController = TextEditingController();
//   TextEditingController shopAddressController = TextEditingController();
//   TextEditingController shopPinCodeController = TextEditingController();
//   File? shopPhoto;
//   bool submitAttempted = false;
//   bool isLoading = false;
//   int ownerId = 0;
//   int uniqueCode = DateTime.now().millisecondsSinceEpoch;
//   final String addShopUrl =
//       "https://syntaxium.in/DUSTBIN_API/add_shop_details.php";
//
//   @override
//   void initState() {
//     super.initState();
//     _getData();
//   }
//
//   final GlobalKey<FormState> shopNameFormKey = GlobalKey<FormState>();
//   final GlobalKey<FormState> shopGstFormKey = GlobalKey<FormState>();
//   final GlobalKey<FormState> shopAddressFormKey = GlobalKey<FormState>();
//   final GlobalKey<FormState> shopPinCodeFormKey = GlobalKey<FormState>();
//
//   Future<void> _getData() async {
//     var sharedPref = await SharedPreferences.getInstance();
//     ownerId = sharedPref.getInt("owner_id")!; // Replace with your actual logic
//   }
//
//   Future<void> _takePicture() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(
//       source: ImageSource.camera,
//       imageQuality: 50,
//     );
//
//     _handleImageSelection(image);
//   }
//
//   Future<void> _selectPicture() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 50,
//       maxWidth: 800,
//       maxHeight: 800,
//     );
//
//     _handleImageSelection(image);
//   }
//
//   void _handleImageSelection(XFile? image) {
//     if (image != null) {
//       setState(() {
//         shopPhoto = File(image.path);
//       });
//     }
//   }
//
//   String? _validateShopName(String? value) {
//     if (submitAttempted && (value == null || value.isEmpty)) {
//       return 'Please enter your business name';
//     } else if (!RegExp(r'^[a-zA-Z]').hasMatch(value!)) {
//       return 'Please enter your business name';
//     }
//     return null;
//   }
//
//   String? _validatePinCode(String? value) {
//     if (submitAttempted && (value == null || value.isEmpty)) {
//       return 'Please enter your pin code';
//     } else if (!RegExp(r'^[1-9]\d{5}$').hasMatch(value!)) {
//       return 'Please enter a valid pin code of 6 digits';
//     }
//     return null;
//   }
//
//   String? _validateShopGst(String? value) {
//     if (submitAttempted && (value == null || value.isEmpty)) {
//       return 'Please enter your gst number';
//     }
//     return null;
//   }
//
//   String? _validateShopAddress(String? value) {
//     if (submitAttempted && (value == null || value.isEmpty)) {
//       return 'Please enter your shop address';
//     } else if (!RegExp(r'^[\s\S]{20,150}$').hasMatch(value!)) {
//       return 'Please enter atleast some part of address';
//     }
//     return null;
//   }
//
//   Future<void> _submitShopForm() async {
//     setState(() {
//       isLoading = true;
//     });
//     if ((shopNameFormKey.currentState?.validate() ?? false) &&
//         (shopGstFormKey.currentState?.validate() ?? false) &&
//         (shopAddressFormKey.currentState?.validate() ?? false) &&
//         (shopPinCodeFormKey.currentState?.validate() ?? false)) {
//       try {
//         var request = http.MultipartRequest('POST', Uri.parse(addShopUrl))
//           ..headers['Accept'] = 'application/json'
//           ..headers["Content-type"] = 'application/x-www-form-urlencoded'
//           ..headers["Content-type"] = 'application/form-mulipart';
//
//         request.fields['owner_id'] = ownerId.toString();
//         request.fields['shop_name'] = shopNameController.text.toString();
//         request.fields['shop_gst'] =
//             shopGSTController.text.toString().trim().toUpperCase();
//         request.fields['shop_address'] = shopAddressController.text.toString();
//         request.fields['shop_unique_code'] = uniqueCode.toString();
//         request.fields['pin_code'] = shopPinCodeController.text.toString();
//         if (shopPhoto != null) {
//           List<int> imageBytes = await shopPhoto!.readAsBytes();
//
//           // Get the file name and content type from the image file
//           String fileName = shopPhoto!.path.split('/').last;
//           request.files.add(http.MultipartFile.fromBytes(
//               'shop_photo', imageBytes,
//               filename: fileName,
//               // contentType: mediaType,
//               contentType: MediaType.parse(lookupMimeType(shopPhoto!.path)!)));
//         }
//
//         var response = await request.send();
//         var result = jsonDecode(await response.stream.bytesToString());
//         if (response.statusCode == 200 && !result["error"]) {
//           Fluttertoast.showToast(
//             msg: result["message"].toString(),
//           );
//           // Navigator.pushReplacement(context,
//           //     MaterialPageRoute(builder: (context) => const ShopWaitingScreen()));
//           Get.offAll(() => const ShopWaitingScreen());
//         } else {
//           Fluttertoast.showToast(
//             msg: result["message"].toString(),
//           );
//           debugPrint(
//               'Error during adding shop in else part: ${response.reasonPhrase}');
//         }
//       } on SocketException catch (e) {
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             debugPrint("Error: $e");
//             return AlertDialog(
//               title: const Text('Error'),
//               content: const Text(
//                   'A network error occurred.\nMake sure that your internet is working.'),
//               actions: [
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       isLoading = false;
//                     });
//                     Future.delayed(const Duration(seconds: 2));
//                     Get.back();
//                   },
//                   child: const Text('Close'),
//                 ),
//               ],
//             );
//           },
//         );
//       } catch (error) {
//         debugPrint('Error during adding shop in catch: $error');
//       } finally {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } else {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Partner Premises Signup'),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.green.shade600, // App bar color
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               // Shop Name Field
//               _buildTextField(
//                 controller: shopNameController,
//                 label: 'Business Name',
//                 icon: Icons.store,
//                 validator: _validateShopName,
//               ),
//               const SizedBox(height: 16),
//
//               // Shop GST Field
//               _buildTextField(
//                 controller: shopGSTController,
//                 label: 'Business Gst',
//                 icon: Icons.assignment,
//                 validator: _validateShopGst,
//               ),
//               const SizedBox(height: 16),
//
//               // Shop Address Field
//               _buildTextField(
//                 controller: shopAddressController,
//                 label: 'Business Address',
//                 icon: Icons.location_on,
//                 validator: _validateShopAddress,
//                 maxLines: 5,
//               ),
//               const SizedBox(height: 16),
//
//               // Pin Code Field
//               _buildTextField(
//                 controller: shopPinCodeController,
//                 label: 'Pin Code',
//                 icon: Icons.pin_drop,
//                 validator: _validatePinCode,
//                 keyboardType: TextInputType.number,
//                 maxLength: 6,
//               ),
//               const SizedBox(height: 16),
//
//               // Image Upload Section
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   _buildImageButton('Take Picture', _takePicture),
//                   const SizedBox(width: 16),
//                   _buildImageButton('Select Picture', _selectPicture),
//                 ],
//               ),
//               const SizedBox(height: 16),
//
//               // Image preview
//               if (shopPhoto != null)
//                 Container(
//                   height: 120,
//                   width: 120,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.3),
//                         spreadRadius: 1,
//                         blurRadius: 6,
//                       ),
//                     ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: Image.file(shopPhoto!, fit: BoxFit.cover),
//                   ),
//                 ),
//
//               // Submit Button
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: isLoading ? null : _submitShopForm,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green.shade600,
//                   minimumSize: const Size(double.infinity, 50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: isLoading
//                     ? const CircularProgressIndicator(
//                   color: Colors.white,
//                 )
//                     : const Text(
//                   'Submit',
//                   style: TextStyle(fontSize: 18, color: Colors.black),
//                 ),
//               ),
//
//               // Logout Button
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () async {
//                   var sharedPref = await SharedPreferences.getInstance();
//                   sharedPref.clear();
//                   Fluttertoast.showToast(msg: "Logged Out Successfully");
//                   Get.offAll(() => const ShopLoginScreen());
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green.shade700,
//                   minimumSize: const Size(double.infinity, 50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   'Logout',
//                   style: TextStyle(fontSize: 18, color: Colors.black),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     required String? Function(String?) validator,
//     TextInputType keyboardType = TextInputType.text,
//     int maxLength = 50,
//     int maxLines = 1,
//   }) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       maxLength: maxLength,
//       maxLines: maxLines,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Colors.green, width: 1),
//         ),
//         filled: true,
//         fillColor: Colors.grey.shade100,
//       ),
//       validator: validator,
//     );
//   }
//
//   Widget _buildImageButton(String label, VoidCallback onPressed) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.green.shade400,
//         minimumSize: const Size(130, 50),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//       child: Text(label, style: const TextStyle(color: Colors.black),),
//     );
//   }
// }
