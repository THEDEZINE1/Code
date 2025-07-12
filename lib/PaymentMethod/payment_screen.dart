import 'package:Decont/MyCartList/cart_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import '../BaseUrl.dart';
import '../CouponCodeList/coupon_list.dart';
import '../CustomeTextStyle/custometextstyle.dart';
import '../theme/AppTheme.dart';

//String? selectedAddressId;
String? user_token = '';
String? userID = '';

class PaymentMethodScreen extends StatefulWidget {
  final String couponCode;
  final String discount;
  final String disID;
  final String message;
  final String? addID;

  final String? CODYesOrNot;

  PaymentMethodScreen({
    required this.couponCode,
    required this.discount,
    required this.disID,
    required this.message,
    this.addID,
    this.CODYesOrNot,
  });

  @override
  _PaymentMethodScreenState createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  //bool _isChecked = false;
  //final bool _shouldShowCheckbox = true;
  String? _selectedPaymentMethod = 'online'; // Track selected payment method
  Map<String, String> localizedStrings = {};
  String currentLangCode = 'en';
  bool isLoading = false;
  List<Map<String, dynamic>> orderDetails = [];
  bool hasMoreData = true;
  String cod_heading = '';
  String item_count = '';
  String super_use_amount = '';
  String online_pay_discount = '';
  String cod_sub_heading = '';
  String online_heading = '';
  String online_sub_heading = '';
  String message = '';
  String disID = '';
  String discount = '';
  String couponCode = '';
  bool isWalletSelected = false; // Checkbox state
  double walletAmount = 0; // Wallet amount
  double user_super_wallet = 0; // Wallet amount
  double totalPayment =
      0; // Add this line to define totalPayment at the class level
  double subTotal =
      0; // Add this line to define totalPayment at the class level
  double shipping =
      0; // Add this line to define totalPayment at the class level
  String wallet_value = 'No'; // Initialize wallet_value to 'No'

  void initState() {
    super.initState();

    _loadCurrentLanguagePreference();
    _initializeData();

    message = widget.message;
    disID = widget.disID;
    discount = widget.discount;
    couponCode = widget.couponCode;
  }

