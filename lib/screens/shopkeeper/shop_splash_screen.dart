import 'dart:async';
import 'dart:ffi';
import 'package:get/get.dart';
import 'package:trasheepartner/screens/navigation_menu.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_approval_wait.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_details_add.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_rejected_update.dart';

class ShopSplashScreen extends StatefulWidget {
  const ShopSplashScreen({super.key});

  @override
  ShopSplashScreenState createState() => ShopSplashScreenState();
}

class ShopSplashScreenState extends State<ShopSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  static const String isShopAdded = 'isShopAdded';
  static const String isShopApproved = 'isShopApproved';
  // ignore: constant_identifier_names
  static const String KEYLOGIN = "login";

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();
    whereToGo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _animation,
              child: Image.asset(
                'images/logo.png',
                height: 380, // Increased height by 20%
                width: 380,
              ),
            ),
            FadeTransition(
                opacity: _animation, child: const Text("PARTNER", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void whereToGo() async {
    var sharedPref = await SharedPreferences.getInstance();
    var isLogin = sharedPref.getBool(KEYLOGIN);
    int? isShopAdd = sharedPref.getInt(isShopAdded);
    int? isShopApprove = sharedPref.getInt(isShopApproved);

    debugPrint("""Let's print the bool values\n
    1) Is login: $isLogin\n
    2) Is Shop Added: $isShopAdd\n
    3) Is Shop Approve: $isShopApprove""");

    Timer(
      const Duration(seconds: 3),
          () {
        if (isLogin == true) {
          if (isShopAdd != null && isShopApprove != null) {
            if (isShopAdd == 0) {
              Get.offAll(() => const ShopDetailsAddScreen());
            } else if (isShopAdd == 1 && isShopApprove == 1) {
              Get.offAll(() => const NavigationMenu());
            } else if (isShopAdd == 1 && isShopApprove == 0) {
              Get.offAll(() => const ShopVerificationScreen());
            } else if (isShopAdd == 1 && isShopApprove == 2) {
              Get.offAll(() => const ShopDetailsRejectUpdateScreen());
            }
          } else {
            Get.offAll(() => const ShopLoginScreen());
          }
        } else {
          Get.offAll(() => const ShopLoginScreen());
        }
      },
    );
  }

}
