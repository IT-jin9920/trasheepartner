// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trasheepartner/screens/navigation_menu.dart';

class ShopProductAddScreen extends StatefulWidget {
  const ShopProductAddScreen({super.key});

  @override
  ShopProductAddScreenState createState() => ShopProductAddScreenState();
}

class ShopProductAddScreenState extends State<ShopProductAddScreen> {
  int uniqueCode = DateTime.now().millisecondsSinceEpoch;
  Map<String, dynamic>? selectedOption;
  bool anyItemAdded = false;
  bool isLoading = false;
  bool submitAttempted = false;
  int limit = 0;
  File? productPhoto;
  String? selectedOfferType;
  final GlobalKey<FormState> productNameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> productBrandFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> productDescFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> productOfferTypeFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> productQuantityFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> productOriginalPriceFormKey =
      GlobalKey<FormState>();
  final GlobalKey<FormState> productDiscountedPriceFormKey =
      GlobalKey<FormState>();

  TextEditingController productName = TextEditingController();
  TextEditingController productBrand = TextEditingController();
  TextEditingController productDescription = TextEditingController();
  TextEditingController productQuantity = TextEditingController();
  TextEditingController productOriginalPrice = TextEditingController();
  TextEditingController productDiscountPrice = TextEditingController();

  String? _validateProductName(String? value) {
    if (submitAttempted && (value == null || value.isEmpty)) {
      return 'Please enter product name';
    } else if (!RegExp(r'^.{2,}(?:\s+.+)?$').hasMatch(value!)) {
      return 'Please enter product name of atleast 2 character';
    }
    return null;
  }

