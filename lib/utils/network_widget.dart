// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class NetworkController extends GetxController {
//   final Connectivity _connectivity = Connectivity();
//
//   @override
//   void onInit() {
//     super.onInit();
//     _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
//   }
//
//   void _updateConnectionStatus(List<ConnectivityResult> connectivityResults) {
//     // Check the latest connectivity result
//     ConnectivityResult connectivityResult = connectivityResults.last;
//
//     if (connectivityResult == ConnectivityResult.none) {
//       Get.rawSnackbar(
//           messageText: const Text(
//             'PLEASE CONNECT TO THE INTERNET',
//             style: TextStyle(color: Colors.white, fontSize: 14),
//           ),
//           isDismissible: false,
//           duration: const Duration(days: 1),
//           backgroundColor: Colors.red[400]!,
//           icon : const Icon(Icons.wifi_off, color: Colors.white, size: 35,),
//           margin: EdgeInsets.zero,
//           snackStyle: SnackStyle.GROUNDED
//       );
//     } else {
//       if (Get.isSnackbarOpen) {
//         Get.closeCurrentSnackbar();
//       }
//     }
//   }
//
// }

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    // Listening to connectivity changes
    // _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
    //   _updateConnectionStatus(results.last);
    // });
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> connectivityResults) {
    // Check the latest connectivity result
    ConnectivityResult connectivityResult = connectivityResults.last;

    if (connectivityResult == ConnectivityResult.none) {
      // Show "No Internet" snackbar
      Get.rawSnackbar(
        messageText: const Text(
          'PLEASE CONNECT TO THE INTERNET',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        isDismissible: false,
        duration: const Duration(days: 1),
        backgroundColor: Colors.red[400]!,
        icon: const Icon(Icons.wifi_off, color: Colors.white, size: 35),
        margin: EdgeInsets.zero,
        snackStyle: SnackStyle.GROUNDED,
      );
    } else {
      // Check if a snackbar is open and close it
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      // Show "You are online" snackbar
      // Get.rawSnackbar(
      //   messageText: const Text(
      //     'You are online',
      //     style: TextStyle(color: Colors.white, fontSize: 14),
      //   ),
      //   isDismissible: true,
      //   duration: const Duration(seconds: 3),
      //   backgroundColor: Colors.green[400]!,
      //   icon: const Icon(Icons.wifi, color: Colors.white, size: 35),
      //   margin: EdgeInsets.zero,
      //   snackStyle: SnackStyle.GROUNDED,
      // );
    }
  }
}
