import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

import 'plan_service.dart';
import 'invoice_generator.dart';
import 'payment_service.dart';

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
  String userPhone = "";
  String? pdfFilePath;
  String? selectedPlanDuration;
  late Razorpay razorpay;
  List<dynamic> plans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    debugPrint("Initializing payment gateway and fetching plans...");
    fetchPlans();
  }

  @override
  void dispose() {
    razorpay.clear();
    super.dispose();
  }

  Future<void> fetchPlans() async {
    var planService = PlanService();
    debugPrint("Fetching plans from the service...");
    var fetchedPlans = await planService.fetchPlans();

    if (fetchedPlans != null) {
      debugPrint("Plans fetched successfully: ${fetchedPlans.length} plans available.");
      setState(() {
        plans = fetchedPlans;
        isLoading = false;
      });
    } else {
      debugPrint("No plans available from the service.");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> openPayment(var plan) async {
    var sharedPref = await SharedPreferences.getInstance();
    owner_id = sharedPref.getInt('owner_id') ?? 0;

    String planName = plan['plan_name'] ?? 'Unknown Plan';
    planId = int.parse(plan['id']?.toString() ?? '1');

    debugPrint("Opening payment for plan: $planName, ID: $planId, Owner ID: $owner_id");

    var paymentService = PaymentService(razorpay);
    paymentService.openPayment(plan, owner_id, planId, context);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint("Payment success response: ${response.paymentId}");
    var paymentService = PaymentService(razorpay);
    paymentService.handlePaymentSuccess(
      response,
      context,
      owner_id,
      pdfFilePath,
      // planId,  // Pass planId here
      // 'Plan Name',  // Pass the actual plan name here
      //userName,  // Pass the actual userName here
      //userEmail,  // Pass the actual userEmail here
      //userPhone,  // Pass the actual userPhone here
    );

  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Log the error details from the PaymentFailureResponse
    debugPrint("Payment failed with error code: ${response.code}");
    debugPrint("Error message: ${response.message}");
    debugPrint("Error reason: ${response.error}");

    // Show the error message in a Snackbar or handle it accordingly
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Payment failed. Error: ${response.message}'),
    ));

    var paymentService = PaymentService(razorpay);
    paymentService.handlePaymentError(response, owner_id, context);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("External wallet selected: ${response.walletName}");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('External Wallet Selected: ${response.walletName}'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscription Plans'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : plans.isEmpty
          ? Center(child: Text('No plans available.'))
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: plans
              .map(
                (plan) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PlanCard(
                plan: plan,
                onSubscribe: openPayment,
              ),
            ),
          )
              .toList(),
        ),
      ),
    );
  }
}

class PlanCard extends StatelessWidget {
  final dynamic plan;
  final Function onSubscribe;

  const PlanCard({
    required this.plan,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    String planName = plan['plan_name'] ?? 'Unknown Plan';
    int planId = int.parse(plan['id']?.toString() ?? '1');
    String planFeaturesString = plan['plan_features'] ?? 'No features available.';
    List<String> planFeatures = planFeaturesString.split('\n');
    String monthlyPrice = plan['monthly_price'] != null
        ? '₹${plan['monthly_price']}'
        : 'Not available';

    debugPrint("Rendering plan card for Plan ID: $planId with name: $planName");

    return Card(
      elevation: 8,
      shadowColor: Colors.greenAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '$planId -> ',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                SizedBox(width: 5),
                Text(
                  planName,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Features:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.green),
            ),
            SizedBox(height: 8),
            Column(
              children: planFeatures
                  .map(
                    (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.label_important_sharp, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          feature,
                          style: TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .toList(),
            ),
            SizedBox(height: 16),
            Text(
              'Price: $monthlyPrice',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.green),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                debugPrint("Subscribe button clicked for Plan ID: $planId");
                onSubscribe(plan);
              },
              child: Text(
                'Subscribe Now',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
