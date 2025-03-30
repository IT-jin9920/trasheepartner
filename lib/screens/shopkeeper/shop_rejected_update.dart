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

class ShopDetailsRejectUpdateScreen extends StatefulWidget {
  const ShopDetailsRejectUpdateScreen({super.key});

  @override
  ShopDetailsRejectUpdateScreenState createState() => ShopDetailsRejectUpdateScreenState();
}

class ShopDetailsRejectUpdateScreenState extends State<ShopDetailsRejectUpdateScreen> {
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
      "https://syntaxium.in/DUSTBIN_API/shopkeeper_rejected_update.php";

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
    setState(() {
      isLoading = true;  // Start loading spinner before making API request
    });

    var sharedPref = await SharedPreferences.getInstance();
    ownerId = sharedPref.getInt("owner_id")!; // Get owner_id from shared preferences

    // API endpoint for fetching shop details
    const String apiUrl = "https://syntaxium.in/DUSTBIN_API/get_shop_details.php";

    try {
      // Make a POST request to the API
      var response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'owner_id': ownerId.toString(),
        },
      );

      if (response.statusCode == 200) {
        // Parse the response body
        var result = jsonDecode(response.body);

        // Print the full response for debugging
        debugPrint("API Response: ${result.toString()}");

        // Check the "is_approve" field to determine the approval status
        int isApprove = result["shop_details"]["is_approve"];

        // Handle the approval status based on the response
        if (isApprove == 2) {
          // Shop is rejected
          Fluttertoast.showToast(msg: "Your shop has been rejected.");
          print("Shop rejected. Response data: $result");

          setState(() {
            shopNameController.text = result["shop_details"]["shop_name"];
            shopGSTController.text = result["shop_details"]["shop_gst"];
            shopAddressController.text = result["shop_details"]["shop_address"];
            shopPinCodeController.text = result["shop_details"]["pin_code"];
          });
        } else {
          // Shop is not rejected (approved or waiting)
          setState(() {
            shopNameController.text = result["shop_details"]["shop_name"];
            shopGSTController.text = result["shop_details"]["shop_gst"];
            shopAddressController.text = result["shop_details"]["shop_address"];
            shopPinCodeController.text = result["shop_details"]["pin_code"];
          });
        }
      } else {
        // Handle unsuccessful API response
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      // Handle exceptions, e.g., network errors
      print("Error while making the request: $e");
    } finally {
      setState(() {
        isLoading = false;  // Stop loading spinner after the API call is done
      });
    }
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
        request.fields['shop_gst'] = shopGSTController.text.toString().trim().toUpperCase();
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
        title: const Text('Shop Details Update'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: isLoading ? Center(child: CircularProgressIndicator(color: Colors.green,)) : Padding(
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
                  maxLength: 10,
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
                    FilteringTextInputFormatter.allow(RegExp('[A-Z0-9]')), // Ensures only uppercase letters and numbers are allowed
                    UpperCaseTextFormatter(), // Custom formatter to make text uppercase
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
                child: const Text('Update'),
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
             //if (isLoading) const CircularProgressIndicator(),
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
