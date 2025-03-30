// // ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
//
// import 'dart:convert';
// import 'dart:io';
// import 'package:get/get.dart';
// import 'package:trasheepartner/screens/navigation_menu.dart';
// import 'package:trasheepartner/screens/shopkeeper/shop_login_screen.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'shop_splash_screen.dart';
//
// class ShopWaitingScreen extends StatelessWidget {
//   const ShopWaitingScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Business Verification'),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//       ),
//       body: SingleChildScrollView(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   'images/waiting.gif',
//                   height: 150,
//                   width: 150,
//                   fit: BoxFit.cover,
//                 ),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'Your Business Profile Is Under Review.',
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//                 const Text(
//                   'Kindly wait for sometime as we are verifying your details.',
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 const Divider(
//                   color: Colors.black,
//                   thickness: 1,
//                 ),
//                 const SizedBox(
//                 ),
//                 Container(
//                   decoration: BoxDecoration(border: Border.all(style: BorderStyle.solid)),
//                   padding: const EdgeInsets.all(8),
//                   child: const Text(
//                     'If you don\'t get an approval within few hours, please email us at info.dprofiz@gmail.com, and we will get back to you at our earliest.',
//                     textAlign: TextAlign.justify,
//                   ),
//                 ),
//                 const Divider(
//                   color: Colors.black,
//                   thickness: 1,
//                   height: 20,
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 const Text(
//                   'Please Login After After Few Hours',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const Text(
//                   'We are verifying your details and soon your business partnership profile will be approved.',
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                     onPressed: () async {
//                       var sharedPref = await SharedPreferences.getInstance();
//                       sharedPref.clear();
//                       Fluttertoast.showToast(msg: "Log Out Successfully");
//                       Future.delayed(const Duration(seconds: 2));
//                       Get.offAll(()=> const ShopLoginScreen());
//                     },
//                     child: const Text("Logout"))
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class ShopVerificationScreen extends StatefulWidget {
//   const ShopVerificationScreen({super.key});
//
//   @override
//   _ShopVerificationScreenState createState() => _ShopVerificationScreenState();
// }
//
// class _ShopVerificationScreenState extends State<ShopVerificationScreen> {
//   bool isLoading = true;
//   bool isShopApprove = false;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }
//
//   Future<void> fetchData() async {
//     const String getDataUrl =
//         "https://syntaxium.in/DUSTBIN_API/get_shop_details.php";
//     var sharedPref = await SharedPreferences.getInstance();
//     int? ownerId = sharedPref.getInt("owner_id");
//     setState(() {
//       isLoading = true;
//     });
//
//     try {
//       Map<String, String> headers = {
//         'Content-Type': 'application/x-www-form-urlencoded',
//         'Accept': 'application/json',
//       };
//       Map<String, String> getDetail = {"owner_id": ownerId.toString()};
//       var response = await http.post(
//         Uri.parse(getDataUrl),
//         headers: headers,
//         body: getDetail,
//       );
//       var result = jsonDecode(response.body);
//       debugPrint("Approval wait scrren screen: ${result.toString()}");
//       if (response.statusCode == 200 && result["error"] == false) {
//         if (result["shop_details"]["is_approve"] == 1) {
//           isShopApprove = true;
//           sharedPref.setBool(ShopSplashScreenState.isShopApproved, true);
//         } else {
//           isShopApprove = false;
//         }
//       }
//       setState(() {
//         isLoading = false;
//       });
//       if (isShopApprove) {
//         // Navigator.pushReplacement(context,
//         //     MaterialPageRoute(builder: (_) => const ShopHomeScreen()));
//             Get.offAll(()=> const NavigationMenu());
//       } else {}
//       debugPrint(response.body);
//     }on SocketException catch (e) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           debugPrint("Error: $e");
//           return AlertDialog(
//             title: const Text('Error'),
//             content: const Text(
//                 'A network error occurred.\nMake sure that your internet is working.'),
//             actions: [
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     isLoading = false;
//                   });
//                   Future.delayed(const Duration(seconds: 2));
//                  Get.back();
//
//                 },
//                 child: const Text('Close'),
//               ),
//             ],
//           );
//         },
//       );
//     } catch (error) {
//       debugPrint('Error during getting data: $error');
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return isLoading
//         ? const Scaffold(
//             body: Center(
//               child: CircularProgressIndicator(),
//             ),
//           )
//         : const ShopWaitingScreen();
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../navigation_menu.dart';
import 'shop_login_screen.dart';
import 'shop_rejected_update.dart';

class ShopWaitingScreen extends StatelessWidget {
  const ShopWaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Verification'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/waiting.gif',
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your Business Profile Is Under Review.',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Kindly wait for some time as we are verifying your details.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.black, thickness: 1),
                const SizedBox(),
                Container(
                  decoration: BoxDecoration(border: Border.all()),
                  padding: const EdgeInsets.all(8),
                  child: const Text(
                    'If you don\'t get an approval within a few hours, please email us at info.dprofiz@gmail.com, and we will get back to you at our earliest.',
                    textAlign: TextAlign.justify,
                  ),
                ),
                const Divider(color: Colors.black, thickness: 1, height: 20),
                const SizedBox(height: 20),
                const Text(
                  'Please Login After A Few Hours',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'We are verifying your details, and soon your business partnership profile will be approved.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    var sharedPref = await SharedPreferences.getInstance();
                    sharedPref.clear();
                    Fluttertoast.showToast(msg: "Logged Out Successfully");
                    Get.offAll(() => const ShopLoginScreen());
                  },
                  child: const Text("Logout"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShopVerificationScreen extends StatefulWidget {
  const ShopVerificationScreen({super.key});

  @override
  _ShopVerificationScreenState createState() => _ShopVerificationScreenState();
}

class _ShopVerificationScreenState extends State<ShopVerificationScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkApprovalStatus();
  }

  Future<void> checkApprovalStatus() async {
    const String getDataUrl =
        "https://syntaxium.in/DUSTBIN_API/get_shop_details.php";
    var sharedPref = await SharedPreferences.getInstance();
    int? ownerId = sharedPref.getInt("owner_id");

    debugPrint("Initiating approval check for owner ID: $ownerId");

    while (true) {
      try {
        setState(() {
          isLoading = true;
        });

        debugPrint("Sending API request to fetch shop details...");

        Map<String, String> headers = {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        };
        Map<String, String> getDetail = {"owner_id": ownerId.toString()};

        var response = await http.post(
          Uri.parse(getDataUrl),
          headers: headers,
          body: getDetail,
        );

        debugPrint("API response status: ${response.statusCode}");

        if (response.statusCode == 200) {
          var result = jsonDecode(response.body);

          debugPrint("API response body: ${response.body}");

          if (result["error"] == false) {
            int approvalStatus = result["shop_details"]["is_approve"];
            debugPrint("Shop approval status: $approvalStatus");

            if (approvalStatus == 1) {
              // Approved
              debugPrint("Shop approved!");
              sharedPref.setInt("isShopApproved", 1);
              Fluttertoast.showToast(
                msg: "Your business application has been Approved.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.greenAccent,
                textColor: Colors.white,
              );
              await Future.delayed(const Duration(seconds: 2));
              Get.offAll(() => const NavigationMenu());
              return;
            } else if (approvalStatus == 2) {
              // Rejected
              // Show toast when shop is rejected
              Fluttertoast.showToast(
                msg: "Your business application has been rejected.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.redAccent,
                textColor: Colors.white,
              );

              debugPrint("Shop rejected. Clearing shared preferences...");
              sharedPref.clear();
              // Fluttertoast.showToast(
              //     msg: "Your business application has been rejected.");

              await Future.delayed(const Duration(seconds: 1));
              //Get.offAll(() => const ShopLoginScreen());
              Get.offAll(() => const ShopDetailsRejectUpdateScreen());
              return;
            }
          } else {
            debugPrint("Error occurred in API response: ${result["message"]}");
          }
        } else {
          debugPrint(
              "Failed to fetch shop details. Status code: ${response.statusCode}");
        }
      } on SocketException {
        Fluttertoast.showToast(msg: "No internet connection. Retrying...");
        debugPrint("Network error occurred. Retrying...");
      } catch (e) {
        debugPrint('Error during API call: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }

      // Poll API every 10 seconds
      debugPrint("Waiting 60 seconds before retrying...");
      await Future.delayed(const Duration(seconds: 60));
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : const ShopWaitingScreen();
  }
}
