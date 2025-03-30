import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PaymentPlanHistoryScreen extends StatefulWidget {
  const PaymentPlanHistoryScreen({super.key});

  @override
  State<PaymentPlanHistoryScreen> createState() =>
      _PaymentPlanHistoryScreenState();
}

class _PaymentPlanHistoryScreenState extends State<PaymentPlanHistoryScreen> {
  List<dynamic> paymentHistory = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchPaymentHistory();
  }

  Future<void> fetchPaymentHistory() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    const url = "https://syntaxium.in/DUSTBIN_API/shop_payment_history.php";
    final requestBody = {"shop_id": "56"}; // Replace this with dynamic shop_id

    try {
      final response = await http.post(
        Uri.parse(url),
        body: requestBody,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        debugPrint("Parsed Response Data: $responseData");

        if (responseData["error"] == false) {
          setState(() {
            paymentHistory = responseData["data"];
          });
          debugPrint("Payment history fetched successfully.");
          debugPrint("Payment History Data: $paymentHistory");
        } else {
          setState(() {
            hasError = true;
          });
        }
      } else {
        setState(() {
          hasError = true;
        });
      }
    } catch (error) {
      debugPrint("Error fetching payment history: $error");
      setState(() {
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
      debugPrint("fetchPaymentHistory() execution completed.");
    }
  }

  Future<void> _generatePdf(Map<String, dynamic> payment) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(16.0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    "Invoice",
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  "Payment Details",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Divider(),
                _buildPdfRow("Payment ID", payment['payment_id']),
                _buildPdfRow("Invoice ID", payment['invoice_id']),
                _buildPdfRow("Payment Reference", payment['payment_reference']),
                _buildPdfRow("Payment Time", payment['payment_time']),
                _buildPdfRow("Plan Name", payment['plan_name']),
                _buildPdfRow(
                    "Plan Expiry Date", payment['plan_expiry_date'] ?? 'N/A'),
                _buildPdfRow(
                    "Remaining Time", payment['remaining_time'] ?? 'N/A'),
                _buildPdfRow("Status", payment['status']),
                pw.SizedBox(height: 20),
                pw.Text(
                  "Shop Details",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Divider(),
                _buildPdfRow("Shop Name", payment['shop_name']),
                _buildPdfRow("Shop Address", payment['shop_address']),
                _buildPdfRow("Pin Code", payment['pin_code']),
                pw.SizedBox(height: 20),
                pw.Text(
                  "Thank You for Your Payment!",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final outputDir = await getTemporaryDirectory();
    final file = File("${outputDir.path}/Invoice_${payment['payment_id']}.pdf");
    await file.writeAsBytes(await pdf.save());

    _showInvoiceOptions(file.path);
  }

  void _showInvoiceOptions(String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invoice Generated'),
        content: Text('Your invoice has been saved at:\n$filePath'),
        actions: [
          TextButton(
            onPressed: () {
              Printing.layoutPdf(
                  onLayout: (_) => File(filePath).readAsBytes());
            },
            child: const Text('Print Invoice'),
          ),
          TextButton(
            onPressed: () {
              Printing.sharePdf(
                  bytes: File(filePath).readAsBytesSync(),
                  filename: 'Invoice.pdf');
            },
            child: const Text('Share Invoice'),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfRow(String label, dynamic value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          value.toString(),
          style: const pw.TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : hasError
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error,
              size: 50,
              color: Colors.red,
            ),
            const SizedBox(height: 10),
            const Text(
              "Failed to fetch payment history.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: fetchPaymentHistory,
              child: const Text("Retry"),
            ),
          ],
        ),
      )
          : paymentHistory.isEmpty
          ? const Center(
        child: Text(
          "No payment history available.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: paymentHistory.length,
        padding: const EdgeInsets.all(10),
        itemBuilder: (context, index) {
          final payment = paymentHistory[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Plan: ${payment['plan_name']}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Shop: ${payment['shop_name']}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Payment Time: ${payment['payment_time']}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Status: ${payment['status']}",
                    style: TextStyle(
                      fontSize: 14,
                      color: payment['status'] == 'done'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Expiry Date: ${payment['plan_expiry_date'] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Remaining time: ${payment['remaining_time'] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _generatePdf(payment);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    child: const Text("Generate Invoice"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
