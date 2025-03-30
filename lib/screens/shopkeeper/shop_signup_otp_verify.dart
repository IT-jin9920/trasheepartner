// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, unrelated_type_equality_checks

import 'dart:io';
import 'dart:math';
import 'package:get/get.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_login_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopSignupOtpVerifyScreen extends StatefulWidget {
  const ShopSignupOtpVerifyScreen({super.key});

  @override
  ShopSignupOtpVerifyScreenState createState() => ShopSignupOtpVerifyScreenState();
}



class ShopSignupOtpVerifyScreenState extends State<ShopSignupOtpVerifyScreen> {
  TextEditingController otpController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  int randomCode = 0;
  bool isLoading = false;
  bool isOtpVerified = false;
  @override
  void initState() {
    super.initState();
    randomCode = Random().nextInt(9000) + 1000;
    // Fetch the email from SharedPreferences when the screen is initialized
    _getEmailFromSharedPref();
  }

  final String signupUrl =
      'https://syntaxium.in/DUSTBIN_API/shop_signup.php';
  // Replace this with your actual signup API endpoint
  final String otpUrl = 'https://syntaxium.in/DUSTBIN_API/shopSignupOtpVerify.php';
  Future<void> _sendSignupOtp() async {
    setState(() {
      isLoading = true;
    });
    var sharedPref = await SharedPreferences.getInstance();
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      };

      // Define request body
      Map<String, String> otpBody = {
        "email": sharedPref.getString("signupEmail").toString().toLowerCase().trim(),
        "otp": randomCode.toString(),
      };
      // Use the http.post method with headers and body
      var response = await http.post(
        Uri.parse(otpUrl),
        headers: headers,
        body: otpBody,
      );
      var result = jsonDecode(response.body);
      debugPrint(response.body);
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
      isOtpVerified = false;
    } else {
      Fluttertoast.showToast(msg: "Otp Verified Successfully");
      isOtpVerified = true;
      _signup();
    }
  }

  Future<void> _signup() async {
    setState(() {
      isLoading = true;
    });
    var sharedPref = await SharedPreferences.getInstance();
    try {
      // Define headers
      Map<String, String> headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      };

      // Define request body
      Map<String, String> signupBody = {
        "fullname": sharedPref.getString("signupName").toString().trim(),
        "email": sharedPref.getString("signupEmail").toString().trim(),
        "password": sharedPref.getString("signupPassword").toString().trim(),
        "phone_number": sharedPref.getString("signupPhoneNumber").toString(),
      };

      // Use the http.post method with headers and body
      var response = await http.post(
        Uri.parse(signupUrl),
        headers: headers,
        body: signupBody,
      );
      var result = jsonDecode(response.body);
      // Check the status code of the response
      if (response.statusCode == 200 && result["error"] == false) {
        Fluttertoast.showToast(msg: result["message"].toString());
        // Navigator.pushReplacement(context,
        //     MaterialPageRoute(builder: (context) => const ShopLoginScreen()));
        Get.offAll(()=> const ShopLoginScreen());
      } else {
        // Request failed
        Fluttertoast.showToast(msg: result["message"].toString());
        debugPrint('Error during signup: ${response.reasonPhrase}');
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
      debugPrint('Error during signup: $error');
    } finally {
      // Set loading to false whether the API call succeeds or fails
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Otp Verification For Signup'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            TextField(
              style: const TextStyle(fontSize: 14),
              readOnly: true,
              controller: emailController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(4.0))),
                labelText: 'Email',
                suffix: InkWell(
                  child: const Text("Send Otp"),
                  onTap: () {
                    _sendSignupOtp();
                  },
                ),
              ),
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
              onPressed: (isLoading && isOtpVerified)
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
    );
  }

  void _getEmailFromSharedPref() async {
    var sharedPref = await SharedPreferences.getInstance();
    String? email = sharedPref.getString("signupEmail");
    if (email != null) {
      // Set the email to the emailController
      emailController.text = email;
      // Print the email value
    }
    else{
      Fluttertoast.showToast(msg: "Something went wrong please signup again");
    }
  }
}