  Future<void> _initializeData() async {
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

    final Map<String, String> body = {
      'addressID': widget.addID.toString(),
      'custID': '$userID',
      'view': 'checkout_info',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());
        log('Response data: $data');

        orderDetails.clear();

        if (data['result'] == 1) {
          final checkoutData = data['data'];

          setState(() {
            cod_heading = checkoutData['online'] ?? "";
            item_count = checkoutData['item_count'] ?? "";
            super_use_amount = checkoutData['super_use_amount'] ?? "";
            online_pay_discount = checkoutData['online_pay_discount'] ?? "";
            subTotal = double.tryParse(
                    checkoutData['subtotal']?.toString() ?? "0.0") ??
                0.0;
            shipping = double.tryParse(
                    checkoutData['shipping']?.toString() ?? "0.0") ??
                0.0;
            totalPayment = double.tryParse(
                    checkoutData['grand_total']?.toString() ?? "0.0") ??
                0.0;
            walletAmount =
                double.tryParse(checkoutData['wallet']?.toString() ?? "0.0") ??
                    0.0;
            user_super_wallet = double.tryParse(
                    checkoutData['user_super_wallet']?.toString() ?? "0.0") ??
                0.0;
          });
          //log('productInfo: $orderDetails'); // Log extracted image URLs
          log('productInfo: $subTotal'); // Log extracted image URLs
        } else if (data['result'] == 2) {
          _showErrorSnackBar(data['message']);
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
    final args = ModalRoute.of(context)?.settings.arguments;

    // if (args != null && args is Map<String, dynamic>) {
    //   selectedAddressId = args['selectedAddressId'];
    //   print(selectedAddressId);
    // } else {
    //   // Handle the case when args is null or not of type Map<String, dynamic>
    //   print("Arguments are missing or in the wrong format.");
    // }

    CheckoutPayment(
        String address_id,
        String payment_type,
        String disID,
        String discount,
        String wallet_value,
        String amountToUseFromWallet,
        String updatedTotalPayment) async {
      setState(() {
        isLoading = true;
      });

      final url = Uri.parse(baseUrl);

      final Map<String, String> headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $user_token',
      };

      final Map<String, String> body = {
        'view': 'checkout',
        'custID': '$userID',
        'addressID': address_id,
        'payment': payment_type,
        'disID': disID,
        'disvalue': discount,
        'wallet_used': wallet_value,
        'wallet_use_value': amountToUseFromWallet,
        'subtotal': updatedTotalPayment,
      };

      try {
        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          log('Response data: $data');

          if (data['result'] == 1) {
            // Extract messages and ID
            print(data);
            // Get.to(const PaymentGateWay());
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

            if (msgcode == '11') {
              // Check if msgcode is 11
              // Extract messages and ID

              // Navigate to the order success screen with the data
              Navigator.pushNamed(context, '/order_webview_PaymentPaytm',
                  arguments: {
                    'message_1': message1,
                    'message_2': message2,
                    'orderId': orderId.toString(),
                    'webUrl': webUrl,
                  });
            } else if (msgcode == '0') {
              final message1 =
                  data['data']['fail_message1'] ?? ''; // Updated message field
              final message2 =
                  data['data']['fail_message'] ?? ''; // Updated message field
              final orderId =
                  data['data']['orderID'].toString(); // Updated ID field

              // Navigate to the order success screen with the data
              Navigator.pushReplacementNamed(context, '/order_success',
                  arguments: {
                    'message_1': message1,
                    'message_2': message2,
                    'orderId': orderId,
                    'status': 'captured',
                  });
            } else {
              _showErrorSnackBar('Invalid msgcode: $msgcode');
              log('Invalid msgcode: $msgcode');
            }

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

    double amountToUseFromWallet = isWalletSelected
        ? (walletAmount >= totalPayment ? totalPayment : walletAmount)
        : 0.0;

// Calculate remaining wallet amount
    double remainingWalletAmount = walletAmount - amountToUseFromWallet;

// If there is a discount, subtract it from the total payment
    double discountAmount =
        double.tryParse(discount) ?? 0.0; // Convert discount string to double
    double updatedTotalPayment =
        totalPayment - amountToUseFromWallet - discountAmount;

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
                translate('Payment Method'),
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15.0),
                      color: AppTheme().whiteColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(translate('Select payment method'),
                              style: CustomTextStyle.GraphikMedium(
                                  18, AppColors.black)),
                          const SizedBox(height: 16),
                          //if (cod_heading!.isNotEmpty)
                          _buildPaymentOption(
                            //heading: cod_heading,
                            heading: 'Google Pay',
                            //subHeading: cod_sub_heading,
                            subHeading: '',
                            value: "googlePay",
                          ),
                          const SizedBox(height: 5),

                          _buildPaymentOption(
                            //heading: cod_heading,
                            heading: 'Phone Pay',
                            //subHeading: cod_sub_heading,
                            subHeading: '',
                            value: "phonePay",
                          ),
                          const SizedBox(height: 5),
                          _buildPaymentOption(
                            //heading: cod_heading,
                            heading: 'Debit Card / Credit Cart / Net Banking',
                            //subHeading: cod_sub_heading,
                            subHeading: '',
                            value: "banking",
                          ),
                          const SizedBox(height: 5),
                          _buildPaymentOption(
                            //heading: cod_heading,
                            heading: 'UPI',
                            //subHeading: cod_sub_heading,
                            subHeading: '',
                            value: "UPI",
                          ),
                          const SizedBox(height: 5),
                          _buildPaymentOption(
                            //heading: cod_heading,
                            heading: 'Other Wallet',
                            //subHeading: cod_sub_heading,
                            subHeading: '',
                            value: "otherWallet",
                          ),
                          const SizedBox(height: 5),
                          _buildPaymentOption(
                            heading: 'Cash On Delivery',
                            subHeading:
                                'Make 100% Payment Online & Balance 0% COD (Cash On Delivery)',
                            value: "cod",
                          )

                          // GestureDetector(
                          //   onTap: (){
                          //
                          //   },
                          //   child: _buildPaymentOption(
                          //     //heading: cod_heading,
                          //     heading: 'Cash On Delivery',
                          //     //subHeading: cod_sub_heading,
                          //     subHeading:
                          //         'Make 100% Payment Online & Balance 0% COD (Cash On Delivery)',
                          //     value: "cod",
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(15.0),
                      color: AppTheme().whiteColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (disID.isEmpty)
                            GestureDetector(
                              onTap: () =>
                                  Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        CouponScreen(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
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
                              )),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Using Flexible instead of Expanded as it's more appropriate for controlling flex behavior
                                  Flexible(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.local_offer_outlined,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Have a coupon code?',
                                          style: CustomTextStyle.GraphikRegular(
                                              14, AppColors.colorPrimary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.black,
                                    size: 15,
                                  ),
                                ],
                              ),
                            ),
                          if (disID.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Wrap the long text with an Expanded widget to prevent overflow
                                Expanded(
                                  child: Text(
                                    message,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: AppColors.black,
                                            fontSize: 14),
                                    overflow: TextOverflow
                                        .ellipsis, // Adds "..." if the text overflows
                                  ),
                                ),

                                // Container for "Remove" button
                                GestureDetector(
                                  onTap: () {
                                    // Clear discount information when "Remove" is clicked
                                    setState(() {
                                      disID = ''; // Clear the disID
                                      discount = ''; // Clear the discount
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors
                                          .transparent, // Set background to transparent
                                      border: Border.all(
                                        color: AppColors
                                            .colorPrimary, // Border color
                                        width:
                                            2, // Border width (adjust as needed)
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          5), // Border radius
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10), // Padding
                                    child: Text(
                                      'Remove',
                                      style: CustomTextStyle.GraphikMedium(
                                          14, AppColors.colorPrimary),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.only(
                          right: 15.0, left: 15.0, bottom: 10.0),
                      color: AppTheme().whiteColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Decont Wallet :- ',
                                    style: CustomTextStyle.GraphikRegular(
                                        16, AppColors.black),
                                  ),
                                  Text(
                                    ' ₹ ${remainingWalletAmount.toStringAsFixed(2)}',
                                    style: CustomTextStyle.GraphikMedium(
                                        14, AppColors.colorPrimary),
                                  ),
                                ],
                              ),
                              Checkbox(
                                value: isWalletSelected,
                                activeColor: AppColors
                                    .colorPrimary, // Change color when checked

                                onChanged: (value) {
                                  setState(() {
                                    isWalletSelected = value ?? false;
                                    wallet_value = isWalletSelected
                                        ? 'Yes'
                                        : 'No'; // Update wallet_value based on checkbox state
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  /*SvgPicture.asset(
                              'assets/icons/wallet.svg',
                              height: 25,
                              width: 25,
                              color: AppTheme().blackColor,
                            ),
                            SizedBox(width: 8),*/
                                  Text(
                                    'Super Wallet ',
                                    style: CustomTextStyle.GraphikRegular(
                                        16, AppColors.black),
                                  ),
                                  Icon(
                                    Icons
                                        .info_outline, // Use the mic icon from the material icons package
                                    color: AppTheme()
                                        .secondTextColor, // Set the icon color as per your theme
                                    size: 15, // Set the icon size
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '₹ $user_super_wallet',
                                    style: CustomTextStyle.GraphikMedium(
                                        14, AppColors.colorPrimary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    /*Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/wallet.svg',
                                height: 25,
                                width: 25,
                                color: AppTheme().blackColor,
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  'Sourcing Sathi Wallet :- ₹ ${walletAmount}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppTheme().blackColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 48,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Checkbox(
                              value: isWalletSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  isWalletSelected = value ?? false;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),*/

                    Container(
                      padding: const EdgeInsets.all(15.0),
                      color: AppTheme().whiteColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(translate('Price Details'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                          color: AppColors.black,
                                          fontSize: 18)),
                              const SizedBox(height: 10),
                              Container(
                                height: 1.0,
                                color: AppTheme().lineColor,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Price ($item_count items)',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium!
                                          .copyWith(
                                              color: AppColors.black,
                                              fontSize: 16)),
                                  Text(
                                    '₹ $subTotal',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                            color: AppColors.tex, fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Online Discount',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium!
                                        .copyWith(
                                            color: AppColors.black,
                                            fontSize: 16),
                                  ),
                                  Text(
                                    '- ₹ $online_pay_discount',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                            color: AppColors.tex, fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Shipping Charge',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium!
                                        .copyWith(
                                            color: AppColors.black,
                                            fontSize: 16),
                                  ),
                                  Text(
                                    '+ ₹ $shipping',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                            color: AppColors.tex, fontSize: 16),
                                  ),
                                ],
                              ),
                              if (isWalletSelected) ...[
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Decont Wallet',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium!
                                          .copyWith(
                                              color: AppColors.black,
                                              fontSize: 16),
                                    ),
                                    Text(
                                      '- ₹ ${amountToUseFromWallet.toStringAsFixed(2)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                              color: AppColors.tex,
                                              fontSize: 16),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Supper Wallet',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium!
                                        .copyWith(
                                            color: AppColors.black,
                                            fontSize: 16),
                                  ),
                                  Text(
                                    '- ₹ $super_use_amount',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                            color: AppColors.tex, fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              if (disID.isNotEmpty)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Discount',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium!
                                          .copyWith(
                                              color: AppColors.black,
                                              fontSize: 16),
                                    ),
                                    Text(
                                      '- ₹ $discount',
                                      //Text('- ₹ 1275.00',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                              color: AppColors.tex,
                                              fontSize: 16),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 5),

                              /*Container(
                          color: AppTheme().whiteColor,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(), // Disable scrolling to prevent overflow
                            itemCount: orderDetails.length,
                            itemBuilder: (context, index) {
                              final label = orderDetails[index];
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(label['key'],
                                        style: TextStyle(color: AppTheme().blackColor, fontSize: 16),
                                      ),
                                      Text('${label['value']}',
                                        style: TextStyle(color: AppTheme().secondTextColor, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  // Add spacing between items
                                  SizedBox(height: 5.0), // Adjust the height as needed for spacing
                                ],
                              );
                            },
                          ),
                        ),*/

                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: CustomPaint(
                                  size: const Size(double.infinity, 1),
                                  painter: DottedLinePainter(
                                    color: AppTheme().lineColor,
                                    strokeWidth: 1.0,
                                    dotSpacing: 4.0,
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Amount Payable',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                  color: AppColors.black,
                                                  fontSize: 16)),
                                      Text(
                                          //'₹ ${totalPayment}',
                                          '₹ ${updatedTotalPayment.toStringAsFixed(2)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                  color: AppColors.black,
                                                  fontSize: 16)),
                                    ],
                                  ),

                                  const SizedBox(height: 5),

                                  //if(disID.isNotEmpty)
                                  /*Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Online Amount',
                                        style: TextStyle(color: AppTheme().blackColor, fontSize: 16),
                                      ),
                                      Text('₹ 12750.00',
                                        style: TextStyle(color: AppTheme().secondTextColor, fontSize: 16),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 5),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('COD Amount',
                                        style: TextStyle(color: AppTheme().blackColor, fontSize: 16),
                                      ),
                                      Text('₹ 12750.00',
                                        style: TextStyle(color: AppTheme().secondTextColor, fontSize: 16),
                                      ),
                                    ],
                                  ),*/
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: true,
                          activeColor: AppColors
                              .colorPrimary, // Change color when checked
                          onChanged: (value) {},
                        ),
                        Expanded(
                          child: Text(
                            'By Processing to place the order, you agree with all the T&C, Policies.',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(color: AppColors.tex, fontSize: 13),
                            overflow: TextOverflow.ellipsis, // Handle overflow
                            maxLines: 2, // Optional: limit the number of lines
                          ),
                        ),
                      ],
                    ),

                    /*Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,  // Align checkbox to the top
                      mainAxisAlignment: MainAxisAlignment.start,   // Align checkbox to the start (left)
                      children: <Widget>[
                        Checkbox(
                          value: true, // Checkbox is always true
                          onChanged: (bool? value) {}, // Disable interaction (no change possible)
                          activeColor: AppTheme().primaryColor, // Change color when checked
                          checkColor: AppTheme().whiteColor, // Color of the checkmark
                        ),
                        Expanded(
                          child: Text(
                            'By Processing to place the order, you agree with all the T&C, Policies.',
                            overflow: TextOverflow.ellipsis, // Optionally truncate text if it overflows
                            maxLines: 2, // Optional: limit the number of lines
                            style: TextStyle(
                              fontSize: 12, // Font size of the text
                              color: Colors.black, // Color of the text
                            ),
                          ),
                        ),
                      ],
                    ),*/
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
                    // Print the selected payment method

                    log('_selectedPaymentMethod: ${_selectedPaymentMethod.toString()}');
                    log('disID: ${disID.toString()}');
                    log('discount: ${discount.toString()}');
                    log('wallet_value: ${wallet_value.toString()}');
                    log('amountToUseFromWallet: ${amountToUseFromWallet.toString()}');
                    log('grandtotal: ${updatedTotalPayment.toString()}');

                    //Navigator.pushNamed(context, '/order_success');
                    CheckoutPayment(
                        widget.addID.toString(),
                        _selectedPaymentMethod.toString(),
                        disID.toString(),
                        discount.toString(),
                        wallet_value.toString(),
                        amountToUseFromWallet.toString(),
                        updatedTotalPayment.toString());
                  },
                  style: ElevatedButton.styleFrom(
                    //backgroundColor: AppTheme().secondaryColor,
                    backgroundColor: isLoading
                        ? Colors.grey // Change to grey when loading
                        : AppColors
                            .colorPrimary, // Original color when not loading
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
                      ? const CircularProgressIndicator(color: AppColors.white)
                      : Text(
                          'Place Order',
                          style: CustomTextStyle.GraphikMedium(
                              14, AppColors.white),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String heading,
    required String subHeading,
    required String value,
  }) {
    final Map<String, String> paymentIcons = {
      "googlePay": 'assets/payment_method_screen/GPay.png',
      "phonePay": 'assets/payment_method_screen/phonepe.png',
      "banking": 'assets/payment_method_screen/card.png',
      "UPI": 'assets/payment_method_screen/UPI.png',
      "otherWallet": 'assets/payment_method_screen/otherWallet.png',
      "cod": 'assets/payment_method_screen/COD.png',
    };

    String iconPath = paymentIcons[value] ?? 'assets/icons/default_payment.svg';

    bool isSelected = _selectedPaymentMethod == value;

    return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.colorPrimary : AppTheme().lineColor,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: InkWell(
          onTap: () {
            if (value == "cod" && widget.CODYesOrNot == 'Not Available') {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('COD Alert',
                        style:
                            CustomTextStyle.GraphikMedium(18, AppColors.black)),
                    content: Text(
                        'Check your cart. A few products are not eligible for the COD option.',
                        style: CustomTextStyle.GraphikRegular(
                            16, AppColors.secondTextColor)),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Get.to(
                            MyCartScreen(),
                          );
                        },
                        child: Text('Update Cart',
                            style: CustomTextStyle.GraphikMedium(
                                14, AppColors.colorPrimary)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Navigate or trigger check cart flow here
                          // Navigator.pushNamed(context, '/cart');
                        },
                        child: Text('Pay Online',
                            style: CustomTextStyle.GraphikMedium(
                                14, AppColors.colorPrimary)),
                      ),
                    ],
                  );
                },
              );
            } else {
              // Update selected payment method
              setState(() {
                _selectedPaymentMethod = value;
              });
              // Add COD payment logic here if needed
            }
          },
          child: ListTile(
            leading: Image.asset(
              iconPath,
              height: 35,
              width: 35,
            ),
            title: Text(
              heading,
              style: CustomTextStyle.GraphikMedium(16, AppColors.black),
            ),
            subtitle: Text(
              subHeading,
              style: CustomTextStyle.GraphikRegular(12, AppColors.greyColor),
            ),
            trailing: Radio<String>(
                value: value,
                groupValue:
                    _selectedPaymentMethod, // Group value to control which radio is selected
                activeColor: AppColors.colorPrimary,
                onChanged: (String? newValue) {
                  onChanged:
                  (String? newValue) {
                    if (newValue == "cod" &&
                        widget.CODYesOrNot == 'Not Available') {
                      // COD not available, show popup
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('COD Not Available'),
                            content: Text('Sorry, COD is not available.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  // Navigate or trigger online payment flow
                                },
                                child: Text('Make Online Payment'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  // Navigate or trigger check cart flow
                                },
                                child: Text('Check Cart'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      setState(() {
                        _selectedPaymentMethod = newValue;
                      });
                    }

                    // setState(() {
                    //   _selectedPaymentMethod =
                    //       newValue; // Update the selected payment method
                    // });
                  };
                }),
          ),
        ));
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
