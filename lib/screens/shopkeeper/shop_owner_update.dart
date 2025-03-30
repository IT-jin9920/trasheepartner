// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopOwnerDetailUpdateScreen extends StatefulWidget {
  const ShopOwnerDetailUpdateScreen({super.key});

  @override
  ShopOwnerDetailUpdateScreenState createState() =>
      ShopOwnerDetailUpdateScreenState();
}

class ShopOwnerDetailUpdateScreenState
    extends State<ShopOwnerDetailUpdateScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool submitAttempted = false;
  bool isLoading = false;

  final GlobalKey<FormState> nameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> phoneFormKey = GlobalKey<FormState>();

  String? _validateName(String? value) {
    if (submitAttempted && (value == null || value.isEmpty)) {
      return 'Please enter your name';
    } else if (!RegExp(r'^[a-zA-Z]+ [a-zA-Z]+$').hasMatch(value!)) {
      return 'Please enter your name in the format "First Last"';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (submitAttempted && (value == null || value.isEmpty)) {
      return 'Please enter your email';
    } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
        .hasMatch(value!)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (submitAttempted && (value == null || value.isEmpty)) {
      return 'Please enter your phone number';
    } else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value!)) {
      return 'Please enter a valid 10-digit number';
    }
    return null;
  }

  int id = 0;
  @override
  void initState() {
    super.initState();
    // Call the function to retrieve SharedPreferences variables
    _retrieveSharedPreferences();
  }

  Future<void> _retrieveSharedPreferences() async {
    var sharedPref = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = sharedPref.getString('owner_name') ?? 'User Name';
      emailController.text =
          sharedPref.getString('owner_email') ?? 'user@example.com';
      phoneController.text =
          sharedPref.getString('phone_number') ?? '0000000000';
      id = sharedPref.getInt("owner_id")!;
    });
  }

  String updateUrl =
      "https://syntaxium.in/DUSTBIN_API/shop_owner_detail_update.php"; // Replace with your API endpoint

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Your Details"),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Form(
                onChanged: () {
                  setState(() {
                    isLoading = false;
                  });
                },
                key: nameFormKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: TextFormField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person_add_rounded),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(4.0)))),
                  validator: _validateName,
                ),
              ),
              const SizedBox(height: 16),
              Form(
                onChanged: () {
                  setState(() {
                    isLoading = false;
                  });
                },
                key: emailFormKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: TextFormField(
                  controller: emailController,
                  readOnly: true,
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_rounded),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(4.0)))),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
              ),
              const SizedBox(height: 16),
              Form(
                onChanged: () {
                  setState(() {
                    isLoading = false;
                  });
                },
                key: phoneFormKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(4.0)))),
                  keyboardType: TextInputType.number,
                  validator: _validatePhone,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading ? null : _updateShopkeeper,
                child: const Text('Update'),
              ),
              const SizedBox(height: 16.0),
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
    });
    if ((nameFormKey.currentState?.validate() ?? false) &&
        (emailFormKey.currentState?.validate() ?? false) &&
        (phoneFormKey.currentState?.validate() ?? false)) {
      try {
        // Define headers
        Map<String, String> headers = {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        };

        // Define request body
        Map<String, String> updateBody = {
          "id": id.toString(),
          "name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "phone_number": phoneController.text.trim(),
        };
        var response = await http.post(
          Uri.parse(updateUrl),
          headers: headers,
          body: updateBody,
        );
        var result = jsonDecode(response.body);
        if (response.statusCode == 200 && result['error'] == false) {
          Fluttertoast.showToast(msg: result['message'].toString());
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
        sharedPref.setString('owner_name', nameController.text);
        sharedPref.setString('owner_email', emailController.text);
        sharedPref.setString('phone_number', phoneController.text);
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
}
