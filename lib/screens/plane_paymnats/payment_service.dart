import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:printing/printing.dart';
import 'dart:io';
import 'invoice_generator.dart';

class PaymentService {
  final Razorpay razorpay;

  PaymentService(this.razorpay);

  void openPayment(var plan, int ownerId, int planId, BuildContext context) {

    String planName = plan['plan_name'] ?? 'Unknown Plan';
    int amount = (plan['monthly_price'] != null)
        ? (plan['monthly_price'] * 100).toInt()
        : 1 * 100;

    debugPrint("Opening payment for plan: $planName, Amount: ₹$amount");

    var options = {
    //  'key': 'rzp_test_VZDTBvpB0TV7v0',
      'key': 'rzp_test_8HoZTGB2PMriVt',
      'amount': amount,
      'name': 'Dprofiz Pvt Ltd',
      'description': 'Subscription Plan: $planName',
      'prefill': {'contact': '8888888888', 'email': 'test@gmail.com'},
      'notes': {'Merchant Name': 'Dprofiz Pvt Ltd', 'Plan ID': planId.toString()},
      'external': {
        'wallets': ['paytm']
      },

    };

    try {
      debugPrint("Payment options prepared: $options");
      razorpay.open(options);
    } catch (e) {
      debugPrint("Error opening Razorpay: $e");
    }
  }

  void handlePaymentSuccess(PaymentSuccessResponse response, BuildContext context, int ownerId, String? pdfFilePath) async {
    String paymentId = response.paymentId ?? "N/A";
    String paymentTime = DateTime.now().toIso8601String();
    String status = "done";
    String orderId = response.orderId ?? "N/A";
    int owner_id = 0;
    int planId = 0;

    debugPrint("Payment Success: Payment ID: $paymentId, Order ID: ${response.orderId}, Time: $paymentTime");

    print("Payment Details:");
    print("Plan ID: $planId"); // Ensure `selectedPlan` contains the plan ID
    print("Payment ID: $paymentId");
    print("Payment Time: $paymentTime");
    print("Status: $status");
    print("Partner ID: $owner_id");

    // Generate invoice after successful payment
    await _generateInvoice(paymentId, response.orderId!, 'Plan Name', 1 * 100,
      //  ownerId, userName, userEmail, userPhone
    );

    Fluttertoast.showToast(msg: 'Payment Successful!');
    _showInvoiceOptions(context, pdfFilePath);
  }

  void handlePaymentError(PaymentFailureResponse response, int ownerId, BuildContext context) {
    String paymentId = "N/A";
    String paymentTime = DateTime.now().toIso8601String();
    String status = "fail";

    debugPrint("Payment Failure: Error message: ${response.message}");

    Fluttertoast.showToast(msg: 'Payment Failed!');
    print("Payment Error: ${response.message}");
  }

  void _showInvoiceOptions(BuildContext context, String? pdfFilePath) {
    debugPrint("Showing invoice options. PDF File Path: $pdfFilePath");

    if (pdfFilePath != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Invoice Generated'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Your invoice has been generated.'),
              if (pdfFilePath != null) Text('Path: $pdfFilePath'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                debugPrint("Printing invoice with file path: $pdfFilePath");
                Printing.layoutPdf(onLayout: (_) => File(pdfFilePath).readAsBytes());
              },
              child: Text('Print Invoice'),
            ),
            TextButton(
              onPressed: () {
                debugPrint("Sharing invoice with file path: $pdfFilePath");
                Printing.sharePdf(bytes: File(pdfFilePath).readAsBytesSync(), filename: 'invoice.pdf');
              },
              child: Text('Share Invoice'),
            ),
          ],
        ),
      );
    } else {
      debugPrint("No PDF file available for sharing or printing.");
    }
  }

  Future<void> _generateInvoice(String paymentId, String orderId, String planName, int amount) async {
    debugPrint("Generating invoice for Payment ID: $paymentId, Order ID: $orderId, Plan Name: $planName, Amount: ₹$amount");

    final pdfGenerator = InvoiceGenerator();

    // Call to generate the invoice
    await pdfGenerator.generateInvoice(paymentId, orderId, planName, amount);

    // await _generateInvoice(
    //   paymentId,
    //   orderId,
    //   planId.toString(),
    //   1 * 100, // Adjust amount as per plan
    // );

  }
}