  String? _validateBrandName(String? value) {
    if (submitAttempted && (value == null || value.isEmpty)) {
      return 'Please enter product brand name';
    } else if (!RegExp(r'^.{2,}(?:\s+.+)?$').hasMatch(value!)) {
      return 'Please enter brand name at least 2 character';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (submitAttempted && (value == null || value.isEmpty)) {
      return 'Please enter product description';
    } else if (!RegExp(r'^.{20,}$').hasMatch(value!)) {
      return 'Please enter atleast some description of product';
    }
    return null;
  }

  String? _validateQuantity(String? value) {
    if (submitAttempted && (value == null || value.isEmpty)) {
      return 'Please enter product quantity';
    } else {
      try {
        int quantity = int.parse(value!);
        if (quantity > limit) {
          return "Please Enter Quantity within the limit, your limit is: $limit";
        }
      } catch (e) {
        return "Please enter a valid numeric quantity";
      }
    }
    return null;
  }

  String? _validateOriginalPrice(String? value) {
    if (submitAttempted && (value == null || value.isEmpty)) {
      return 'Please enter product original price';
    } else if (!RegExp(r'^[1-9]\d{0,6}(\.\d{1,2})?$').hasMatch(value!)) {
      return 'Please enter a valid price between 1-9999';
    }
    if (productDiscountPrice.text != "") {
      if (double.tryParse(value)! < double.parse(productDiscountPrice.text)) {
        return 'Discounted Price Exceeds Original.';
      }
    }
    return null;
  }

  String? _validateDiscountedPrice(String? value) {
    if (submitAttempted && (value == null || value.isEmpty)) {
      return 'Please enter product discounted price';
    } else if (!RegExp(r'^[1-9]\d{0,6}(\.\d{1,2})?$').hasMatch(value!)) {
      return 'Please enter a valid price between 1-9999';
    }
    if (productOriginalPrice.text != "") {
      if (double.parse(value) > double.parse(productOriginalPrice.text)) {
        return 'Discounted Price Exceeds Original.';
      }
    }
    return null;
  }

  String productAddUrl =
      "https://syntaxium.in/DUSTBIN_API/shop_product_add.php";

  // String productFetchUrl =
  //     "https://syntaxium.in/DUSTBIN_API/shop_product_fetch.php";
  String FetchDataurl =
      "https://syntaxium.in/DUSTBIN_API/shop_payment_history.php";

  // List<String> uniqueProductNames = [];
  List<Map<String, dynamic>> alreadyProductAdded = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true; // Show loader initially
    });

    // Call _checkPlanStatus first and wait for its completion
    await _checkPlanStatus();

    // Proceed to other API calls only after _checkPlanStatus is complete
    // await _fetchDropdownOptions();
    await _fetchData();

    setState(() {
      isLoading = false; // Hide loader after all API calls are complete
    });
  }

  Future<void> _checkPlanStatus() async {
    const String apiUrl =
        "https://syntaxium.in/DUSTBIN_API/shop_product_prefetch.php";

    try {
      var sharedPref = await SharedPreferences.getInstance();
      int? shopId = sharedPref.getInt("shop_id");

      log("Shop ID retrieved from SharedPreferences: $shopId",
          name: "SHARED_PREF");

      final Map<String, String> requestBody = {
        'shop_id': shopId.toString(),
      };

      log("Sending request to API with body: $requestBody",
          name: "API_REQUEST_BODY");

      final response = await http.post(
        Uri.parse(apiUrl),
        body: requestBody,
      );

      if (response.statusCode == 200) {
        log("API Response: ${response.body}", name: "API_RESPONSE");
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('data')) {
          List<dynamic> dataList = data['data'];
          int totalRemainingQuantity = 0;

          for (var item in dataList) {
            if (item.containsKey('remaining_quantity')) {
              totalRemainingQuantity +=
                  int.parse(item['remaining_quantity'].toString());
            }
          }
          limit = totalRemainingQuantity;

          log("Total Remaining Quantity: $totalRemainingQuantity",
              name: "API_DATA");

          if (totalRemainingQuantity == 0) {
            log("Remaining quantity is 0. Redirecting to No Plan page.",
                name: "REDIRECT");
            Get.to(const NoPlanPageScreen());
          } else {
            log("Remaining quantity is not 0. Proceeding to Home page.",
                name: "NAVIGATION");
          }
        } else {
          log("Key 'data' not found in the API response.", name: "API_ERROR");
        }
      } else {
        log("Failed to fetch data. HTTP Status: ${response.statusCode}",
            name: "API_ERROR");
      }
    } catch (e) {
      log("An error occurred: $e", name: "API_EXCEPTION");
    }
  }

  Future<void> _fetchData() async {
    debugPrint("Fetching data started...");

    var sharedPref = await SharedPreferences.getInstance();
    int? shopId = sharedPref.getInt("shop_id");

    debugPrint("Retrieved shop ID: $shopId");

    setState(() {
      isLoading = true; // Show loader before API call
    });

    try {
      Map<String, String> headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      };

      Map<String, String> productFetchBody = {
        "shop_id": shopId.toString(),
      };

      debugPrint("Request Headers: $headers");
      debugPrint("Request Body: $productFetchBody");

      var response = await http.post(
        Uri.parse(FetchDataurl),
        headers: headers,
        body: productFetchBody,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      var result = jsonDecode(response.body);
      bool error = result["error"];
      String message = result["message"];

      debugPrint("API Error Status: $error");
      debugPrint("API Message: $message");

      if (response.statusCode == 200 && !error) {
        // Parse payment details
        List<dynamic> paymentDetails = result["data"];
        List<Map<String, dynamic>> parsedPayments = paymentDetails
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        // Get the current date
        DateTime currentDate = DateTime.now();
        debugPrint("Current Date: $currentDate");

        bool canAddProducts = false;

        // Process each payment record
        for (var payment in parsedPayments) {
          String expiryDateStr = payment["plan_expiry_date"] ?? "";
          String remainingTimeStr = payment["remaining_time"] ?? "";

          if (expiryDateStr.isNotEmpty) {
            try {
              // Parse the plan expiry date
              DateTime expiryDate = DateTime.parse(expiryDateStr);
              if (currentDate.isAfter(expiryDate)) {
                debugPrint(
                    "Plan Expired: Payment ID: ${payment['payment_id']}, Expiry Date: $expiryDate (Earlier than Current Date)");
              } else if (currentDate.isAtSameMomentAs(expiryDate)) {
                debugPrint(
                    "Plan Expiry Today: Payment ID: ${payment['payment_id']}, Expiry Date: $expiryDate (Equal to Current Date)");
              } else {
                // Add limits only if remaining time is not zero
                if (remainingTimeStr != "0 days, 0 hours, 0 minutes") {
                  canAddProducts = true;
                } else {}
              }
            } catch (e) {
              debugPrint(
                  "Error parsing expiry date for Payment ID: ${payment['payment_id']}, Error: $e");
            }
          } else {
            debugPrint(
                "No Expiry Date Found for Payment ID: ${payment['payment_id']}");
          }
        }

        if (!canAddProducts) {
          debugPrint(
              "No active plan or remaining time. Redirecting to subscription page.");
          Get.offAllNamed(
              '/SubscriptionPage'); // Replace with your subscription page route
          return;
        }

        // Update state with the fetched data
        setState(() {
          anyItemAdded = true;
          alreadyProductAdded =
              parsedPayments; // Store complete payment details
        });

        debugPrint("Payment details fetched successfully.");
      } else if (error) {
        setState(() {
          anyItemAdded = false;
        });
        debugPrint("Error from API: $message");
      }
    } catch (error) {
      debugPrint('Error during fetching: $error');
    } finally {
      setState(() {
        isLoading = false; // Hide loader after API response
      });
      debugPrint("Fetching data completed.");
    }
  }

  // Future<void> _fetchDropdownOptions() async {
  //   var sharedPref = await SharedPreferences.getInstance();
  //   int? shopId = sharedPref.getInt("shop_id");
  //   int? ownerId = sharedPref.getInt("owner_id");
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   try {
  //     Map<String, String> headers = {
  //       'Content-Type': 'application/x-www-form-urlencoded',
  //       'Accept': 'application/json',
  //     };
  //     Map<String, String> productFetchBody = {
  //       "shop_id": shopId.toString(),
  //       "owner_id": ownerId.toString(),
  //     };
  //
  //     var response = await http.post(
  //       Uri.parse(productFetchUrl),
  //       headers: headers,
  //       body: productFetchBody,
  //     );
  //
  //     var result = jsonDecode(response.body);
  //     bool er = result["error"];
  //
  //     if (response.statusCode == 200 && er == false) {
  //       Set<String> uniqueNames = Set<String>.from(
  //         result['shop_qr_details'].map((item) => item['product_name']),
  //       );
  //
  //       setState(() {
  //         anyItemAdded = true;
  //         uniqueProductNames = uniqueNames.toList();
  //         alreadyProductAdded =
  //             List<Map<String, dynamic>>.from(result['shop_qr_details']);
  //       });
  //     } else if (er == true) {
  //       setState(() {
  //         anyItemAdded = false;
  //       });
  //     }
  //   } on SocketException catch (e) {
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         debugPrint("Error: $e");
  //         return AlertDialog(
  //           title: const Text('Error'),
  //           content: const Text(
  //               'A network error occurred.\nMake sure that your internet is working.'),
  //           actions: [
  //             ElevatedButton(
  //               onPressed: () {
  //                 setState(() {
  //                   isLoading = false;
  //                 });
  //                 Future.delayed(const Duration(seconds: 2));
  //                 Get.back();
  //               },
  //               child: const Text('Close'),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   } catch (error) {
  //     debugPrint('Error during fetching in catch: $error');
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  Future<void> _takePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    _handleImageSelection(image);
  }

  Future<void> _selectPicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 800,
    );
    _handleImageSelection(image);
  }

  void _handleImageSelection(XFile? image) {
    if (image != null) {
      setState(() {
        productPhoto = File(image.path);
      });
    }
  }

  // Future<void> _fetchProductDetails(
  //     Map<String, dynamic>? selectedProduct) async {
  //   if (selectedProduct != null) {
  //     setState(() {
  //       productName.text = selectedProduct['product_name'];
  //       productDescription.text = selectedProduct['product_description'];
  //     });
  //   }
  // }

  Future<void> _addProduct() async {
    print("Submit button clicked");

    var sharedPref = await SharedPreferences.getInstance();
    int? shopId = sharedPref.getInt("shop_id");
    int? ownerId = sharedPref.getInt("owner_id");

    if (shopId == null || ownerId == null) {
      Fluttertoast.showToast(msg: "Shop ID or Owner ID is missing.");
      return;
    }

    setState(() {
      isLoading = true;
      submitAttempted = true;
    });

    if ((productNameFormKey.currentState?.validate() ?? false) &&
        (productBrandFormKey.currentState?.validate() ?? false) &&
        (productDescFormKey.currentState?.validate() ?? false) &&
        (productQuantityFormKey.currentState?.validate() ?? false) &&
        (productOriginalPriceFormKey.currentState?.validate() ?? false) &&
        (productDiscountedPriceFormKey.currentState?.validate() ?? false) &&
        (productOfferTypeFormKey.currentState?.validate() ?? false) &&
        (productPhoto != null)) {
      try {
        var request = http.MultipartRequest('POST', Uri.parse(productAddUrl))
          ..headers['Accept'] = 'application/json'
          ..headers["Content-type"] = 'application/x-www-form-urlencoded'
          ..headers["Content-type"] = 'application/form-mulipart';
        request.fields['shop_id'] = shopId.toString();
        request.fields['owner_id'] = ownerId.toString();
        request.fields['product_name'] = productName.text.trim();
        request.fields['product_brand'] = productBrand.text.trim();
        request.fields['product_unique_code'] = uniqueCode.toString();
        request.fields['product_desc'] = productDescription.text.trim();
        request.fields['product_quantity'] = productQuantity.text;
        request.fields['offer_type'] = selectedOfferType.toString().trim();
        request.fields['original_price'] = productOriginalPrice.text;
        request.fields['discounted_price'] = productDiscountPrice.text;

        if (productPhoto != null) {
          List<int> imageBytes = await productPhoto!.readAsBytes();
          String fileName = productPhoto!.path.split('/').last;
          request.files.add(http.MultipartFile.fromBytes(
              'product_photo', imageBytes,
              filename: fileName,
              contentType:
                  MediaType.parse(lookupMimeType(productPhoto!.path)!)));
        }

        var response = await request.send();
        var result = jsonDecode(await response.stream.bytesToString());
        bool er = result["error"];
        if (response.statusCode == 200 && er == false) {
          Fluttertoast.showToast(msg: result["message"].toString());
          Get.offAll(() => const NavigationMenu());
        } else {
          Fluttertoast.showToast(msg: result["message"].toString());
        }
      } on SocketException catch (e) {
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
        debugPrint('Error during product add in catch: $error');
        Fluttertoast.showToast(msg: "An unexpected error occurred.");
      } finally {
        setState(() {
          isLoading = false;
          productName.text = '';
          productBrand.text = '';
          productDescription.text = '';
          productQuantity.text = '';
          productOriginalPrice.text = '';
          productDiscountPrice.text = '';
          selectedOption = null;
          productPhoto = null;
        });
      }
    } else {
      if (productPhoto == null) {
        Fluttertoast.showToast(msg: "Please Select an Image.");
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text("Product Add Page"),
              automaticallyImplyLeading: true,
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Visibility(
                    //   visible: anyItemAdded,
                    //   child: DropdownButton<String>(
                    //     value: selectedOption != null
                    //         ? selectedOption!['product_name']
                    //         : null,
                    //     onChanged: (String? value) {
                    //       setState(() {
                    //         // Find the selected product by name
                    //         selectedOption = alreadyProductAdded.firstWhere(
                    //             (item) => item['product_name'] == value,
                    //             orElse: () => {});
                    //         // Fetch product details when an item is selected from the dropdown
                    //         _fetchProductDetails(selectedOption);
                    //       });
                    //     },
                    //     items: uniqueProductNames.map<DropdownMenuItem<String>>(
                    //         (String productName) {
                    //       return DropdownMenuItem<String>(
                    //         value: productName,
                    //         child: Text(productName),
                    //       );
                    //     }).toList(),
                    //     hint: const Text('Select a Product'),
                    //   ),
                    // ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Limit: $limit"),
                        Form(
                          onChanged: () {
                            setState(() {
                              isLoading = false;
                            });
                          },
                          key: productNameFormKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: TextFormField(
                            controller: productName,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                                labelText: 'Product Name',
                                prefixIcon: Icon(Icons.person_add_rounded),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(4.0)))),
                            validator: _validateProductName,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Form(
                          onChanged: () {
                            setState(() {
                              isLoading = false;
                            });
                          },
                          key: productBrandFormKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: TextFormField(
                            controller: productBrand,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                                labelText: 'Product Brand Name',
                                prefixIcon:
                                    Icon(Icons.branding_watermark_rounded),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(4.0)))),
                            validator: _validateBrandName,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Form(
                          onChanged: () {
                            setState(() {
                              isLoading = false;
                            });
                          },
                          key: productDescFormKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: TextFormField(
                            minLines: 2,
                            maxLines: 5,
                            controller: productDescription,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                                labelText: 'Product Description',
                                prefixIcon: Icon(Icons.description_rounded),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(4.0)))),
                            validator: _validateDescription,
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Form(
                          onChanged: () {
                            setState(() {
                              isLoading = false;
                            });
                          },
                          key: productOfferTypeFormKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                                labelText: 'Offer Type',
                                prefixIcon: Icon(Icons.local_offer_rounded),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(4.0)))),
                            items: <String>['INDIVIDUAL', 'BULK']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectedOfferType = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select an option';
                              }
                              return null;
                            },
                            hint: const Text('SELECT OFFER TYPE'),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Form(
                          onChanged: () {
                            setState(() {
                              isLoading = false;
                            });
                          },
                          key: productQuantityFormKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: TextFormField(
                            controller: productQuantity,
                            decoration: const InputDecoration(
                              labelText: 'Product Quantity',
                              prefixIcon: Icon(Icons.numbers_rounded),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4.0))),
                              errorMaxLines: 3,
                              // Keep the field compact
                              errorStyle: TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              // Allow only numeric input
                            ],
                            validator: _validateQuantity,
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Form(
                          onChanged: () {
                            setState(() {
                              isLoading = false;
                            });
                          },
                          key: productOriginalPriceFormKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: TextFormField(
                            controller: productOriginalPrice,
                            decoration: const InputDecoration(
                                labelText: 'Original Rate Per Unit Qty',
                                prefixIcon: Icon(Icons.currency_rupee_rounded),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(4.0)))),
                            keyboardType: TextInputType.number,
                            validator: _validateOriginalPrice,
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Form(
                          onChanged: () {
                            setState(() {
                              isLoading = false;
                            });
                          },
                          key: productDiscountedPriceFormKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: TextFormField(
                            controller: productDiscountPrice,
                            decoration: const InputDecoration(
                                labelText: 'Discounted Rate Per Unit Qty',
                                prefixIcon: Icon(Icons.currency_rupee_rounded),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(4.0)))),
                            keyboardType: TextInputType.number,
                            validator: _validateDiscountedPrice,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _takePicture,
                              child: const Text('Take Picture'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _selectPicture,
                              child: const Text('Select Picture'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (productPhoto != null)
                          Image.file(
                            productPhoto!,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: isLoading ? null : _addProduct,
                          // If isLoading is true, the button is disabled
                          child: isLoading
                              ? const CircularProgressIndicator() // Show loader inside button when loading
                              : const Text('Submit'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              productName.text = '';
                              productBrand.text = '';
                              productDescription.text = '';
                              productQuantity.text = '';
                              productOriginalPrice.text = '';
                              productDiscountPrice.text = '';
                              selectedOption = null;
                              productPhoto = null;
                              selectedOfferType = null;
                            });
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (isLoading) const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          );
  }

  @override
  void dispose() {
    super.dispose();
    productName.dispose();
    productBrand.dispose();
    productDescription.dispose();
    productDiscountPrice.dispose();
    productOriginalPrice.dispose();
    productQuantity.dispose();
  }
}

class NoPlanPageScreen extends StatelessWidget {
  const NoPlanPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("NO Active Plans Go Basck to home"),
            TextButton(
                onPressed: () => Get.offAll(const NavigationMenu()),
                child: const Text("NO PLAN")),
          ],
        ),
      ),
    );
  }
}
