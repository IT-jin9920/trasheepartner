import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ShopAllProductDisplayScreen extends StatefulWidget {
  const ShopAllProductDisplayScreen({super.key});

  @override
  ShopAllProductDisplayScreenState createState() =>
      ShopAllProductDisplayScreenState();
}

class ShopAllProductDisplayScreenState
    extends State<ShopAllProductDisplayScreen> {
  List<Map<String, dynamic>> shopList = [];
  int shopId = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchShopList();
  }

  Future<void> _fetchShopList() async {
    setState(() {
      isLoading = true;
    });

    var sharedPref = await SharedPreferences.getInstance();
    shopId = sharedPref.getInt("shop_id") ?? 0;

    const String apiUrl =
        "https://syntaxium.in/DUSTBIN_API/shop_all_product_display.php";

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
        setState(() {
          shopList =
          List<Map<String, dynamic>>.from(result['shop_product_display']);
        });
      } else {
        debugPrint("Error fetching shop list: ${result['message']}");
      }
    } on SocketException catch (e) {
      _showErrorDialog('A network error occurred.\nMake sure your internet is working.');
      debugPrint("SocketException: $e");
    } catch (error) {
      debugPrint('Error during shop list fetch: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
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

  String cleanImagePath(String imagePath) {
    if (imagePath.startsWith('../')) {
      imagePath = imagePath.substring(2);
    }

    if (!imagePath.startsWith('/')) {
      imagePath = '/$imagePath';
    }

    return imagePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Product'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
          return Card(
            elevation: 10,
            margin: const EdgeInsets.all(10),
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
                  title: Text(
                    "${shopList[index]['product_name']} - ${shopList[index]['product_brand']}",
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Quantity: ${shopList[index]['product_quantity']}",
                      ),
                      Text(
                        shopList[index]['in_stock'] == 0
                            ? "In Stock"
                            : "Out Of Stock",
                        style: TextStyle(
                          color: shopList[index]['in_stock'] == 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      Text("Id: ${shopList[index]['id']}")
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Original Price: ${shopList[index]['original_price']}",
                        style: const TextStyle(color: Colors.red),
                      ),
                      Text(
                        "Discounted Price: ${shopList[index]['discounted_price']}",
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
