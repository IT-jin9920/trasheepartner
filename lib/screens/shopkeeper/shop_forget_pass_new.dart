// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'shop_login_screen.dart';

class ShopForgetNewPassSetupScreen extends StatefulWidget {
  const ShopForgetNewPassSetupScreen({super.key});

  @override
  _ShopForgetNewPassSetupScreenState createState() =>
      _ShopForgetNewPassSetupScreenState();
}

class _ShopForgetNewPassSetupScreenState
    extends State<ShopForgetNewPassSetupScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool isLoading = false;
  bool submitAttempted = false;
  bool normalPasswordVisible = false;
  bool confirmPasswordVisible = false;
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();
  final String signupUrl =
      'https://syntaxium.in/DUSTBIN_API/update_shopkeeper_password.php';

  String? _validatePassword(String? value) {
    if (submitAttempted && (value == null || value.isEmpty)) {
      return 'Please enter your password';
    } else if (!RegExp(
            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*(),.?":{}|<>])[A-Za-z\d!@#\$%^&*(),.?":{}|<>]{8,}$')
        .hasMatch(value!)) {
      return 'Password must contain at least 1 lowercase,\n1 uppercase, 1 digit, and 1 special character';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (submitAttempted && (value == null || value.isEmpty)) {
      return 'Please confirm your password';
    } else if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _updatePassword() async {
    setState(() {
      isLoading = true;
    });

    if ((passwordFormKey.currentState?.validate() ?? false)) {
      setState(() {
        isLoading = false;
      });
      try {
        Map<String, String> headers = {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        };
        var sharedPref = await SharedPreferences.getInstance();
        String updateEmail = sharedPref.getString("updateEmail").toString();
        Map<String, String> upatePassBody = {
          "email": updateEmail.toLowerCase().trim(),
          "new_password": _passwordController.text.trim(),
        };

        var response = await http.post(
          Uri.parse(signupUrl),
          headers: headers,
          body: upatePassBody,
        );
        var result = jsonDecode(response.body);
        debugPrint("Result: ${result.toString()}");
        if (response.statusCode == 200 && result["error"] == false) {
          Fluttertoast.showToast(msg: result["message"].toString());
          // Navigator.pushReplacement(context,
          //     MaterialPageRoute(builder: (context) => const ShopLoginScreen()));
          Get.offAll(() => const ShopLoginScreen());
          _passwordController.text = "";
          _confirmPasswordController.text = "";
        } else {
          Fluttertoast.showToast(msg: result["message"].toString());
          debugPrint('Error during update password: ${response.reasonPhrase}');
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
        debugPrint('Error during update password: $error');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Password Setup'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: passwordFormKey,
              autovalidateMode: submitAttempted
                  ? AutovalidateMode.always
                  : AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.password),
                        suffixIcon: IconButton(
                          icon: Icon(normalPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(
                              () {
                                normalPasswordVisible = !normalPasswordVisible;
                                isLoading = false;
                              },
                            );
                          },
                        ),
                        border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(4.0)))),
                    obscureText: !normalPasswordVisible,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.password),
                        suffixIcon: IconButton(
                          icon: Icon(confirmPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(
                              () {
                                confirmPasswordVisible =
                                    !confirmPasswordVisible;
                                isLoading = false;
                              },
                            );
                          },
                        ),
                        border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(4.0)))),
                    obscureText: !confirmPasswordVisible,
                    validator: _validateConfirmPassword,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isLoading ? null : _updatePassword,
                    child: const Text('Update Password'),
                  ),
                  const SizedBox(height: 16),
                  if (isLoading) const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
