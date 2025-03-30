import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ShopNonRedeemProductDisplayScreen extends StatefulWidget {
  const ShopNonRedeemProductDisplayScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ShopNonRedeemProductDisplayScreenState createState() =>
      _ShopNonRedeemProductDisplayScreenState();
}

class _ShopNonRedeemProductDisplayScreenState
    extends State<ShopNonRedeemProductDisplayScreen> {
  List<Map<String, dynamic>> shopList = [];
  int shopId = 0;
  bool isLoading = true; // Variable to manage loading state

  static const String apiUrl =
      "https://syntaxium.in/DUSTBIN_API/shop_non_redeem_product_display.php";

  @override
  void initState() {
    super.initState();
    _fetchShopList();
  }

  Future<void> _fetchShopList() async {
    var sharedPref = await SharedPreferences.getInstance();
    setState(() {
      shopId = sharedPref.getInt("shop_id") ?? 0;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {"shop_id": shopId.toString()},
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['error'] == false) {
        setState(() {
          shopList = List<Map<String, dynamic>>.from(result['shop_product_display']);
        });
      } else {
        debugPrint("Error fetching shop list: ${result['message']}");
      }
    } on SocketException catch (e) {
      _showNetworkErrorDialog(e.toString());
    } catch (error) {
      debugPrint('Error during shop list fetch in catch: $error');
    } finally {
      setState(() {
        isLoading = false; // Hide loading spinner after fetching data
      });
    }
  }

  String cleanImagePath(String imagePath) {
    if (imagePath.startsWith('../')) {
      imagePath = imagePath.substring(2);
    }
    return imagePath.startsWith('/') ? imagePath : '/$imagePath';
  }

  void _showNetworkErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text('A network error occurred: $error'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Not Redeemed Products'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loader while fetching data
          : shopList.isEmpty
          ? const Center(
        child: Text(
          'No data available',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: shopList.length,
        itemBuilder: (context, index) {
          final product = shopList[index];
          return Card(
            elevation: 10,
            margin: const EdgeInsets.all(10),
            color: const Color.fromARGB(255, 240, 240, 240),
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
                          "https://syntaxium.in${cleanImagePath(product["product_photo_path"])}",
                        ),
                      ),
                    ),
                  ),
                  title: Text("${product['product_name']} - ${product['product_brand']}"),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Quantity: ${product['product_quantity']}"),
                      Text("Id: ${product['id']}"),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Original Price: ${product['original_price']}",
                        style: const TextStyle(color: Colors.red),
                      ),
                      Text(
                        "Discounted Price: ${product['discounted_price']}",
                        style: const TextStyle(color: Colors.green),
                      ),
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
    final product = shopList[index];
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
                  "https://syntaxium.in${cleanImagePath(product["product_photo_path"])}",
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
