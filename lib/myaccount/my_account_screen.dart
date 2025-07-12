import 'dart:convert';
import 'dart:developer';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../CustomeTextStyle/custometextstyle.dart';
import '../Dashboard/home_screen.dart';
import '../MyWallet/wallet_history_Screen.dart';
import '../OrderList/order_list_screen.dart';
import '../ProfileScreen/profile_screen.dart';
import '../theme/AppTheme.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../AboutUs/about_us_screen.dart';
import '../AddressScreen/add_edit_address_screen.dart';
import '../BaseUrl.dart';
import '../ContactUs/contact_us_screen.dart';
import '../Notification/notification_screen.dart';
import '../ReferScreen/refer_screen.dart';

String? name = '';
String? email = '';
String? mobile = '';
String? user_token = '';
String? image = '';
String? userID = '';
String? wallet_amount = '';

class MyAccountPage extends StatefulWidget {
  final VoidCallback onBack;

  MyAccountPage({required this.onBack});

  @override
  _MyAccountPageState createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  Map<String, String> localizedStrings = {};
  String currentLangCode = 'en';
  String? url; // Nullable URL to handle dynamic assignment
  String? packageName;
  String? version;

  @override
  void dispose() {
    // Ensure the overlay is removed when the widget is disposed
    super.dispose();
  }

  @override
  void initState() {
    _loadCurrentLanguagePreference();
    _initializeData(); // Call the async method
    _getPackageInfo();

    super.initState();
  }

