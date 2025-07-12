import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import '../CustomeTextStyle/custometextstyle.dart';
import '../theme/AppTheme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../BaseUrl.dart';
import '../productDetails/product_details_screen.dart';

String? user_token = '';
String? userID = '';

class OrderDetailScreen extends StatefulWidget {
  final String product_id;
  final String home;

  OrderDetailScreen({Key? key, required this.product_id, required this.home})
      : super(key: key);

  @override
  _OrderDetailState createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetailScreen> {
  List<Map<String, dynamic>> selectedItems = [];
  String _product_id = '';
  Map<String, String> localizedStrings = {};
  String currentLangCode = 'en';
  bool isLoading = false;
  bool? cancel_order;
  Map<String, dynamic>? orderShipping;

  List<Map<String, dynamic>> productLabels = [];
  List<Map<String, dynamic>> orderDetails = [];
  List<Map<String, dynamic>> productTests = [];
  List<Map<String, dynamic>> order_summary = [];
  bool hasMoreData = true;
  final TextEditingController _pinController = TextEditingController();
  bool isCheckVisible = false;
  String Name = '';
  String Address = '';
  String Gst_No = '';
  String Mobile = '';
  String Email = '';
  String Home = '';
  String total = '';
  TextEditingController _reasonController = TextEditingController();
  List<Map<String, dynamic>> itemList = [];

  void initState() {
    super.initState();
    _loadCurrentLanguagePreference();
    _initializeData();

    _product_id = widget.product_id;
    Home = widget.home;

    print('Item ID in Summary Screen: ${widget.home}');

    _pinController.addListener(() {
      if (_pinController.text.length == 6) {
        setState(() {
          isCheckVisible = true;
        });
      } else {
        setState(() {
          isCheckVisible = false;
        });
      }
    });
  }

  Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status;

    // Check if the permission is already granted
    if (status.isGranted) {
      return true;
    } else {
      // Request permission
      var result = await Permission.storage.request();
      return result.isGranted;
    }
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
      'view': 'orders',
      'page': 'detail',
      'orderID': _product_id,
      'custID': '$userID',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());
        log('Response data: $data');

        orderDetails.clear();
        orderShipping?.clear();

        if (data['result'] == 1) {
          // Extract product details
          /*cancel_order = data['data']['cancel_order'];
          total = data['data']['total_amount'];*/
          orderShipping = data['data']['address'].first;
          orderDetails =
              List<Map<String, dynamic>>.from(data['data']['order_detail']);
          productLabels =
              List<Map<String, dynamic>>.from(data['data']['item_list']);
          //productTests = List<Map<String, dynamic>>.from(data['data']['orderPayments']);
          order_summary =
              List<Map<String, dynamic>>.from(data['data']['order_summary']);

          /*Name = orderShipping?['name'];
          Address = orderShipping?['address'];
          Gst_No = orderShipping?['gst_no'];
          Mobile = orderShipping?['mobile'];
          Email = orderShipping?['email'];*/
          Name = orderShipping?['name'];
          Address = orderShipping?['address'];
          Mobile = orderShipping?['phone'];
          Gst_No = orderShipping?['gst_no'];
          Email = orderShipping?['email'];
          total = data['data']['amount'];
          setState(() {
          });
          log('productLabels: $productLabels');
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
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
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

  // Function to call the API
  Future<void> _cancelOrder(String reason) async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(order_cancel);

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token',
    };

