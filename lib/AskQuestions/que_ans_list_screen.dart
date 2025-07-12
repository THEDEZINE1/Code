import 'dart:convert';
import 'dart:developer';

//import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../CustomeTextStyle/custometextstyle.dart';
import '../theme/AppTheme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../BaseUrl.dart';


String? first_name = '';
String? last_name = '';
String? email = '';
String? mobile = '';
String? user_token = '';
String? image = '';
String selectedTestIds = '';
int? cart_count;
String? type = '';

class QuestionAndAnswerListScreen extends StatefulWidget {
  //final String product_id;

  // Constructor
  //RatingAndReviewScreen({Key? key, required this.product_id}) : super(key: key);

  @override
  _QuestionAndAnswerListScreen createState() => _QuestionAndAnswerListScreen();
}

class _QuestionAndAnswerListScreen extends State<QuestionAndAnswerListScreen> {
  Map<String, String> localizedStrings = {};
  String currentLangCode = 'en';
  bool isLoading = false;
  Map<String, dynamic>? productInfo;
  List<Map<String, dynamic>> productLabels = [];
  List<Map<String, dynamic>> productTests = [];
  bool hasMoreData = true;

  String Name = '';
  String partner_name = '';
  String price = '';
  String mrp = '';
  String unit = '';
  String description = '';
  String _product_id = '';
// Default message color




// Default selected size
  List<Map<String, dynamic>> selectedItems = [];

  double rating = 3; // Example dynamic rating value

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
      first_name = prefs.getString('first_name') ?? '';
      last_name = prefs.getString('last_name') ?? '';
      email = prefs.getString('email') ?? '';
      mobile = prefs.getString('mobile') ?? '';
      user_token = prefs.getString('user_token') ?? '';
      type = prefs.getString('type') ?? '';
      image = prefs.getString('image') ?? '';
      cart_count = prefs.getInt('cart_count')!;

    });


    //await _dashboardData();
  }

  Future<void> _dashboardData() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(product_details);

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token',
    };

    final Map<String, dynamic> body = {
      'product_id': _product_id, // Assuming the API requires the item ID to remove
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());
        log('Response data: $data');

        productInfo?.clear();

        if (data['result'] == 1) {
          // Extract product details
          productInfo = data['data']['product_detail'];
          productLabels = List<Map<String, dynamic>>.from(data['data']['product_label']);
          productTests = List<Map<String, dynamic>>.from(data['data']['product_test']);

          Name = productInfo?['name'];
          partner_name = productInfo?['partner_name'];
          price = productInfo?['price'];
          mrp = productInfo?['mrp'];
          unit = productInfo?['base_weight'];
          description = productInfo?['description'];

          setState(() {
            // Set selectedItems to only include tests that are in the cart
            selectedItems = productTests.where((test) => test['in_cart']).toList();
            selectedTestIds = selectedItems.map((test) => test['test_id'].toString()).join(',');

          });
          print('Selected Test IDs: $selectedTestIds');

          log('productInfo: $productInfo'); // Log extracted image URLs
          log('productTests: $productTests'); // Log extracted image URLs
        } else {
          _showErrorSnackBar(data['message']);
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
      SnackBar(content: Text(message,style: Theme.of(context)
          .textTheme
          .displayMedium!
          .copyWith(color: AppColors.white))),
    );
  }

  AddToCart(String quantity, String selectedTestIds, String product_id) async {

    // Prepare the API call
    final url = Uri.parse(addCart); // Replace with your API endpoint
    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token', // Include the user token if necessary
    };


    final Map<String, String> body = {
      'product_id': product_id, // Pass the car ID to the API
      'qty': quantity, // Pass the new favorite state
      'test_id': selectedTestIds, // Pass the new favorite state
    };

    try {
      // Make the API call
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Successfully updated favorite status
          log('updated: ${data['message']}');
          final totalItem = data['data']['totalItem'];
          final prefs = await SharedPreferences.getInstance();

          setState(()  {
            // Ensure precision up to 2 decimal points
            cart_count = totalItem;
            prefs.setInt('cart_count', totalItem);
          });

          Navigator.pushNamed(context, '/my_cart');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'],style: Theme.of(context)
                .textTheme
                .displayMedium!
                .copyWith(color: AppColors.white)),),
          );
        } else {
          // Handle error returned by the API
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'],style: Theme.of(context)
                .textTheme
                .displayMedium!
                .copyWith(color: AppColors.white))),
          );
        }
      } else {
        // Handle HTTP error responses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.reasonPhrase}',style: Theme.of(context)
              .textTheme
              .displayMedium!
              .copyWith(color: AppColors.white))),
        );
      }
    } catch (e) {
      // Handle exceptions
      log('Error updating favorite status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred.',style: Theme.of(context)
            .textTheme
            .displayMedium!
            .copyWith(color: AppColors.white))),
      );
    }
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
                      onPressed: () => Navigator.pop(context),
                    ),
                  );
                },
              ),
              backgroundColor: Colors.white,
              elevation: 0.0,
              title: Text(
                translate('Frequently Asked Questions'),
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: AppTheme().whiteColor,
                        //padding: const EdgeInsets.all(10.0),
                        padding: const EdgeInsets.only(right: 10.0, left: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /*SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between start and end
                              children: [
                                Row(
                                  children: [

                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Frequently Asked Questions',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppTheme().new_maintextcolor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),

                                      ],
                                    ),

                                  ],
                                ),

                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFfae0e1), // Light red background color for the button
                                    borderRadius: BorderRadius.circular(5.0), // Rounded corners
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                    vertical: 6.0,
                                  ), // Add padding inside the button
                                  child: Text(
                                    'ASK NOW', // Button text
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFd9232d), // Dark red text color
                                      fontWeight: FontWeight.w600, // Bold text
                                    ),
                                    textAlign: TextAlign.center, // Center-align the text
                                  ),
                                ),
                              ],
                            ),*/

                            //SizedBox(height: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const SizedBox(height: 10),
                                Text(
                                  ' Displaying Questions 2/3',
                                  style: TextStyle(fontSize: 12, color: AppTheme().new_maintextcolor),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),
                            Divider(
                              color: AppTheme().lineColor,
                              thickness: 1.0,
                            ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 12, // Replace with actual number of reviews
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [

                            Text(
                              'Q${index + 1}: Does it support inverter?',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme().new_maintextcolor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              margin: const EdgeInsets.only(left: 25.0),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ans: Yes, it does',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xff6f6f6f),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      if ((index + 1) % 1 == 0 && index != 11) // Add a divider after every two items, except the last item
                        Divider(
                          color: AppTheme().lineColor,
                          thickness: 1.0,
                        ),

                      /*if ((index + 1) % 2 == 0 && index != dynamicList.length - 1) // Check for dynamic list
                        Divider(
                          color: AppTheme().lineColor,
                          thickness: 1.0,
                        ),*/
                    ],
                  );
                },
              ),
                          ],
                        ),
                      ),
                    ],
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

  Widget _buildRatingItem(int rating, Color color, double progress) {
    return Row(
      children: <Widget>[
        Text(
          '$rating',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10.0,
            backgroundColor: const Color(0xFFededed),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
