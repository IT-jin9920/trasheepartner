// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:get/get.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_signup_otp_verify.dart';
import 'package:flutter/material.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopSignupScreen extends StatefulWidget {
  const ShopSignupScreen({super.key});

  @override
  _ShopSignupScreenState createState() => _ShopSignupScreenState();
}

class _ShopSignupScreenState extends State<ShopSignupScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool isLoading = false;
  bool submitAttempted = false;
  bool passwordVisible = false;

  final GlobalKey<FormState> nameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> phoneFormKey = GlobalKey<FormState>();

  String? _validateName(String? value) {
    if (submitAttempted && (value == null || value.isEmpty)) {
      return 'Please enter your name';
    } else if (!RegExp(r'^[a-zA-Z]+ [a-zA-Z]+(?:\s[a-zA-Z]+)*$').hasMatch(value!)) {
      return 'Please enter your name in the format "First Last"';
    }
    return null;
  }

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
    } else if (!RegExp(
            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*(),.?":{}|<>])[A-Za-z\d!@#\$%^&*(),.?":{}|<>]{8,}$')
        .hasMatch(value!)) {
      return 'Password must contain at least 1 lowercase,\n1 uppercase, 1 digit, and 1 special character';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (submitAttempted && (value == null || value.isEmpty)) {
      return 'Please enter your phone number';
    } else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value!)) {
      return 'Please enter a valid 10-digit phone number\nstarting between 6-9';
    }
    return null;
  }

  void _signup() async {
    setState(() {
      submitAttempted = true;
    });

    if ((nameFormKey.currentState?.validate() ?? false) &&
        (emailFormKey.currentState?.validate() ?? false) &&
        (passwordFormKey.currentState?.validate() ?? false) &&
        (phoneFormKey.currentState?.validate() ?? false)) {
      // Validation successful, perform signup
      var sharedPref = await SharedPreferences.getInstance();
      String signupEmail = emailController.text.toLowerCase().trim();
      String signupName = nameController.text.trim();
      String signupPassword = passwordController.text.trim();
      String signupPhoneNumber = phoneController.text;
      sharedPref.setString("signupEmail", signupEmail);
      sharedPref.setString("signupName", signupName);
      sharedPref.setString("signupPassword", signupPassword);
      sharedPref.setString("signupPhoneNumber", signupPhoneNumber);
      Get.offAll(()=> const ShopSignupOtpVerifyScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Signup'),
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
                onChanged: (){
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
                onChanged: (){
                  setState(() {
                    isLoading = false;
                  });
                },
                key: emailFormKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                      labelText: 'Business Email',
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
                onChanged: (){
                  setState(() {
                    isLoading=false;
                  });
                },
                key: passwordFormKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
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
              Form(
                onChanged: (){
                  setState(() {
                    isLoading = false;
                  });
                },
                key: phoneFormKey,
                autovalidateMode: submitAttempted
                    ? AutovalidateMode.always
                    : AutovalidateMode.onUserInteraction,
                child: TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                      labelText: 'Business Phone',
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
                onPressed: isLoading ? null : _signup,
                child: const Text('Signup'),
              ),
              const SizedBox(height: 16),
              if (isLoading) const CircularProgressIndicator(),
              Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    InkWell(
                      child: const Text(
                        "Login Now!",
                        style: TextStyle(
                            color: Colors.blue, fontSize: 14, letterSpacing: 1),
                      ),
                      onTap: () {

                        Get.offAll(()=> const ShopLoginScreen());
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
