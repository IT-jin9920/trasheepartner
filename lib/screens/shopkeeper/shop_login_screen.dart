// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trasheepartner/screens/navigation_menu.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_rejected_update.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_signup_screen.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_details_add.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_approval_wait.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'shop_forget_pass_email.dart';
import 'shop_splash_screen.dart';

class ShopLoginScreen extends StatefulWidget {
  const ShopLoginScreen({super.key});

  @override
  ShopLoginScreenState createState() => ShopLoginScreenState();
}

class ShopLoginScreenState extends State<ShopLoginScreen> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  bool submitAttempted = false;
  bool validateEmail = false;
  bool validatePassword = false;
  bool passwordVisible = false;
  final GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();
  final String loginUrl = 'https://syntaxium.in/DUSTBIN_API/shop_login.php';

  String? _validateEmail(String? value) {
    if (submitAttempted && (value == null || value.isEmpty)) {
      return 'Please enter your email';
    } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+\s*$')
        .hasMatch(value!)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (submitAttempted && (value == null || value.isEmpty)) {
      return 'Please enter your password';
    } else if (value!.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  // Future<void> _login() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   if ((emailFormKey.currentState?.validate() ?? false) &&
  //       (passwordFormKey.currentState?.validate() ?? false)) {
  //     try {
  //       Map<String, String> headers = {
  //         'Content-Type': 'application/x-www-form-urlencoded',
  //         'Accept': 'application/json',
  //       };
  //
  //       Map<String, String> loginBody = {
  //         "email": emailController.text.toLowerCase().trim(),
  //         "password": passwordController.text.trim(),
  //       };
  //
  //       var response = await http.post(
  //         Uri.parse(loginUrl),
  //         headers: headers,
  //         body: loginBody,
  //       );
  //
  //       if (response.statusCode == 200) {
  //         var result = jsonDecode(response.body);
  //         if (result is Map && result.containsKey("error") && result["error"] == false) {
  //           var sharedPref = await SharedPreferences.getInstance();
  //           await sharedPref.setBool(ShopSplashScreenState.KEYLOGIN, true);
  //
  //           var userDetails = result["user_details"];
  //           if (userDetails is Map) {
  //             await sharedPref.setInt(
  //                 ShopSplashScreenState.isShopAdded, userDetails["is_shop_added"] ?? 0);
  //             await sharedPref.setInt(
  //                 ShopSplashScreenState.isShopApproved, userDetails["is_shop_approve"] ?? 0);
  //             // Store other details...
  //           }
  //
  //           if (result.containsKey("shop_details") && result["shop_details"] is Map) {
  //             var shopDetails = result["shop_details"];
  //             await sharedPref.setInt("shop_id", shopDetails["shop_id"]);
  //             // Store other shop details...
  //           }
  //
  //           Fluttertoast.showToast(msg: result["message"].toString());
  //
  //           if (userDetails["is_shop_added"] == 1 && userDetails["is_shop_approve"] == 1) {
  //             Get.offAll(() => const NavigationMenu());
  //           } else if (userDetails["is_shop_added"] == 1 && userDetails["is_shop_approve"] == 0) {
  //             Get.offAll(() => const ShopVerificationScreen());
  //           } else if (userDetails["is_shop_added"] == 0) {
  //             Get.offAll(() => const ShopDetailsAddScreen());
  //           }
  //         } else {
  //           Fluttertoast.showToast(msg: result["message"] ?? "Login failed.");
  //         }
  //       } else {
  //         Fluttertoast.showToast(msg: "Failed with status: ${response.statusCode}");
  //       }
  //     } on SocketException catch (e) {
  //       if (mounted) {
  //         _showErrorDialog("Network error occurred. Please check your internet connection.");
  //       }
  //     } catch (error) {
  //       debugPrint("Error during login: $error");
  //     } finally {
  //       if (mounted) {
  //         setState(() {
  //           isLoading = false;
  //         });
  //       }
  //     }
  //   } else {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  Future<void> _login() async {
    setState(() {
      isLoading = true;
    });

    if ((emailFormKey.currentState?.validate() ?? false) &&
        (passwordFormKey.currentState?.validate() ?? false)) {
      try {
        debugPrint("Login attempt started...");

        // Define headers
        Map<String, String> headers = {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        };
        debugPrint("Headers: $headers");

        // Define request body
        Map<String, String> loginBody = {
          "email": emailController.text.toLowerCase().trim(),
          "password": passwordController.text.trim(),
        };
        debugPrint("Request Body: $loginBody");

        // Send POST request
        var response = await http.post(
          Uri.parse(loginUrl),
          headers: headers,
          body: loginBody,
        );
        debugPrint("Response Status Code: ${response.statusCode}");
        debugPrint("Response Body: ${response.body}");

        var result = jsonDecode(response.body);
        debugPrint("Decoded Response: $result");

        bool er = result["error"];
        if (response.statusCode == 200 && er == false) {
          debugPrint("Login successful.");

          var sharedPref = await SharedPreferences.getInstance();
          sharedPref.setBool(ShopSplashScreenState.KEYLOGIN, true);

          int isShopAdded = result["user_details"]["is_shop_added"];
          int isShopApproved = result["user_details"]["is_shop_approve"];

          sharedPref.setInt(ShopSplashScreenState.isShopAdded, isShopAdded);
          sharedPref.setInt(ShopSplashScreenState.isShopApproved, isShopApproved);

          sharedPref.setInt("owner_id", result["user_details"]["owner_id"]);
          sharedPref.setString("owner_email", result["user_details"]["email"]);
          sharedPref.setString("owner_name", result["user_details"]["fullname"]);
          sharedPref.setString("phone_number", result["user_details"]["phone_number"]);

          if (result["shop_details"] != null) {
            sharedPref.setInt("shop_id", result["shop_details"]["shop_id"]);
            sharedPref.setString("shop_name", result["shop_details"]["shop_name"]);
            sharedPref.setString("shop_gst", result["shop_details"]["shop_gst"]);
            sharedPref.setString("shop_photo", result["shop_details"]["shop_photo_path"]);
            sharedPref.setString("shop_address", result["shop_details"]["shop_address"]);
            sharedPref.setString("shop_pin_code", result["shop_details"]["shop_pin_code"]);
            debugPrint("Shop details saved.");
          }

          Fluttertoast.showToast(msg: result["message"].toString());

          if (isShopAdded == 1 && isShopApproved == 1) {
            debugPrint("Navigating to NavigationMenu...");
            Get.offAll(() => const NavigationMenu());
          } else if (isShopAdded == 1 && isShopApproved == 0) {
            debugPrint("Navigating to ShopVerificationScreen...");
            Get.offAll(() => const ShopVerificationScreen());
          } else if (isShopAdded == 0 && isShopApproved == 0) {
            debugPrint("Navigating to ShopDetailsAddScreen...");
            Get.offAll(() => const ShopDetailsAddScreen());
          } else if (isShopAdded == 1 && isShopApproved == 2) {
            debugPrint("Navigating to ShopDetailsRejectUpdateScreen...");
            Get.offAll(() => const ShopDetailsRejectUpdateScreen());
          }
        } else {
          debugPrint("Login failed: ${result["message"]}");
          Fluttertoast.showToast(msg: result["message"].toString());
        }
      } on SocketException catch (e) {
        debugPrint("Network Error: $e");

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('A network error occurred.\nMake sure that your internet is working.'),
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
        debugPrint('Unexpected Error: $error');
      } finally {
        setState(() {
          isLoading = false;
        });
        debugPrint("Login attempt completed.");
      }
    } else {
      debugPrint("Validation failed. Check email and password fields.");
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Login'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Form(
                onChanged: () {
                  setState(() {
                    isLoading = false;
                  });
                },
                key: emailFormKey,
                autovalidateMode: submitAttempted
                    ? AutovalidateMode.always
                    : AutovalidateMode.onUserInteraction,
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(4.0)))),
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
                key: passwordFormKey,
                autovalidateMode: submitAttempted
                    ? AutovalidateMode.always
                    : AutovalidateMode.onUserInteraction,
                child: TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.password),
                      suffixIcon: IconButton(
                        icon: Icon(passwordVisible
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(
                            () {
                              passwordVisible = !passwordVisible;
                            },
                          );
                        },
                      ),
                      border: const OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(4.0)))),
                  obscureText: !passwordVisible,
                  validator: _validatePassword,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading ? null : _login,
                child: const Text('Login'),
              ),
              const SizedBox(height: 16),
              if (isLoading) const CircularProgressIndicator(),
              Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an Account Yet?  "),
                    InkWell(
                      child: const Text(
                        "Signup Now!",
                        style: TextStyle(
                            color: Colors.blue, fontSize: 14, letterSpacing: 1),
                      ),
                      onTap: () {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) =>
                        //             const ShopSignupScreen()));
                        Get.to(()=> const ShopSignupScreen());
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      child: const Text(
                        "Forgot your password?",
                        style: TextStyle(
                            color: Colors.blue, fontSize: 14, letterSpacing: 1),
                      ),
                      onTap: () {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) =>
                        //             const ShopForgetEmailOtpScreen()));
                                    Get.to(()=> const ShopForgetEmailOtpScreen());
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
