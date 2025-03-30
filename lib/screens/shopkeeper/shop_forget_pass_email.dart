// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, unrelated_type_equality_checks

import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shop_forget_pass_new.dart';

class ShopForgetEmailOtpScreen extends StatefulWidget {
  const ShopForgetEmailOtpScreen({super.key});

  @override
  ShopForgetEmailOtpScreenState createState() => ShopForgetEmailOtpScreenState();
}

class ShopForgetEmailOtpScreenState extends State<ShopForgetEmailOtpScreen> {
  TextEditingController otpController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  int randomCode = 0;

  @override
  void initState(){
    super.initState();
    randomCode = Random().nextInt(9000) + 1000;
  }

  bool isLoading = false;

  // Replace this with your actual signup API endpoint
  final String otpUrl = 'https://syntaxium.in/DUSTBIN_API/shopForgetOtpVerify.php';

  Future<void> _sendOtp() async {
    setState(() {
      isLoading = true;
    });

    try {
      Map<String, String> headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      };

      // Define request body
      Map<String, String> otpBody = {
        "email": emailController.text.toLowerCase().trim(),
        "otp": randomCode.toString(),
      };
      // Use the http.post method with headers and body
      var response = await http.post(
        Uri.parse(otpUrl),
        headers: headers,
        body: otpBody,
      );
      var result = jsonDecode(response.body);
      debugPrint(response.body.toString());
      bool er = result["error"];
      if (response.statusCode == 200 && er == false) {
        Fluttertoast.showToast(
          msg: result["message"],
        );
      } else {
        // Request failed
        Fluttertoast.showToast(
          msg: result["message"],
        );
        debugPrint('Error during otp: ${response.reasonPhrase}');
      }
    }
    on SocketException catch (e) {
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
      // Handle network or other errors
      debugPrint('Error during otp: $error');
    } finally {
      // Set loading to false whether the API call succeeds or fails
      setState(() {
        isLoading = false;
      });
    }
  }

  void verifyOtp() async {
    if (randomCode.toString() != otpController.text.toString()) {
      Fluttertoast.showToast(msg: "Incorrect Otp Entered");
    } else {
      var sharedPref = await SharedPreferences.getInstance();
      sharedPref.setString("updateEmail", emailController.text);
      Fluttertoast.showToast(msg: "Otp Verified Successfull");
      // Navigator.pushReplacement(context,
      //     MaterialPageRoute(builder: (context) => const ShopForgetNewPassSetupScreen()));
          Get.offAll(() => const ShopForgetNewPassSetupScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Otp Verification'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_outlined),
                   border: const OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(4.0))),
                    labelText: 'Email',
                    suffix: InkWell(
                      child: const Text("Send Otp"),
                      onTap: () {
                        _sendOtp();
                      },
                    )),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                decoration: const InputDecoration(
                      labelText: 'OTP',
                      prefixIcon: Icon(Icons.password),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(4.0)))),
                obscureText: true,
                maxLength: 4,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        verifyOtp();
                      },
                child: const Text('Submit'),
              ),
              const SizedBox(height: 16),
              if (isLoading) const CircularProgressIndicator(),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
