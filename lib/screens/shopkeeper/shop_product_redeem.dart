import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ShopRedeemProductDisplayScreen extends StatefulWidget {
  const ShopRedeemProductDisplayScreen({super.key});

  @override
  _ShopRedeemProductDisplayScreenState createState() =>
      _ShopRedeemProductDisplayScreenState();
}

class _ShopRedeemProductDisplayScreenState
    extends State<ShopRedeemProductDisplayScreen> {
  List<Map<String, dynamic>> shopList = [];
  int shopId = 0;
  bool isLoading = true; // Set to true initially to show loading spinner

  @override
  void initState() {
    super.initState();
    _fetchShopList();
  }

  Future<void> _fetchShopList() async {
    var sharedPref = await SharedPreferences.getInstance();
    setState(() {
      shopId = sharedPref.getInt("shop_id") ?? 0;
      isLoading = true; // Start loading when fetching data
    });

    const String apiUrl =
        "https://syntaxium.in/DUSTBIN_API/shop_redeem_product_display.php";

    try {
      Map<String, String> headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      };

      Map<String, String> requestBody = {
        "shop_id": shopId.toString(),
      };

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: requestBody,
      );

      var result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['error'] == false) {
        // Update the shopList with fetched data
        setState(() {
          shopList =
          List<Map<String, dynamic>>.from(result['shop_product_display']);
        });
      } else {
        // No data available case
        setState(() {
          shopList = []; // Set to empty if no data or error
        });
      }
    } on SocketException catch (e) {
      // Handle network error
      _showNetworkErrorDialog("Network error: $e");
    } catch (error) {
      debugPrint('Error during shop list fetch: $error');
      _showNetworkErrorDialog("An unexpected error occurred. Please try again.");
    } finally {
      setState(() {
        isLoading = false; // Stop loading after fetching data
      });
    }
  }

  void _showNetworkErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: [
            ElevatedButton(
              onPressed: () {
                Get.back(); // Close the dialog
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                _fetchShopList(); // Retry fetching data
              },
              child: const Text('Retry'),
            ),
          ],
        );
      },
    );
  }

  String cleanImagePath(String imagePath) {
    if (imagePath.startsWith('../')) {
      imagePath = imagePath.substring(2);
    }
    return imagePath.startsWith('/') ? imagePath : '/$imagePath';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Redeemed Products'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loader while data is being fetched
          : shopList.isEmpty
          ? const Center(
        child: Text(
          'No data available', // Show this message if no data is available
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: shopList.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 10,
            margin: const EdgeInsets.all(10),
            color: const Color.fromARGB(255, 255, 255, 255),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: GestureDetector(
                    onTap: () {
                      _showImageDialog(context, index);
                    },
                    child: Hero(
                      tag: "productImage$index",
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                          "https://syntaxium.in${cleanImagePath(shopList[index]["product_photo_path"])}",
                        ),
                      ),
                    ),
                  ),
                  title: Text(shopList[index]['product_name'] +
                      " - " +
                      shopList[index]['product_brand']),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Quantity: ${shopList[index]['product_quantity']}",
                      ),
                      Text("Id: ${shopList[index]['id']}"),
                    ],
                  ),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Original Price: ${shopList[index]['original_price']}",
                        style: const TextStyle(color: Colors.red),
                      ),
                      Text(
                        "Discounted Price: ${shopList[index]['discounted_price']}",
                        style: const TextStyle(color: Colors.green),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showImageDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: GestureDetector(
            onTap: () {
              Get.back(); // Close the dialog when tapped
            },
            child: SizedBox(
              width: double.infinity,
              height: 300,
              child: Hero(
                tag: 'productImage$index',
                child: Image.network(
                  "https://syntaxium.in${cleanImagePath(shopList[index]["product_photo_path"])}",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
