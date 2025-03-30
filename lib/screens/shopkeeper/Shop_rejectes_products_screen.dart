import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'shop_detail_update.dart';
import 'shop_product_details_update_screen.dart';

class ShopRejectesProductsScreen extends StatefulWidget {
  const ShopRejectesProductsScreen({super.key});

  @override
  _ShopRejectesProductsScreenState createState() =>
      _ShopRejectesProductsScreenState();
}

class _ShopRejectesProductsScreenState
    extends State<ShopRejectesProductsScreen> {
  List<Map<String, dynamic>> shopList = [];
  int shopId = 0;
  bool isLoading = true;

  static const String apiUrl =
      "https://syntaxium.in/DUSTBIN_API/shop_rejected_product_fetch.php";

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
      print(result);

      if (response.statusCode == 200 && result['error'] == false) {
        setState(() {
          shopList = List<Map<String, dynamic>>.from(result['data']);
        });
      } else {
        debugPrint("Error fetching shop list: ${result['message']}");
      }
    } on SocketException catch (e) {
      _showNetworkErrorDialog(e.toString());
    } catch (error) {
      debugPrint("Error fetching shop list: $error");
    } finally {
      setState(() {
        isLoading = false;
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
        title: const Text('Rejected Product Update'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : shopList.isEmpty
          ? const Center(
        child: Text('No data available', style: TextStyle(fontSize: 18)),
      )
          : ListView.builder(
        itemCount: shopList.length,
        itemBuilder: (context, index) {
          final product = shopList[index];
          return GestureDetector(
            onTap: () {
              //_showImageDialog(context, index);
              _printProductDetails(product);
                // Get.to(const ShopProductDetailsUpdateScreen());
              Get.offAll(() => const ShopProductDetailsUpdateScreen(), arguments: product);
            },
            child: Card(
              elevation: 5,
              margin: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ListTile(
                leading: Hero(
                  tag: "productImage$index",
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      "https://syntaxium.in${cleanImagePath(product["product_photo_path"])}",
                    ),
                  ),
                ),
                title: Text("${product['product_name']} - ${product['product_brand']}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Original Price: ${product['original_price']}", style: const TextStyle(color: Colors.red)),
                    Text("Discounted Price: ${product['discounted_price']}", style: const TextStyle(color: Colors.green)),
                  const SizedBox(height: 5,),
                    Align(
                      alignment: Alignment.center, // Center align this specific text
                      child: Text(
                        "Offer Type: ${product['offer_type']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Quantity: ${product['product_quantity']}"),
                    Text("Id: ${product['product_id']}"),
                  ],
                ),
              ),
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
              Get.back();
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

  // Print all product details to console
  void _printProductDetails(Map<String, dynamic> product) {
    print("Product Details:");
    print("Product Name: ${product['product_name']}");
    print("Brand: ${product['product_brand']}");
    print("Quantity: ${product['product_quantity']}");
    print("Product ID: ${product['product_id']}");
    print("Original Price: ${product['original_price']}");
    print("Discounted Price: ${product['discounted_price']}");
    print("Photo Path: ${product['product_photo_path']}");
  }
}
