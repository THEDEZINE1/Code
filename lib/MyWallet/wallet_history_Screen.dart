import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import '../CustomeTextStyle/custometextstyle.dart';
import '../theme/AppTheme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../BaseUrl.dart';

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

class WalletHistoryScreen extends StatefulWidget {
  @override
  _WalletHistoryScreen createState() => _WalletHistoryScreen();
}

class _WalletHistoryScreen extends State<WalletHistoryScreen> {
  Map<String, String> localizedStrings = {};
  String currentLangCode = 'en';
  bool isLoading = false;
  String _walletBalance = '0.00';
  String _superWalletBalance = '0.00';
  String _walletMSG = '';
  List<Map<String, dynamic>> _transactionData = [];
  bool hasMoreData = true;
  bool isPaginationLoading = false;
  final ScrollController _scrollController = ScrollController();
  String pageCode = '0';

  @override
  void initState() {
    super.initState();

    _loadCurrentLanguagePreference();
    _initializeData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!isPaginationLoading && hasMoreData) {
          _fetchTransactionData();
        }
      }
    });
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      first_name = prefs.getString('first_name') ?? '';
      last_name = prefs.getString('last_name') ?? '';
      user_token = prefs.getString('user_token') ?? '';
      email = prefs.getString('email') ?? '';
      mobile = prefs.getString('mobile') ?? '';
      userID = prefs.getString('userID') ?? '';
      type = prefs.getString('type') ?? '';
    });

    await _fetchTransactionData();
  }

  Future<void> _fetchTransactionData() async {
    if (isPaginationLoading) return;

    setState(() {
      isPaginationLoading = true;
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
          final superWalletBalance = data['data']['super_walletBal'] ?? '0.00';
          final walletMessage = data['data']['walletMessage'] ?? 'No Message';

          final prefs = await SharedPreferences.getInstance();

          // Safely extract values with null checks
          await prefs.setString(
              'wallet_amount',
              data['data']['walletBal'] ??
                  '0.00'); // Default to empty string if null

          if (data['data'].containsKey('pagination')) {
            final pagination = data['data']['pagination'];
            if (pagination['next_page'] != null &&
                pagination['next_page'].toString().isNotEmpty) {
              pageCode = pagination['next_page'].toString();
            } else {
              hasMoreData = false;
            }
          }

          final transactionData = List<Map<String, dynamic>>.from(
            data['data']['transction_data']?.map((transaction) {
                  return {
                    'orderID': transaction['OrderID'] ?? '',
                    'remark': transaction['Remark'] ?? '',
                    'symbol': transaction['symbol'] ?? '',
                    'amount': transaction['Amount'] ?? '0.00',
                    'walletType': transaction['wallet_type'] ?? '',
                    'type': transaction['type'] ?? '',
                    'transactionDate': transaction['TransactionDate'] ?? '',
                  };
                }) ??
                [],
          );

          setState(() {
            _walletBalance = walletBalance;
            _superWalletBalance = superWalletBalance;
            _walletMSG = _walletBalance;
            _transactionData.addAll(transactionData);
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
        isPaginationLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
        message,
        style: CustomTextStyle.GraphikMedium(16, AppColors.white),
      )),
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // Set a responsive height for the ListView (as a percentage of the screen height)
// 50% of screen height (this can be adjusted as needed)
    double itemHeight = 80.0; // Base height of each item

    // Calculate total height based on the number of items and the screen size

    // Adjust for pagination loading (add extra space for loading indicator)
    if (isPaginationLoading) {
// Add extra height for loading indicator if needed
    }

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
                translate('Wallet History'),
                //widget.carName, // Use widget.carName here
                style: CustomTextStyle.GraphikMedium(16, AppColors.black),
              ),
            ),
            Container(
              height: 1.0,
              color: AppColors.textFieldBorderColor,
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.mainBackgroundColor,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.colorPrimary,
              ),
            )
          : SingleChildScrollView(
              child: Container(
                color: AppColors.white,
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    // Existing CardView
                    Card(
                      color: AppColors.colorPrimary,
                      // Assuming AppTheme().primaryColor
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Decont Wallet',
                                  style: CustomTextStyle.GraphikMedium(
                                      16, AppColors.white),
                                ),
                                Text(
                                  '₹ $_walletBalance',
                                  style: CustomTextStyle.GraphikRegular(
                                      14, AppColors.white),
                                ),
                                const SizedBox(height: 15),
                                Row(children: [
                                  Text(
                                    'Super Wallet',
                                    style: CustomTextStyle.GraphikMedium(
                                        16, AppColors.white),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Stack(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const SizedBox(
                                                          height: 16),
                                                      Text(
                                                        'Super Wallet Info',
                                                        style: CustomTextStyle
                                                            .GraphikMedium(
                                                                16,
                                                                AppColors
                                                                    .black),
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Divider(),
                                                      const SizedBox(
                                                          height: 10),
                                                      Text(
                                                        'Now use 25% of this balance can\nbe used in a single transaction.\nThis Can\'t be transferred to bank or\ndeconrt wallet.',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: CustomTextStyle
                                                            .GraphikRegular(
                                                                13.5,
                                                                AppColors
                                                                    .darkgreenColor),
                                                      ),
                                                      const SizedBox(
                                                          height: 16),
                                                      Icon(
                                                        Icons
                                                            .account_balance_wallet_rounded,
                                                        size: 64,
                                                        color: Colors.black87,
                                                      ),
                                                      const SizedBox(
                                                          height: 12),
                                                      Divider(),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'YOUR SUPER BALANCE',
                                                            style: CustomTextStyle
                                                                .GraphikMedium(
                                                                    11,
                                                                    AppColors
                                                                        .secondTextColor),
                                                          ),
                                                          Text(
                                                            // '₹ ${balance.toStringAsFixed(2)}',
                                                            '₹$_superWalletBalance',
                                                            style: CustomTextStyle
                                                                .GraphikMedium(
                                                                    12.5,
                                                                    AppColors
                                                                        .black),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Close (X) Button
                                                Positioned(
                                                  right: 4,
                                                  top: 4,
                                                  child: GestureDetector(
                                                    onTap: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.grey[300],
                                                      ),
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets
                                                                .all(6.0),
                                                        child: Icon(Icons.close,
                                                            size: 18),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: const Icon(
                                      Icons.info,
                                      color: Colors.white,
                                      size: 17.0,
                                    ),
                                  ),
                                ]),
                                Text(
                                  '₹ $_superWalletBalance',
                                  style: CustomTextStyle.GraphikRegular(
                                      14, AppColors.white),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/addMoney');
                                },
                                child: Text(
                                  // 'Add Money',
                                  'Add Money',
                                  style: CustomTextStyle.GraphikMedium(
                                      14, AppColors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Transaction History Section
                    _transactionData.isNotEmpty
                        ? Container(
                            color:
                                Colors.white, // Assuming AppTheme().whiteColor
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  'Transaction History',
                                  style: CustomTextStyle.GraphikMedium(
                                      18, AppColors.black),
                                ),
                                const SizedBox(height: 10),

                                // Transaction ListView
                                SizedBox(
                                  //height: 400.0, // Set height for scrolling content
                                  height:
                                      600.0, // Set height for scrolling content
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    itemCount: _transactionData.length +
                                        (isPaginationLoading ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (isPaginationLoading &&
                                          index == _transactionData.length) {
                                        return const Center(
                                            child: CircularProgressIndicator(
                                          color: AppColors.colorPrimary,
                                        )); // Show loader while paginating
                                      }

                                      final transaction =
                                          _transactionData[index];
                                      final isPositive = transaction['type'] ==
                                          'blue'; // Check if symbol is '+'

                                      return Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    isPositive
                                                        ? 'assets/icons/positive.svg'
                                                        : 'assets/icons/negative.svg',
                                                    height:
                                                        30, // Adjust size if needed
                                                    width: 30,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  const SizedBox(width: 15.0),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '${transaction['remark']}',
                                                        style: CustomTextStyle
                                                            .GraphikMedium(
                                                                13,
                                                                AppColors
                                                                    .black),
                                                      ),
                                                      const SizedBox(
                                                          height: 5.0),
                                                      Text(
                                                        '${transaction['transactionDate']},',
                                                        style: CustomTextStyle
                                                            .GraphikRegular(
                                                                13,
                                                                AppColors
                                                                    .black),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '${transaction['symbol']} ₹ ${transaction['amount']}',
                                                style: CustomTextStyle
                                                        .GraphikMedium(
                                                            13, AppColors.black)
                                                    ?.copyWith(
                                                        color: isPositive
                                                            ? AppColors
                                                                .darkgreenColor
                                                            : AppColors.red),
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 5.0),
                                          if (index !=
                                              _transactionData.length - 1)
                                            const Divider(
                                              color: AppColors
                                                  .textFieldBorderColor,
                                              thickness: 1,
                                              height: 10,
                                            ),
                                          const SizedBox(height: 5.0),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Center(
                            child: Text(
                              'No Transaction History Available',
                              style: CustomTextStyle.GraphikMedium(
                                  20, AppColors.black),
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