  Future<void> _getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      packageName = packageInfo.packageName;
      version = packageInfo.version;
    });
  }

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
      email = prefs.getString('email') ?? '';
      mobile = prefs.getString('mobile') ?? '';
      user_token = prefs.getString('user_token') ?? '';
      userID = prefs.getString('userID') ?? '';
      wallet_amount = prefs.getString('wallet_amount') ?? '';

      image = prefs.getString('image') ?? '';
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Call the onBack callback to set the index to 0
        widget.onBack();
        Navigator.pop(context);
        return false; // Prevents the default back button behavior (returning to previous screen)
      },
      child: Scaffold(
        backgroundColor: AppTheme().mainBackgroundColor,
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
                          color: AppColors.black,
                        ),
                        onPressed: () {
                          Get.to(const Home());
                          // Navigator.pushNamed(context, '/home');
                        },
                      ),
                    );
                  },
                ),
                backgroundColor: Colors.white,
                elevation: 0.0,
                title: Text(
                  translate('My Account'),
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
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // User Profile
              Padding(
                padding: const EdgeInsets.only(right: 10.0, left: 10.0),
                child: Card(
                  color: AppColors.white,
                  surfaceTintColor: Colors.transparent,
                  // Set the background color to white
                  // Elevation for the shadow effect
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // Rounded corners
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        /*CircleAvatar(
                        radius: 30,
                        backgroundImage:
                        '$image' != null && '$image'.isNotEmpty
                            ? NetworkImage('$image')
                            : AssetImage('assets/images/profile.png')
                        as ImageProvider,
                      ),
                      const SizedBox(width: 16),*/
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hey, $name',
                                style: CustomTextStyle.GraphikMedium(
                                    16, AppColors.black)),
                            Text('+91 $mobile',
                                style: CustomTextStyle.GraphikRegular(
                                    14, AppColors.secondTextColor)),
                          ],
                        ),
                        const Spacer(),
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: '$image'.isNotEmpty
                              ? NetworkImage('$image')
                              : const AssetImage('assets/images/profile.png')
                                  as ImageProvider,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Account Options
              Padding(
                padding: const EdgeInsets.only(right: 10.0, left: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // My Orders Card
                    Expanded(
                      child: Card(
                        color: AppColors.white,
                        surfaceTintColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: InkWell(
                          onTap: () {
                            Get.to(OrderListScreen(
                              onBack: () {},
                            ));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/my_order.svg',
                                  // Replace with your SVG asset path
                                  width: 40, // Set the width of the SVG icon
                                  height: 40, // Set the height of the SVG icon
                                ),
                                const SizedBox(
                                  width: 8,
                                  height: 10,
                                ),
                                Text(
                                  translate('My Orders'),
                                  style: CustomTextStyle.GraphikMedium(
                                      15, AppColors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Refer Earn
                    Expanded(
                      child: Card(
                        color: AppColors.white,
                        surfaceTintColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: InkWell(
                          onTap: () {
                            Get.to(ReferScreen());
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/refer_us.svg',
                                  // Replace with your SVG asset path
                                  width: 40, // Set the width of the SVG icon
                                  height: 40, // Set the height of the SVG icon
                                ),
                                const SizedBox(
                                  width: 8,
                                  height: 10,
                                ),
                                Text(
                                  translate('Refer Us'),
                                  style: CustomTextStyle.GraphikMedium(
                                      15, AppColors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              //My Wallet
              Padding(
                padding: const EdgeInsets.only(right: 10.0, left: 10.0),
                child: GestureDetector(
                  onTap: () {
                    Get.to(WalletHistoryScreen());
                  },
                  child: Card(
                    color: AppColors.colorPrimary,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/wallet.svg',
                            width: 40,
                            height: 40,
                            color: AppTheme().whiteColor,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Wallet',
                                style: CustomTextStyle.GraphikMedium(
                                    18, AppColors.white),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '₹ $wallet_amount',
                                style: CustomTextStyle.GraphikRegular(
                                    16, AppColors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // My Profile
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    // Profile Details Card
                    Card(
                      color: AppTheme().whiteColor,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          // Profile Details
                          ListTile(
                            leading: SvgPicture.asset(
                              'assets/icons/profile_account.svg',
                              // Replace with your SVG asset path
                              width: 40, // Set the width of the SVG icon
                              height: 40, // Set the height of the SVG icon
                            ),
                            title: Text('My Profile',
                                style: CustomTextStyle.GraphikRegular(
                                    16, AppColors.black)),
                            trailing: SvgPicture.asset(
                              'assets/icons/right_icon.svg',
                              // Replace with your SVG asset path
                              width: 15, // Set the width of the SVG icon
                              height: 15, // Set the height of the SVG icon
                            ),
                            onTap: () {
                              Get.to(ProfileScreenPage());
                            },
                          ),

                          Padding(
                            padding: const EdgeInsets.only(
                                right: 15.0, left: 15.0, top: 5.0, bottom: 5.0),
                            child: Container(
                              height: 1,
                              color: AppTheme().lineColor,
                            ),
                          ),

                          // Save Address
                          ListTile(
                            leading: SvgPicture.asset(
                              'assets/icons/save_address.svg',
                              width: 40,
                              height: 40,
                            ),
                            title: Text(translate('Add/Edit Address'),
                                style: CustomTextStyle.GraphikRegular(
                                    16, AppColors.black)),
                            trailing: SvgPicture.asset(
                              'assets/icons/right_icon.svg',
                              width: 15,
                              height: 15,
                            ),
                            onTap: () {
                              Get.to(const AddressScreen());
                            },
                          ),

                          Padding(
                            padding: const EdgeInsets.only(
                                right: 15.0, left: 15.0, top: 5.0, bottom: 5.0),
                            child: Container(
                              height: 1,
                              color: AppTheme().lineColor,
                            ),
                          ),

                          // Notifications
                          ListTile(
                            leading: SvgPicture.asset(
                              'assets/icons/notification.svg',
                              width: 40,
                              height: 40,
                            ),
                            title: Text(translate('Notifications'),
                                style: CustomTextStyle.GraphikRegular(
                                    16, AppColors.black)),
                            trailing: SvgPicture.asset(
                              'assets/icons/right_icon.svg',

                              width: 15, // Set the width of the SVG icon
                              height: 15,
                            ),
                            onTap: () {
                              Get.to(NotificationsPage(
                                onBack: () {},
                              ));
                            },
                          ),

                          Padding(
                            padding: const EdgeInsets.only(
                                right: 15.0, left: 15.0, top: 5.0, bottom: 5.0),
                            child: Container(
                              height: 1,
                              color: AppTheme().lineColor,
                            ),
                          ),

                          // Contact Us
                          ListTile(
                            leading: SvgPicture.asset(
                              'assets/icons/contact_us.svg',
                              // Replace with your SVG asset path
                              width: 40, // Set the width of the SVG icon
                              height: 40, // Set the height of the SVG icon
                            ),
                            title: Text(translate('Contact Us'),
                                style: CustomTextStyle.GraphikRegular(
                                    16, AppColors.black)),
                            trailing: SvgPicture.asset(
                              'assets/icons/right_icon.svg',
                              // Replace with your SVG asset path
                              width: 15, // Set the width of the SVG icon
                              height: 15, // Set the height of the SVG icon
                            ),
                            onTap: () {
                              Get.to(ContactUsScreen());
                            },
                          ),

                          Padding(
                            padding: const EdgeInsets.only(
                                right: 15.0, left: 15.0, top: 5.0, bottom: 5.0),
                            child: Container(
                              height: 1,
                              color: AppTheme().lineColor,
                            ),
                          ),

                          // Rate Us
                          ListTile(
                            leading: SvgPicture.asset(
                              'assets/icons/rate_us.svg',
                              // Replace with your SVG asset path
                              width: 40, // Set the width of the SVG icon
                              height: 40, // Set the height of the SVG icon
                            ),
                            title: Text(translate('Rate Us'),
                                style: CustomTextStyle.GraphikRegular(
                                    16, AppColors.black)),
                            trailing: SvgPicture.asset(
                              'assets/icons/right_icon.svg',
                              // Replace with your SVG asset path
                              width: 15, // Set the width of the SVG icon
                              height: 15, // Set the height of the SVG icon
                            ),
                            onTap: () async {
                              // Navigate to Notifications page
                              //Navigator.of(context).pushNamed("/notification");
                              if (packageName == null) {
                                return;
                              }

                              if (io.Platform.isAndroid) {
                                // For Android, use the Play Store link
                                url =
                                    'https://play.google.com/store/apps/details?id=com.decont.android';
                              } else if (io.Platform.isIOS) {
                                // For iOS, use the App Store link
                                //url = 'https://apps.apple.com/in/app/sourcing-sathi/id6739795594';
                                url =
                                    'https://apps.apple.com/app/id$packageName';
                              } else {
                                throw 'Unsupported platform';
                              }

                              if (url != null && await canLaunch(url!)) {
                                await launch(url!);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                          ),

                          Padding(
                            padding: const EdgeInsets.only(
                                right: 15.0, left: 15.0, top: 5.0, bottom: 5.0),
                            child: Container(
                              height: 1,
                              color: AppTheme().lineColor,
                            ),
                          ),

                          // About Us
                          ListTile(
                            leading: SvgPicture.asset(
                              'assets/icons/about_us.svg',
                              // Replace with your SVG asset path
                              width: 40, // Set the width of the SVG icon
                              height: 40, // Set the height of the SVG icon
                            ),
                            title: Text(translate('About Us'),
                                style: CustomTextStyle.GraphikRegular(
                                    16, AppColors.black)),
                            trailing: SvgPicture.asset(
                              'assets/icons/right_icon.svg',
                              // Replace with your SVG asset path
                              width: 15, // Set the width of the SVG icon
                              height: 15, // Set the height of the SVG icon
                            ),
                            onTap: () {
                              Get.to(AboutUsScreen());
                            },
                          ),

                          Padding(
                            padding: const EdgeInsets.only(
                                right: 15.0, left: 15.0, top: 5.0, bottom: 5.0),
                            child: Container(
                              height: 1,
                              color: AppTheme().lineColor,
                            ),
                          ),

                          // Deactivate Account
                          ListTile(
                            leading: SvgPicture.asset(
                              'assets/icons/deactivate_account.svg',
                              width: 40,
                              height: 40,
                            ),
                            title: Text(translate('Deactivate Account'),
                                style: CustomTextStyle.GraphikRegular(
                                    16, AppColors.black)),
                            trailing: SvgPicture.asset(
                              'assets/icons/right_icon.svg',
                              width: 15,
                              height: 15,
                            ),
                            onTap: () {
                              _showDeactivateAccountDialog(context);
                            },
                          ),

                          // Terms & Conditions
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              //logout
              Padding(
                padding: const EdgeInsets.only(
                    right: 10.0, left: 10.0, bottom: 10.0),
                child: Column(
                  children: [
                    // Profile Details Card
                    Card(
                      color: AppColors.white,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logout
                          ListTile(
                            leading: SvgPicture.asset(
                              'assets/icons/logout.svg',
                              // Replace with your SVG asset path
                              width: 40, // Set the width of the SVG icon
                              height: 40, // Set the height of the SVG icon
                            ),
                            title: Text(translate('Logout'),
                                style: CustomTextStyle.GraphikRegular(
                                    16, AppColors.black)),
                            onTap: () {
                              // Handle logout action
                              _showErrorDialog(context);
                            },
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
      ),
    );
  }
}

void _showDeactivateAccountDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppTheme().whiteColor,
        surfaceTintColor: AppTheme().whiteColor,
        title: Text(
          'Deactivate Account',
          style: CustomTextStyle.GraphikMedium(18, AppColors.black),
        ),
        content: Text(
          'Do you really want to Deactivate Account? \nYour all data will be erased.',
          style: CustomTextStyle.GraphikRegular(14, AppColors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Action for changing number
              Navigator.pop(context); // Close the dialog
              // Add your logic to change number here
            },
            child: Text('No',
                style:
                    CustomTextStyle.GraphikMedium(14, AppColors.colorPrimary)),
          ),
          TextButton(
            onPressed: () async {
              // Action for signing up

              _Deactivate(context);
            },
            child: Text('Yes',
                style:
                    CustomTextStyle.GraphikMedium(14, AppColors.colorPrimary)),
          ),
        ],
      );
    },
  );
}

Future<void> _Deactivate(BuildContext context) async {
  final url = Uri.parse(baseUrl); // Replace with your API endpoint

  final Map<String, String> headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Authorization':
        'Bearer $user_token', // Include the user token if necessary
  };

  final Map<String, String> body = {
    'view': 'deactive', // Pass the car ID to the API
    'custID': '$userID', // Pass the car ID to the API
  };

  try {
    // Make the API call
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log('Response data: $data');

      if (data['status'] == 'success') {
        // Successfully updated favorite status
        SharedPreferences preferences = await SharedPreferences.getInstance();
        await preferences.clear();
        Navigator.of(context)
            .pushNamedAndRemoveUntil("/login", (route) => false);
      } else {
        // Handle error returned by the API
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            data['message'],
            style: CustomTextStyle.GraphikMedium(16, AppColors.white),
          )),
        );
      }
    } else {
      // Handle HTTP error responses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'Error: ${response.reasonPhrase}',
          style: CustomTextStyle.GraphikMedium(16, AppColors.white),
        )),
      );
    }
  } catch (e) {
    // Handle exceptions
    log('Error updating favorite status: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
        'Error: ${e}',
        style: CustomTextStyle.GraphikMedium(16, AppColors.white),
      )),
    );
  }
}

void _showErrorDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        title: Text(
          'Logout',
          style: CustomTextStyle.GraphikMedium(18, AppColors.black),
        ),
        content: Text(
          'Do you really want to logout?',
          style: CustomTextStyle.GraphikRegular(14, AppColors.colorPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Action for changing number
              Navigator.pop(context); // Close the dialog
              // Add your logic to change number here
            },
            child: Text('No',
                style:
                    CustomTextStyle.GraphikMedium(14, AppColors.colorPrimary)),
          ),
          TextButton(
            onPressed: () async {
              // Action for signing up
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              await preferences.clear();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil("/login", (route) => false);
            },
            child: Text('Yes',
                style:
                    CustomTextStyle.GraphikMedium(14, AppColors.colorPrimary)),
          ),
        ],
      );
    },
  );
}
