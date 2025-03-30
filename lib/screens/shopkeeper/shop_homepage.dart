// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_privacy_policy.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_about_developer.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_detail_update.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_login_screen.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_owner_update.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_product_approval_wait.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_product_approved.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_product_display.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_product_non_redeem.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_product_redeem.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_product_stock_update.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Payment_plan_history_screen.dart';
import 'Shop_rejectes_products_screen.dart';
import 'Subscription_plans_paymant.dart';
import 'payment_plan_screen.dart';

class ShopHomeScreen extends StatefulWidget {
  const ShopHomeScreen({super.key});

  @override
  ShopHomeScreenState createState() => ShopHomeScreenState();
}

class ShopHomeScreenState extends State<ShopHomeScreen> {
  String userName = "";
  String userEmail = "";
  String userImageUrl = "";
  String userPhone = "";
  bool isLoading = false;
  int shopId = 0;
  dynamic totalProduct = 0;
  dynamic totalRedeemProduct = 0;
  dynamic totalNonRedeemProduct = 0;
  dynamic totalRejectedProduct = 0;
  dynamic totalApprovedProduct = 0;
  dynamic totalNonApprovedProduct = 0;
  String shopHomeUrl = "https://syntaxium.in/DUSTBIN_API/shop_homepage.php";

  @override
  void initState() {
    super.initState();
    _retrieveData();
  }

