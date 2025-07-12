import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../BaseUrl.dart';
import '../CustomeTextStyle/custometextstyle.dart';
import '../Dashboard/home_screen.dart';
import '../productDetails/product_details_screen.dart';
import '../theme/AppTheme.dart';
import 'delivery_address_screen.dart';

int total = 0;
int totalQuantity = 0;
double totalPrice = 0.00;
String? user_token = '';
String testID = '';
String? productID = '';
String? type = '';
String? ID = '';
String? productGrandTotal;
String? userID = '';

class MyCartScreen extends StatefulWidget {
  @override
  _MyCartScreenState createState() => _MyCartScreenState();
}

class _MyCartScreenState extends State<MyCartScreen> {
  List<Map<String, dynamic>> selectedItems = [];
  Map<String, String> localizedStrings = {};
  String currentLangCode = 'en';
  bool hasMoreData = true;
  bool isLoading = false;
  List cartItems = [];
  List deliverySelection = [];
  String totalCartAmount = '0';
  String totalItemAmount = '0';
  String? CodeYesOrNot;
  int itemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguagePreference();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Load user preferences and initialize data
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      user_token = prefs.getString('user_token') ?? '';
      type = prefs.getString('type') ?? '';
      userID = prefs.getString('userID') ?? '';
    });
    await _dashboardData();
  }

  Future<void> _dashboardData() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(baseUrl);
    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token',
    };
    final Map<String, String> body = {
      'view': 'cart',
      'page': 'list',
      'custID': '$userID',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());
        log('Response data: $data');
        log('$userID');

        cartItems.clear();

        if (data['status'] == 'success') {
          List cartListData = data['data']['cart'];
          dynamic totalAmountValue = data['data']['grand_total'];
          double totalAmount = double.parse(totalAmountValue.toString());
          int cartItemCount = int.parse(data['data']['total']);

          // Extract items with deliverySelection details
          List<dynamic> updatedCartItems = cartListData.map((item) {
            return {
              "cartID": item['cartID'],
              "name": item['name'],
              "productID": item['productID'],
              "priceID": item['priceID'],
              "deliveryType": item['deliveryType'] ?? '',
              "deliverySelection": item['deliverySelection'] ?? [],
              "image": item['image'],
              "price": item['price'],
              "mrp": item['mrp'],
              "min_qty": item['min_qty'],
              "cod_option_view": item['cod_option_view'],
              "gst_price_text": item['gst_price_text'],
              "cod_text": item['cod_text'],
              "cod_text_color_code": item['cod_text_color_code'],
              "total_item_price": item['total_item_price'],
              "quantity": item['quantity'],
              "selectedLabel": item['deliverySelection']?.firstWhere(
                      (option) => option['type'] == item['deliveryType'],
                      orElse: () => {})['label'] ??
                  'Select Delivery Type',
              "selectedNotes": item['deliverySelection']?.firstWhere(
                      (option) => option['type'] == item['deliveryType'],
                      orElse: () => {})['notes'] ??
                  '',
            };
          }).toList();

          setState(() {
            cartItems = updatedCartItems; // Updated list with selected labels

            totalCartAmount = totalAmount.toString();
            itemCount = cartItemCount;
          });
        } else {
          _showErrorSnackBar('Error: ${data['message']}');
        }
      } else {
        _showErrorSnackBar('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: CustomTextStyle.GraphikMedium(16, AppColors.white)),
      ),
    );
  }

  Future<void> _loadLanguage(String langCode) async {
    final String jsonString =
        await rootBundle.loadString('assets/lang/$langCode.json');
    setState(() {
      localizedStrings = Map<String, String>.from(json.decode(jsonString));
    });
  }

  Future<void> _loadCurrentLanguagePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? langCode = prefs.getString('selected_language_code');

    if (langCode != null && langCode.isNotEmpty) {
      setState(() {
        currentLangCode = langCode;
      });
      await _loadLanguage(currentLangCode);
    }
  }

  String translate(String key) {
    return localizedStrings[key] ?? key;
  }

  Future<void> _removeItemById(
      String productID, String priceID, String cartID) async {
    final url = Uri.parse(baseUrl);

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token', // Use your actual token here
    };

    // Body of the request
    final Map<String, dynamic> body = {
      'view': 'cart',
      'custID': '$userID',
      'page': 'remove',
      'priceID': priceID.toString(),
      'productID': productID.toString(),
      'cartID': cartID.toString(),
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());
        if (data['status'] == 'success') {
          // Successfully removed item from the server
          log('Item removed successfully: $data');

          final totalAmount = data['data']['amount_total'];
          final totalItem = data['data']['cart_count'];
          final totalProductAmount = data['data']['grand_total'];

          if (totalAmount != null) {
            // Handle SharedPreferences outside of setState
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('cart_count', totalItem);

            setState(() {
              // Update UI based on fetched values
              cartItems.removeWhere((item) => item['productID'] == productID);
              totalCartAmount =
                  double.parse(totalAmount.toString()).toStringAsFixed(2);
            });
          } else {
            log('totalAmount is null');
          }
        } else {
          // Server responded with an error message
          _showErrorSnackBar('Error: ${data['message']}');
        }
      } else {
        _showErrorSnackBar('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
    }
  }

  Future<void> _clearCart() async {
    final url = Uri.parse(baseUrl);

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token',
    };

    final Map<String, dynamic> body = {
      'view': 'cart',
      'custID': '$userID',
      'page': 'clear',
    };

    // Set the state to clear the cart

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());
        if (data['status'] == 'success') {
          log('Cart cleared successfully: $data');
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('cart_count', 0);

          setState(() {
            cartItems.clear(); // Clear all items in the cart
          });
        } else {
          _showErrorSnackBar('Error: ${data['message']}');
        }
      } else {
        _showErrorSnackBar('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
    }
  }

  void _showDeliverySelectionPopup(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme().whiteColor,
          surfaceTintColor: AppTheme().whiteColor,
          title: Text(
            "Select Delivery Type",
            style: CustomTextStyle.GraphikMedium(16, AppColors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: item['deliverySelection'].map<Widget>((option) {
              return ListTile(
                title: Text(
                  option['label'],
                  style: CustomTextStyle.GraphikRegular(
                      15, AppColors.secondTextColor),
                ),
                onTap: () async {
                  Navigator.of(context).pop();

                  // Optimistically update UI
                  setState(() {
                    item['selectedLabel'] = option['label'];
                    item['deliveryType'] = option['type'];
                  });

                  // Log for debugging
                  log('Selected Type: ${option['type']}');
                  log('Selected Cart ID: ${item['cartID']}');

                  await _updateDeliveryType(item, option);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _updateDeliveryType(
      Map<String, dynamic> item, Map<String, dynamic> option) async {
    final url = Uri.parse(baseUrl);

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token', // Use your actual token here
    };

    final Map<String, dynamic> body = {
      'view': 'cart',
      'custID': '$userID', // Assuming the API requires the item ID to remove
      'page': 'update_delivery_type',
      'cartID': option['cartID'].toString(),
      'deliveryType': option['type'].toString(),
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          log('Delivery type updated successfully: $data');
          //Navigator.of(context).pop();
          await _dashboardData();
          // Navigate to cart page or perform any other success action
          setState(() {});
        } else {
          // Handle server-side error
          _showErrorSnackBar('Error: ${data['message']}');
        }
      } else {
        // Handle HTTP error
        _showErrorSnackBar('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle network or unexpected errors
      _showErrorSnackBar('An error occurred: $e');
    }
  }

  /*void _showDeliverySelectionPopup(Map item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Delivery Type"),
          content: Container(
            child: SingleChildScrollView(  // Make the content scrollable
              child: Column(
                mainAxisSize: MainAxisSize.min,  // Prevent overflow
                children: [
                  ListView.builder(
                    shrinkWrap: true,  // Makes ListView take only required space
                    physics: NeverScrollableScrollPhysics(),  // Disable ListView's internal scrolling
                    itemCount: item['deliverySelection'].length,
                    itemBuilder: (context, index) {
                      final option = item['deliverySelection'][index];
                      bool isSelected = option['type'] == item['deliveryType'];

                      return ListTile(
                        title: Text(option['label']),
                        tileColor: isSelected ? Colors.blue.withOpacity(0.2) : null,  // Highlight selected item
                        onTap: () {
                          // Update the delivery type and label when an option is selected
                          setState(() {
                            item['deliveryType'] = option['type'];
                            item['selectedLabel'] = option['label'];
                          });
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(
          kToolbarHeight + 1.0, // AppBar default height + container height
        ),
        child: Column(
          children: [
            AppBar(
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Get.to(Home()),
              ),
              backgroundColor: Colors.white,
              title: Text(
                'My Cart',
                style: CustomTextStyle.GraphikMedium(16, AppColors.black),
              ),
            ),
            Container(
              height: 1.0,
              color: AppTheme().lineColor,
            ),
          ],
        ),
      ),
      backgroundColor: AppTheme().mainBackgroundColor,
      body: Column(
        children: [
          // Main content: ListView or empty message
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.colorPrimary,
                    ),
                  )
                : cartItems.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              // SVG image (ensure you have the image in your assets)
                              SvgPicture.asset(
                                'assets/icons/no_cart.svg', // Path to your SVG file in assets
                                height: 150, // Adjust size as needed
                              ),
                              const SizedBox(height: 20),

                              // Text message
                              Text(
                                'Your cart is empty',
                                style: CustomTextStyle.GraphikMedium(
                                    22, AppColors.black),
                              ),
                              const SizedBox(height: 10),

                              // Additional message or info
                              Text(
                                'There are no products in your cart.\nExplore and add some!',
                                textAlign: TextAlign.center,
                                style: CustomTextStyle.GraphikRegular(
                                    18, AppColors.secondTextColor),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              color: AppTheme().whiteColor,
                              padding: const EdgeInsets.only(
                                  right: 15.0,
                                  left: 15.0,
                                  bottom: 10.0,
                                  top: 10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${cartItems.length} items',
                                    style: CustomTextStyle.GraphikMedium(
                                        14, AppColors.secondTextColor),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Alert',
                                                style: CustomTextStyle
                                                    .GraphikMedium(
                                                        18, AppColors.black)),
                                            content: Text(
                                                'Do you really want to clear cart ?.',
                                                style: CustomTextStyle
                                                    .GraphikRegular(
                                                        16,
                                                        AppColors
                                                            .secondTextColor)),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('No',
                                                    style: CustomTextStyle
                                                        .GraphikMedium(
                                                            14,
                                                            AppColors
                                                                .colorPrimary)),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  _clearCart();
                                                  Get.to(const Home());
                                                },
                                                child: Text('Yes',
                                                    style: CustomTextStyle
                                                        .GraphikMedium(
                                                            14,
                                                            AppColors
                                                                .colorPrimary)),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/delete.svg', // Path to your SVG asset
                                          width:
                                              20, // Set the width of the SVG icon
                                          height:
                                              20, // Set the height of the SVG icon
                                          color: AppColors
                                              .red, // Optional: set the color of the SVG icon
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          translate('Clear Cart'),
                                          style: CustomTextStyle.GraphikMedium(
                                              14, AppColors.secondTextColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: cartItems.length,
                              itemBuilder: (context, index) {
                                final item = cartItems[index];
                                CodeYesOrNot = item['cod_text'];

                                void navigateToDetails(BuildContext context) {
                                  Navigator.of(context).pop();

                                  Get.to(
                                    ProductDetailScreen(
                                        product_id:
                                            item['productID'].toString()),
                                  );
                                }

                                return GestureDetector(
                                  onTap: () {
                                    navigateToDetails(context);
                                  },
                                  child: Container(
                                    color: Colors.white,
                                    padding: const EdgeInsets.all(15.0),
                                    margin: const EdgeInsets.only(bottom: 10.0),
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              bottom: 10.0),
                                          child: Row(
                                            children: [
                                              Container(
                                                height: 100.0,
                                                width: 100.0,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: AppTheme().lineColor,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                        item['image']),
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10.0),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        // Use a Container or SizedBox to limit the size of the Text, or just let it take space naturally
                                                        Flexible(
                                                          child: Text(
                                                            item['name'],
                                                            style: CustomTextStyle
                                                                .GraphikMedium(
                                                                    14,
                                                                    AppColors
                                                                        .black),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        // Delete icon on the right side
                                                        GestureDetector(
                                                          onTap: () {
                                                            _removeItemById(
                                                                item[
                                                                    'productID'],
                                                                item['priceID'],
                                                                item['cartID']);
                                                          },
                                                          child:
                                                              SvgPicture.asset(
                                                            'assets/icons/delete.svg', // Path to your SVG asset
                                                            width:
                                                                20, // Set the width of the SVG icon
                                                            height:
                                                                20, // Set the height of the SVG icon
                                                            color: AppColors
                                                                .red, // Optional: set the color of the SVG icon
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Visibility(
                                                                    visible: item['price'] !=
                                                                            null &&
                                                                        item['price']
                                                                            .isNotEmpty,
                                                                    child: Text(
                                                                      '₹ ${'${item['price']}'}',
                                                                      style: CustomTextStyle.GraphikMedium(
                                                                          14,
                                                                          AppColors
                                                                              .black),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 5.0,
                                                                  ),
                                                                  Visibility(
                                                                    visible: item['mrp'] !=
                                                                            null &&
                                                                        item['mrp']
                                                                            .isNotEmpty,
                                                                    child: Text(
                                                                      '₹ ${'${item['mrp']}'}',
                                                                      style: CustomTextStyle.GraphikRegular(9, AppTheme().secondTextColor)?.copyWith(
                                                                          decoration: TextDecoration
                                                                              .lineThrough,
                                                                          decorationThickness:
                                                                              1,
                                                                          decorationColor: AppColors
                                                                              .black,
                                                                          fontSize:
                                                                              13),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Visibility(
                                                                visible: item[
                                                                            'gst_price_text'] !=
                                                                        null &&
                                                                    item['gst_price_text']
                                                                        .isNotEmpty,
                                                                child: Text(
                                                                  '${item['gst_price_text']}',
                                                                  style: CustomTextStyle
                                                                      .GraphikRegular(
                                                                          9,
                                                                          AppTheme()
                                                                              .secondTextColor),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Visibility(
                                                      visible: item[
                                                              'cod_option_view'] ==
                                                          'Yes', // Check if cod_option_view is 'Yes'
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            'COD :-  ',
                                                            style: CustomTextStyle
                                                                .GraphikMedium(
                                                                    10,
                                                                    AppTheme()
                                                                        .blackColor),
                                                          ),
                                                          Text(
                                                            '${item['cod_text']}',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontFamily:
                                                                  'GraphikRegular',
                                                              color: item['cod_text_color_code'] !=
                                                                          null &&
                                                                      item['cod_text_color_code']
                                                                          .isNotEmpty
                                                                  ? Color(int.parse(
                                                                      '0xFF${item['cod_text_color_code'].substring(1)}'))
                                                                  : Colors
                                                                      .black, // Fallback if cod_text_color_code is empty
                                                              /*color: item['cod_text_color_code'] != null && item['cod_text_color_code'].isNotEmpty
                                                    ? Color(int.parse('0x${item['cod_text_color_code'].substring(1)}')) // Remove # and convert hex color code to Color
                                                    : Colors.black, // Default color if cod_text_color_code is null or empty*/
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5.0),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  // Left Side Texts
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          SizedBox(
                                                                            width:
                                                                                30.0,
                                                                            height:
                                                                                30.0,
                                                                            child:
                                                                                ElevatedButton(
                                                                              onPressed: () async {
                                                                                // Convert item['quantity'] and item['min_qty'] to integers
                                                                                int quantity = int.parse(item['quantity'].toString());
                                                                                int minQty = int.parse(item['min_qty'].toString());

                                                                                // Make the API call first before updating the quantity
                                                                                if (quantity > minQty) {
                                                                                  // Call the API to update the cart
                                                                                  final url = Uri.parse(baseUrl); // Replace with your API endpoint
                                                                                  final Map<String, String> headers = {
                                                                                    'Content-Type': 'application/x-www-form-urlencoded',
                                                                                    'Authorization': 'Bearer $user_token', // Include the user token if necessary
                                                                                  };

                                                                                  final Map<String, String> body = {
                                                                                    'view': 'cart',
                                                                                    'custID': '$userID',
                                                                                    'page': 'update',
                                                                                    'productID': item['productID'].toString(),
                                                                                    'productQty': (quantity - 1).toString(), // Decrement the quantity by 1
                                                                                    'cartID': item['cartID'].toString(),
                                                                                    'priceID': item['priceID'].toString(),
                                                                                  };

                                                                                  try {
                                                                                    // Make the API call
                                                                                    final response = await http.post(url, headers: headers, body: body);

                                                                                    if (response.statusCode == 200) {
                                                                                      final data = jsonDecode(response.body);
                                                                                      log('Response data: $data');

                                                                                      if (data['status'] == 'success') {
                                                                                        log('response: ${data['message']}');

                                                                                        // Get total amount and cart list
                                                                                        final totalAmount = data['data']['amount_total'];
                                                                                        final totalItem = data['data']['cart_count'];
                                                                                        final totalProductAmount = data['data']['total_item_price'];

                                                                                        if (totalAmount != null) {
                                                                                          // Handle SharedPreferences outside of setState
                                                                                          final prefs = await SharedPreferences.getInstance();
                                                                                          await prefs.setInt('cart_count', totalItem);

                                                                                          setState(() {
                                                                                            // Update UI based on fetched values
                                                                                            //totalCartAmount = totalAmount.toString();
                                                                                            totalCartAmount = double.parse(totalAmount.toString()).toStringAsFixed(2);
                                                                                            productGrandTotal = double.parse(totalProductAmount.toString()).toStringAsFixed(2);
                                                                                            item['total_item_price'] = totalProductAmount;
                                                                                            // Optionally, update other fields as required
                                                                                          });
                                                                                        } else {
                                                                                          log('totalAmount is null');
                                                                                        }

                                                                                        // After successful API response, update the quantity in the item
                                                                                        setState(() {
                                                                                          item['quantity'] = (quantity - 1).toString();
                                                                                        });
                                                                                      } else {
                                                                                        // Handle error returned by the API
                                                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                                                          SnackBar(
                                                                                            content: Text(data['message'], style: CustomTextStyle.GraphikMedium(16, AppColors.white)),
                                                                                          ),
                                                                                        );
                                                                                      }
                                                                                    } else {
                                                                                      // Handle HTTP error responses
                                                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                                                        SnackBar(content: Text('Error: ${response.reasonPhrase}', style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
                                                                                      );
                                                                                    }
                                                                                  } catch (e) {
                                                                                    // Handle exceptions
                                                                                    log('Error updating favorite status: $e');
                                                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                                                      SnackBar(
                                                                                        content: Text('An unexpected error occurred.', style: CustomTextStyle.GraphikMedium(16, AppColors.white)),
                                                                                      ),
                                                                                    );
                                                                                  }
                                                                                } else {
                                                                                  // Show a SnackBar indicating the minimum purchase quantity has been reached
                                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                                    SnackBar(
                                                                                      content: Text("Min Purchase Qty ${item['min_qty']}", style: CustomTextStyle.GraphikMedium(16, AppColors.white)),
                                                                                    ),
                                                                                  );
                                                                                }

                                                                                // Log the current state
                                                                                log(item['quantity'].toString());
                                                                                log(item['productID'].toString());
                                                                                log(item['priceID'].toString());
                                                                                log(item['cartID'].toString());
                                                                              },
                                                                              style: ElevatedButton.styleFrom(
                                                                                foregroundColor: AppTheme().whiteColor,
                                                                                backgroundColor: AppColors.colorPrimary,
                                                                                shape: RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                                ),
                                                                                side: const BorderSide(
                                                                                  color: AppColors.white,
                                                                                  width: 1.5, // Border width
                                                                                ),
                                                                                padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
                                                                              ),
                                                                              child: const Icon(Icons.remove, color: AppColors.white),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 5.0),
                                                                          Container(
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              border: Border.all(color: AppTheme().new_maintextcolor, width: 1.0),
                                                                              color: AppTheme().whiteColor,
                                                                              // Set the background color
                                                                              borderRadius: BorderRadius.circular(5.0), // Rounded corners with radius 5
                                                                            ),
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                                                                            // Add padding around the text
                                                                            child:
                                                                                Text(
                                                                              '${item['quantity']}',
                                                                              style: CustomTextStyle.GraphikMedium(12, AppColors.black),
                                                                              // Name
                                                                              textAlign: TextAlign.center, // Center-align the text
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 5.0),
                                                                          SizedBox(
                                                                            width:
                                                                                30.0,
                                                                            height:
                                                                                30.0,
                                                                            child:
                                                                                ElevatedButton(
                                                                              onPressed: () async {
                                                                                //item['quantity']++;
                                                                                int quantity = int.parse(item['quantity'].toString());

                                                                                final url = Uri.parse(baseUrl); // Replace with your API endpoint
                                                                                final Map<String, String> headers = {
                                                                                  'Content-Type': 'application/x-www-form-urlencoded',
                                                                                  'Authorization': 'Bearer $user_token', // Include the user token if necessary
                                                                                };

                                                                                final Map<String, String> body = {
                                                                                  'view': 'cart',
                                                                                  'custID': '$userID',
                                                                                  'page': 'update',
                                                                                  'productID': item['productID'].toString(),
                                                                                  'productQty': (quantity + 1).toString(),
                                                                                  'cartID': item['cartID'].toString(),
                                                                                  'priceID': item['priceID'].toString(),
                                                                                };

                                                                                try {
                                                                                  // Make the API call
                                                                                  final response = await http.post(url, headers: headers, body: body);

                                                                                  if (response.statusCode == 200) {
                                                                                    final data = jsonDecode(response.body);
                                                                                    log('Response data: $data');

                                                                                    if (data['status'] == 'success') {
                                                                                      log('response: ${data['message']}');

                                                                                      // Get total amount and cart list
                                                                                      final totalAmount = data['data']['amount_total'];
                                                                                      final totalItem = data['data']['cart_count'];
                                                                                      final totalProductAmount = data['data']['total_item_price'];

                                                                                      if (totalAmount != null) {
                                                                                        // Handle SharedPreferences outside of setState
                                                                                        final prefs = await SharedPreferences.getInstance();
                                                                                        await prefs.setInt('cart_count', totalItem);

                                                                                        setState(() {
                                                                                          // Update UI based on fetched values
                                                                                          totalCartAmount = double.parse(totalAmount.toString()).toStringAsFixed(2);
                                                                                          // Optionally, update other fields as required
                                                                                          productGrandTotal = double.parse(totalProductAmount.toString()).toStringAsFixed(2);
                                                                                          item['total_item_price'] = totalProductAmount;
                                                                                          /*productGrandTotal = double.parse(totalProductAmount.toString()).toStringAsFixed(2);
                                                                item['price'] = totalProductAmount; // Example calculation*/
                                                                                        });
                                                                                      } else {
                                                                                        log('totalAmount is null');
                                                                                      }

                                                                                      setState(() {
                                                                                        item['quantity'] = int.parse(item['quantity'].toString()) + 1;
                                                                                      });
                                                                                    } else {
                                                                                      // Handle error returned by the API
                                                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                                                        SnackBar(content: Text(data['message'], style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
                                                                                      );
                                                                                    }
                                                                                  } else {
                                                                                    // Handle HTTP error responses
                                                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                                                      SnackBar(content: Text('Error: ${response.reasonPhrase}', style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
                                                                                    );
                                                                                  }
                                                                                } catch (e) {
                                                                                  // Handle exceptions
                                                                                  log('Error updating favorite status: $e');
                                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                                    SnackBar(content: Text('An unexpected error occurred.', style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
                                                                                  );
                                                                                }

                                                                                log(item['quantity'].toString());
                                                                                log(item['productID'].toString());
                                                                                log(item['priceID'].toString());
                                                                                log(item['cartID'].toString());
                                                                              },
                                                                              style: ElevatedButton.styleFrom(
                                                                                foregroundColor: AppTheme().whiteColor,
                                                                                backgroundColor: AppColors.colorPrimary,
                                                                                shape: RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                                ),
                                                                                side: const BorderSide(
                                                                                  color: AppColors.white,
                                                                                  width: 1.5, // Border width
                                                                                ),
                                                                                padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
                                                                              ),
                                                                              child: const Icon(Icons.add, color: AppColors.white),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),

                                                                  // Right Side Text
                                                                  Visibility(
                                                                    visible: item['total_item_price'] !=
                                                                            null &&
                                                                        item['total_item_price']
                                                                            .isNotEmpty,
                                                                    child: Text(
                                                                      '₹ ${item['total_item_price']}',
                                                                      style: CustomTextStyle.GraphikMedium(
                                                                          12,
                                                                          AppTheme()
                                                                              .blackColor),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Divider(
                                            height: 1.0,
                                            color: AppTheme().lineColor),
                                        const SizedBox(height: 10),
                                        if (cartItems.isNotEmpty)
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    item['deliverySelectionHeading'] ??
                                                        "Delivery Type",
                                                    style: CustomTextStyle
                                                        .GraphikMedium(
                                                            14,
                                                            AppColors
                                                                .secondTextColor),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  InkWell(
                                                    onTap: () {
                                                      _showDeliverySelectionPopup(
                                                          item); // Open delivery selection popup
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 3,
                                                          horizontal: 5),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: AppColors
                                                                .colorPrimary),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            // Display selected delivery type label
                                                            item['selectedLabel'] ??
                                                                "Select Delivery Type",
                                                            style: CustomTextStyle
                                                                .GraphikRegular(
                                                                    11,
                                                                    AppTheme()
                                                                        .blackColor),
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          const Icon(
                                                            Icons
                                                                .keyboard_arrow_down,
                                                            size: 20,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Visibility(
                                                visible: item['selectedNotes']
                                                    .toString()
                                                    .isNotEmpty,
                                                child: Text(
                                                  item['selectedNotes']
                                                      .toString(),
                                                  style: CustomTextStyle
                                                      .GraphikRegular(
                                                          11,
                                                          AppTheme()
                                                              .blackColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
          ),

          if (cartItems.isNotEmpty &&
              double.tryParse(totalCartAmount) != null &&
              double.parse(totalCartAmount) > 0.0)
            Column(
              children: [
                Container(
                  height: 1.0,
                  color: AppTheme().lineColor,
                ),
                Container(
                  color: AppTheme().whiteColor,
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Amount',
                            style: CustomTextStyle.GraphikMedium(
                                12, AppColors.secondTextColor),
                          ),
                          //${totalAmount.toStringAsFixed(2)}
                          Text(
                            '₹ $totalCartAmount',
                            style: CustomTextStyle.GraphikRegular(
                                16, AppColors.black),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Get.to(DeliveryAddressScreen(
                            CODYesOrNot: CodeYesOrNot,
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.colorPrimary,
                          // Background color of the button
                          minimumSize:
                              const Size(150, 50), // Adjust width as needed
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical:
                                  15), // Vertical padding for button content
                        ),
                        child: Text(
                          'Continue',
                          style: CustomTextStyle.GraphikMedium(
                              14, AppColors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
