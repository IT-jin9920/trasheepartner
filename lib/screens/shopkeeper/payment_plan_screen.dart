import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import 'dart:convert';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../navigation_menu.dart';
import 'payment_invoice_genrate_screen_view.dart';

class PlanDemo extends StatefulWidget {
  const PlanDemo({super.key});

  @override
  State<PlanDemo> createState() => _PlanDemoState();
}

class _PlanDemoState extends State<PlanDemo> {
  int owner_id = 0;
  int planId = 0;
  String userName = "";
  String userEmail = "";
  String userImageUrl = "";
  String userPhone = "";
  String? pdfFilePath;
  String? selectedPlanDuration;
  late Razorpay razorpay;
  List<dynamic> plans = [];
  bool isLoading = true;
  final String merchantName = "Dprofiz Pvt Ltd";
  final String upiHandle = "DPROFIZ23.09@cmsidfc";

  @override
  void initState() {
    super.initState();
    fetchPlans();
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    razorpay
        .clear(); // Dispose the Razorpay instance when the widget is disposed
    super.dispose();
  }

  Future<void> fetchPlans() async {
    var sharedPref = await SharedPreferences.getInstance();
    owner_id = sharedPref.getInt('owner_id') ?? 0;


    var url = 'https://syntaxium.in/DUSTBIN_API/shopkeeper_plans.php';
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          plans = data['plan_details'];
          isLoading = false;
        });
      } else {
        showError('Failed to load plans. Please try again later.');
      }
    } catch (error) {
      showError('Network error: $error');
    }
  }

  void showError(String message) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<Widget> formatFeatures(String featureText) {
    List<Widget> formattedText = [];
    List<String> lines = featureText.split("\n");
    for (String line in lines) {
      if (line.contains('*')) {
        int start = line.indexOf('*');
        int end = line.lastIndexOf('*');
        if (start != -1 && end != -1 && end > start) {
          String beforeBold = line.substring(0, start);
          String boldText = line.substring(start + 1, end);
          String afterBold = line.substring(end + 1);
          formattedText.add(Text(beforeBold));
          formattedText.add(Text(
            boldText,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ));
          formattedText.add(Text(afterBold));
        }
      } else {
        formattedText.add(Text(line));
      }
      formattedText.add(const SizedBox(height: 4));
    }
    return formattedText;
  }

  void openPayment(var plan) {
    print("Plan Details -> : $plan");

    // Extract dynamic values from the plan object (API response)
    String planName = plan['plan_name'] ?? 'Unknown Plan';
    planId = int.parse(plan['id']?.toString() ?? '1');
    String selectedDuration = plan['selected_duration'] ?? 'Monthly';

    // Dynamically calculate the amount based on the selected duration
    int amount = 0;
    switch (selectedDuration) {
      case 'Monthly':
        amount = (plan['monthly_price'] ?? 1) * 100;
        break;
      case 'Quarterly':
        amount = (plan['quaterly_price'] ?? 1) * 100;
        break;
      case 'Half-Yearly':
        amount = (plan['half_yearly_price'] ?? 1) * 100;
        break;
      case 'Yearly':
        amount = (plan['yearly_price'] ?? 1) * 100;
        break;
      default:
        amount = 1 * 100; // Fallback to a default value if no duration matches
    }

    // Print the selected plan details, including the price for the selected duration
    print("Selected Plan Name: $planName");
    print("Selected Plan ID: $planId");
    print("Selected Duration: $selectedDuration");
    print("Amount to Pay: ₹$amount");

    // Razorpay options with dynamic values from the plan object
    var options = {
     // 'key': 'rzp_test_00c36kD21CoCL3',
      'key': 'rzp_live_7OyHnlSm8NglEZ',
      'amount': amount,
      'name': merchantName,
      'description': 'Subscription Plan: $planName',
      'prefill': {'contact': '9016235324', 'email': 'info.dprofiz@gmail.com'},
      'notes': {'Merchant Name': merchantName, 'Plan ID': planId.toString()},
      'external': {
        'wallets': ['paytm']
      },
    };

    try {
      razorpay.open(options);
    } catch (e) {
      print("Error opening Razorpay: $e");
    }
  }

  // Future<void> PaymantofPlan({
  //   required String planId, // Plan ID
  //   required String paymentId, // Payment ID
  //   required String paymentTime, // Payment Time
  //   required String status, // Status (Payment status)
  //   required String partnerId, // Partner ID
  //   required String payment_duration_name, // Partner ID
  // }) async {
  //   var sharedPref = await SharedPreferences.getInstance();
  //   int ownerId = sharedPref.getInt('owner_id') ?? 0; // Get owner_id from SharedPreferences
  //
  //   var url = 'https://syntaxium.in/DUSTBIN_API/shopkeeper_subscription_plan_buy.php';
  //
  //   // Debug logs for input parameters
  //   print("API Endpoint: $url");
  //   print("Request Parameters:");
  //   print("Plan ID: $planId");
  //   print("Payment ID: $paymentId");
  //   print("Payment Time: $paymentTime");
  //   print("Status: $status");
  //   print("Partner ID: $partnerId");
  //   print("Owner ID: $ownerId");
  //   print("Plan Duration ID: $selectedPlanDuration");
  //
  //   try {
  //     var response = await http.post(
  //       Uri.parse(url),
  //       body: {
  //         'plan_id': planId,
  //         'payment_id': paymentId,
  //         'payment_time': paymentTime,
  //         'status': status,
  //         'partner_id': partnerId,
  //         'owner_id': ownerId.toString(),
  //         'payment_duration_name': selectedPlanDuration.toString().trim(),
  //       },
  //     );
  //
  //     // Log HTTP response status code
  //     print("Response Status Code: ${response.statusCode}");
  //
  //     if (response.statusCode == 200) {
  //       var data = jsonDecode(response.body);
  //
  //       // Log response data
  //       print("Response Data: $data");
  //
  //       setState(() {
  //         // Example: Uncomment this if you have `plans` in your state
  //         // plans = data['plan_details']; // Update the plans data
  //         isLoading = false;
  //       });
  //
  //       if (data['error'] == false && data["payment_data"]["status"]=="done"){
  //         // Log success message from the API
  //         print("API Success Message: ${data['message']}");
  //
  //         Fluttertoast.showToast(
  //           msg: data['message'],
  //         );
  //
  //
  //         // Show invoice options
  //         _showInvoiceOptions();
  //
  //       } else {
  //         // Log error message from the API
  //         print("API Error Message: ${data['message']}");
  //         showError(data['message']);
  //       }
  //     } else {
  //       // Log error for non-200 status codes
  //       print("HTTP Error: Failed to load plans. Status Code: ${response.statusCode}");
  //       showError('Failed to load plans. Please try again later.');
  //     }
  //   } catch (error) {
  //     // Log network error details
  //     print("Network Error: $error");
  //     showError('Network error: $error');
  //   }
  // }

  Future<void> PaymantofPlan({
    required String planId,
    required String paymentId,
    required String paymentTime,
    required String status,
    required String partnerId,
    required String payment_duration_name,
  }) async {
    setState(() {
      isLoading = true; // Start loader
    });

    var sharedPref = await SharedPreferences.getInstance();
    int ownerId = sharedPref.getInt('owner_id') ?? 0;
    // Retrieve values from SharedPreferences
    //int ownerId = sharedPref.getInt('shop_id') ?? 0;
    String userName = sharedPref.getString('owner_name') ?? 'User Name';
    String userEmail = sharedPref.getString('owner_email') ?? 'user@example.com';
    String userPhone = sharedPref.getString('owner_phone') ?? '0000000000';

    // Log the retrieved values for debugging
    debugPrint("Retrieved Data :");
    debugPrint("  User Name: $userName");
    debugPrint("  User Email: $userEmail");
    debugPrint("  User Phone: $userPhone");

    var url = 'https://syntaxium.in/DUSTBIN_API/shopkeeper_subscription_plan_buy.php';

    debugPrint("API Endpoint: $url");
    debugPrint("Request Parameters:");
    debugPrint("Plan ID: $planId");
    debugPrint("Payment ID: $paymentId");
    debugPrint("Payment Time: $paymentTime");
    debugPrint("Status: $status");
    debugPrint("Partner ID: $partnerId");
    debugPrint("Owner ID: $ownerId");
    debugPrint("Plan Duration Name: $payment_duration_name");

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'plan_id': planId,
          'payment_id': paymentId,
          'payment_time': paymentTime,
          'status': status,
          'partner_id': partnerId,
          'owner_id': ownerId.toString(),
          'payment_duration_name': payment_duration_name.trim(),
        },
      );

      debugPrint("Response Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        debugPrint("Response Data: $data");

        setState(() {
          isLoading = false; // Stop loader
        });

        if (data['error'] == false) {
          debugPrint("API Success Message: ${data['message']}");
          Fluttertoast.showToast(
            msg: data['message'],
          );

          // Log subscription data
          if (data['subscription_data'] != null) {
            debugPrint("Subscription Data:");
            debugPrint("  Monthly Price: ${data['subscription_data']['monthly_price']}");
            debugPrint("  Allocated Quantity: ${data['subscription_data']['allocated_quantity']}");
          } else {
            debugPrint("No subscription data available in the response.");
          }

          // Call _showInvoiceOptions after successful payment
          //_showInvoiceOptions();

          // Invoice Number
          // Shop id
          // Name
          // Email
          // Phone

          // Navigate to Invoice Page with Data
          Get.to(
                () => PaymentInvoiceGenrateScreenView(),
            arguments: {
              "paymentId": paymentId,
              "paymentTime": paymentTime,
              "partnerId": partnerId,
              "payment_duration_name": payment_duration_name,
              "monthly_price": data['subscription_data']['monthly_price'],
              "allocated_quantity": data['subscription_data']['allocated_quantity'],
              "ownerId": ownerId,
              "userName": userName,
              "userEmail": userEmail,
              "userPhone": userPhone,
            },
          );

          // Log the arguments being passed to the next screen
          debugPrint("Navigating to PaymentInvoiceGenrateScreenView with the following arguments:");
          debugPrint("Payment ID: $paymentId");
          debugPrint("Payment Time: $paymentTime");
          debugPrint("Partner ID: $partnerId");
          debugPrint("Plan Duration Name: $payment_duration_name");
          debugPrint("Monthly Price: ${data['subscription_data']['monthly_price']}");
          debugPrint("Allocated Quantity: ${data['subscription_data']['allocated_quantity']}");
          debugPrint("Owner ID: $ownerId");
          debugPrint("User Name: $userName");
          debugPrint("User Email: $userEmail");
          debugPrint("User Phone: $userPhone");



        } else {
          debugPrint("API Error Message: ${data['message']}");
          showError(data['message']);
        }
      } else {
        debugPrint("HTTP Error: Failed to load plans. Status Code: ${response.statusCode}");
        setState(() {
          isLoading = false; // Stop loader
        });
        showError('Failed to load plans. Please try again later.');
      }
    } catch (error) {
      debugPrint("Network Error: $error");
      setState(() {
        isLoading = false; // Stop loader
      });
      //showError('Network error: $error');
    }
  }


  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    String paymentId = response.paymentId ?? "N/A";
    String orderId = response.orderId ?? "N/A";
    String paymentTime = DateTime.now().toIso8601String(); // Current timestamp
    String status = "done";
    // int partnerId = 123; // Replace with actual partner_id if available

    print("Payment Details:");
    print("Plan ID 357: $planId"); // Ensure `selectedPlan` contains the plan ID
    print("Payment ID: $paymentId");
    print("Payment Time: $paymentTime");
    print("Status: $status");
    print("Partner ID: $owner_id");

    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: Text('Payment Successful! Payment ID: $paymentId'),
    // ));

    // await _generateInvoice(
    //   paymentId,
    //   orderId,
    //   planId.toString(),
    //   1 * 100, // Adjust amount as per plan
    // );

    PaymantofPlan(
      planId: planId.toString(),
      paymentId: paymentId,
      paymentTime: paymentTime,
      status: status,
      partnerId: owner_id.toString(),
      payment_duration_name: selectedPlanDuration ?? 'Monthly', // Default value
    );

    // // Show invoice options
    //_showInvoiceOptions();


    //Get.offAll(NavigationMenu());
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    String paymentId =
        "N/A"; // Payment ID is not available in PaymentFailureResponse
    String paymentTime = DateTime.now().toIso8601String(); // Current timestamp
    String status = "fail"; // Status is "Failed" when payment fails

    // Assuming you have a way to get planId and ownerId (you may already have them from the context)
    print(planId);
    print("397");
    PaymantofPlan(
      planId: planId.toString(),
      paymentId: paymentId,
     //paymentId: '0',
      paymentTime: paymentTime,
      status: status,
      partnerId: owner_id.toString(),
      payment_duration_name: selectedPlanDuration ?? 'Monthly', // Default value
    );

    print("Payment Error: ");
    print("Plan ID: $planId");
    print("Payment ID: $paymentId");
    print("Payment Time: $paymentTime");
    print("Status: $status");
    print("Partner ID: $owner_id");
    print("Error Message: ${response.message}");
    print("Error code: ${response.code}");
    print("Error error: ${response.error}");

    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: Text('Payment Failed! Error: ${response.message}'),
    // ));

    //Get.offAll(NavigationMenu());
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    String paymentTime = DateTime.now().toIso8601String(); // Current timestamp
    String status = "External Wallet Selected";

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('External Wallet Selected: ${response.walletName}'),
    ));
  }

  void _showInvoiceOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invoice Generated'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Your invoice has been generated.'),
            if (pdfFilePath != null) Text('Path: $pdfFilePath'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Printing.layoutPdf(
                  onLayout: (_) => File(pdfFilePath!).readAsBytes());
            },
            child: const Text('Print Invoice'),
          ),
          TextButton(
            onPressed: () {
              Printing.sharePdf(
                  bytes: File(pdfFilePath!).readAsBytesSync(),
                  filename: 'invoice.pdf');
            },
            child: const Text('Share Invoice'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateInvoice(
      String paymentId, String orderId, String planName, int amount) async {
    final pdf = pw.Document();
    final logoBytes = await rootBundle.load('images/pdflogo.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    final dplogoBytes = await rootBundle.load('images/dp-logo.png');
    final dplogoImage = pw.MemoryImage(dplogoBytes.buffer.asUint8List());

    // Generate invoice content
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header and Logo
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Image(logoImage),
                  // pw.Image(pw.MemoryImage(File('images/pdflogo.png').readAsBytesSync())),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Invoice',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Invoice Details
            pw.Text('Invoice Number: $orderId',
                style: const pw.TextStyle(fontSize: 12)),
            pw.Text('Payment ID: $paymentId',
                style: const pw.TextStyle(fontSize: 12)),
            pw.Text('Date: ${DateTime.now().toString()}',
                style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 10),

            // Bill To
            pw.Text('BILL FROM:',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text('Name: Dprofiz Pvt Ltd'),
            pw.Text('Email: Dprofiz.in'),
            pw.Text('Phone: 9016235324'),
            pw.SizedBox(height: 20),

            // Bill To
            pw.Text('BILL TO:',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text('Shop Id : $owner_id'),
            pw.Text('Name : $userName'),
            pw.Text('Email id : $userEmail'),
            pw.Text('Phone No : $userPhone'),
            pw.SizedBox(height: 20),

            // Invoice Table
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration:
                      pw.BoxDecoration(color: PdfColor.fromHex("#E0E0E0")),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text('ITEM DESCRIPTION',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text('PRICE',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(planName),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text('Rs.${amount / 100}'),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Total Due
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Total Amount Rs.${amount / 100}',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),

            // Footer
            pw.Text('Thank You!',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Administrator, Dprofiz Pvt Ltd'),
            pw.Image(dplogoImage),
            pw.SizedBox(height: 10),
            pw.Image(logoImage),
          ],
        ),
      ),
    );

    // Save the PDF to the temporary directory
    final outputDir = await getTemporaryDirectory();
    final file = File('${outputDir.path}/invoice.pdf');
    await file.writeAsBytes(await pdf.save());

    setState(() {
      pdfFilePath = file.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        //centerTitle: true,
        //backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : plans.isEmpty
              ? const Center(
                  child: Text(
                    'No plans available.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height:
                        plans.length * 410, // Constrained height for better UX
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: plans.length,
                      itemBuilder: (context, index) {
                        final plan = plans[index];
                        final priceOptions = {
                          'Monthly': '₹${plan['monthly_price']}',
                          'Quarterly': '₹${plan['quaterly_price']}',
                          'Half-Yearly': '₹${plan['half_yearly_price']}',
                          'Yearly': '₹${plan['yearly_price']}',
                        };

                        return StatefulBuilder(
                          builder: (context, setState) {
                            String? selectedOption;

                            return Container(
                              width: 280,
                              margin: const EdgeInsets.only(right: 16),
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${plan['id']} -> ${plan['plan_name']}',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Features:',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: _parsePlanFeatures(
                                            plan['plan_features']),
                                      ),
                                      // SizedBox(height: 16),
                                      // DropdownButton<String>(
                                      //   value: selectedOption,
                                      //   hint: Text('Choose a plan'),
                                      //   isExpanded: true,
                                      //   items: priceOptions.entries.map((entry) {
                                      //     return DropdownMenuItem<String>(
                                      //       value: entry.key,
                                      //       child: Text('${entry.key} - ${entry.value}'),
                                      //     );
                                      //   }).toList(),
                                      //   onChanged: (value) {
                                      //     setState(() {
                                      //       selectedPlanDuration = value;
                                      //     });
                                      //     print(
                                      //         'Selected Plan: $value, Price: ${priceOptions[value]}');
                                      //   },
                                      // ),

                                      const Spacer(),
                                      DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                          labelText: 'Plan Duration',
                                          prefixIcon: Icon(Icons.access_time),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(4.0)),
                                          ),
                                        ),
                                        value: selectedPlanDuration,
                                        // Bind the selected value
                                        hint: const Text('Choose a plan'),
                                        isExpanded: true,
                                        items:
                                            priceOptions.entries.map((entry) {
                                          return DropdownMenuItem<String>(
                                            value: entry.key,
                                            child: Text(
                                                '${entry.key} - ${entry.value}'),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedPlanDuration = value;
                                          });
                                          print(selectedPlanDuration);
                                          print(
                                              'Selected Plan: $value, Price: ${priceOptions[value]}');
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please select a plan duration';
                                          }
                                          return null;
                                        },
                                      ),

                                      SizedBox(
                                        height: 110,
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 16),
                                            if (selectedPlanDuration != null)
                                              Text(
                                                'Selected Plan: $selectedPlanDuration - ${priceOptions[selectedPlanDuration]}',
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.green),
                                              ),
                                            const SizedBox(height: 16),
                                            if (selectedPlanDuration != null)
                                              Center(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    debugPrint(
                                                        "Subscribe button clicked for Plan ID: ${plan['id']}");
                                                    debugPrint(
                                                        "Subscribe button clicked for Plan Duration: ${selectedPlanDuration}");
                                                    debugPrint(
                                                        "Subscribe button clicked for Plan Duration: ${priceOptions[selectedPlanDuration]}");

                                                    // Ensure selectedPlanDuration has a value
                                                    if (selectedPlanDuration ==
                                                            null ||
                                                        selectedPlanDuration!
                                                            .isEmpty) {
                                                      print(
                                                          'Error: No plan duration selected');
                                                      return;
                                                    }

                                                    // Print the selected plan and its price in separate lines
                                                    print(
                                                        'Selected Plan: $selectedPlanDuration');
                                                    print(
                                                        'Price: ₹${priceOptions[selectedPlanDuration]}');

                                                    // Call openPayment with the selected plan and selected duration
                                                    final selectedPlan = {
                                                      ...plan,
                                                      'selected_duration':
                                                          selectedPlanDuration,
                                                      'selected_price':
                                                          priceOptions[
                                                              selectedPlanDuration],
                                                      // Pass the price corresponding to selectedPlanDuration
                                                    };

                                                    openPayment(
                                                        selectedPlan); // Pass the selected plan to openPayment

                                                    // openPayment(plan);
                                                  },
                                                  child: const Text(
                                                    'Pay Now',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.green,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 30,
                                                            vertical: 12),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
    );
  }

  // List<Widget> _parsePlanFeatures(String features) {
  //   return features.split("|").map((line) {
  //     final parts = line.split('*');
  //     return Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Icon(Icons.label_important_sharp, color: Colors.green, size: 20),
  //         SizedBox(width: 8),
  //         Expanded(
  //           child: Text.rich(
  //             TextSpan(
  //               children: parts.map((part) {
  //                 if (part.isNotEmpty) {
  //                   return TextSpan(
  //                     text: part,
  //                     style: part.startsWith('*') && part.endsWith('*')
  //                         ? TextStyle(fontWeight: FontWeight.bold)
  //                         : null,
  //                   );
  //                 }
  //                 return TextSpan(text: '');
  //               }).toList(),
  //             ),
  //           ),
  //         ),
  //       ],
  //     );
  //   }).toList();
  // }

  List<Widget> _parsePlanFeatures(String features) {
    return features.split("|").map((line) {
      final parts = line
          .split('*')
          .where((part) => part.isNotEmpty)
          .toList(); // Remove empty parts
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.label_important_sharp, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: parts.map((part) {
                  return TextSpan(
                    text: part,
                    style: part.startsWith('*') && part.endsWith('*')
                        ? const TextStyle(fontWeight: FontWeight.bold)
                        : null,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }
}