  Future<void> _retrieveData() async {
    var sharedPref = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
      // Replace 'key' with the actual keys you have used to store data
      userName = sharedPref.getString('owner_name') ?? 'User Name';
      userEmail = sharedPref.getString('owner_email') ?? 'user@example.com';
      userImageUrl =
          sharedPref.getString('shop_photo') ?? 'shop_images/logo.png';
      shopId = sharedPref.getInt("shop_id") ?? 0;
    });
    try {
      // Define headers
      Map<String, String> headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      };
      // Define request body
      Map<String, String> dataRetriveBody = {"shop_id": shopId.toString()};

      // Use the http.post method with headers and body
      var response = await http.post(
        Uri.parse(shopHomeUrl),
        headers: headers,
        body: dataRetriveBody,
      );
      var result = jsonDecode(response.body);
      bool er = result["error"];
      if (response.statusCode == 200 && er == false) {
        totalProduct = result["total_product"] ?? 0;
        totalApprovedProduct = result["approved_count"] ?? 0;
        totalNonApprovedProduct = result["not_approved_count"] ?? 0;
        totalRejectedProduct = result["rejected_count"] ?? 0;
        totalRedeemProduct = result["history_counts"]["redeemed"] ?? 0;
        totalNonRedeemProduct = result["history_counts"]["not_redeemed"] ?? 0;
      } else {
        debugPrint("Data Fetch Success: HomePage");
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
      debugPrint('Error during fetching in catch: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String cleanImagePath(String imagePath) {
    if (imagePath.startsWith('../')) {
      imagePath = imagePath.substring(2);
    }

    if (!imagePath.startsWith('/')) {
      imagePath = '/$imagePath';
    }
    return imagePath;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child:  CircularProgressIndicator(
            color: Colors.green,
          ))
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: const Text('Home Screen'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () async {
                    var sharedPref = await SharedPreferences.getInstance();
                    sharedPref.clear();
                    Fluttertoast.showToast(msg: "Log Out Successfully");
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ShopLoginScreen()),
                    );
                  },
                ),
              ],
            ),
            drawer: Drawer(
              backgroundColor: Colors.white,
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      _showImageDialog(context);
                    },
                    child: Hero(
                      tag: 'userImage',
                      child: UserAccountsDrawerHeader(
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 239, 239, 239),
                        ),
                        currentAccountPicture: CircleAvatar(
                          backgroundImage: NetworkImage(
                              "https://syntaxium.in${cleanImagePath(userImageUrl)}"),
                        ),
                        accountName: Text(
                          userName,
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        accountEmail: Text(
                          userEmail,
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.payment_rounded),
                    // Payment-related icon
                    title: const Text('Plans & Payment'),
                    onTap: () {
                      Get.to(() => const PlanDemo());
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.history_rounded),
                    // Payment history icon
                    title: const Text('Payment History'),
                    onTap: () {
                      Get.to(() =>
                          const PaymentPlanHistoryScreen()); // Navigate to the Payment History screen
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.person_rounded),
                    // Person-related icon for user details
                    title: const Text('Update Your Details'),
                    onTap: () {
                      Get.to(() => const ShopOwnerDetailUpdateScreen());
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.storefront_rounded),
                    // Shop-related icon
                    title: const Text('Update Shop Details'),
                    onTap: () {
                      Get.to(() => const ShopDetailUpdateScreen());
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.inventory_2_rounded),
                    // Inventory-related icon
                    title: const Text('Update Stock'),
                    onTap: () {
                      Get.to(() => const ShopProductStockUpdate());
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.logout_rounded), // Logout icon
                    title: const Text('Logout'),
                    onTap: () async {
                      var sharedPref = await SharedPreferences.getInstance();
                      sharedPref.clear();
                      Fluttertoast.showToast(msg: "Logged Out Successfully");
                      Future.delayed(const Duration(seconds: 2), () {
                        Get.offAll(() => const ShopLoginScreen());
                      });
                    },
                  ),

                  // Add more list items as needed
                ],
              ),
            ),
            body: RefreshIndicator(
              color: Colors.green,
              onRefresh: _retrieveData,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                        elevation: 8,
                        margin: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                                leading: const Icon(Icons.shopping_cart_rounded,
                                    color: Colors.green),
                                title: const Text("Total Product Offered"),
                                trailing: Text(totalProduct.toString()),
                                subtitle: GestureDetector(
                                  child: const Text("View Products"),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const ShopAllProductDisplayScreen()),
                                    );
                                  },
                                )),
                          ],
                        )),
                    Card(
                        elevation: 8,
                        margin: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                                leading: const Icon(
                                  Icons.shopping_cart_checkout_rounded,
                                  color: Colors.green,
                                ),
                                title: const Text("Total Product Redeem"),
                                trailing: Text(totalRedeemProduct.toString()),
                                subtitle: GestureDetector(
                                  child: const Text("View Redeem Products"),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const ShopRedeemProductDisplayScreen()),
                                    );
                                  },
                                )),
                          ],
                        )),
                    Card(
                        elevation: 8,
                        margin: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                                leading: const Icon(
                                  Icons.watch_later_outlined,
                                  color: Colors.orange,
                                ),
                                title: const Text("Total Yet To Redeem"),
                                trailing:
                                    Text(totalNonRedeemProduct.toString()),
                                subtitle: GestureDetector(
                                  child: const Text("View Non-Redeem Products"),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const ShopNonRedeemProductDisplayScreen()),
                                    );
                                  },
                                )),
                          ],
                        )),
                    Card(
                        elevation: 8,
                        margin: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                                leading: const Icon(
                                  Icons.timelapse_rounded,
                                  color: Colors.orange,
                                ),
                                title: const Text("Products Awaiting Approval"),
                                trailing:
                                    Text(totalNonApprovedProduct.toString()),
                                subtitle: GestureDetector(
                                  child: const Text("View Waiting Products"),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const ShopNonApprovedProductScreen()),
                                    );
                                  },
                                )),
                          ],
                        )),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ShopApprovedProductScreen(),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 8,
                        margin: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.check_circle_outline_rounded,
                                // Icon for approved status
                                color: Colors.green,
                              ),
                              title: const Text("Approved Products"),
                              trailing: Text(totalApprovedProduct.toString()),
                              subtitle: const Text("View Approved Products"),
                            ),
                          ],
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const ShopRejectesProductsScreen(), // Assuming a separate screen for rejected products
                          ),
                        );
                      },
                      child: Card(
                        elevation: 8,
                        margin: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons
                                    .cancel_rounded, // Icon for rejected status
                                color: Colors.red,
                              ),
                              title: const Text("Rejected Products Update"),
                              trailing: Text(totalRejectedProduct.toString()),
                              subtitle:
                                  const Text("View Rejected Products Update"),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Card(
                    //     elevation: 8,
                    //     margin: const EdgeInsets.all(8),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(15.0),
                    //     ),
                    //     child: Column(
                    //       children: [
                    //         ListTile(
                    //           leading: const Icon(Icons.account_box_outlined),
                    //           title: const Text("About Developer"),
                    //           subtitle: GestureDetector(
                    //             child: const Text("Contact Developer"),
                    //             onTap: () {
                    //               Navigator.push(
                    //                 context,
                    //                 MaterialPageRoute(
                    //                     builder: (_) => const DeveloperAboutScreen()),
                    //               );
                    //             },
                    //           ),
                    //         ),
                    //       ],
                    //     )),

                    const SizedBox(height: 16),

                    GestureDetector(
                      child: const Text("Privacy Policy"),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PrivacyPolicyPage()));
                      },
                    ),

                  ],
                ),
              ),
            ),
          );
  }

  // ignore: unused_element
  void _showLargeImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: GestureDetector(
            onTap: () {
              Get.back(); // Close the dialog on tap
            },
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: GestureDetector(
            onTap: () {
              Get.back(); // Close the dialog when tapped
            },
            child: SizedBox(
              width: double.infinity,
              height: 300,
              child: Hero(
                tag: 'userImage',
                child: Image.network(
                  "https://syntaxium.in/$userImageUrl",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
