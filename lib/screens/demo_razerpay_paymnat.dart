// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:razorpay_web/razorpay_web.dart';
//
// void main() => runApp(const MyApp());
//
// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   late Razorpay _razorpay;
//   String? orderId ; // Store Order ID
//
//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//
//     // Razorpay event listeners
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }
//
//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }
//
//   // ✅ Step 1: Create Order Before Payment
//   Future<void> createOrderAndPay() async {
//     try {
//       var response = await http.post(
//         Uri.parse("https://rfid-n31h.onrender.com/api/payments/create-order"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "amount": 10000, // ₹100 in paise
//           "currency": "INR"
//         }),
//       );
//
//       log("🔄 API Response: ${response.body}");
//       log("🔄 Status Code: ${response.statusCode}");
//
//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         //orderId = data["order_id"]; // Extract order_id
//         orderId = "order_Q2g0uPe68zLjJV"; // Extract order_id
//
//         if (orderId != null) {
//           log("✅ Order Created: $orderId");
//           openCheckout();
//         } else {
//           log("❌ Order ID is NULL, API Response: $data");
//           Fluttertoast.showToast(msg: "Order creation failed: No Order ID");
//         }
//       } else {
//         log("❌ Order Creation Failed: ${response.body}");
//         Fluttertoast.showToast(msg: "Failed to create order. Try again.");
//       }
//     } catch (e) {
//       log("❌ Exception in Order Creation: $e");
//       Fluttertoast.showToast(msg: "Error creating order.");
//     }
//   }
//
//   // ✅ Step 2: Open Razorpay Payment Gateway
//   void openCheckout() async {
//     if (orderId == null) {
//       Fluttertoast.showToast(msg: "Order ID is missing. Try again.");
//       return;
//     }
//
//     var options = {
//       'key': 'rzp_test_1DP5mmOlF5G5ag', // Replace with your Razorpay Key
//       'amount': 10000, // ₹100 in paise
//       'currency': 'INR',
//       'order_id': orderId, // Attach Order ID
//       'name': 'Acme Corp.',
//       'description': 'Test Payment',
//       'prefill': {
//         'contact': '8888888888',
//         'email': 'test@razorpay.com',
//       },
//       'theme': {
//         'color': '#3399cc',
//       },
//       'external': {
//         'wallets': ['paytm'],
//       }
//     };
//
//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       debugPrint('❌ Error: $e');
//     }
//   }
//
//   // ✅ Step 3: Handle Payment Success
//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     log('✅ Payment Success: ${response.paymentId}');
//     Fluttertoast.showToast(
//       msg: "Payment Successful: ${response.paymentId}",
//       toastLength: Toast.LENGTH_SHORT,
//     );
//
//     // Call verification API
//     verifyPayment(response.paymentId!, response.signature!);
//   }
//
//   // ✅ Step 4: Verify Payment
//   Future<void> verifyPayment(String paymentId, String signature) async {
//     if (orderId == null) {
//       log("❌ Order ID is missing. Cannot verify payment.");
//       return;
//     }
//
//     try {
//       var response = await http.post(
//         Uri.parse("https://rfid-n31h.onrender.com/api/payments/verify-payment"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "order_id": "order_Q2g0uPe68zLjJV",
//           //"order_id": orderId,
//           "razorpay_payment_id": paymentId,
//           "razorpay_signature": signature,
//         }),
//       );
//
//       log("🔄 Payment Verification Response: ${response.body}");
//       log("🔄 Status Code: ${response.statusCode}");
//       log("🔄 response Body: ${response.body}");
//
//       if (response.statusCode == 200) {
//         Fluttertoast.showToast(msg: "Payment Verified Successfully!");
//       } else {
//         Fluttertoast.showToast(msg: "Payment Verification Failed.");
//       }
//     } catch (e) {
//       log("❌ Error Verifying Payment: $e");
//       Fluttertoast.showToast(msg: "Error verifying payment.");
//     }
//   }
//
//   // ✅ Handle Payment Error
//   void _handlePaymentError(PaymentFailureResponse response) {
//     log('❌ Payment Error: ${response.message}');
//     Fluttertoast.showToast(
//       msg: "Payment Failed: ${response.message}",
//       toastLength: Toast.LENGTH_SHORT,
//     );
//   }
//
//   // ✅ Handle External Wallet
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     log('ℹ️ External Wallet Used: ${response.walletName}');
//     Fluttertoast.showToast(
//       msg: "External Wallet Used: ${response.walletName}",
//       toastLength: Toast.LENGTH_SHORT,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(title: const Text('Razorpay Payment')),
//         body: Center(
//           child: ElevatedButton(
//             onPressed: createOrderAndPay, // First create order, then pay
//             child: const Text('Pay with Razorpay'),
//           ),
//         ),
//       ),
//     );
//   }
// }
