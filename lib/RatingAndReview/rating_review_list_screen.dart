import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:Decont/RatingAndReview/write_review_screen.dart';
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

class RatingAndReviewScreen extends StatefulWidget {
  //final String product_id;

  // Constructor
  //RatingAndReviewScreen({Key? key, required this.product_id}) : super(key: key);

  @override
  _RatingAndReviewScreen createState() => _RatingAndReviewScreen();
}

class _RatingAndReviewScreen extends State<RatingAndReviewScreen> {
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




  final List<String> _sizes = [
    '500 gm',
    '1 kg',
    '2 kg',
    // Add more sizes here
  ];

  String _selectedSize = ''; // Default selected size
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
                translate('All Review'),
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

                  //Review
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
                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between start and end
                              children: [
                                Row(
                                  children: [

                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Reviews & Ratings',
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
                              ],
                            ),

                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const SizedBox(height: 10),
                                Text(
                                  'Pantum P2512W Wi-Fi Single Function Monochrome Laser Printer, Print Speed: 22ppm',
                                  style: TextStyle(fontSize: 12, color: AppTheme().new_maintextcolor),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[

                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '4.7',
                                                style: TextStyle(
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.darkgreenColor),
                                              ),
                                              Icon(
                                                Icons.star,
                                                size: 32,
                                                color: AppColors.darkgreenColor,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 15),
                                          Text(
                                            'Average Rating based on 6 ratings and 6 reviews',
                                            style: TextStyle(fontSize: 12, color: AppTheme().new_maintextcolor),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10), // Space between the two widgets
                                    Expanded(
                                      flex: 1, child:  Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        _buildRatingItem(5, Colors.green, 0.8),
                                        _buildRatingItem(4, Colors.green, 0.4),
                                        _buildRatingItem(3, Colors.grey, 0),
                                        _buildRatingItem(2, Colors.grey, 0),
                                        _buildRatingItem(1, Colors.grey, 0),
                                      ],
                                    ),
                                      //child: _buildRatingBar(),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                // Action when the button is clicked
                                print("Write a review button clicked");
                                Navigator.of(context).push(PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => WriteReviewScreen(),
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
                                // You can perform any action here like navigating to another page or showing a dialog.
                              },
                              child: Center(
                                child: Container(
                                  width: double.infinity, // Make the container take up the full width
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFfae0e1), // Light red background color for the button
                                    borderRadius: BorderRadius.circular(5.0), // Rounded corners
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0), // Horizontal padding
                                  child: const Align(
                                    alignment: Alignment.center, // Center the text vertically and horizontally
                                    child: Text(
                                      'WRITE A REVIEW', // Button text
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFd9232d), // Dark red text color
                                        fontWeight: FontWeight.w600, // Bold text
                                      ),
                                      textAlign: TextAlign.center, // Center-align the text
                                    ),
                                  ),
                                ),
                              ),
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
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between start and end
                                            children: [
                                              Row(
                                                children: [
                                                  // Build dynamic stars based on rating
                                                  for (int i = 0; i < 5; i++)
                                                    Icon(
                                                      i < rating.floor() // Full stars for rating
                                                          ? Icons.star
                                                          : (i < rating && rating - rating.floor() >= 0.5
                                                          ? Icons.star_half // Half star if needed
                                                          : Icons.star_border), // Empty stars
                                                      size: 20,
                                                      color: const Color(0xfffdb92c),
                                                    ),
                                                  const SizedBox(width: 8),
                                                ],
                                              ),

                                              Text(
                                                'Verified Purchase', // Button text
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.darkgreenColor,
                                                ),
                                                textAlign: TextAlign.center, // Center-align the text
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 10),

                                          Text(
                                            'User  ${index + 1}',
                                            style: TextStyle(fontSize: 14, color: AppTheme().new_maintextcolor),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'February 17, 2024 ',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xff6f6f6f),
                                                fontWeight: FontWeight.w400
                                            ),
                                          ),

                                          const SizedBox(height: 10),

                                          Text(
                                            'Solid choice ',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: AppTheme().new_maintextcolor,
                                                fontWeight: FontWeight.w600
                                            ),
                                          ),

                                          const SizedBox(height: 2),

                                          Text(
                                            'I received the printer precisely as promised and the shipping was quick I am overjoyed with my buy. ',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppTheme().new_maintextcolor,
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                    if (index < 1) // Add a divider only between items, not after the last one
                                      Divider(
                                        color: AppTheme().lineColor,
                                        thickness: 1.0,
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),


                  //ask questions
                  /*SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: AppTheme().whiteColor,
                        //padding: const EdgeInsets.all(10.0),
                        padding: EdgeInsets.only(right: 10.0, left: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),

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
                            ),

                            SizedBox(height: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 10),
                                Text(
                                  ' Displaying Questions 2/3',
                                  style: TextStyle(fontSize: 12, color: AppTheme().new_maintextcolor),
                                ),
                              ],
                            ),

                            SizedBox(height: 10),
                            Divider(
                              color: AppTheme().lineColor,
                              thickness: 1.0,
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: 2, // Replace with actual number of reviews
                              itemBuilder: (context, index) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: 5.0),
                                      child: Container(

                                        //padding: const EdgeInsets.all(10.0),

                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [

                                            Text(
                                              'Q1: Does it support inverter?',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: AppTheme().new_maintextcolor,
                                                  fontWeight: FontWeight.w400
                                              ),
                                            ),
                                            SizedBox(height: 2),

                                            Container(
                                              margin: EdgeInsets.only(left: 25.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Ans: Yes, it does',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Color(0xff6f6f6f),
                                                        fontWeight: FontWeight.w600
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),
                                    ),
                                    if (index < 1) // Add a divider only between items, not after the last one
                                      Divider(
                                        color: AppTheme().lineColor,
                                        thickness: 1.0,
                                      ),
                                  ],
                                );
                              },
                            ),

                            Divider(
                              color: AppTheme().lineColor,
                              thickness: 1.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between start and end
                              children: [
                                Row(
                                  children: [
                                    // Build dynamic stars based on rating
                                    Text(
                                      ' VIEW 4 MORE FAQs', // Button text
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xff086ac9), // Dark red text color
                                          fontWeight: FontWeight.w600

                                      ),
                                      textAlign: TextAlign.center, // Center-align the text
                                    ),
                                  ],
                                ),

                                Icon(Icons.chevron_right, color: Color(0xff086ac9),), // Empty stars



                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),*/

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
