// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:pdf/pdf.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// class Subscripation_plan_paymant extends StatefulWidget {
//   const Subscripation_plan_paymant({super.key});
//
//   @override
//   State<Subscripation_plan_paymant> createState() =>
//       _Subscripation_plan_paymantState();
// }
//
// class _Subscripation_plan_paymantState
//     extends State<Subscripation_plan_paymant> {
//   late Razorpay razorpay;
//   String selectedPlan = '';
//   String? pdfFilePath;
//   String userName = "";
//   String userEmail = "";
//   String userImageUrl = "";
//   String userPhone = "";
//   bool isLoading = false;
//   int shopId = 0;
//   List<dynamic> plans = [];
//   bool hasError = false;
//
//   final String merchantName = "Dprofiz Pvt Ltd";
//   final String upiHandle = "DPROFIZ23.09@cmsidfc"; // BHIM UPI handle
//   //final String upiHandle = "dprofiz@upi"; // BHIM UPI handle
//
//   @override
//   void initState() {
//     super.initState();
//     fetchPlans();
//     razorpay = Razorpay();
//     _retrieveData();
//
//     // Add event listeners to handle payment events
//     razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }
//
//   @override
//   void dispose() {
//     // Clean up Razorpay instance to avoid memory leaks
//     razorpay.clear();
//     super.dispose();
//   }
//
//   Future<void> _retrieveData() async {
//     var sharedPref = await SharedPreferences.getInstance();
//     setState(() {
//       isLoading = true;
//
//       // Retrieve data from SharedPreferences
//       userName = sharedPref.getString('owner_name') ?? 'User Name';
//       userEmail = sharedPref.getString('owner_email') ?? 'user@example.com';
//       shopId = sharedPref.getInt("shop_id") ?? 0;
//       userPhone = sharedPref.getString("phone_number") ?? '1122334455';
//
//       // Add print statements to debug
//       print('Retrieved owner_name: $userName');
//       print('Retrieved owner_email: $userEmail');
//       print('Retrieved shop_id: $shopId');
//       print('Retrieved Phone number: $userPhone');
//     });
//   }
//
//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     print("Payment Successful! Payment ID: ${response.paymentId}");
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text('Payment Successful! Payment ID: ${response.paymentId}'),
//     ));
//
//     await _generateInvoice(
//       // response.paymentId!, selectedPlan
//       response.paymentId ?? "N/A",
//       response.orderId ?? "N/A",
//       selectedPlan,
//       1 * 100, // Adjust amount as per plan
//     );
//
//     // generateAndOpenPDF(
//     //   response.paymentId ?? "N/A",
//     //   response.orderId ?? "N/A",
//     //   selectedPlan,
//     //   1 * 100, // Adjust amount as per plan
//     // );
//
//     // Show invoice options
//     _showInvoiceOptions();
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) {
//     print("Payment Failed! Error: ${response.message}");
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text('Payment Failed! Error: ${response.message}'),
//     ));
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     print("External Wallet Selected! Wallet Name: ${response.walletName}");
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text('External Wallet Selected: ${response.walletName}'),
//     ));
//   }
//
//   Future<void> _generateInvoice(
//       String paymentId, String orderId, String planName, int amount) async {
//     final pdf = pw.Document();
//     final logoBytes = await rootBundle.load('images/pdflogo.png');
//     final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
//     final dplogoBytes = await rootBundle.load('images/dp-logo.png');
//     final dplogoImage = pw.MemoryImage(dplogoBytes.buffer.asUint8List());
//
//     // Generate invoice content
//     pdf.addPage(
//       pw.Page(
//         build: (pw.Context context) => pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             // Header and Logo
//             pw.Center(
//               child: pw.Column(
//                 children: [
//                   pw.Image(logoImage),
//                   // pw.Image(pw.MemoryImage(File('images/pdflogo.png').readAsBytesSync())),
//                   pw.SizedBox(height: 20),
//                   pw.Text(
//                     'Invoice',
//                     style: pw.TextStyle(
//                         fontSize: 24, fontWeight: pw.FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//             pw.SizedBox(height: 20),
//
//             // Invoice Details
//             pw.Text('Invoice Number: $orderId',
//                 style: pw.TextStyle(fontSize: 12)),
//             pw.Text('Payment ID: $paymentId',
//                 style: pw.TextStyle(fontSize: 12)),
//             pw.Text('Date: ${DateTime.now().toString()}',
//                 style: pw.TextStyle(fontSize: 12)),
//             pw.SizedBox(height: 10),
//
//             // Bill To
//             pw.Text('BILL FROM:',
//                 style:
//                     pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
//             pw.Text('Name: Partner Name'),
//             pw.Text('Email: test@razorpay.com'),
//             pw.Text('Phone: 8888888888'),
//             pw.SizedBox(height: 20),
//
//             // Bill To
//             pw.Text('BILL TO:',
//                 style:
//                     pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
//             pw.Text('Shop Id : $shopId'),
//             pw.Text('Name : $userName'),
//             pw.Text('Email id : $userEmail'),
//             pw.Text('Phone No : $userPhone'),
//             pw.SizedBox(height: 20),
//
//             // Invoice Table
//             pw.Table(
//               border: pw.TableBorder.all(),
//               columnWidths: {
//                 0: pw.FlexColumnWidth(3),
//                 1: pw.FlexColumnWidth(1),
//               },
//               children: [
//                 pw.TableRow(
//                   decoration:
//                       pw.BoxDecoration(color: PdfColor.fromHex("#E0E0E0")),
//                   children: [
//                     pw.Padding(
//                       padding: const pw.EdgeInsets.all(8.0),
//                       child: pw.Text('ITEM DESCRIPTION',
//                           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//                     ),
//                     pw.Padding(
//                       padding: const pw.EdgeInsets.all(8.0),
//                       child: pw.Text('PRICE',
//                           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//                     ),
//                   ],
//                 ),
//                 pw.TableRow(
//                   children: [
//                     pw.Padding(
//                       padding: const pw.EdgeInsets.all(8.0),
//                       child: pw.Text(planName),
//                     ),
//                     pw.Padding(
//                       padding: const pw.EdgeInsets.all(8.0),
//                       child: pw.Text('Rs.${amount / 100}'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             pw.SizedBox(height: 20),
//
//             // Total Due
//             pw.Align(
//               alignment: pw.Alignment.centerRight,
//               child: pw.Text(
//                 'Total Amount Rs.${amount / 100}',
//                 style:
//                     pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
//               ),
//             ),
//             pw.SizedBox(height: 20),
//
//             // Footer
//             pw.Text('Thank You!',
//                 style:
//                     pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
//             pw.SizedBox(height: 10),
//             pw.Text('Administrator, Dprofiz Pvt Ltd'),
//             pw.Image(dplogoImage),
//             pw.SizedBox(height: 10),
//             pw.Image(logoImage),
//           ],
//         ),
//       ),
//     );
//
//     // Save the PDF to the temporary directory
//     final outputDir = await getTemporaryDirectory();
//     final file = File('${outputDir.path}/invoice.pdf');
//     await file.writeAsBytes(await pdf.save());
//
//     setState(() {
//       pdfFilePath = file.path;
//     });
//   }
//
//   // void generateAndOpenPDF(String paymentId, String orderId, String planName, int amount) async {
//   //   final pdf = pw.Document();
//   //
//   //   pdf.addPage(
//   //     pw.Page(
//   //       build: (pw.Context context) => pw.Column(
//   //         crossAxisAlignment: pw.CrossAxisAlignment.start,
//   //         children: [
//   //           // Header and Logo
//   //           pw.Center(
//   //             child: pw.Column(
//   //               children: [
//   //                 pw.Image(pw.MemoryImage(File('images/pdflogo.png').readAsBytesSync())),
//   //                 pw.SizedBox(height: 10),
//   //                 pw.Text(
//   //                   'Invoice',
//   //                   style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
//   //                 ),
//   //               ],
//   //             ),
//   //           ),
//   //           pw.SizedBox(height: 20),
//   //
//   //           // Invoice Details
//   //           pw.Text('Invoice Number: $orderId', style: pw.TextStyle(fontSize: 12)),
//   //           pw.Text('Payment ID: $paymentId', style: pw.TextStyle(fontSize: 12)),
//   //           pw.Text('Date: ${DateTime.now().toString()}', style: pw.TextStyle(fontSize: 12)),
//   //           pw.SizedBox(height: 10),
//   //
//   //           // Bill To
//   //           pw.Text('BILL FROM:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
//   //           pw.Text('Name: Partner Name'),
//   //           pw.Text('Email: test@razorpay.com'),
//   //           pw.Text('Phone: 8888888888'),
//   //           pw.SizedBox(height: 20),
//   //
//   //           // Invoice Table
//   //           pw.Table(
//   //             border: pw.TableBorder.all(),
//   //             columnWidths: {
//   //               0: pw.FlexColumnWidth(3),
//   //               1: pw.FlexColumnWidth(1),
//   //             },
//   //             children: [
//   //               pw.TableRow(
//   //                 decoration: pw.BoxDecoration(color: PdfColor.fromHex("#E0E0E0")),
//   //                 children: [
//   //                   pw.Padding(
//   //                     padding: const pw.EdgeInsets.all(8.0),
//   //                     child: pw.Text('ITEM DESCRIPTION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//   //                   ),
//   //                   pw.Padding(
//   //                     padding: const pw.EdgeInsets.all(8.0),
//   //                     child: pw.Text('PRICE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//   //                   ),
//   //                 ],
//   //               ),
//   //               pw.TableRow(
//   //                 children: [
//   //                   pw.Padding(
//   //                     padding: const pw.EdgeInsets.all(8.0),
//   //                     child: pw.Text(planName),
//   //                   ),
//   //                   pw.Padding(
//   //                     padding: const pw.EdgeInsets.all(8.0),
//   //                     child: pw.Text('₹${amount / 100}'),
//   //                   ),
//   //                 ],
//   //               ),
//   //             ],
//   //           ),
//   //           pw.SizedBox(height: 20),
//   //
//   //           // Total Due
//   //           pw.Align(
//   //             alignment: pw.Alignment.centerRight,
//   //             child: pw.Text(
//   //               'Total Due: ₹${amount / 100}',
//   //               style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
//   //             ),
//   //           ),
//   //           pw.SizedBox(height: 20),
//   //
//   //           // Footer
//   //           pw.Text('Thank You!', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
//   //           pw.SizedBox(height: 10),
//   //           pw.Text('Administrator, Dprofiz Pvt Ltd'),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   //
//   //   // Save PDF
//   //   final output = await getApplicationDocumentsDirectory();
//   //   final file = File('${output.path}/invoice.pdf');
//   //   await file.writeAsBytes(await pdf.save());
//   //
//   //   // Open PDF for Viewing
//   //   await Printing.sharePdf(bytes: await pdf.save(), filename: 'invoice.pdf');
//   // }
//
//   void _showInvoiceOptions() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Invoice Generated'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('Your invoice has been generated.'),
//             if (pdfFilePath != null) Text('Path: $pdfFilePath'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Printing.layoutPdf(
//                   onLayout: (_) => File(pdfFilePath!).readAsBytes());
//             },
//             child: Text('Print Invoice'),
//           ),
//           TextButton(
//             onPressed: () {
//               Printing.sharePdf(
//                   bytes: File(pdfFilePath!).readAsBytesSync(),
//                   filename: 'invoice.pdf');
//             },
//             child: Text('Share Invoice'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // void openPayment(String plan) {
//   //   int amount;
//   //   switch (plan) {
//   //     case 'Basic':
//   //       amount = 1 * 100;
//   //       break;
//   //     case 'Medium':
//   //       amount = 5 * 100;
//   //       break;
//   //     case 'Advanced':
//   //       amount = 10 * 100;
//   //       break;
//   //     default:
//   //       amount = 1 * 100;
//   //       break;
//   //   }
//   //
//   //   // var options = {
//   //   //   'key': 'rzp_test_1DP5mmOlF5G5ag',
//   //   //   'amount': amount,
//   //   //   'name': 'Trashee Shop',
//   //   //   'description': 'Business Partner Subscription Plan: $plan',
//   //   //   'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
//   //   // };
//   //
//   //   var options = {
//   //     'key': 'rzp_test_8HoZTGB2PMriVt',
//   //     //'key': 'rzp_test_1DP5mmOlF5G5ag',
//   //     'amount': amount,
//   //     'name': merchantName,
//   //     'description': 'Business Partner Subscription Plan: $plan',
//   //     'prefill': {'contact': userPhone, 'email': userEmail},
//   //     'upi': upiHandle,
//   //     'retry': {'enabled': true, 'max_count': 1},
//   //     'send_sms_hash': true,
//   //     'notes': {
//   //       'Merchant Name': merchantName,
//   //       'UPI Handle': upiHandle,
//   //     },
//   //     'external': {
//   //       'wallets': ['paytm']
//   //     },
//   //
//   //     'disable_redesign_v15': false,
//   //     'experiments.upi_turbo':true,
//   //     'ep':'https://api-web-turbo-upi.ext.dev.razorpay.in/test/checkout.html?branch=feat/turbo/tpv'
//   //   };
//   //
//   //   try {
//   //     razorpay.open(options);
//   //   } catch (e) {
//   //     print("Error opening Razorpay: $e");
//   //   }
//   // }
//
//   Future<void> fetchPlans() async {
//     try {
//       final response = await http.get(
//         Uri.parse('https://syntaxium.in/DUSTBIN_API/shopkeeper_plans.php'),
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           plans = data['plans']; // Adjust based on API response structure
//           isLoading = false;
//         });
//       } else {
//         throw Exception('Failed to load plans');
//       }
//     } catch (error) {
//       setState(() {
//         hasError = true;
//         isLoading = false;
//       });
//       debugPrint("Error fetching plans: $error");
//     }
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Subscription Plans')),
//       body: Column(
//         children: [
//           // Subscription plans UI here
//
//           Text(
//             'Choose Your Subscription Plan',
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//           ),
//           SizedBox(height: 20),
//
//           // Subscription Plan Cards
//           Expanded(
//             child: GridView.builder(
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 1,
//                 crossAxisSpacing: 20,
//                 mainAxisSpacing: 20,
//                 childAspectRatio: 3 / 2,
//               ),
//               itemCount: 3,
//               itemBuilder: (context, index) {
//                 String planName;
//                 String planDesc;
//                 String price;
//                 switch (index) {
//                   case 0:
//                     planName = 'Basic';
//                     planDesc = 'Basic Plan for small shops.';
//                     price = '₹1';
//                     break;
//                   case 1:
//                     planName = 'Medium';
//                     planDesc = 'Medium Plan for growing businesses.';
//                     price = '₹5';
//                     break;
//                   case 2:
//                     planName = 'Advanced';
//                     planDesc = 'Advanced Plan for large enterprises.';
//                     price = '₹10';
//                     break;
//                   default:
//                     planName = '';
//                     planDesc = '';
//                     price = '';
//                     break;
//                 }
//
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       selectedPlan = planName;
//                     });
//                     //openPayment(planName);
//                   },
//                   child: Card(
//                     elevation: 5,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.business,
//                           size: 50,
//                           color: Colors.blue,
//                         ),
//                         SizedBox(height: 10),
//                         Text(
//                           planName,
//                           style: Theme.of(context)
//                               .textTheme
//                               .displayMedium
//                               ?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                         ),
//                         SizedBox(height: 5),
//                         Text(
//                           planDesc,
//                           textAlign: TextAlign.center,
//                           style:
//                               Theme.of(context).textTheme.bodyLarge?.copyWith(
//                                     color: Colors.grey[600],
//                                   ),
//                         ),
//                         SizedBox(height: 20),
//                         Text(
//                           price,
//                           style:
//                               Theme.of(context).textTheme.bodyMedium?.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.green,
//                                   ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//
//           SizedBox(height: 20),
//
//           if (selectedPlan.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 4),
//               child: GestureDetector(
//                 onTap: () {
//                   //openPayment(selectedPlan); // Ensure selectedPlan is defined
//                 },
//                 child: Container(
//                   padding: EdgeInsets.symmetric(vertical: 15),
//                   // Vertical padding for the "button" size
//                   decoration: BoxDecoration(
//                     color: Colors.blue, // Button background color
//                     borderRadius: BorderRadius.circular(12), // Rounded corners
//                   ),
//                   child: Center(
//                     child: Text(
//                       'Pay for $selectedPlan Plan',
//                       // Dynamically shows the selected plan
//                       style: TextStyle(
//                         fontSize: 16, // Font size for the text
//                         fontWeight: FontWeight.bold, // Text weight
//                         color: Colors.white, // Text color (white for contrast)
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
