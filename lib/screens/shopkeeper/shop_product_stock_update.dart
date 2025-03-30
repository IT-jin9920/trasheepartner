// ignore_for_file: unnecessary_question_mark

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ShopProductStockUpdate extends StatefulWidget {
  const ShopProductStockUpdate({super.key});

  @override
  State<ShopProductStockUpdate> createState() => _ShopProductStockUpdateState();
}

class _ShopProductStockUpdateState extends State<ShopProductStockUpdate> {
  bool isLoading = false;
  bool submitAttempted = false;
  List<dynamic> stockProducts = [];
  dynamic? selectedValue1;
  dynamic? selectedValue2;
  int shopId = 0;
  final GlobalKey<FormState> productNameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> stockFormKey = GlobalKey<FormState>();
  final String fetchApi =
      "https://syntaxium.in/DUSTBIN_API/shop_stock_fetch.php";
  final String updateUrl =
      "https://syntaxium.in/DUSTBIN_API/shop_stock_update.php";

  @override
  void initState() {
    super.initState();
    _fetchStock();
  }

  Future<void> _fetchStock() async {
    var sharedPref = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
      shopId = sharedPref.getInt("shop_id") ?? 0;
    });

    try {
      // Define headers
      Map<String, String> fetchHeaders = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      };

      // Define request body
      Map<String, String> productBody = {
        "shop_id": shopId.toString(),
      };

      // Use the http.post method with headers and body
      var response = await http.post(
        Uri.parse(fetchApi),
        headers: fetchHeaders,
        body: productBody,
      );

      var result = jsonDecode(response.body);
      if (response.statusCode == 200 && result['error'] == false) {
        // Update the shopList with the fetched data
        setState(() {
          stockProducts = result['stock_products'] as List<dynamic>;
        });
      } else {
        debugPrint("Error fetching shop list: ${result['message']}");
      }
    } on SocketException catch (e) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          debugPrint("Error: $e");
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'A network error occurred.\nMake sure that your internet is working.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = false;
                  });
                  Future.delayed(const Duration(seconds: 2));
                  Get.back();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      debugPrint('Error during shop list fetch in catch: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String? _validateProduct(dynamic? value) {
    if (value == null || value == "") {
      return 'Please select the product.';
    }
    return null;
  }

  String? _validateStock(dynamic? value) {
    if (value == null || value == "") {
      return 'Please select stock status.';
    }
    return null;
  }

  Future<void> _updateStock() async {
    setState(() {
      isLoading = true;
      submitAttempted = true;
    });

    if ((productNameFormKey.currentState?.validate() ?? false) &&
        (stockFormKey.currentState?.validate() ?? false)) {
      try {
        // Define headers
        Map<String, String> updateHeaders = {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        };

        // Define request body
        Map<String, String> stockBody = {
          "id": selectedValue1.toString(),
          "in_stock": selectedValue2.toString(),
        };

        // Use the http.post method with headers and body
        var response = await http.post(
          Uri.parse(updateUrl),
          headers: updateHeaders,
          body: stockBody,
        );

        var result = jsonDecode(response.body);
        if (response.statusCode == 200 && result['error'] == false) {
          Fluttertoast.showToast(msg: result["message"].toString());
          // ignore: use_build_context_synchronously
          Get.back();
        } else {
          debugPrint("Error stock update ${result['message']}");
        }
      } on SocketException catch (e) {
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            debugPrint("Error: $e");
            return AlertDialog(
              title: const Text('Error'),
              content: const Text(
                  'A network error occurred.\nMake sure that your internet is working.'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = false;
                    });
                    Future.delayed(const Duration(seconds: 2));
                    Get.back();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      } catch (error) {
        debugPrint('Error during stock update in catch: $error');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Update'),
        centerTitle: true,
      ),
      body: stockProducts.isEmpty
          ? const Center(
              child: Text(
                'No data available',
                style: TextStyle(fontSize: 18),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Form(
                      key: productNameFormKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: () {
                        setState(() {
                          isLoading = false;
                        });
                      },
                      child: DropdownButtonFormField<String>(
                        validator: _validateProduct,
                        value: selectedValue1?.toString(),
                        onChanged: (value) {
                          setState(() {
                            selectedValue1 = value;
                          });
                        },
                        items: stockProducts.map((product) {
                          return DropdownMenuItem<String>(
                            value: product['id'].toString(),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey)),
                              ),
                              child: ListTile(
                                leading: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Id: ${product['id'].toString()}",
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      "Quantity: ${product["product_quantity"].toString()}",
                                    ),
                                  ],
                                ),
                                title: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      product['product_name'],
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(product["product_brand"]),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "₹${product["discounted_price"].toString()}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      "₹${product["original_price"].toString()}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.red,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        selectedItemBuilder: (BuildContext context) {
                          return stockProducts.map<Widget>((product) {
                            return Text(product['product_name'] +
                                " - Id: " +
                                product["id"].toString());
                          }).toList();
                        },
                        hint: const Text('Select Product'),
                        isExpanded: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(16),
                          border: OutlineInputBorder(),
                          labelText: 'Select Product',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: stockFormKey,
                      autovalidateMode: submitAttempted
                          ? AutovalidateMode.always
                          : AutovalidateMode.onUserInteraction,
                      onChanged: () {
                        setState(() {
                          isLoading = false;
                        });
                      },
                      child: DropdownButtonFormField<String>(
                        value: selectedValue2?.toString(),
                        onChanged: (value) {
                          setState(() {
                            selectedValue2 = value;
                          });
                        },
                        items: const [
                          DropdownMenuItem<String>(
                            value: '0',
                            child: Text('In Stock'),
                          ),
                          DropdownMenuItem<String>(
                            value: '1',
                            child: Text('Out of Stock'),
                          ),
                        ],
                        hint: const Text('Select Stock Status'),
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(16),
                          labelText: 'Select Stock Status',
                        ),
                        validator: _validateStock,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    ElevatedButton(
                      onPressed: isLoading ? null : () => _updateStock(),
                      child: const Text("Update Stock"),
                    ),
                    if (isLoading) const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
    );
  }
}