    final Map<String, dynamic> body = {
      'id': _product_id, // Assuming the API requires the item ID to remove
      'remark': reason, // Assuming the API requires the item ID to remove
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Successfully updated favorite status
          Navigator.of(context).pop(); // Close the bottom sheet
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
    /*Future<void> downloadPDF(String url) async {
      try {
        // Get the application directory
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String savePath = '${appDocDir.path}/order_invoice.pdf';

        // Use Dio to download the file
        Dio dio = Dio();
        await dio.download(url, savePath);

        print("PDF downloaded to: $savePath");
      } catch (e) {
        print("Error downloading PDF: $e");
      }
    }*/

    Future<void> downloadPDF(String url) async {
      // Request storage permission
      var status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        Uri uri = Uri.parse(url);
        String fileName = uri.pathSegments.last;

        try {
          // Start the download
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            // Get the file path in the Downloads directory
            //final directory = Directory('/storage/emulated/0/Download');
            //final file = File('${directory.path}/$fileName');
            final directory = await getExternalStorageDirectory();
            final file = File(
                '${directory!.path}/$fileName'); // Construct the full file path
            await file.writeAsBytes(response.bodyBytes);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Download completed!')),
              //SnackBar(content: Text('Download completed! PDF saved at ${file.path}')),
            );
          } else {
            // Handle server errors
            String errorMessage =
                'Failed to download PDF: ${response.statusCode}';
            _showErrorSnackBar(errorMessage);
          }
        } catch (e) {
          // Handle unexpected errors
          _showErrorSnackBar('Error: $e');
        }
      } else {
        // Handle the case when permission is denied
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: const Text('Storage permission denied')),
        );
      }
    }

    return WillPopScope(
      onWillPop: () async {
        // Call the onBack callback to set the index to 0
        if (Home == "Home") {
          // If home is "home", navigate to the dashboard
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          // Otherwise, just pop the current screen
          Navigator.pop(context, true);
        }
        return false; // Prevents the default back button behavior (returning to previous screen)
      },
      child: Scaffold(
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
                  //onPressed: () => Navigator.pop(context, true),
                  onPressed: () {
                    if (Home == "Home") {
                      // If home is "home", navigate to the dashboard
                      Navigator.of(context).pushReplacementNamed('/home');
                    } else {
                      // Otherwise, just pop the current screen
                      Navigator.pop(context, true);
                    }
                  },
                ),
                backgroundColor: Colors.white,
                title: Text(
                  translate('Order Details'),
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
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.colorPrimary,
                      ),
                    )
                  : productLabels.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                SvgPicture.asset(
                                  'assets/icons/no_cart.svg',
                                  height: 150,
                                ),
                                const SizedBox(height: 20),

                                // Text message
                                Text(
                                  'Your order is empty',
                                  style: CustomTextStyle.GraphikMedium(
                                      22, AppColors.black),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              Visibility(
                                visible: order_summary.isNotEmpty,
                                child: Container(
                                  color: AppTheme().whiteColor,
                                  padding: const EdgeInsets.only(
                                      right: 15.0,
                                      left: 15.0,
                                      bottom: 10.0,
                                      top: 10.0),
                                  child: ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(), // Prevent scrolling
                                    shrinkWrap:
                                        true, // Use only the necessary space
                                    itemCount: order_summary.length,
                                    itemBuilder: (context, itemIndex) {
                                      final item = order_summary[itemIndex];
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item['label'],
                                            style:
                                                CustomTextStyle.GraphikMedium(
                                                    15,
                                                    AppColors.secondTextColor),
                                          ),
                                          const SizedBox(
                                            height: 10.0,
                                          ),
                                          Text(
                                            '${item['value']}',
                                            style:
                                                CustomTextStyle.GraphikRegular(
                                                    15, AppColors.black),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                              if (productLabels.isNotEmpty) ...[
                                const SizedBox(height: 10.0),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: productLabels.length,
                                  itemBuilder: (context, index) {
                                    final item = productLabels[index];
                                    void navigateToDetails(
                                        BuildContext context) {
                                      Navigator.of(context)
                                          .push(PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            ProductDetailScreen(
                                                product_id: item['product_id']
                                                    .toString()),
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          const begin = Offset(1.0, 0.0);
                                          const end = Offset.zero;
                                          const curve = Curves.easeInOut;

                                          var tween = Tween(
                                                  begin: begin, end: end)
                                              .chain(CurveTween(curve: curve));
                                          var offsetAnimation =
                                              animation.drive(tween);

                                          return SlideTransition(
                                            position: offsetAnimation,
                                            child: child,
                                          );
                                        },
                                      ));
                                    }

                                    return GestureDetector(
                                      onTap: () {
                                        navigateToDetails(context);
                                      },
                                      child: Container(
                                        color: Colors.white,
                                        padding: const EdgeInsets.all(15.0),
                                        margin:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: 100.0,
                                                  width: 100.0,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color:
                                                          AppTheme().lineColor,
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    image: DecorationImage(
                                                      image: NetworkImage(item[
                                                          'product_image']),
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10.0),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // Product Name
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Expanded(
                                                            // Wrap Text in Expanded to ensure ellipsis works
                                                            child: Text(
                                                              item['name'],
                                                              style: CustomTextStyle
                                                                  .GraphikMedium(
                                                                      15,
                                                                      AppColors
                                                                          .black),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 5.0),

                                                      Container(
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              '₹ ${item['price']}',
                                                              style: CustomTextStyle
                                                                  .GraphikMedium(
                                                                      13,
                                                                      AppColors
                                                                          .secondTextColor),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            const SizedBox(
                                                              width: 10.0,
                                                            ),
                                                            Text(
                                                              '${item['quantity']} Qty',
                                                              style: CustomTextStyle
                                                                  .GraphikRegular(
                                                                      12,
                                                                      AppColors
                                                                          .secondTextColor),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 5.0),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (item['rate_product'] == true)
                                              Divider(
                                                  height: 1.0,
                                                  color: AppTheme().lineColor),
                                            if (item['rate_product'] == true)
                                              Container(
                                                margin:
                                                    const EdgeInsets.all(10.0),
                                                child: Row(
                                                  children: [
                                                    if (item['rate_product'] ==
                                                        true)
                                                      Expanded(
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            // Handle edit action
                                                            log(item[
                                                                'product_name']);
                                                            //Navigator.of(context).pushNamed("/rating");
                                                            Navigator.pushNamed(
                                                              context,
                                                              '/rating',
                                                              arguments: {
                                                                'product_name':
                                                                    item[
                                                                        'product_name'],
                                                                'product_image':
                                                                    item[
                                                                        'product_image'],
                                                                'partner_name':
                                                                    item[
                                                                        'partner_name'],
                                                                'weight': item[
                                                                    'weight'],
                                                                'unit': item[
                                                                    'unit'],
                                                                'product_id': item[
                                                                    'product_id'],
                                                              },
                                                            );
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            surfaceTintColor:
                                                                AppTheme()
                                                                    .whiteColor,
                                                            backgroundColor:
                                                                AppTheme()
                                                                    .whiteColor,
                                                            side: BorderSide(
                                                                color: AppTheme()
                                                                    .redColor),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.0)),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        15.0),
                                                            textStyle:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        16.0),
                                                          ),
                                                          child: Text(
                                                            'Rate Product',
                                                            style: CustomTextStyle
                                                                .GraphikMedium(
                                                                    14,
                                                                    AppColors
                                                                        .red),
                                                          ),
                                                        ),
                                                      ),
                                                    const SizedBox(width: 10.0),
                                                    Visibility(
                                                      visible: item[
                                                                  'order_invoice_download'] !=
                                                              null &&
                                                          item['order_invoice_download']
                                                              .isNotEmpty,
                                                      child: Expanded(
                                                        child: ElevatedButton(
                                                          onPressed: () async {
                                                            // Request permissions
                                                            String pdfUrl = item[
                                                                'order_invoice_download'];
                                                            await downloadPDF(
                                                                pdfUrl);
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            surfaceTintColor:
                                                                AppTheme()
                                                                    .whiteColor,
                                                            backgroundColor:
                                                                AppTheme()
                                                                    .whiteColor,
                                                            side: BorderSide(
                                                                color: AppTheme()
                                                                    .primaryColor),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.0)),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        15.0),
                                                            textStyle:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        16.0),
                                                          ),
                                                          child: Text(
                                                            'Order Invoice',
                                                            style: CustomTextStyle
                                                                .GraphikRegular(
                                                                    14,
                                                                    AppColors
                                                                        .colorPrimary),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10.0),
                                                    Visibility(
                                                      visible: item[
                                                                  'shipping_invoice_download'] !=
                                                              null &&
                                                          item['shipping_invoice_download']
                                                              .isNotEmpty, // Check if phone is not empty

                                                      child: Expanded(
                                                        child: ElevatedButton(
                                                          onPressed: () async {
                                                            String pdfUrl = item[
                                                                'shipping_invoice_download'];
                                                            await downloadPDF(
                                                                pdfUrl);
                                                            // Request permissions
                                                            /*bool permissionGranted = await requestStoragePermission();
                                                    if (permissionGranted) {
                                                      String pdfUrl = item['shipping_invoice_download'];
                                                      await downloadPDF(pdfUrl);
                                                    } else {
                                                      print("Storage permission not granted, cannot download PDF.");
                                                    }*/
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            surfaceTintColor:
                                                                AppTheme()
                                                                    .whiteColor,
                                                            backgroundColor:
                                                                AppTheme()
                                                                    .whiteColor,
                                                            side: BorderSide(
                                                                color: AppTheme()
                                                                    .primaryColor),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.0)),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        15.0),
                                                            textStyle:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        16.0),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              'Shipping Invoice',
                                                              style: CustomTextStyle
                                                                  .GraphikRegular(
                                                                      14,
                                                                      AppColors
                                                                          .colorPrimary),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (item['test_items'] != null &&
                                                item['test_items'].isNotEmpty)
                                              Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 10.0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  border: Border.all(
                                                    color: AppTheme().lineColor,
                                                    width: 1.0, // Border width
                                                  ),
                                                ),
                                                child: ListView.builder(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(), // Prevent scrolling
                                                  shrinkWrap:
                                                      true, // Use only the necessary space
                                                  itemCount:
                                                      item['test_items'].length,
                                                  itemBuilder:
                                                      (context, itemIndex) {
                                                    final item1 =
                                                        item['test_items']
                                                            [itemIndex];
                                                    return Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                            height:
                                                                5.0), // Adjust the height as needed for spacing

                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Image.asset(
                                                              "assets/images/product.png",
                                                              height: 30,
                                                              width: 30,
                                                            ),
                                                            const SizedBox(
                                                                width: 8.0),
                                                            // Space between icon and text
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  item1[
                                                                      'test_name'],
                                                                  style: CustomTextStyle
                                                                      .GraphikRegular(
                                                                          14,
                                                                          AppColors
                                                                              .colorPrimary),
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      '₹ ${item1['total']}',
                                                                      style: TextStyle(
                                                                          color: AppTheme()
                                                                              .blackColor,
                                                                          fontSize:
                                                                              14),
                                                                    ),
                                                                    const SizedBox(
                                                                      width:
                                                                          10.0,
                                                                    ),
                                                                    Text(
                                                                      'Tax: ₹ ${item1['tax']}',
                                                                      style: CustomTextStyle.GraphikRegular(
                                                                          14,
                                                                          AppColors
                                                                              .colorPrimary),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),

                                                        // Add spacing between items
                                                        const SizedBox(
                                                            height:
                                                                10.0), // Adjust the height as needed for spacing
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                              Container(
                                color: AppTheme().whiteColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        translate('Delivery Address'),
                                        style: CustomTextStyle.GraphikMedium(
                                            16, AppColors.black),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(Name,
                                          style: CustomTextStyle.GraphikMedium(
                                              14, AppColors.black)),
                                      const SizedBox(height: 10),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/icons/location_pin.svg', // Path to your SVG icon
                                                  height:
                                                      22.0, // Adjust height as needed
                                                  width:
                                                      22.0, // Adjust width as needed
                                                  color: AppTheme()
                                                      .secondTextColor,
                                                ),
                                                const SizedBox(
                                                    width:
                                                        8.0), // Spacing between icon and text
                                                Expanded(
                                                  // Wrap the Text widget in Expanded
                                                  child: Text(Address,
                                                      maxLines:
                                                          2, // Limit to 2 lines for address
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: CustomTextStyle
                                                          .GraphikRegular(
                                                              13,
                                                              AppColors
                                                                  .secondTextColor)),
                                                ),
                                              ],
                                            ),

                                            /*Row(
                              crossAxisAlignment: CrossAxisAlignment.start,  // Aligns the icon to the top
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start, // Aligns to the start (top)
                                  children: [
                                    const SizedBox(height: 5),
                                    SvgPicture.asset(
                                      'assets/icons/location_pin.svg', // Replace with your SVG asset path
                                      width: 15, // Set the width of the SVG icon
                                      height: 15, // Set the height of the SVG icon
                                      color: AppTheme().secondTextColor, // Optional: set the color of the SVG icon
                                    ),
                                  ],
                                ),
                                SizedBox(width: 8), // Adding some space between the icon and the text
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to the start
                                  children: [
                                    Text(Address),
                                  ],
                                ),
                              ],
                            ),*/

                                            if (Gst_No.isNotEmpty)
                                              const SizedBox(height: 10),
                                            Visibility(
                                              visible: Gst_No
                                                  .isNotEmpty, // Check if phone is not empty
                                              child: Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/icons/document_gst.svg', // Replace with your SVG asset path
                                                    width:
                                                        22, // Set the width of the SVG icon
                                                    height:
                                                        22, // Set the height of the SVG icon
                                                    color: AppTheme()
                                                        .secondTextColor, // Optional: set the color of the SVG icon
                                                  ),
                                                  const SizedBox(
                                                      width:
                                                          8), // Adding some space between the icon and the text

                                                  Text(Gst_No,
                                                      style: CustomTextStyle
                                                          .GraphikRegular(
                                                              12,
                                                              AppColors
                                                                  .secondTextColor)),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/icons/phone.svg', // Replace with your SVG asset path
                                                  width:
                                                      22, // Set the width of the SVG icon
                                                  height:
                                                      22, // Set the height of the SVG icon
                                                  color: AppTheme()
                                                      .secondTextColor, // Optional: set the color of the SVG icon
                                                ),
                                                const SizedBox(
                                                    width:
                                                        8), // Adding some space between the icon and the text

                                                Text(Mobile,
                                                    style: CustomTextStyle
                                                        .GraphikRegular(
                                                            12,
                                                            AppColors
                                                                .secondTextColor)),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/icons/email.svg', // Replace with your SVG asset path
                                                  width:
                                                      22, // Set the width of the SVG icon
                                                  height:
                                                      22, // Set the height of the SVG icon
                                                  color: AppTheme()
                                                      .secondTextColor, // Optional: set the color of the SVG icon
                                                ),
                                                const SizedBox(
                                                    width:
                                                        8), // Adding some space between the icon and the text

                                                Text(Email,
                                                    style: CustomTextStyle
                                                        .GraphikRegular(
                                                            12,
                                                            AppColors
                                                                .secondTextColor)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                color: AppTheme().whiteColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Order Payment Summary',
                                          style: CustomTextStyle.GraphikMedium(
                                              16, AppColors.black)),
                                      const SizedBox(height: 10),
                                      Container(
                                        color: AppTheme().whiteColor,
                                        child: ListView.builder(
                                          // Use shrinkWrap to allow the GridView to take only the required height
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(), // Disable scrolling to prevent overflow

                                          itemCount: orderDetails.length,
                                          itemBuilder: (context, index) {
                                            final label = orderDetails[index];
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  label['label'],
                                                  style: CustomTextStyle
                                                      .GraphikMedium(
                                                          15,
                                                          AppColors
                                                              .secondTextColor),
                                                ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                Text(
                                                  '₹ ${label['value']}',
                                                  style: CustomTextStyle
                                                      .GraphikRegular(
                                                          15, AppColors.black),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 10.0),
                                        child: CustomPaint(
                                          size: const Size(double.infinity, 1),
                                          // Width can be infinity
                                          painter: DottedLinePainter(
                                            color: AppTheme().lineColor,
                                            strokeWidth: 1.0,
                                            dotSpacing: 4.0,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Total Payout',
                                            style:
                                                CustomTextStyle.GraphikRegular(
                                                    14, AppColors.black),
                                          ),
                                          //Text('₹${totalAmount.toStringAsFixed(2)}',
                                          Text('₹ $total',
                                              style:
                                                  CustomTextStyle.GraphikMedium(
                                                      15, AppColors.black)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
            if (cancel_order == true)
              Column(
                children: [
                  Container(
                    height: 1.0,
                    color: AppTheme().lineColor,
                  ),
                  Container(
                    width: double.infinity,
                    color: AppTheme().whiteColor,
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translate('Cancellation Policy'),
                          style: TextStyle(
                            color: AppTheme().firstTextColor,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'If you want to cancel order you must wait for Q.C result. After result, you can cancel the order.',
                          style: TextStyle(
                            color: AppTheme().secondTextColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                _showCancellationBottomSheet(context),
                            child: Text(
                              translate('Cancel Order'),
                              style:
                                  TextStyle(color: AppTheme().secondaryColor),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme().whiteColor,
                              surfaceTintColor: AppTheme().whiteColor,
                              side:
                                  BorderSide(color: AppTheme().secondaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Method to show cancellation bottom sheet
  void _showCancellationBottomSheet(BuildContext context) {
    final FocusNode _focusNode = FocusNode();

    showModalBottomSheet(
      backgroundColor: AppTheme().whiteColor,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        // Use WidgetsBinding.addPostFrameCallback to ensure focus request after the build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(_focusNode);
        });

        return Container(
          height: MediaQuery.of(context).size.height /
              1.1, // Full height of the screen
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                  const Text(
                    'Order Cancellation',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _reasonController,
                focusNode: _focusNode, // Use focus node to control focus
                decoration: InputDecoration(
                  labelText: 'Reason for Cancellation',
                  hintText: 'Enter your reason here',
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
              const SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    String reason = _reasonController.text;
                    if (reason.isNotEmpty) {
                      _cancelOrder(reason);
                    } else {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a reason')),
                      );
                    }
                  },
                  child: Text(
                    'Confirm Cancellation',
                    style: TextStyle(color: AppTheme().secondaryColor),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme().whiteColor,
                    side: BorderSide(color: AppTheme().secondaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DottedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dotSpacing;

  DottedLinePainter({
    this.color = Colors.black,
    this.strokeWidth = 1.0,
    this.dotSpacing = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0.0;
    final path = Path();

    while (startX < size.width) {
      path.moveTo(startX, size.height / 2);
      path.lineTo(startX + 5, size.height / 2);
      startX += 10 + dotSpacing;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Widget _buildPriceItem(String title, String price) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: AppTheme().thirdTextColor)),
        Text(price, style: TextStyle(color: AppTheme().firstTextColor)),
      ],
    ),
  );
}

Widget _buildOrderDetailRow(String title, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: TextStyle(color: AppTheme().blackColor),
      ),
      Text(
        value,
        style: TextStyle(color: AppTheme().secondTextColor),
      ),
    ],
  );
}
