import 'dart:convert';
import 'dart:developer';

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

class AskQuestionScreen extends StatefulWidget {
  final String productName;

  // Constructor
  AskQuestionScreen({Key? key, required this.productName}) : super(key: key);

  @override
  _AskQuestionScreen createState() => _AskQuestionScreen();
}

class _AskQuestionScreen extends State<AskQuestionScreen> {
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
  final TextEditingController _reviewController = TextEditingController();

  List<Map<String, dynamic>> selectedItems = [];

  void initState() {
    super.initState();
    _loadCurrentLanguagePreference();
    _initializeData();

  }

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      first_name = prefs.getString('first_name') ?? '';
      email = prefs.getString('email') ?? '';
      mobile = prefs.getString('mobile') ?? '';
      type = prefs.getString('type') ?? '';
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
      'product_id':
          _product_id, // Assuming the API requires the item ID to remove
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
          productLabels =
              List<Map<String, dynamic>>.from(data['data']['product_label']);
          productTests =
              List<Map<String, dynamic>>.from(data['data']['product_test']);

          Name = productInfo?['name'];
          partner_name = productInfo?['partner_name'];
          price = productInfo?['price'];
          mrp = productInfo?['mrp'];
          unit = productInfo?['base_weight'];
          description = productInfo?['description'];

          setState(() {
            // Set selectedItems to only include tests that are in the cart
            selectedItems =
                productTests.where((test) => test['in_cart']).toList();
            selectedTestIds = selectedItems
                .map((test) => test['test_id'].toString())
                .join(',');
          });
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
      SnackBar(
          content: Text(message,
              style: Theme.of(context)
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

  void _handleSubmit() {
    String reviewText = _reviewController.text;
    if (reviewText.isNotEmpty) {
      // Process the review text (e.g., send it to your backend)
      FocusScope.of(context).unfocus();

      // Optionally clear the text field
      _reviewController.clear();
    } else {}
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
                translate('Ask Question'),
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
                        padding: const EdgeInsets.only(right: 10.0, left: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const SizedBox(height: 5),
                                Text(
                                  widget.productName,
                                  style: CustomTextStyle.GraphikMedium(
                                      15, AppColors.black),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Ask for information which is not captured in then product specifications',
                              style: CustomTextStyle.GraphikRegular(
                                  15, AppColors.secondTextColor),
                            ),
                            const SizedBox(height: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: _reviewController,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 2, // Allow up to 4 lines of input
                                  decoration: InputDecoration(
                                    labelText:
                                        'Write Your Question', // Label for the TextField
                                    labelStyle: CustomTextStyle.GraphikMedium(
                                        14, AppColors.greyColor),
                                    alignLabelWithHint:
                                        true, // Align the label with the top-left of the input
                                    border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors
                                                .textFieldBorderColor)),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColors.textFieldBorderColor,
                                        width: 1.0,
                                      ),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColors.textFieldBorderColor,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                  style: CustomTextStyle.GraphikRegular(
                                      14, AppColors.black),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  // Your action when the button is clicked
                                  _handleSubmit();
                                },
                                child: Container(
                                  width: double
                                      .infinity, // Make the container take up the full width
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors
                                        .colorPrimary, // Light red background color for the button
                                    borderRadius: BorderRadius.circular(
                                        5.0), // Rounded corners
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0), // Horizontal padding
                                  child: Align(
                                    alignment: Alignment
                                        .center, // Center the text vertically and horizontally
                                    child: Text(
                                      'SUBMIT', // Button text
                                      style: CustomTextStyle.GraphikMedium(
                                          14, AppColors.white),
                                      textAlign: TextAlign
                                          .center, // Center-align the text
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
