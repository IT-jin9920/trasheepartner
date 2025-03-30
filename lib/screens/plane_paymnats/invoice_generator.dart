import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';

class InvoiceGenerator {
  Future<void> generateInvoice(String paymentId, String orderId, String planName, int amount) async {
    final pdf = pw.Document();
    final pdfPath = 'invoice_$paymentId.pdf';
    final file = File(pdfPath);

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Column(
            children: [
              pw.Text('Invoice', style: pw.TextStyle(fontSize: 24)),
              pw.Text('Payment ID: $paymentId'),
              pw.Text('Order ID: $orderId'),
              pw.Text('Plan: $planName'),
              pw.Text('Amount: ₹$amount'),
              pw.Text('Date: ${DateTime.now()}'),
            ],
          ),
        );
      },
    ));

    await file.writeAsBytes(await pdf.save());
  }
}
