import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../BaseUrl.dart';
import '../productDetails/product_details_screen.dart';
import '../theme/AppTheme.dart';


String? user_token = '';
int? product_id;

class RatingBarExample extends StatefulWidget {
  @override
  _RatingBarExampleState createState() => _RatingBarExampleState();
}

class _RatingBarExampleState extends State<RatingBarExample> {
  double _rating = 0;
  Map<String, String> localizedStrings = {};
  String currentLangCode = 'en';
  bool isLoading = false;
  bool hasMoreData = true;
  TextEditingController _reasonController = TextEditingController();

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
    });
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

  Future<void> _submit(String reason, String rating, String product_id) async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(product_review_store);

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token',
    };

    final Map<String, dynamic> body = {
      'description': reason, // Assuming the API requires the item ID to remove
      'rate': rating, // Assuming the API requires the item ID to remove
      'product_id': product_id, // Assuming the API requires the item ID to remove
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Successfully updated favorite status
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ProductDetailScreen(product_id: product_id.toString()),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ));
          FocusScope.of(context).unfocus(); // Dismiss the keyboard
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        } else {
          // Handle error returned by the API
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      } else {
        // Handle error response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    final FocusNode _focusNode = FocusNode();

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    String product_name = args['product_name'];
    String product_image = args['product_image'];
    String partner_name = args['partner_name'];
    String weight = args['weight'];
    String unit = args['unit'];
    product_id = args['product_id'];


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
                      onPressed: () => Navigator.pop(context),
                    ),
                  );
                },
              ),
              backgroundColor: Colors.white,
              elevation: 0.0,
              title: Text(
                'Feedback & Review',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium!
                    .copyWith(color: AppColors.black),
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
          Expanded(
            child: SingleChildScrollView(

              child: Column(

                children: [
                  Container(
                    padding: const EdgeInsets.all(15.0),

                    height: 130.0,
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 100.0,
                          width: 100.0, // Fixed width
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey, // Border color
                              width: 1.0, // Border width
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                            image: DecorationImage(
                              image: NetworkImage(product_image),
                              fit: BoxFit.contain, // Adjust image fit
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0), // Spacing between image and text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      product_name,
                                      //                                       // Example text from car object
                                      style: const TextStyle(
                                      fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2, // Limit to 1 line for name
                                      overflow:
                                      TextOverflow.ellipsis, // Ellipsis for overflow
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5.0), // Space between text elements
                              Text(
                                partner_name,
                                // Another text field from car object
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: AppTheme().secondTextColor,
                                ),
                                maxLines: 1, // Limit to 2 lines
                                overflow: TextOverflow.ellipsis, // Ellipsis for overflow
                              ),
                              const SizedBox(height: 10.0),
                              Container(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Visibility(
                                            //visible: widget.car.price != null && widget.car.price.isNotEmpty,
                                            child: Text(
                                              //'₹ ${'${'widget.car.price'} / ${'widget.car.unit'}'}',
                                              '${weight} / ${unit}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppTheme().firstTextColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          /*SizedBox(
                                            width: 5.0,
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 3.0),
                                            child: Visibility(
                                              //visible: widget.car.mrp != null && widget.car.mrp.isNotEmpty,
                                              child: Text(
                                                '₹ ${'${'widget.car.mrp'}'}',
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: AppTheme().secondTextColor,
                                                    decoration: TextDecoration.lineThrough),
                                              ),
                                            ),
                                          ),*/
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10.0),
                  Container(
                    padding: const EdgeInsets.all(15.0),
                    color: AppTheme().whiteColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('How would you rete this product?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            RatingBar(
                              filledIcon: Icons.star,       // Icon when rated
                              emptyIcon: Icons.star_border, // Icon when not rated
                              size: 40,                     // Size of stars
                              initialRating: _rating,       // Initial rating
                              maxRating: 5,                 // Maximum rating (out of 5 stars)
                              onRatingChanged: (rating) {
                                setState(() {
                                  _rating = rating;
                                });
                              },
                              filledColor: AppTheme().primaryColor,    // Color of the filled stars
                              emptyColor: Colors.grey,     // Color of the empty stars
                              halfFilledIcon: Icons.star_half, // Optional: Half filled icon
                            ),
                            const SizedBox(height: 10),

                            Container(
                              height: 1.0,
                              color: AppTheme().lineColor,
                            ),
                            const SizedBox(height: 20),

                            const Text('Write a Review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _reasonController,
                              focusNode: _focusNode, // Use focus node to control focus
                              decoration: InputDecoration(
                                labelText: 'How is the product? What do you like?',
                                labelStyle: TextStyle(color: AppTheme().secondTextColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(color: AppTheme().lineColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(color: AppTheme().lineColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(color: AppTheme().lineColor),
                                ),
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 1.0,
            color: AppTheme().lineColor,
          ),
          Container(
            color: AppTheme().whiteColor,
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              width: double.infinity, // Button takes up full width
              child: ElevatedButton(
                onPressed: () async {

                  print('Selected Payment Method: ${_reasonController.text}');
                  print('Selected payment: ${_rating.toString()}');
                  print('Selected user_token: ${product_id.toString()}');
                  _submit(_reasonController.text, _rating.toString(), product_id.toString());

                  // Print the selected payment method
                  /*print('Selected Payment Method: $_selectedPaymentMethod');
                  print('Selected payment: $totalPayment');
                  print('Selected user_token: $user_token');
                  //Navigator.pushNamed(context, '/order_success');
                  CheckoutPayment(selectedAddressId.toString(), _selectedPaymentMethod.toString());*/
                },
                style: ElevatedButton.styleFrom(
                  //backgroundColor: AppTheme().secondaryColor,
                  backgroundColor: isLoading
                      ? Colors.grey // Change to grey when loading
                      : AppTheme().secondaryColor, // Original color when not loading
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                /*child: Text(
                    'Place Order',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme().whiteColor,
                    ),
                  ),*/
                child: isLoading
                    ? const CircularProgressIndicator(        color: AppColors.colorPrimary,
                )
                    : Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme().whiteColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

    );
  }
}
