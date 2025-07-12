import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../BaseUrl.dart';
import '../CustomeTextStyle/custometextstyle.dart';
import '../theme/AppTheme.dart';
import 'package:http/http.dart' as http;

String? first_name = '';
String? user_token = '';
String? last_name = '';
String? email = '';
String? mobile = '';
String? userID = '';
String? image = '';
String selectedTestIds = '';
int? cart_count;
String? type = '';
String version = '';

class AddMoneyScreen extends StatefulWidget {
  @override
  _AddMoneyScreenState createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _amountController = TextEditingController();

  Map<String, String> localizedStrings = {};
  String currentLangCode = 'en';
  bool isLoading = false;
  String _walletBalance = '0.00';
  bool hasMoreData = true;
  String pageCode = '0';

  void initState() {
    super.initState();
    _loadCurrentLanguagePreference();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Load user preferences and initialize data
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      first_name = prefs.getString('first_name') ?? '';
      last_name = prefs.getString('last_name') ?? '';
      user_token = prefs.getString('user_token') ?? '';
      email = prefs.getString('email') ?? '';
      mobile = prefs.getString('mobile') ?? '';
      userID = prefs.getString('userID') ?? '';
      type = prefs.getString('type') ?? '';
      image = prefs.getString('image') ?? '';
    });

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;
    });

    await _dashboardData();
  }

  Future<void> _dashboardData() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(baseUrl); // Replace with your API endpoint
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token',
    };
    final body = {
      'view': 'wallet_transction',
      'userID': userID ?? '',
      'userPhone': mobile ?? '',
      'pagecode': pageCode,
    };

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());
        if (data['result'] == 1) {
          final walletBalance = data['data']['walletBal'] ?? '0.00';

          setState(() {
            _walletBalance = walletBalance;
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

  Future<void> _loadLanguage(String langCode) async {
    final String jsonString =
        await rootBundle.loadString('assets/lang/$langCode.json');
    setState(() {
      localizedStrings = Map<String, String>.from(json.decode(jsonString));
    });
  }

  String translate(String key) {
    return localizedStrings[key] ?? key;
  }

  add_money() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(baseUrl);

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token',
    };

    final Map<String, String> body = {
      'view': 'add_money',
      'custID': '$userID',
      'mobile': '$mobile',
      'amount': _amountController.text,
      'page': 'add_money',
      'appVersion': '${version}',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log('Response data: $data');

        if (data['result'] == 1) {
          // Extract messages and ID
          final msgcode = data['data']['msgcode']; // Extract msgcode
          final message1 =
              data['data']['fail_message1'] ?? ''; // Updated message field
          final message2 =
              data['data']['fail_message'] ?? ''; // Updated message field
          final orderId =
              data['data']['orderID'].toString(); // Updated ID field
          final amount =
              double.tryParse(data['data']['amount']?.toString() ?? '0.0') ??
                  0.0; // Parse amount as double
          final webUrl = data['data']['web_url'] ?? ''; // Extracted web_url

          Navigator.pushNamed(context, '/add_money_webview_payment',
              arguments: {
                'message_1': message1,
                'message_2': message2,
                'orderId': orderId.toString(),
                'webUrl': webUrl,
              });

          /*final message1 = data['data']['fail_message1'] ?? '';  // Updated message field
            final message2 = data['data']['fail_message'] ?? '';   // Updated message field
            final orderId = data['data']['orderID'].toString();    // Updated ID field
            final amount = double.tryParse(data['data']['amount']?.toString() ?? '0.0') ?? 0.0; // Parse amount as double
            final webUrl = data['data']['web_url'] ?? '';          // Extracted web_url

            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('cart_count', 0);

            // Navigate to the order success screen with the data
            Navigator.pushNamed(context, '/order_webview_PaymentPaytm', arguments: {
              'message_1': message1,
              'message_2': message2,
              'orderId': orderId.toString(),
              'webUrl': webUrl,
            });*/
        } else {
          _showErrorSnackBar(data['message']);
          log('Data: ${data['message']}');
        }
      } else {
        _showErrorSnackBar('Error: ${response.reasonPhrase}');
        log('Data: ${response.reasonPhrase}');
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
                'Add Money',

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  color: AppColors.colorPrimary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Decont Wallet',
                        style:
                            CustomTextStyle.GraphikMedium(18, AppColors.white),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '₹ ${_walletBalance}',
                        style:
                            CustomTextStyle.GraphikRegular(16, AppColors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 15.0, left: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            // Evenly spaced buttons
                            children: <Widget>[
                              // First button
                              Flexible(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _amountController.text = '100';
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: AppColors.colorPrimary,
                                    backgroundColor: Colors.white,
                                    // Text color (pink)
                                    side: const BorderSide(
                                        color: AppColors.colorPrimary,
                                        width: 1),
                                    // Border color (pink)
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          5), // Corner radius
                                    ),
                                    padding: const EdgeInsets.all(
                                        10), // Padding added for the button text
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '+ ₹ 100',
                                        style: CustomTextStyle.GraphikMedium(
                                            16, AppColors.black),

                                        textAlign:
                                            TextAlign.center, // Center text
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Second button
                              Flexible(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _amountController.text = '200';
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: AppColors.colorPrimary,
                                    backgroundColor: Colors.white,
                                    // Text color (pink)
                                    side: const BorderSide(
                                        color: AppColors.colorPrimary,
                                        width: 1),
                                    // Border color (pink)
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          5), // Corner radius
                                    ),
                                    padding: const EdgeInsets.all(
                                        10), // Padding added for the button text
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '+ ₹ 200',
                                        style: CustomTextStyle.GraphikMedium(
                                            16, AppColors.black),

                                        textAlign:
                                            TextAlign.center, // Center text
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Third button
                              Flexible(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _amountController.text = '500';
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: AppColors.colorPrimary,
                                    backgroundColor: Colors.white,
                                    // Text color (pink)

                                    side: const BorderSide(
                                        color: AppColors.colorPrimary,
                                        width: 1),
                                    // Border color (pink)
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          5), // Corner radius
                                    ),
                                    padding: const EdgeInsets.all(
                                        10), // Padding added for the button text
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '+ ₹ 500',
                                        style: CustomTextStyle.GraphikMedium(
                                            16, AppColors.black),

                                        textAlign:
                                            TextAlign.center, // Center text
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Fourth button
                              Flexible(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _amountController.text = '1000';
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: AppColors.colorPrimary,
                                    backgroundColor: Colors.white,
                                    // Text color (pink)

                                    side: const BorderSide(
                                        color: AppColors.colorPrimary,
                                        width: 1),
                                    // Border color (pink)
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          5), // Corner radius
                                    ),
                                    padding: const EdgeInsets.all(
                                        10), // Padding added for the button text
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '+ ₹ 1000',
                                        style: CustomTextStyle.GraphikMedium(
                                            16, AppColors.black),

                                        textAlign:
                                            TextAlign.center, // Center text
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          Form(
                            key: _formKey,
                            child: TextFormField(
                                controller: _amountController,
                                cursorColor: AppColors.colorPrimary,
                                decoration: InputDecoration(
                                  errorStyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(color: AppColors.colorPrimary),
                                  labelText: 'Enter Amount',
                                  labelStyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(color: AppColors.textSub),
                                  border: const OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an amount';
                                  }
                                  return null;
                                },
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                      color: AppColors.black,
                                    )),
                          ),
                          const SizedBox(height: 20.0),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
            height: 1.0,
            color: AppTheme().lineColor,
          ),
          Container(
            color: AppTheme().whiteColor,
            padding: const EdgeInsets.all(5.0),
            child: SizedBox(
              width: double.infinity, // Button takes up full width
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Handle the amount submission
                    print('Amount added: ${_amountController.text}');
                    add_money();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.colorPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text('Add Money',
    style: CustomTextStyle.GraphikMedium(16, AppColors.white),

    )),
              ),
            ),
        ],
      ),
    );
  }
}
