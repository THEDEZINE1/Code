import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import '../CustomeTextStyle/custometextstyle.dart';
import '../theme/AppTheme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'dart:developer';

import '../BaseUrl.dart';
import '../OrderDetailsScreen/order_details_screen.dart';

String? user_token = '';
String? userID = '';

class OrderListScreen extends StatefulWidget {
  final VoidCallback onBack;

  OrderListScreen({required this.onBack});

  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final Map<String, int> cart = {};
  Map<String, String> localizedStrings = {};
  String currentLangCode = 'en';
  String Category = '';
  List<Map<String, dynamic>> orderMasterList = [];
  String pageCode = '0';
  bool isLoading = false;
  bool hasMoreData = true;
  bool isPaginationLoading = false; // For pagination loading

  final ScrollController _scrollController = ScrollController();

  void initState() {
    super.initState();
    _loadCurrentLanguagePreference();
    _initializeData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (hasMoreData && !isPaginationLoading && !isLoading) {
          _dashboardData(); // Load more data
        }
      }
    });
  }

  Future<void> _initializeData() async {
    // Load user preferences and initialize data
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      user_token = prefs.getString('user_token') ?? '';
      userID = prefs.getString('userID') ?? '';
    });
    print(userID);
    await _dashboardData();
  }

  /*Future<void> _dashboardData() async {
    if (isLoading || isPaginationLoading) return; // Prevent multiple requests
    isPaginationLoading = true; // Set loading for pagination
    if (!isLoading) isLoading = true; // Set loading for initial data

    final url = Uri.parse(baseUrl); // Your API endpoint

    final Map<String, String> body = {
      'view': 'orders', // Pagination
      'page': 'list', // Pagination
      'custID': userID ?? '',
      'pagecode': pageCode, // Pagination
    };

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());
        log('Response data: $data');

        if (data['result'] == 1) {
          // Extract orderMaster data
          orderMasterList.addAll(
            (data['data']['order_list'] as List).map((item) {
              return {
                'label': item['label'],
                'value': item['value'],
              };
            }).toList(),
          );

          log('data: - $orderMasterList');
          // Handle pagination
          if (data['data'].containsKey('pagination')) {
            final pagination = data['data']['pagination'];
            if (pagination['next_page'] != null &&
                pagination['next_page'].toString().isNotEmpty) {
              pageCode = pagination['next_page'].toString(); // Update next page number
            } else {
              hasMoreData = false; // No more pages available
            }
          }

          setState(() {}); // Update UI with new data
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      log('Error: $e');
    } finally {
      isLoading = false;
      isPaginationLoading = false; // Reset pagination loading state
    }

  }*/

  Future<void> _dashboardData() async {
    if (isLoading || isPaginationLoading) return; // Prevent multiple requests
    isPaginationLoading = true; // Set loading for pagination
    if (!isLoading) isLoading = true; // Set loading for initial data

    final url = Uri.parse(baseUrl); // Your API endpoint

    final Map<String, String> body = {
      'view': 'orders', // Pagination
      'page': 'list', // Pagination
      'custID': userID ?? '',
      'pagecode': pageCode, // Pagination
    };

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token',
    };
    print(body);
    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());
        log('Response data: $data');

        if (data['result'] == 1) {
          // Extract orderMaster data
          List orders = data['data']['order_list'] ?? [];

          if (orders.isNotEmpty) {
            orderMasterList.addAll(orders
                .map((item) => {
                      'orderID': item['orderID'],
                      'amount': item['amount'],
                      'date': item['date'],
                      'status': item['status'],
                      'total_items': item['total_items'],
                      //'orderData': item['orderData'], // Order details
                    })
                .toList());

            log('data: - $orderMasterList');
          } else {
            // No orders found
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('No data found.',
                      style:
                          CustomTextStyle.GraphikMedium(16, AppColors.white))),
            );
          }

          // Handle pagination
          if (data['data'].containsKey('pagination')) {
            final pagination = data['data']['pagination'];
            if (pagination['next_page'] != null &&
                pagination['next_page'].toString().isNotEmpty) {
              pageCode =
                  pagination['next_page'].toString(); // Update next page number
            } else {
              hasMoreData = false; // No more pages available
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(data['message'],
                    style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${response.reasonPhrase}',
                  style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
        );
      }
    } catch (e) {
      log('Error: $e');
    } finally {
      isLoading = false;
      isPaginationLoading = false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    return WillPopScope(
      onWillPop: () async {
        widget.onBack();
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(
            kToolbarHeight + 1.0,
          ),
          child: Column(
            children: [
              AppBar(
                surfaceTintColor: Colors.transparent,
                leading: Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        widget.onBack();
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
                backgroundColor: Colors.white,
                elevation: 0.0,
                title: Text(
                  translate('Order List'),
                  style: CustomTextStyle.GraphikMedium(16, AppColors.black),
                ),
              ),
              Container(
                height: 1.0,
                color: Colors.grey[300],
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
            : orderMasterList.isEmpty
                ? Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'No Orders Available',
                          style: CustomTextStyle.GraphikMedium(
                              20, AppColors.black),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    controller: _scrollController,
                    itemCount:
                        orderMasterList.length + (isPaginationLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Get.to(
                            OrderDetailScreen(
                              product_id:
                                  orderMasterList[index]['orderID'].toString(),
                              home: '',
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: AppColors.textFieldBorderColor),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        'ORDER # ${orderMasterList[index]['orderID'].toString()}',
                                        style: CustomTextStyle.GraphikMedium(
                                            16, AppColors.black)),
                                    ElevatedButton(
                                        onPressed: () async {
                                          Get.to(
                                            OrderDetailScreen(
                                              product_id: orderMasterList[index]
                                                      ['orderID']
                                                  .toString(),
                                              home: '',
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.colorPrimary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6, horizontal: 10),
                                        ),
                                        child: Text(
                                          translate('View Details >'),
                                          style: CustomTextStyle.GraphikMedium(
                                              12, AppColors.white),
                                        )),
                                  ],
                                ),
                              ),
                              Divider(color: AppTheme().lineColor),
                              const SizedBox(height: 5.0),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: _buildOrderDetailRow(
                                  "Order Date",
                                  orderMasterList[index]['date'],
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              const Divider(
                                height: 1,
                                color: AppColors.textFieldBorderColor,
                              ),
                              const SizedBox(height: 5.0),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: _buildOrderDetailRow(
                                  "Status",
                                  '${orderMasterList[index]['status']}',
                                  svgIcon: orderMasterList[index]['status'] ==
                                          'Pending'
                                      ? SvgPicture.asset(
                                          'assets/icons/waiting.svg',
                                          height: 18)
                                      : orderMasterList[index]['status'] ==
                                              'Waiting'
                                          ? SvgPicture.asset(
                                              'assets/icons/waiting.svg',
                                              height: 18)
                                          : orderMasterList[index]['status'] ==
                                                  'Delivered'
                                              ? SvgPicture.asset(
                                                  'assets/icons/approve.svg',
                                                  height: 18)
                                              : orderMasterList[index]
                                                          ['status'] ==
                                                      'Canceled'
                                                  ? SvgPicture.asset(
                                                      'assets/icons/reject.svg',
                                                      height: 18)
                                                  : null,
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              const Divider(
                                height: 1,
                                color: AppColors.textFieldBorderColor,
                              ),
                              const SizedBox(height: 5.0),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: _buildOrderDetailRow("Total Items",
                                    '${orderMasterList[index]['total_items']}'),
                              ),
                              const SizedBox(height: 5.0),
                              const Divider(
                                height: 1,
                                color: AppColors.textFieldBorderColor,
                              ),
                              const SizedBox(height: 5.0),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: _buildOrderDetailRow("Total Amount",
                                    '₹ ${orderMasterList[index]['amount']}'),
                              ),
                              const SizedBox(height: 5.0),

                              /*ListView.builder(
                    // Use shrinkWrap to allow the GridView to take only the required height
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(), // Disable scrolling to prevent overflow

                    itemCount: orderMasterList.length,
                    itemBuilder: (context, index) {
                      final label = orderMasterList[index];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(label['label'], style: TextStyle(color: AppTheme().blackColor, fontSize: 16),),
                          SizedBox(height: 10.0,),
                          Text('₹ ${label['value']}', style: TextStyle(color: AppTheme().secondTextColor, fontSize: 16),),
                        ],
                      );
                    },
                  ),*/

                              /*ListView.builder(
                    physics: NeverScrollableScrollPhysics(), // Prevent scrolling
                    shrinkWrap: true, // Use only the necessary space
                    itemCount: order['orderData'].length,
                    itemBuilder: (context, itemIndex) {
                      final item = order['orderData'][itemIndex];
                      return Container(
                        margin: const EdgeInsets.only(top:5.0, bottom: 5.0),

                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme().lineColor, width: 1.0), // Border with color and width
                          borderRadius: BorderRadius.circular(5.0), // Rounded corners
                        ),
                        //child: _buildOrderDetailRow("Partner Name:", '${item['partner_name']}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildOrderDetailRow("Partner Name:", '${item['partner_name']}'),
                            _buildOrderDetailRow("Items:", '${item['item_count']}'),
                            _buildOrderDetailRow("Total:", '${item['total']}'),

                          ],
                        ),

                      );

                    },
                  ),*/
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildOrderDetailRow(
    String title,
    String value, {
    SvgPicture? svgIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Title
          Text(
            title,
            style: CustomTextStyle.GraphikMedium(14, AppColors.secondTextColor),
          ),

          // Right side: Value + Icon
          Row(
            children: [
              Text(
                value,
                style: CustomTextStyle.GraphikRegular(15, AppColors.black),
              ),
              if (svgIcon != null) ...[
                const SizedBox(width: 6),
                svgIcon,
              ],
            ],
          ),
        ],
      ),
    );
  }
}
