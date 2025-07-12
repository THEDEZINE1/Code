import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../CustomeTextStyle/custometextstyle.dart';
import '../PaymentMethod/payment_screen.dart';
import '../theme/AppTheme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../BaseUrl.dart';

String? user_token = '';
String? userID = '';

class CouponScreen extends StatefulWidget {
  @override
  _CouponScreen createState() => _CouponScreen();
}

class _CouponScreen extends State<CouponScreen> {
  Map<String, String> localizedStrings = {};
  String currentLangCode = 'en';
  bool isLoading = false;

  List<Map<String, dynamic>> productLabels = [];
  bool hasMoreData = true;
  final TextEditingController _reviewController = TextEditingController();

  bool isTextEntered = false;

  List<dynamic> couponList = [];

  void initState() {
    super.initState();
    _loadCurrentLanguagePreference();
    _initializeData();

    //_product_id = widget.product_id;
    //print('Item ID in Summary Screen: ${widget.product_id}');
  }

  Future<void> _initializeData() async {
    // Load user preferences and initialize data
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      user_token = prefs.getString('user_token') ?? '';
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

    final Map<String, dynamic> body = {
      'view': 'coupon_list', // Assuming the API requires the item ID to remove
      'custID': '$userID', // Assuming the API requires the item ID to remove
    };

    try {
      final response = await http.post(url, headers: headers, body: body);
      final data = jsonDecode(response.body.trim());

      if (data['result'] == '1') {
        log('Response data: $data');
        setState(() {
          couponList = data['data']['coupon_list'];
        });
      } else {
        final data = jsonDecode(response.body.trim());

        _showErrorSnackBar('${data['message']}');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
      print(e);
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
              style: CustomTextStyle.GraphikMedium(16, AppColors.white)!
                  .copyWith(color: AppColors.white))),
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
    print('selectedLangCode: $langCode');

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

  Future<void> applyCoupon(String couponCode, BuildContext context) async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    final url = Uri.parse(baseUrl); // Use your actual API base URL

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token', // Add user token for authorization
    };

    final Map<String, dynamic> body = {
      'view': 'discount', // Assuming the API requires the item ID to remove
      'custID': '$userID', // Assuming the API requires customer ID
      'coupon_code': couponCode,
    };

    try {
      // Send POST request
      final response = await http.post(url, headers: headers, body: body);

      // Check if the response is successful
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());
        log('Response data: $data');

        // Check if the API status is success
        if (data['status'] == 'success') {
          // Extract discount and discount ID
          final discount = data['data']['Discount'];
          final disID = data['data']['disID'];
          final message = data['message'];

          // Navigate to the Payment Screen with the discount and disID
          Navigator.of(context).pop();

          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  PaymentMethodScreen(
                disID: disID.toString(),
                discount: discount,
                couponCode: couponCode,
                message: message,
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );

          /*Navigator.pushNamed(
            context,
            '/payment_method', // Change this to your payment screen route
            arguments: {
              'couponCode': couponCode,
              'discount': discount,
              'disID': disID,
            },
          );*/

          // Show success message
        } else {
          // Show error message if the status is not success
          _showErrorSnackBar(data['message']);
        }
      } else {
        // Handle the case when the response code is not 200
        _showErrorSnackBar('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Catch any exceptions (like network errors)
      _showErrorSnackBar('An error occurred: $e');
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
    }
  }

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
              leading: Builder(
                builder: (BuildContext context) {
                  return RotatedBox(
                    quarterTurns: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        // Close the keyboard and navigate back
                        FocusScope.of(context).unfocus();
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
              backgroundColor: Colors.white,
              elevation: 0.0,
              title: Text(
                'Apply Promocode',
                //widget.carName, // Use widget.carName here
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: AppColors.colorPrimary,
            ))
          : (couponList.isEmpty)
              ? Center(
                  child: Text(
                    "No coupon code available",
                    style: CustomTextStyle.GraphikMedium(
                        18, AppColors.secondTextColor),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              color: AppTheme().whiteColor,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 25),

                                  // Promo Code TextField
                                  TextField(
                                    controller: _reviewController,
                                    onChanged: (value) {
                                      setState(() {
                                        isTextEntered = value.isNotEmpty;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Have a promocode? Enter here',
                                      labelStyle: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(color: AppColors.textSub),
                                      alignLabelWithHint: true,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme().placeHolderColor,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme().placeHolderColor,
                                          width: 1.0,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme().placeHolderColor,
                                          width: 1.0,
                                        ),
                                      ),
                                      suffixIcon: isTextEntered
                                          ? TextButton(
                                              style: TextButton.styleFrom(
                                                backgroundColor: AppColors
                                                    .colorPrimary, // Button background color
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                              ),
                                              onPressed: () {
                                                // Get the coupon code from the TextField
                                                final couponCode =
                                                    _reviewController.text
                                                        .trim();
                                                applyCoupon(
                                                    couponCode, context);
                                              },
                                              child: Text(
                                                'Apply',
                                                style: CustomTextStyle
                                                    .GraphikMedium(
                                                        16, AppColors.white),
                                              ),
                                            )
                                          : null,
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          color: AppColors.black,
                                        ),
                                  ),

                                  const SizedBox(height: 20),
                                  Text(
                                    'Choose from the offers below',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: AppColors.black,
                                            fontSize: 18),
                                  ),
                                  const SizedBox(height: 10),

                                  // Coupon List
                                  ListView.builder(
                                    itemCount: couponList.length,
                                    shrinkWrap: true, // Important
                                    physics:
                                        const NeverScrollableScrollPhysics(), // Prevent scroll conflict
                                    itemBuilder: (context, index) {
                                      final coupon = couponList[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Container(
                                          padding: const EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            boxShadow: const [
                                              BoxShadow(
                                                  color: Colors.grey,
                                                  blurRadius: 1.0)
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Left side: Coupon Details
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      coupon['code'],
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .displayMedium!
                                                          .copyWith(
                                                              color: AppColors
                                                                  .black,
                                                              fontSize: 15),
                                                      overflow: TextOverflow
                                                          .ellipsis, // Prevent overflow
                                                    ),
                                                    if (coupon['msg'] != null &&
                                                        coupon['msg']!
                                                            .isNotEmpty)
                                                      Text(
                                                        coupon['msg'],
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleSmall!
                                                            .copyWith(
                                                                color: AppColors
                                                                    .textSub,
                                                                fontSize: 12),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis, // Prevent overflow
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                  width:
                                                      10), // Add space between components
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: AppColors.colorPrimary,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                                child: TextButton(
                                                  onPressed: () {
                                                    print(
                                                        'Coupon ID: ${coupon['couponID']}');
                                                    print(
                                                        'Code: ${coupon['code']}');
                                                    print(
                                                        'Message: ${coupon['msg']}');
                                                    // Handle Apply action

                                                    applyCoupon(coupon['code'],
                                                        context);
                                                  },
                                                  child: Text(
                                                    'Apply',
                                                    style: CustomTextStyle
                                                        .GraphikMedium(16,
                                                            AppColors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
