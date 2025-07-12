import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../CustomeTextStyle/custometextstyle.dart';
import '../theme/AppTheme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
String? userID = '';


class WriteReviewScreen extends StatefulWidget {

  // Constructor
  WriteReviewScreen({Key? key}) : super(key: key);

  @override
  _WriteReviewScreen createState() => _WriteReviewScreen();
}

class _WriteReviewScreen extends State<WriteReviewScreen> {
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
  double _rating = 0.0; // Store rating value

  final TextEditingController _reviewController = TextEditingController();


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
      userID = prefs.getString('userID') ?? '';
      type = prefs.getString('type') ?? '';
      image = prefs.getString('image') ?? '';
      cart_count = prefs.getInt('cart_count')!;

    });

    //await _dashboardData();
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

  Future<void> _handleSubmit() async {

    final url = Uri.parse(baseUrl); // Replace with your API endpoint

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token', // Include the user token if necessary
    };

    final Map<String, String> body = {
      'view': 'product_review', // Pass the car ID to the API
      'page': 'add', // Pass the car ID to the API
      'custID': '$userID', // Pass the car ID to the API
      'productID': _product_id, // Pass the car ID to the API
      'star': _rating.toString(), // Pass the new favorite state
      'desc': _reviewController.text, // Pass the new favorite state
    };

    try {
      // Make the API call
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Successfully updated favorite status
          FocusScope.of(context).unfocus();

          // Optionally clear the text field
          _reviewController.clear();
          Navigator.pushNamed(context, '/my_cart');

        } else {
          // Handle error returned by the API
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      } else {
        // Handle HTTP error responses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      // Handle exceptions
      log('Error updating favorite status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred.')),
      );
    }
    /*String reviewText = _reviewController.text;
    if (reviewText.isNotEmpty) {
      // Process the review text (e.g., send it to your backend)
      FocusScope.of(context).unfocus();

      print('Review submitted: $reviewText');
      // Optionally clear the text field
      _reviewController.clear();
    } else {
      print('Review text is empty!');
      // You can also show a toast/snackbar if the field is empty
    }*/
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;


    final productName = args['productName'];

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
                translate('Write Review'),
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
                                          'Review for',
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
                                const SizedBox(height: 5),
                                Text(
                                  productName,
                                  style: TextStyle(fontSize: 12, color: AppTheme().new_maintextcolor),
                                ),
                                const SizedBox(height: 10),

                              ],
                            ),

                            const SizedBox(height: 10),

                            Text(
                              'Rate this product',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme().new_maintextcolor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // RatingBar widget
                                RatingBar.builder(
                                  initialRating: _rating, // Use the state variable for the initial rating
                                  minRating: 0,
                                  itemSize: 40,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (rating) {
                                    setState(() {
                                      _rating = rating; // Update the rating state with the new rating value
                                    });
                                    print(rating); // You can store or send the rating value
                                  },
                                ),
                                /*SizedBox(height: 20),
                                // Display the rating as text
                                Text(
                                  'Rating: ${_rating.toStringAsFixed(1)}', // Display the selected rating dynamically
                                  style: TextStyle(fontSize: 16),
                                ),*/
                              ],
                            ),

                            const SizedBox(height: 15),

                            Text(
                              'Review this product',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme().new_maintextcolor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            Text(
                              'Share your experience with other customers',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme().new_maintextcolor,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                TextField(
                                  controller: _reviewController,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 4, // Allow up to 4 lines of input
                                  decoration: InputDecoration(
                                    labelText: 'Write Your Review', // Label for the TextField
                                    labelStyle: TextStyle(
                                      color: AppTheme().secondTextColor,
                                    ),
                                    alignLabelWithHint: true, // Align the label with the top-left of the input
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
                                  ),
                                ),
                              ],
                            ),


                            const SizedBox(height: 20),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  // Your action when the button is clicked
                                  print(_rating); // You can store or send the rating value
                                  _handleSubmit();


                                },
                                child: Container(
                                  width: double.infinity, // Make the container take up the full width
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.colorPrimary, // Light red background color for the button
                                    borderRadius: BorderRadius.circular(5.0), // Rounded corners
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0), // Horizontal padding
                                  child: const Align(
                                    alignment: Alignment.center, // Center the text vertically and horizontally
                                    child: Text(
                                      'SUBMIT', // Button text
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.white, // Dark red text color
                                        fontWeight: FontWeight.w600, // Bold text
                                      ),
                                      textAlign: TextAlign.center, // Center-align the text
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

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
}
