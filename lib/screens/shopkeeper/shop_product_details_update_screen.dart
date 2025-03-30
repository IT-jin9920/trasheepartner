// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trasheepartner/screens/navigation_menu.dart';

class ShopProductDetailsUpdateScreen extends StatefulWidget {
  const ShopProductDetailsUpdateScreen({super.key});

  @override
  ShopProductDetailsUpdateScreenState createState() => ShopProductDetailsUpdateScreenState();
}

class ShopProductDetailsUpdateScreenState extends State<ShopProductDetailsUpdateScreen> {

  int uniqueCode = DateTime.now().millisecondsSinceEpoch;
  Map<String, dynamic>? selectedOption;
  bool anyItemAdded = false;
  bool isLoading = false;
  bool submitAttempted = false;
  File? productPhoto;
  String? productId;
  String? createdAt;
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
    } else if (!RegExp(r'^[1-9]\d{0,2}(\.\d{1,2})?$').hasMatch(value!)) {
      return 'Please enter a valid quantity between 1-999';
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
      "https://syntaxium.in/DUSTBIN_API/shop_product_update.php";
  // String productFetchUrl =
  //     "https://syntaxium.in/DUSTBIN_API/shop_product_fetch.php";

  // List<String> uniqueProductNames = [];
  //List<Map<String, dynamic>> alreadyProductAdded = [];
  @override
  void initState() {
    super.initState();

    final product = Get.arguments;

    print(product);
    print("12345");
    setState(() {
      productId = product["product_id"].toString();
      createdAt = product["created_at"];
      selectedOfferType = product["offer_type"];
      productName.text = product["product_name"];
      productBrand.text = product["product_brand"];
      productDescription.text = product["product_description"];
      productQuantity.text = (product["product_quantity"]).toString();
      productOriginalPrice.text = product["original_price"].toString();
      productDiscountPrice.text = product["discounted_price"].toString();
    });

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
  //         List<Map<String, dynamic>>.from(result['shop_qr_details']);
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

  Future<void> _updateProduct() async {
    print("Submit button clicked");

    // Retrieve SharedPreferences
    var sharedPref = await SharedPreferences.getInstance();
    int? shopId = sharedPref.getInt("shop_id");
    int? ownerId = sharedPref.getInt("owner_id");

    print("Shop ID retrieved: $shopId");
    print("Owner ID retrieved: $ownerId");

    if (shopId == null || ownerId == null) {
      print("Validation failed: Shop ID or Owner ID is missing.");
      Fluttertoast.showToast(msg: "Shop ID or Owner ID is missing.");
      return;
    }

    // Set loading state
    setState(() {
      isLoading = true;
      submitAttempted = true;
    });

    // Image validation
    print("Validating product image...");
    if (productPhoto == null) {
      print("Image validation failed: No image selected.");
      Fluttertoast.showToast(msg: "Please select an image.");
      setState(() {
        isLoading = false;
      });
      return;
    } else {
      // Validate image size and format
      final fileSize = await productPhoto!.length(); // File size in bytes
      final fileFormat = lookupMimeType(productPhoto!.path);

      print("Image size: $fileSize bytes");
      print("Image format: $fileFormat");

      const maxFileSize = 5 * 1024 * 1024; // 5 MB

      if (fileSize > maxFileSize) {
        print("Image validation failed: Image size exceeds 5 MB.");
        Fluttertoast.showToast(msg: "Image size must be less than 5 MB.");
        setState(() {
          isLoading = false;
        });
        return;
      }

      if (fileFormat == null || !['image/jpeg', 'image/png'].contains(fileFormat)) {
        print("Image validation failed: Invalid format.");
        Fluttertoast.showToast(msg: "Only JPEG and PNG formats are allowed.");
        setState(() {
          isLoading = false;
        });
        return;
      }
    }
    print("Image validation passed.");

    // Log all form values
    print("Logging all form values:");
    print("Product Name: ${productName.text}");
    print("Product Brand: ${productBrand.text}");
    print("Product Description: ${productDescription.text}");
    print("Product Quantity: ${productQuantity.text}");
    print("Original Price: ${productOriginalPrice.text}");
    print("Discounted Price: ${productDiscountPrice.text}");
    print("Offer Type: ${selectedOfferType?.toString()}");

    // Ensure `selectedOfferType` is not null
    if (selectedOfferType == null) {
      print("Validation failed: Offer Type is not selected.");
      Fluttertoast.showToast(msg: "Please select an offer type.");
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Form validation
    print("Validating form fields...");
    bool isFormValid = (productNameFormKey.currentState?.validate() ?? false) &&
        (productBrandFormKey.currentState?.validate() ?? false) &&
        (productDescFormKey.currentState?.validate() ?? false) &&
        (productOriginalPriceFormKey.currentState?.validate() ?? false) &&
        (productDiscountedPriceFormKey.currentState?.validate() ?? false);

    print("Form validation result: $isFormValid");

    if (!isFormValid) {
      print("Form validation failed: Missing or invalid fields.");
      Fluttertoast.showToast(msg: "Please fill all required fields.");
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Prepare and send the request
    try {
      print("Preparing HTTP request...");
      var request = http.MultipartRequest('POST', Uri.parse(productAddUrl))
        ..headers['Accept'] = 'application/json'
        ..headers["Content-type"] = 'application/form-multipart'
        ..fields.addAll({
          'product_id': productId.toString(),
          'created_at': createdAt.toString(),
          'shop_id': shopId.toString(),
          'owner_id': ownerId.toString(),
          'product_name': productName.text.trim(),
          'product_brand': productBrand.text.trim(),
          'product_unique_code': uniqueCode.toString(),
          'product_desc': productDescription.text.trim(),
          'product_quantity': productQuantity.text,
          'offer_type': selectedOfferType.toString().trim(),
          'original_price': productOriginalPrice.text,
          'discounted_price': productDiscountPrice.text,
        });

      List<int> imageBytes = await productPhoto!.readAsBytes();
      String fileName = productPhoto!.path.split('/').last;
      request.files.add(http.MultipartFile.fromBytes(
        'product_photo',
        imageBytes,
        filename: fileName,
        contentType: MediaType.parse(lookupMimeType(productPhoto!.path)!),
      ));

      print("Request fields: ${request.fields}");
      print("Request file: $fileName");

      var response = await request.send();
      var responseString = await response.stream.bytesToString();
      print("HTTP Response status code: ${response.statusCode}");
      print("HTTP Response body: $responseString");

      var result = jsonDecode(responseString);
      bool hasError = result["error"];

      if (response.statusCode == 200 && !hasError) {
        print("Request succeeded: ${result["message"]}");
        Fluttertoast.showToast(msg: result["message"].toString());
        Get.offAll(() => const NavigationMenu());
      } else {
        print("Request failed: ${result["message"]}");
        Fluttertoast.showToast(msg: result["message"].toString());
      }
    } on SocketException catch (e) {
      print("Network error: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text(
            'A network error occurred.\nPlease check your internet connection.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = false;
                });
                Get.back();
              },
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (error) {
      print("Unexpected error: $error");
      Fluttertoast.showToast(msg: "An unexpected error occurred.");
    } finally {
      print("Resetting state and clearing fields...");
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
  }



  // Future<void> _updateProduct() async {
  //   print("Submit button clicked");
  //
  //   var sharedPref = await SharedPreferences.getInstance();
  //   int? shopId = sharedPref.getInt("shop_id");
  //   int? ownerId = sharedPref.getInt("owner_id");
  //
  //   if (shopId == null || ownerId == null) {
  //     Fluttertoast.showToast(msg: "Shop ID or Owner ID is missing.");
  //     return;
  //   }
  //
  //   setState(() {
  //     isLoading = true;
  //     submitAttempted = true;
  //   });
  //
  //   if ((productNameFormKey.currentState?.validate() ?? false) &&
  //       (productBrandFormKey.currentState?.validate() ?? false) &&
  //       (productDescFormKey.currentState?.validate() ?? false) &&
  //       (productQuantityFormKey.currentState?.validate() ?? false) &&
  //       (productOriginalPriceFormKey.currentState?.validate() ?? false) &&
  //       (productDiscountedPriceFormKey.currentState?.validate() ?? false) &&
  //       (productOfferTypeFormKey.currentState?.validate() ?? false) &&
  //       (productPhoto != null)) {
  //
  //     try {
  //       print("Try M agya");
  //       var request = http.MultipartRequest('POST', Uri.parse(productAddUrl))
  //         ..headers['Accept'] = 'application/json'
  //         ..headers["Content-type"] = 'application/x-www-form-urlencoded'
  //         ..headers["Content-type"] = 'application/form-mulipart';
  //       request.fields['product_id'] = productId.toString();
  //       request.fields['created_at'] = createdAt.toString();
  //       request.fields['shop_id'] = shopId.toString();
  //       request.fields['owner_id'] = ownerId.toString();
  //       request.fields['product_name'] = productName.text.trim();
  //       request.fields['product_brand'] = productBrand.text.trim();
  //       request.fields['product_unique_code'] = uniqueCode.toString();
  //       request.fields['product_desc'] = productDescription.text.trim();
  //       request.fields['product_quantity'] = productQuantity.text;
  //       request.fields['offer_type'] = selectedOfferType.toString().trim();
  //       request.fields['original_price'] = productOriginalPrice.text;
  //       request.fields['discounted_price'] = productDiscountPrice.text;
  //
  //       if (productPhoto != null) {
  //         List<int> imageBytes = await productPhoto!.readAsBytes();
  //         String fileName = productPhoto!.path.split('/').last;
  //         request.files.add(http.MultipartFile.fromBytes(
  //             'product_photo', imageBytes,
  //             filename: fileName,
  //             contentType: MediaType.parse(lookupMimeType(productPhoto!.path)!)));
  //       }
  //
  //       var response = await request.send();
  //       print("Response $response");
  //       var result = jsonDecode(await response.stream.bytesToString());
  //       bool er = result["error"];
  //
  //       print(result);
  //       print("315");
  //
  //       if (response.statusCode == 200 && er == false) {
  //         Fluttertoast.showToast(msg: result["message"].toString());
  //         Get.offAll(() => const NavigationMenu());
  //       } else {
  //         Fluttertoast.showToast(msg: result["message"].toString());
  //       }
  //     } on SocketException catch (e) {
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           debugPrint("Error: $e");
  //           return AlertDialog(
  //             title: const Text('Error'),
  //             content: const Text(
  //                 'A network error occurred.\nMake sure that your internet is working.'),
  //             actions: [
  //               ElevatedButton(
  //                 onPressed: () {
  //                   setState(() {
  //                     isLoading = false;
  //                   });
  //                   Future.delayed(const Duration(seconds: 2));
  //                   Get.back();
  //                 },
  //                 child: const Text('Close'),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     } catch (error) {
  //       debugPrint('Error during product add in catch: $error');
  //       Fluttertoast.showToast(msg: "An unexpected error occurred.");
  //     } finally {
  //       setState(() {
  //         isLoading = false;
  //         productName.text = '';
  //         productBrand.text = '';
  //         productDescription.text = '';
  //         productQuantity.text = '';
  //         productOriginalPrice.text = '';
  //         productDiscountPrice.text = '';
  //         selectedOption = null;
  //         productPhoto = null;
  //       });
  //     }
  //   } else {
  //     if (productPhoto == null) {
  //       Fluttertoast.showToast(msg: "Please Select an Image.");
  //     }
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Add Page Update"),
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
              //                 (item) => item['product_name'] == value,
              //             orElse: () => {});
              //         // Fetch product details when an item is selected from the dropdown
              //         _fetchProductDetails(selectedOption);
              //       });
              //     },
              //     items: uniqueProductNames
              //         .map<DropdownMenuItem<String>>((String productName) {
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
                              borderRadius:
                              BorderRadius.all(Radius.circular(4.0)))),
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
                    autovalidateMode:AutovalidateMode.onUserInteraction,
                    child: TextFormField(
                      controller: productBrand,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                          labelText: 'Product Brand Name',
                          prefixIcon: Icon(Icons.branding_watermark_rounded),
                          border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(4.0)))),
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
                              borderRadius:
                              BorderRadius.all(Radius.circular(4.0)))),
                      validator: _validateDescription,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  // Form(
                  //   onChanged: () {
                  //     setState(() {
                  //       isLoading = false;
                  //     });
                  //   },
                  //   key: productOfferTypeFormKey,
                  //   autovalidateMode: AutovalidateMode.onUserInteraction,
                  //   child: DropdownButtonFormField<String>(
                  //     decoration: const InputDecoration(
                  //         labelText: 'Offer Type',
                  //         prefixIcon: Icon(Icons.local_offer_rounded),
                  //         border: OutlineInputBorder(
                  //             borderRadius:
                  //             BorderRadius.all(Radius.circular(4.0)))),
                  //     items: <String>['INDIVIDUAL', 'BULK'].map((String value) {
                  //       return DropdownMenuItem<String>(
                  //         value: value,
                  //         child: Text(value),
                  //       );
                  //     }).toList(),
                  //     onChanged: (newValue) {
                  //       setState(() {
                  //         selectedOfferType = newValue;
                  //       });
                  //     },
                  //     validator: (value) {
                  //       if (value == null || value.isEmpty) {
                  //         return 'Please select an option';
                  //       }
                  //       return null;
                  //     },
                  //     hint: const Text('SELECT OFFER TYPE'),
                  //   ),
                  // ),
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
                      enabled: false,
                      maxLength: 3,
                      controller: productQuantity,
                      decoration: const InputDecoration(
                          labelText: 'Product Quantity',
                          prefixIcon: Icon(Icons.numbers_rounded),
                          border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(4.0)))),
                      keyboardType: TextInputType.number,
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
                              borderRadius:
                              BorderRadius.all(Radius.circular(4.0)))),
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
                    autovalidateMode:AutovalidateMode.onUserInteraction,
                    child: TextFormField(
                      controller: productDiscountPrice,
                      decoration: const InputDecoration(
                          labelText: 'Discounted Rate Per Unit Qty',
                          prefixIcon: Icon(Icons.currency_rupee_rounded),
                          border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(4.0)))),
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
                    onPressed: isLoading ? null : _updateProduct, // If isLoading is true, the button is disabled
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
