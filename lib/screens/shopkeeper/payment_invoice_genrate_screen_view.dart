import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trasheepartner/screens/navigation_menu.dart';

class PaymentInvoiceGenrateScreenView extends StatefulWidget {
  const PaymentInvoiceGenrateScreenView({super.key});

  @override
  State<PaymentInvoiceGenrateScreenView> createState() =>
      _PaymentInvoiceGenrateScreenViewState();
}

class _PaymentInvoiceGenrateScreenViewState
    extends State<PaymentInvoiceGenrateScreenView> {
  late final Map<String, dynamic> invoiceData;

  @override
  void initState() {
    super.initState();
    invoiceData =
        Get.arguments; // Retrieve data passed from the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Details'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Image
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'images/pdflogo.png', // Add your banner image here
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'Payment Invoice',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Payment Details
                  _buildRow('Payment ID', invoiceData['paymentId']),
                  _buildRow('Payment Time', invoiceData['paymentTime']),
                  _buildRow('Partner ID', invoiceData['partnerId']),
                  _buildRow(
                      'Plan Duration', invoiceData['payment_duration_name']),
                  const Divider(),

                  // Subscription Details in Table Format
                  const Text(
                    'Subscription Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTable([
                    {
                      'label': 'Monthly Price',
                      'value': '₹${invoiceData['monthly_price']}',
                    },
                    {
                      'label': 'Allocated Quantity',
                      'value':
                      '${invoiceData['allocated_quantity']} Coupens Quntity',
                    },
                  ]),
                  const Divider(),

                  // User Details
                  const Text(
                    'User Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildRow('Owner ID', invoiceData['ownerId']),
                  _buildRow('User Name', invoiceData['userName']),
                  _buildRow('User Email', invoiceData['userEmail']),
                  _buildRow('User Phone', invoiceData['userPhone']),
                  const Divider(),

                  // Thank You Message
                  const SizedBox(height: 20),
                  const Text(
                    'Thank You!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We appreciate your business and are committed to serving you. Please reach out for any support or queries.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Admin Signature
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Dprofiz Pvt Ltd',
                            // Replace with dynamic admin name if available
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Signature',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          Image.asset(
                            'images/dp-logo.png',
                            // Add your signature image here
                            height: 40,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Go Back Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.offAll(const NavigationMenu()); // Navigate back to the previous screen
                       // Get.back(); // Navigate back to the previous screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Go Back',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build a row for displaying key-value pairs
  Widget _buildRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis, // Handle overflow
            ),
          ),
          const SizedBox(width: 8), // Optional spacing between label and value
          Expanded(
            flex: 3,
            child: Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis, // Handle overflow
            ),
          ),
        ],
      ),
    );
  }

  /// Build a table for structured data display
  Widget _buildTable(List<Map<String, String>> data) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3), // Allocate more space for labels
        1: FlexColumnWidth(2), // Allocate less space for values
      },
      children: data
          .map(
            (row) => TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                row['label']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis, // Handle text overflow
                maxLines:
                1, // Ensure the label doesn't wrap to the next line
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                row['value']!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                overflow: TextOverflow.ellipsis, // Handle text overflow
                maxLines:
                1, // Ensure the value doesn't wrap to the next line
              ),
            ),
          ],
        ),
      )
          .toList(),
    );
  }
}
