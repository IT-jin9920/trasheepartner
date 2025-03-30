// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopDetailUpdateScreen extends StatefulWidget {
  const ShopDetailUpdateScreen({super.key});

  @override
  ShopDetailUpdateScreenState createState() => ShopDetailUpdateScreenState();
}

class ShopDetailUpdateScreenState extends State<ShopDetailUpdateScreen> {
  TextEditingController shopNameController = TextEditingController();
  TextEditingController shopGSTController = TextEditingController();
  TextEditingController shopAddressController = TextEditingController();
  TextEditingController shopPinCodeController = TextEditingController();
  int shopId = 0;
  bool submitAttempted = false;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    // Call the function to retrieve SharedPreferences variables
    _retrieveSharedPreferences();
  }

  final GlobalKey<FormState> shopNameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> shopGstFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> shopAddressFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> shopPinCodeFormKey = GlobalKey<FormState>();
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
      return 'Please enter a valid pin code starting from 1\nand of 6 digits';
    }
    return null;
  }

  String? _validateShopGst(String? value) {
    if (submitAttempted && (value == null || value.isEmpty)) {
      return 'Please enter your GST Number';
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

  Future<void> _retrieveSharedPreferences() async {
    var sharedPref = await SharedPreferences.getInstance();
    setState(() {
      // Replace 'key' with the actual keys you have used to store data
      shopNameController.text =
          sharedPref.getString('shop_name') ?? 'Shop Name';
      shopGSTController.text = sharedPref.getString('shop_gst') ?? 'ABC12345';
      shopAddressController.text =
          sharedPref.getString('shop_address') ?? 'Shop Address';
      shopPinCodeController.text =
          sharedPref.getString('shop_pin_code') ?? '000000';
      shopId = sharedPref.getInt('shop_id')!;
    });
  }

  String updateUrl = "https://syntaxium.in/DUSTBIN_API/shop_detail_update.php";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Business Details'),
        centerTitle: true,
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
                  controller: shopGSTController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                      labelText: 'Business Gst',
                      prefixIcon: Icon(Icons.person_add_rounded),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(4.0)))),
                  validator: _validateShopGst,
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
                  maxLines: 3,
                  maxLength: 150,
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
              ElevatedButton(
                onPressed: isLoading ? null : _updateShopkeeper,
                child: const Text('Submit'),
              ),
              const SizedBox(height: 16),
              if (isLoading) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateShopkeeper() async {
    setState(() {
      isLoading = true;
      submitAttempted = true;
    });
    if ((shopNameFormKey.currentState?.validate() ?? false) &&
        (shopGstFormKey.currentState?.validate() ?? false) &&
        (shopAddressFormKey.currentState?.validate() ?? false) &&
        (shopPinCodeFormKey.currentState?.validate() ?? false)) {
      try {
        // Define headers
        Map<String, String> headers = {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        };

        // Define request body
        Map<String, String> updateBody = {
          "shop_id": shopId.toString(),
          "shop_name": shopNameController.text.trim(),
          "shop_gst": shopGSTController.text.trim(),
          "shop_address": shopAddressController.text.trim(),
          "pincode": shopPinCodeController.text.trim(),
        };

        // Use the http.post method with headers and body
        var response = await http.post(
          Uri.parse(updateUrl),
          headers: headers,
          body: updateBody,
        );
        var result = jsonDecode(response.body);
        debugPrint(result.toString());

        if (response.statusCode == 200 && result['error'] == false) {
          Fluttertoast.showToast(msg: result['message'].toString());
          // Navigate back or to the profile page after a successful update
          Get.back();
        } else {
          Fluttertoast.showToast(msg: result['message'].toString());
        }
      }on SocketException catch (e) {
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
        debugPrint('Error during shopkeeper update in catch: $error');
      } finally {
        setState(() {
          isLoading = false;
        });
        var sharedPref = await SharedPreferences.getInstance();
        sharedPref.setString("shop_name", shopNameController.text);
        sharedPref.setString("shop_gst", shopGSTController.text);
        sharedPref.setString("shop_address", shopAddressController.text);
        sharedPref.setString("shop_pin_code", shopPinCodeController.text);
      }
    } else {
      isLoading = false;
      submitAttempted = false;
    }
  }
}
