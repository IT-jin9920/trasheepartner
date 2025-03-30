import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_homepage.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_product_add.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_redeem_page.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
     // backgroundColor: Colors.transparent, // Set a background color for the body
      bottomNavigationBar: Obx(
            () => ClipRRect(
         // borderRadius: const BorderRadius.vertical(top: Radius.circular(30)), // Rounded corners for the nav bar
          child: NavigationBar(
            height: 80,
            elevation: 0,
            backgroundColor: const Color(0xffd9ddce), // Customize background color
            indicatorColor: Colors.black12,
            selectedIndex: controller.selectedIndex.value,
            onDestinationSelected: (index) =>
            controller.selectedIndex.value = index,
            destinations:  [
              NavigationDestination(
                  icon: Icon(Icons.home,
                      color: controller.selectedIndex.value == 0
                          ? Colors.black
                          : null),
                  label: 'Home'),
              NavigationDestination(
                  icon: Icon(Icons.shopping_cart_checkout_rounded,
                      color: controller.selectedIndex.value == 1
                          ? Colors.black
                          : null),
                  label: 'Add Product'),
              NavigationDestination(
                  icon: Icon(Icons.qr_code_scanner_rounded,
                      color: controller.selectedIndex.value == 2
                          ? Colors.black
                          : null),
                  label: 'Redeem Product'),
            ],
          ),
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const ShopHomeScreen(),
    const ShopProductAddScreen(),
    const ShopRedeemScreen(),
  ];
}
