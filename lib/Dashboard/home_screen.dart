import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io' show Platform;
import 'package:Decont/AskQuestions/que_ans_list_screen.dart';
import 'package:Decont/ContactUs/contact_us_screen.dart';
import 'package:Decont/Help_and_Support/help_and_support_screen.dart';
import 'package:Decont/MyCartList/cart_list_screen.dart';
import 'package:Decont/ReferScreen/refer_screen.dart';
import 'package:Decont/SelectLanguage/select_language.dart';
import 'package:Decont/login/login_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../CustomeTextStyle/custometextstyle.dart';
import '../Notification/notification_screen.dart';
import '../OrderList/order_list_screen.dart';
import '../SearchScreen/search_screen.dart';
import '../WebviewPage/WebviewScreen.dart';
import '../theme/AppTheme.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../BaseUrl.dart';
import '../CategoryList/category_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../MyWallet/wallet_history_Screen.dart';
import '../myaccount/my_account_screen.dart';
import '../productDetails/product_details_screen.dart';

String? name = '';
String? email = '';
String? mobile = '';
String? user_token = '';
String? image = '';
int cart_count = 0;
String version = '';
String? userID = '';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> bannerImagesList = [];
  List<Map<String, dynamic>> newArrivalsList = [];
  List<Map<String, dynamic>> homeCategoryList = [];
  List<dynamic> products = [];
  List<Map<String, dynamic>> cart_product_list = [];

  List<Map<String, dynamic>> categoryProducts = [];
  final Map<String, int> cart = {};
  bool _isExiting = false;
  String currentLangCode = 'en';
  String? fcmToken;
  String? _walletBalance;
  String? special_zone;
  String? customer_membership;
  String img_refer = '';
  bool isLoading = false;
  String? packageName;
  String? url;
  int _currentIndex = 0;
  bool _isFavorite = false;
  int _selectedIndex = 0;

  // final CarouselController _carouselController = CarouselController() ;

  Map<String, String> localizedStrings = {};


  // final List<Widget> _pages = [
  //   const Home(),
  //   ReferScreen(),
  //   WishListScreen(),
  //   NotificationsPage(onBack: () {}),
  //   MyAccountPage(onBack: () {})
  // ];

  // void _onItemTapped(int index) {
  //   if (index >= 0 && index < _pages.length) {
  //     if (index == 3) {
  //       if (userID == null || userID!.isEmpty) {
  //         showDialog(
  //           context: context,
  //           builder: (context) {
  //             return AlertDialog(
  //               backgroundColor: AppColors.white,
  //               surfaceTintColor: AppColors.white,
  //               title: Text(
  //                 'Login Required',
  //                 style: CustomTextStyle.GraphikMedium(18, AppColors.black),
  //               ),
  //               content: Text(
  //                 'Please log in.',
  //                 style: CustomTextStyle.GraphikRegular(14, AppColors.black),
  //               ),
  //               actions: [
  //                 TextButton(
  //                   onPressed: () {
  //                     Navigator.pop(context); // Close the dialog
  //                   },
  //                   child: Text(
  //                     'Cancel',
  //                     style: CustomTextStyle.GraphikMedium(
  //                         14, AppColors.colorPrimary),
  //                   ),
  //                 ),
  //                 TextButton(
  //                   onPressed: () {
  //                     Get.to(LoginScreen());
  //                   },
  //                   child: Text(
  //                     'Login',
  //                     style: CustomTextStyle.GraphikMedium(
  //                         14, AppColors.colorPrimary),
  //                   ),
  //                 ),
  //               ],
  //             );
  //           },
  //         );
  //       } else {
  //         Get.to(NotificationsPage(onBack: () {}));
  //       }
  //     } else {
  //       setState(() {
  //         _selectedIndex = index;
  //       });
  //     }
  //   }
  // }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    _requestPermissions();
    _initializeFCM();

    _loadCurrentLanguagePreference();
    _initializeData();
  }

  Future<void> _initializeFCM() async {}

  Future<void> _requestPermissions() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("Notification permission granted");
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print("Notification permission denied");
      // Optionally, open app settings if the user denies permission
      await _openAppSettings();
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("Notification permission provisionally granted");
    } else {
      print("User hasn't made a decision yet");
    }
  }

  Future<void> _getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      packageName = packageInfo.packageName;
      version = packageInfo.version;
    });
  }

  // Open the app settings page
  Future<void> _openAppSettings() async {
    bool opened = await openAppSettings();
    if (opened) {
      print("App settings opened. Please enable notifications.");
    } else {
      print("Failed to open app settings.");
    }
  }

  /*Future<void> _getToken() async {
    // Get the FCM token
    fcmToken = await FirebaseMessaging.instance.getToken();
    //fcmToken = '';
    print("FCM Token: $fcmToken");
  }*/

  /*Future<void> _getToken() async {
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken != null) {
        print("FCM Token: $fcmToken");
      } else {
        print("FCM Token not found");
      }
    } catch (e) {
      print("Error fetching FCM token: $e");
    }
  }*/
  // Future<void> _toggleFavorite() async {
  //   // Prepare the API call
  //   final url =
  //   Uri.parse(add_remove_wishlist); // Replace with your API endpoint
  //   final Map<String, String> headers = {
  //     'Content-Type': 'application/x-www-form-urlencoded',
  //     'Authorization': 'Bearer $user_token',
  //     // Include the user token if necessary
  //   };
  //   /*final body = jsonEncode({
  //     'product_id': widget.car.id, // Pass the car ID to the API
  //     'flag': _isFavorite, // Pass the new favorite state
  //   });*/
  //
  //   final Map<String, String> body = {
  //     'product_id':
  //     _ser, // Pass the car ID to the API
  //     'flag': _isFavorite.toString(), // Pass the new favorite state
  //   };
  //
  //   try {
  //     // Make the API call
  //     final response = await http.post(url, headers: headers, body: body);
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       if (data['status'] == 'success') {
  //         // Successfully updated favorite status
  //         log('Favorite status updated: ${data['message']}');
  //
  //         setState(() {
  //           _isFavorite = !_isFavorite; // Toggle the favorite state
  //           //widget.car.inWishlist = _isFavorite; // Update the car's wishlist state locally
  //         });
  //       } else {
  //         // Handle error returned by the API
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //               content: Text(
  //                 data['message'],
  //                 style: CustomTextStyle.GraphikMedium(16, AppColors.white),
  //               )),
  //         );
  //       }
  //     } else {
  //       // Handle HTTP error responses
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //             content: Text(
  //               'Error: ${response.reasonPhrase}',
  //               style: CustomTextStyle.GraphikMedium(16, AppColors.white),
  //             )),
  //       );
  //     }
  //   } catch (e) {
  //     // Handle exceptions
  //     log('Error updating favorite status: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('An unexpected error occurred.',
  //             style: CustomTextStyle.GraphikMedium(16, AppColors.white)),
  //       ),
  //     );
  //   }
  // }

  Future<void> _getToken() async {
    try {
      // Check if platform is iOS or Android
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // Get the APNs token for iOS
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();

        final _mess = FirebaseMessaging.instance;
        if (apnsToken != null) {
          print("APNs Token: $apnsToken");
          fcmToken = apnsToken;
        } else {
          print("APNs Token not found");
        }
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        // Get the FCM token for Android
        String? FcmToken = await FirebaseMessaging.instance.getToken();

        if (FcmToken != null) {
          print("FCM Token: $FcmToken");
          fcmToken = FcmToken;
        } else {
          print("FCM Token not found");
        }
      } else {
        print("Unsupported platform");
      }
    } catch (e) {
      print("Error fetching token: $e");
    }
  }

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
      email = prefs.getString('email') ?? '';
      mobile = prefs.getString('mobile') ?? '';
      user_token = prefs.getString('user_token') ?? '';
      userID = prefs.getString('userID') ?? '';
      image = prefs.getString('image') ?? '';
      cart_count = prefs.getInt('cart_count')!;
    });
    print('Stored user_token: $user_token');
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;
    });

    await _getToken();
    await _dashboardData();
    await _getPackageInfo();
  }

  Future<void> _dashboardData() async {
    // if (isLoading) return; // Prevent multiple requests when already loading
    setState(() {
      isLoading = true; // Set loading to true when starting the API call
    });

    final url = Uri.parse(baseUrl); // Replace with your API endpoint
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token',
    };

    final body = {
      'view': 'dashboard',
      'token': fcmToken ?? '',
      'custID': userID.toString(),
      'app_version': version,
      'deviceID': '',
      'os_type': Platform.operatingSystem,
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['result'] == 1) {
          final prefs = await SharedPreferences.getInstance();

          // Safely extract values with null checks
          await prefs.setString(
              'wallet_amount',
              data['data']['customer_wallet'] ??
                  '0.00'); // Default to empty string if null
          await prefs.setInt(
              'cart_count', int.tryParse(data['data']['cart_count']) ?? 0);

          cart_product_list.clear();

          setState(() {
            _walletBalance = data['data']['customer_wallet'] ?? '0.00';
            special_zone = data['data']['special_zone'] ?? '';
            customer_membership = data['data']['customer_membership'] ?? '';
            cart_count = int.tryParse(data['data']['cart_count']) ?? 0;

            img_refer = data['data']['img_refer'] ?? '';
            bannerImagesList = List<Map<String, dynamic>>.from(
                (data['data']['banners'] as List).map((item) => {
                      'image': item['image'],
                      'catID': item['catID'],
                    }));

            homeCategoryList = List<Map<String, dynamic>>.from(
                (data['data']['home_category_list'] as List).map((item) => {
                      'catID': item['catID'],
                      'name': item['name'],
                      'icon': item['icon'],
                      'subcat': item['subcat'],
                    }));

            products = List<Map<String, dynamic>>.from(
                (data['data']['products'] as List<dynamic>? ?? []).map((item) {
              return {
                'catID': item['catID'],
                'category_name': item['category_name'],
                'category_subcate': item['category_subcate'],
                'category_banner': item['category_banner'],
                'category_products': List<Map<String, dynamic>>.from(
                    (item['category_products'] as List<dynamic>? ?? [])
                        .map((subItem) {
                  return {
                    'productID': subItem['productID'],
                    'name': subItem['name'],
                    'image': subItem['image'],
                    'price': subItem['price'],
                    'discount': subItem['discount'],
                    'without_gst_mrp': subItem['without_gst_mrp'],
                    'without_gst_price': subItem['without_gst_price'],
                    'without_gst_disc': subItem['without_gst_disc'],
                    'review_count': subItem['review_count'],
                    'review_msg': subItem['review_msg'],
                  };
                }))
              };
            }));

            cart_product_list.addAll((data['data']['cart_product_list'] as List)
                .map((item) => {
                      'productID': item['productID'],
                      'name': item['name'],
                      'image': item['image'],
                      'mrp': item['mrp'],
                      'price': item['price'],
                      'discount': item['discount'],
                      'quantity': item['quantity'],
                      'without_gst_price': item['without_gst_price'],
                      'without_gst_mrp': item['without_gst_mrp'],
                      'without_gst_disc': item['without_gst_disc'],
                      'gst_price_text': item['gst_price_text'],
                    })
                .toList());
          });

          log('cart_product_list: $data');
        } else {
          _showError(data['message']);
        }
      } else {
        _showError('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      log('Error updating dashboard data: $e');
      _showError('An unexpected error occurred.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading =
              false; // Set loading to false when the request is complete
        });
      }
    }
  }

  void _showError(String message) {
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
    // Get screen width and height
    double screenWidth = MediaQuery.of(context).size.width;

    // Define dynamic sizing based on screen width
    double iconSize = screenWidth < 350 ? 40.0 : 50.0;
    void _showErrorDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppTheme().whiteColor,
            surfaceTintColor: AppTheme().whiteColor,
            title: Text(
              'Logout',
              style: CustomTextStyle.GraphikMedium(18, AppColors.black),
            ),
            content: Text(
              'Do you really want to logout?',
              style: CustomTextStyle.GraphikRegular(14, AppColors.black),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('No',
                    style: CustomTextStyle.GraphikMedium(
                        14, AppColors.colorPrimary)),
              ),
              TextButton(
                onPressed: () async {
                  SharedPreferences preferences =
                      await SharedPreferences.getInstance();
                  await preferences.clear();
                  Get.to(const LoginScreen());
                },
                child: Text('Yes',
                    style: CustomTextStyle.GraphikMedium(
                        14, AppColors.colorPrimary)),
              ),
            ],
          );
        },
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (_isExiting) {
          return true;
        } else {
          _isExiting = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Press back again to exit",
                    style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
          );
          /*Fluttertoast.showToast(
            msg: "Press back again to exit",
            toastLength: Toast.LENGTH_SHORT,
          );*/

          // Reset the exit state after 2 seconds
          Timer(const Duration(seconds: 2), () {
            _isExiting = false;
          });

          // Prevent exit
          return false;
        }
      },
      child: Scaffold(
        extendBody: false,
        drawer: Drawer(
          backgroundColor: AppColors.white,
          surfaceTintColor: AppColors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  if (userID == null || userID!.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: AppColors.white,
                          surfaceTintColor: AppColors.white,
                          title: Text(
                            'Login Required',
                            style: CustomTextStyle.GraphikMedium(
                                18, AppColors.black),
                          ),
                          content: Text(
                            'Please log in to access your account.',
                            style: CustomTextStyle.GraphikRegular(
                                14, AppColors.black),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Cancel',
                                style: CustomTextStyle.GraphikMedium(
                                    14, AppColors.colorPrimary),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.to(LoginScreen());
                              },
                              child: Text(
                                'Login',
                                style: CustomTextStyle.GraphikMedium(
                                    14, AppColors.colorPrimary),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    // If user is logged in, proceed to show user profile or navigate to the account page
                    Navigator.of(context)
                        .pop(); // Close the drawer or any other popup

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyAccountPage(
                          onBack: () {
                            setState(() {
                              // Handle onBack logic
                            });
                          },
                        ),
                      ),
                    );
                  }
                },
                child: SizedBox(
                  height: userID == null || userID!.isEmpty
                      ? 180.0
                      : 180.0, // Height based on user login status
                  child: DrawerHeader(
                    decoration: const BoxDecoration(
                      color: AppColors.colorPrimary,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                userID == null || userID!.isEmpty
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$name', // Display name if available
                                            style:
                                                CustomTextStyle.GraphikRegular(
                                                    14, AppColors.white),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 5.0),
                                          GestureDetector(
                                            onTap: () {
                                              Get.to(LoginScreen());
                                            },
                                            child: Text(
                                              'Login', // Text for users who are not logged in
                                              style:
                                                  CustomTextStyle.GraphikMedium(
                                                      16, AppColors.white),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundImage: '$image'.isNotEmpty
                                                ? NetworkImage('$image')
                                                : const AssetImage(
                                                        'assets/images/profile.png')
                                                    as ImageProvider,
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '$name', // Display user's name
                                                style: CustomTextStyle
                                                    .GraphikMedium(
                                                        16, AppColors.white),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 5.0),
                                              Text(
                                                '+91 $mobile', // Display user's mobile number
                                                style: CustomTextStyle
                                                    .GraphikRegular(
                                                        14, AppColors.white),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_outlined,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        const SizedBox(height: 15.0),
                      ],
                    ),
                  ),
                ),
              ),

              /*GestureDetector(
                onTap: () {
                  // Add your click event logic here
                  // For example, navigate to another page or show a dialog
                  Navigator.of(context).pop();

                  Navigator.push(
                    context as BuildContext,
                    MaterialPageRoute(
                      builder: (context) => MyAccountPage(
                        onBack: () {
                          setState(() {

                          });
                        },
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 250.0, // Set your desired height here
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: AppTheme().secondaryColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: '$image' != null &&
                                      '$image'.isNotEmpty
                                      ? NetworkImage('$image')
                                      : AssetImage('assets/images/profile.png')
                                  as ImageProvider,
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_forward_ios_outlined,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        SizedBox(height: 15.0),
                        Text(
                          '$name',
                          style: TextStyle(
                            color: AppTheme().whiteColor,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          '+91 $mobile',
                          style: TextStyle(
                            color: AppTheme().whiteColor,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),*/

              // if (userID != null && userID!.isNotEmpty) ...[
              //   if (customer_membership == 'Yes') ...[
              //     ListTile(
              //       leading: SvgPicture.asset(
              //         'assets/icons/my_subscription.svg',
              //         height: 30.0,
              //         width: 30.0,
              //       ), // Icon
              //       title: Text(
              //         'My Subscription',
              //         style: Theme.of(context)
              //             .textTheme
              //             .displayMedium!
              //             .copyWith(color: AppColors.black),
              //       ),
              //       dense: true, // Reduces vertical spacing
              //
              //       onTap: () {
              //         Navigator.of(context).pop();
              //         //Navigator.of(context).pushNamed("/my_cart");
              //         Navigator.of(context).push(PageRouteBuilder(
              //           pageBuilder: (context, animation, secondaryAnimation) {
              //             // Define the target page (Wish List screen)
              //             return SubscriberListScreen();
              //           },
              //           transitionsBuilder:
              //               (context, animation, secondaryAnimation, child) {
              //             // Define the right-to-left transition
              //             const begin =
              //                 Offset(1.0, 0.0); // Start offscreen to the right
              //             const end = Offset.zero; // End at the screen's center
              //             const curve = Curves.easeInOut; // Animation curve
              //
              //             var tween = Tween(begin: begin, end: end)
              //                 .chain(CurveTween(curve: curve));
              //             var offsetAnimation = animation.drive(tween);
              //
              //             return SlideTransition(
              //               position: offsetAnimation,
              //               child: child,
              //             );
              //           },
              //         ));
              //       },
              //     ),
              //   ] else ...[
              //     ListTile(
              //       leading: SvgPicture.asset(
              //         'assets/icons/my_subscription_2.svg',
              //         height: 30.0,
              //         width: 30.0,
              //       ), // Icon
              //       title: Text(
              //         'Apna Decont',
              //         style: Theme.of(context)
              //             .textTheme
              //             .titleSmall!
              //             .copyWith(color: AppColors.tex),
              //       ),
              //       dense: true, // Reduces vertical spacing
              //
              //       onTap: () {
              //         Navigator.of(context).pop();
              //         //Navigator.of(context).pushNamed("/my_cart");
              //         // Navigator.of(context).push(PageRouteBuilder(
              //         //   pageBuilder: (context, animation, secondaryAnimation) {
              //         //     // Define the target page (Wish List screen)
              //         //     return WebViewPage();
              //         //   },
              //         //   transitionsBuilder:
              //         //       (context, animation, secondaryAnimation, child) {
              //         //     // Define the right-to-left transition
              //         //     const begin =
              //         //         Offset(1.0, 0.0); // Start offscreen to the right
              //         //     const end = Offset.zero; // End at the screen's center
              //         //     const curve = Curves.easeInOut; // Animation curve
              //         //
              //         //     var tween = Tween(begin: begin, end: end)
              //         //         .chain(CurveTween(curve: curve));
              //         //     var offsetAnimation = animation.drive(tween);
              //         //
              //         //     return SlideTransition(
              //         //       position: offsetAnimation,
              //         //       child: child,
              //         //     );
              //         //   },
              //         // ));
              //       },
              //     ),
              //   ],
              // ],

              ListTile(
                leading: SvgPicture.asset(
                  'assets/decont_drawer/home.svg',
                  height: 22.0,
                  width: 22.0,
                ), // Icon
                title: Text(
                  translate('Home'),
                  style: CustomTextStyle.GraphikMedium(
                      14, AppColors.secondTextColor),
                ),
                dense: true, // Reduces vertical spacing

                onTap: () {
                  Navigator.of(context).pop();
                },
              ),

              //deal of the day
              ListTile(
                leading: SvgPicture.asset(
                  'assets/decont_drawer/shopBycat.svg',
                  height: 22.0,
                  width: 22.0,
                ), // Icon
                title: Text(
                  translate('Shop By Categories'),
                  style: CustomTextStyle.GraphikMedium(
                      14, AppColors.secondTextColor),
                ),
                dense: true, // Reduces vertical spacing

                onTap: () {
                  Navigator.pop(context);
                  Get.to(CategoryPage(catID: ''));
                },
              ),

              ListTile(
                leading: SvgPicture.asset(
                  'assets/decont_drawer/dealOfTheDay.svg',
                  height: 22.0,
                  width: 22.0,
                ), // Icon
                title: Text(
                  translate('Deal Of The Day'),
                  style: CustomTextStyle.GraphikMedium(
                      14, AppColors.secondTextColor),
                ),
                dense: true, // Reduces vertical spacing

                onTap: () {
                  Navigator.of(context).pop();
                  //Navigator.of(context).pushNamed("/order_list");
                },
              ),
              Container(
                height: 1,
                color: AppTheme().lineColor,
              ),

              ListTile(
                  leading: SvgPicture.asset(
                    'assets/decont_drawer/myOrder.svg',
                    height: 22.0,
                    width: 22.0,
                  ), // Icon
                  title: Text(
                    translate('My Order'),
                    style: CustomTextStyle.GraphikMedium(
                        14, AppColors.secondTextColor),
                  ),
                  dense: true, // Reduces vertical spacing

                  onTap: () {
                    Navigator.of(context).pop();
                    if (userID == null || userID!.isEmpty) {
                      // If userID is null or empty, show a message or navigate to the login screen
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: AppTheme().whiteColor,
                            surfaceTintColor: AppTheme().whiteColor,
                            title: Text(
                              'Login Required',
                              style: CustomTextStyle.GraphikMedium(
                                  22, AppColors.black),
                            ),
                            content: Text(
                              'Please log in to access your orders.',
                              style: CustomTextStyle.GraphikRegular(
                                  18, AppColors.black),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close the dialog
                                },
                                child: Text(
                                  'Cancel',
                                  style: CustomTextStyle.GraphikMedium(
                                      16, AppColors.colorPrimary),
                                ),
                              ),
                              TextButton(
                                  onPressed: () {
                                    Get.to(LoginScreen());
                                  },
                                  child: Text(
                                    'Login',
                                    style: CustomTextStyle.GraphikMedium(
                                        16, AppColors.colorPrimary),
                                  )),
                            ],
                          );
                        },
                      );
                    } else {
                      Get.to(OrderListScreen(
                        onBack: () {},
                      ));
                      //Navigator.pushNamed(context, "/order_list");
                    }
                  }),

              //refer
              ListTile(
                leading: SvgPicture.asset(
                  'assets/decont_drawer/myAccount.svg',
                  height: 22.0,
                  width: 22.0,
                ), // Icon
                title: Text(
                  translate('My Account'),
                  style: CustomTextStyle.GraphikMedium(
                      14, AppColors.secondTextColor),
                ),
                dense: true, // Reduces vertical spacing

                onTap: () {
                  Navigator.of(context).pop();
                  if (userID == null || userID!.isEmpty) {
                    // If userID is null or empty, show a message or navigate to the login screen
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: AppTheme().whiteColor,
                          surfaceTintColor: AppTheme().whiteColor,
                          title: Text(
                            'Login Required',
                            style: CustomTextStyle.GraphikMedium(
                                22, AppColors.black),
                          ),
                          content: Text(
                            'Please log in to access your account.',
                            style: CustomTextStyle.GraphikRegular(
                                18, AppColors.black),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog
                              },
                              child: Text(
                                'Cancel',
                                style: CustomTextStyle.GraphikMedium(
                                    16, AppColors.colorPrimary),
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  Get.to(LoginScreen());
                                },
                                child: Text(
                                  'Login',
                                  style: CustomTextStyle.GraphikMedium(
                                      16, AppColors.colorPrimary),
                                )),
                          ],
                        );
                      },
                    );
                  } else {
                    Get.to(MyAccountPage(onBack: () {}));
                    Navigator.pushNamed(context, "/my_account");
                  }
                },
              ),

              //wallet
              ListTile(
                leading: SvgPicture.asset(
                  'assets/decont_drawer/myWallet.svg',
                  height: 22.0,
                  width: 22.0,
                ), // Icon
                title: Text(
                  translate('My Wallet'),
                  style: CustomTextStyle.GraphikMedium(
                      14, AppColors.secondTextColor),
                ),
                dense: true, // Reduces vertical spacing

                onTap: () {
                  Navigator.of(context).pop();
                  if (userID == null || userID!.isEmpty) {
                    // If userID is null or empty, show a message or navigate to the login screen
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: AppTheme().whiteColor,
                          surfaceTintColor: AppTheme().whiteColor,
                          title: Text(
                            'Login Required',
                            style: CustomTextStyle.GraphikMedium(
                                22, AppColors.black),
                          ),
                          content: Text(
                            'Please log in to access your wallet.',
                            style: CustomTextStyle.GraphikRegular(
                                18, AppColors.black),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog
                              },
                              child: Text(
                                'Cancel',
                                style: CustomTextStyle.GraphikMedium(
                                    16, AppColors.colorPrimary),
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  Get.to(LoginScreen());
                                },
                                child: Text(
                                  'Login',
                                  style: CustomTextStyle.GraphikMedium(
                                      16, AppColors.colorPrimary),
                                )),
                          ],
                        );
                      },
                    );
                  } else {
                    Get.to(WalletHistoryScreen());
                    // Navigator.pushNamed(context, "/wallet_history");
                  }
                },
              ),

              ListTile(
                leading: SvgPicture.asset(
                  'assets/decont_drawer/myCart.svg',
                  height: 22.0,
                  width: 22.0,
                ), // Icon
                title: Text(
                  translate('My Cart'),
                  style: CustomTextStyle.GraphikMedium(
                      14, AppColors.secondTextColor),
                ),
                dense: true,

                onTap: () {
                  Navigator.of(context).pop();
                  if (userID == null || userID!.isEmpty) {
                    // If userID is null or empty, show a message or navigate to the login screen
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: AppTheme().whiteColor,
                          surfaceTintColor: AppTheme().whiteColor,
                          title: Text(
                            'Login Required',
                            style: CustomTextStyle.GraphikMedium(
                                22, AppColors.black),
                          ),
                          content: Text(
                            'Please log in to access your cart.',
                            style: CustomTextStyle.GraphikRegular(
                                18, AppColors.black),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog
                              },
                              child: Text(
                                'Cancel',
                                style: CustomTextStyle.GraphikMedium(
                                    16, AppColors.colorPrimary),
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  Get.to(LoginScreen());
                                },
                                child: Text(
                                  'Login',
                                  style: CustomTextStyle.GraphikMedium(
                                      16, AppColors.colorPrimary),
                                )),
                          ],
                        );
                      },
                    );
                  } else {
                    Get.to(
                      MyCartScreen(),
                    );
                    //Navigator.pushNamed(context, "/my_cart");
                  }
                },
              ),

              ListTile(
                leading: SvgPicture.asset(
                  'assets/decont_drawer/myWishlist.svg',
                  height: 22.0,
                  width: 22.0,
                ), // Icon
                title: Text(
                  translate('My Wishlist'),
                  style: CustomTextStyle.GraphikMedium(
                      14, AppColors.secondTextColor),
                ),
                dense: true, // Reduces vertical spacing

                onTap: () {
                  Navigator.of(context).pop();
                  if (userID == null || userID!.isEmpty) {
                    // If userID is null or empty, show a message or navigate to the login screen
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: AppTheme().whiteColor,
                          surfaceTintColor: AppTheme().whiteColor,
                          title: Text(
                            'Login Required',
                            style: CustomTextStyle.GraphikMedium(
                                22, AppColors.black),
                          ),
                          content: Text(
                            'Please log in to access your wishlist.',
                            style: CustomTextStyle.GraphikRegular(
                                18, AppColors.black),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog
                              },
                              child: Text(
                                'Cancel',
                                style: CustomTextStyle.GraphikMedium(
                                    16, AppColors.colorPrimary),
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  Get.to(LoginScreen());
                                },
                                child: Text(
                                  'Login',
                                  style: CustomTextStyle.GraphikMedium(
                                      16, AppColors.colorPrimary),
                                )),
                          ],
                        );
                      },
                    );
                  } else {
                    Get.back();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Wishlist feature is coming soon!'),
                      ),
                    );

                    //Navigator.pushNamed(context, "/wish_list");
                  }
                },
              ),
              Container(
                height: 1,
                color: AppTheme().lineColor,
              ),
              ListTile(
                leading: SvgPicture.asset(
                  'assets/decont_drawer/bulkOrder.svg',
                  height: 22.0,
                  width: 22.0,
                ), // Icon
                title: Text(
                  translate('Bulk Order'),
                  style: CustomTextStyle.GraphikMedium(
                      14, AppColors.secondTextColor),
                ),
                dense: true, // Reduces vertical spacing

                onTap: () {
                  Navigator.of(context).pop();
                  if (userID == null || userID!.isEmpty) {
                    // If userID is null or empty, show a message or navigate to the login screen
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: AppTheme().whiteColor,
                          surfaceTintColor: AppTheme().whiteColor,
                          title: Text(
                            'Login Required',
                            style: CustomTextStyle.GraphikMedium(
                                22, AppColors.black),
                          ),
                          content: Text(
                            'Please log in to access your bulk order.',
                            style: CustomTextStyle.GraphikRegular(
                                18, AppColors.black),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog
                              },
                              child: Text(
                                'Cancel',
                                style: CustomTextStyle.GraphikMedium(
                                    16, AppColors.colorPrimary),
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  Get.to(LoginScreen());
                                },
                                child: Text(
                                  'Login',
                                  style: CustomTextStyle.GraphikMedium(
                                      16, AppColors.colorPrimary),
                                )),
                          ],
                        );
                      },
                    );
                  } else {
                    Get.to(WebViewExample(
                      title: 'Bulk Order',
                      link: 'bulkorder.html',
                    ));
                  }
                },
              ),

              ListTile(
                leading: SvgPicture.asset(
                  'assets/decont_drawer/quotation.svg',
                  height: 22.0,
                  width: 22.0,
                ), // Icon
                title: Text(
                  translate('Quotation'),
                  style: CustomTextStyle.GraphikMedium(
                      14, AppColors.secondTextColor),
                ),
                dense: true, // Reduces vertical spacing

                onTap: () {
                  Navigator.of(context).pop();
                  if (userID == null || userID!.isEmpty) {
                    // If userID is null or empty, show a message or navigate to the login screen
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: AppTheme().whiteColor,
                          surfaceTintColor: AppTheme().whiteColor,
                          title: Text(
                            'Login Required',
                            style: CustomTextStyle.GraphikMedium(
                                22, AppColors.black),
                          ),
                          content: Text(
                            'Please log in to access your quotation.',
                            style: CustomTextStyle.GraphikRegular(
                                18, AppColors.black),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog
                              },
                              child: Text(
                                'Cancel',
                                style: CustomTextStyle.GraphikMedium(
                                    16, AppColors.colorPrimary),
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  Get.to(LoginScreen());
                                },
                                child: Text(
                                  'Login',
                                  style: CustomTextStyle.GraphikMedium(
                                      16, AppColors.colorPrimary),
                                )),
                          ],
                        );
                      },
                    );
                  } else {
                    Get.back();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Quotation feature is coming soon!'),
                      ),
                    );
                    //  Navigator.pushNamed(context, "/quotation");
                  }
                },
              ),

              ListTile(
                leading: SvgPicture.asset(
                  'assets/decont_drawer/referEarn.svg',
                  height: 22.0,
                  width: 22.0,
                ), // Icon
                title: Text(
                  translate('Refer & Earn'),
                  style: CustomTextStyle.GraphikMedium(
                      14, AppColors.secondTextColor),
                ),
                dense: true, // Reduces vertical spacing

                onTap: () {
                  Navigator.of(context).pop();
                  if (userID == null || userID!.isEmpty) {
                    // If userID is null or empty, show a message or navigate to the login screen
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: AppTheme().whiteColor,
                          surfaceTintColor: AppTheme().whiteColor,
                          title: Text(
                            'Login Required',
                            style: CustomTextStyle.GraphikMedium(
                                22, AppColors.black),
                          ),
                          content: Text(
                            'Please log in to access your refer & earn.',
                            style: CustomTextStyle.GraphikRegular(
                                18, AppColors.black),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog
                              },
                              child: Text(
                                'Cancel',
                                style: CustomTextStyle.GraphikMedium(
                                    16, AppColors.colorPrimary),
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  Get.to(LoginScreen());
                                },
                                child: Text(
                                  'Login',
                                  style: CustomTextStyle.GraphikMedium(
                                      16, AppColors.colorPrimary),
                                )),
                          ],
                        );
                      },
                    );
                  } else {
                    Get.to(ReferScreen());
                  }
                },
              ),
              Container(
                height: 1,
                color: AppTheme().lineColor,
              ),
              ListTile(
                leading: SvgPicture.asset(
                  'assets/decont_drawer/chooseLanguage.svg',
                  height: 22.0,
                  width: 22.0,
                ), // Icon
                title: Text(
                  translate('Choose Language'),
                  style: CustomTextStyle.GraphikMedium(
                      14, AppColors.secondTextColor),
                ),
                dense: true, // Reduces vertical spacing

                onTap: () {
                  Navigator.of(context).pop();
                  if (userID == null || userID!.isEmpty) {
                    // If userID is null or empty, show a message or navigate to the login screen
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: AppTheme().whiteColor,
                          surfaceTintColor: AppTheme().whiteColor,
                          title: Text(
                            'Login Required',
                            style: CustomTextStyle.GraphikMedium(
                                22, AppColors.black),
                          ),
                          content: Text(
                            'Please log in to access your Choose Language.',
                            style: CustomTextStyle.GraphikRegular(
                                18, AppColors.black),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog
                              },
                              child: Text(
                                'Cancel',
                                style: CustomTextStyle.GraphikMedium(
                                    16, AppColors.colorPrimary),
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  Get.to(LoginScreen());
                                },
                                child: Text(
                                  'Login',
                                  style: CustomTextStyle.GraphikMedium(
                                      16, AppColors.colorPrimary),
                                )),
                          ],
                        );
                      },
                    );
                  } else {
                    Get.back();
                    Get.to(SelectLanguage());
                    //Navigator.pushNamed(context, "/selectLanguage");
                  }
                },
              ),

              ListTile(
                leading: SvgPicture.asset(
                  'assets/decont_drawer/sellOnDecont.svg',
                  height: 22.0,
                  width: 22.0,
                ), // Icon
                title: Text(
                  translate('Sell On Decont'),
                  style: CustomTextStyle.GraphikMedium(
                      14, AppColors.secondTextColor),
                ),
                dense: true, // Reduces vertical spacing

                onTap: () {
                  Navigator.of(context).pop();
                  if (userID == null || userID!.isEmpty) {
                    // If userID is null or empty, show a message or navigate to the login screen
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: AppTheme().whiteColor,
                          surfaceTintColor: AppTheme().whiteColor,
                          title: Text(
                            'Login Required',
                            style: CustomTextStyle.GraphikMedium(
                                22, AppColors.black),
                          ),
                          content: Text(
                            'Please log in to access your Sell On Decont.',
                            style: CustomTextStyle.GraphikRegular(
                                18, AppColors.black),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog
                              },
                              child: Text(
                                'Cancel',
                                style: CustomTextStyle.GraphikMedium(
                                    16, AppColors.colorPrimary),
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  Get.to(LoginScreen());
                                },
                                child: Text(
                                  'Login',
                                  style: CustomTextStyle.GraphikMedium(
                                      16, AppColors.colorPrimary),
                                )),
                          ],
                        );
                      },
                    );
                  } else {
                    Get.back();
                    Get.to(ContactUsScreen());
                    //Navigator.pushNamed(context, "/contact_us");
                  }
                },
              ),
              Container(
                height: 1,
                color: AppTheme().lineColor,
              ),
              ListTile(
                leading: SvgPicture.asset(
                  'assets/decont_drawer/contactUs.svg',
                  height: 22.0,
                  width: 22.0,
                ), // Icon
                title: Text(
                  translate('Contact Us'),
                  style: CustomTextStyle.GraphikMedium(
                      14, AppColors.secondTextColor),
                ),
                dense: true, // Reduces vertical spacing

                onTap: () {
                  Navigator.pop(context);

                  Navigator.pushNamed(context, "/contact_us");
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  'assets/decont_drawer/helpFeedback.svg',
                  height: 22.0,
                  width: 22.0,
                ), // Icon
                title: Text(
                  translate('Help/Feedback'),
                  style: CustomTextStyle.GraphikMedium(
                      14, AppColors.secondTextColor),
                ),
                dense: true, // Reduces vertical spacing

                onTap: () {
                  Navigator.pop(context);
                  Get.to(HelpAndSupportScreen());
                  //       Navigator.pushNamed(context, "/help_and_support");
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  'assets/decont_drawer/helpFeedback.svg',
                  height: 22.0,
                  width: 22.0,
                ), // Icon
                title: Text(
                  translate('FAQ'),
                  style: CustomTextStyle.GraphikMedium(
                      14, AppColors.secondTextColor),
                ),
                dense: true, // Reduces vertical spacing

                onTap: () {
                  Navigator.pop(context);
                  Get.to(WebViewExample(
                    title: 'FAQ',
                    link: 'decont-faq.html',
                  ));
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  'assets/decont_drawer/rateUs.svg',
                  height: 22.0,
                  width: 22.0,
                ), // Icon
                title: Text(
                  translate('Rate Us'),
                  style: CustomTextStyle.GraphikMedium(
                      14, AppColors.secondTextColor),
                ),
                dense: true, // Reduces vertical spacing

                onTap: () async {
                  Get.back();
                  if (packageName == null) {
                    return;
                  }
                  if (Platform.isAndroid) {
                    url = 'https://play.google.com/store/apps/details?id=';
                  } else if (Platform.isIOS) {
                    url = 'https://apps.apple.com/app/id$packageName';
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
              Container(
                height: 1,
                color: AppTheme().lineColor,
              ),
              userID == ''
                  ? ListTile(
                      leading: SvgPicture.asset(
                        'assets/decont_drawer/logOut.svg',
                        height: 22.0,
                        width: 22.0,
                        color: AppColors.green,
                      ), // Icon
                      title: Text(
                        translate('Login'),
                        style: CustomTextStyle.GraphikMedium(
                            14, AppColors.secondTextColor),
                      ),
                      dense: true,

                      onTap: () {
                        Get.to(LoginScreen());
                      },
                    )
                  : ListTile(
                      leading: SvgPicture.asset(
                        'assets/decont_drawer/logOut.svg',
                        height: 22.0,
                        width: 22.0,
                      ), // Icon
                      title: Text(
                        translate('Logout'),
                        style: CustomTextStyle.GraphikMedium(
                            14, AppColors.secondTextColor),
                      ),
                      dense: true,

                      onTap: () {
                        _showErrorDialog(context);
                      },
                    ),
            ],
          ),
        ),
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
                    return IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: AppColors.black,
                      ),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    );
                  },
                ),
                backgroundColor: Colors.white,
                elevation: 0.0,
                title: Text(
                  'Decont',
                  textAlign: TextAlign.left,
                  style: CustomTextStyle.GraphikMedium(16, AppColors.black),
                ),
                actions: [
                  Column(
                    children: [
                      const SizedBox(height: 10.0),

                      GestureDetector(
                        onTap: () {
                          // Check if userID is null or empty
                          if (userID == null || userID!.isEmpty) {
                            // If userID is null or empty, show a message or navigate to the login screen
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: AppTheme().whiteColor,
                                  surfaceTintColor: AppTheme().whiteColor,
                                  title: Text(
                                    'Login Required',
                                    style: CustomTextStyle.GraphikMedium(
                                        16, AppColors.black),
                                  ),
                                  content: Text(
                                    'Please log in to access your wallet.',
                                    style: CustomTextStyle.GraphikMedium(
                                        16, AppColors.black),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context); // Close the dialog
                                      },
                                      child: Text(
                                        'Cancel',
                                        style: CustomTextStyle.GraphikMedium(
                                            16, AppColors.black),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Get.to(LoginScreen());
                                      },
                                      child: Text('Login',
                                          style: CustomTextStyle.GraphikRegular(
                                              14, AppColors.colorPrimary)),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            Get.to(WalletHistoryScreen());
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/wallet.svg',
                                  // Path to your SVG file
                                  width: 25, // Set the width of the SVG icon
                                  height: 25, // Set the height of the SVG icon
                                  color: Colors
                                      .black, // Optional: change the color if needed
                                ),
                                const SizedBox(width: 5.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'My Wallet',
                                      style: CustomTextStyle.GraphikMedium(
                                          11, AppColors.black),
                                    ),
                                    const SizedBox(height: 1.0),
                                    Text(
                                      isLoading || _walletBalance == null
                                          ? ''
                                          : '₹ $_walletBalance',
                                      style: CustomTextStyle.GraphikRegular(
                                          12, AppColors.colorPrimary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 5.0),
                      // Adjust the height as needed for spacing
                    ],
                  ),
                  const SizedBox(width: 5.0),
                  Container(
                    margin: const EdgeInsets.only(right: 15),
                    // Adds 10px margin to the right
                    child: Stack(
                      children: <Widget>[
                        IconButton(
                          color: Colors.black,
                          icon: SvgPicture.asset(
                            'assets/icons/shopping_cart.svg',
                            // Path to your SVG file
                            width: 24, // Set the width of the SVG icon
                            height: 24, // Set the height of the SVG icon
                            color: Colors
                                .black, // Optional: change the color if needed
                          ),
                          onPressed: () {
                            if (userID == null || userID!.isEmpty) {
                              // If userID is null or empty, show a message or navigate to the login screen
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: AppTheme().whiteColor,
                                    surfaceTintColor: AppTheme().whiteColor,
                                    title: Text(
                                      'Login Required',
                                      style: CustomTextStyle.GraphikMedium(
                                          16, AppColors.black),
                                    ),
                                    content: Text(
                                      'Please log in to access my cart.',
                                      style: CustomTextStyle.GraphikMedium(
                                          16, AppColors.black),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(
                                              context); // Close the dialog
                                        },
                                        child: Text(
                                          'Cancel',
                                          style: CustomTextStyle.GraphikRegular(
                                              14, AppColors.colorPrimary),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Get.to(LoginScreen());
                                        },
                                        child: Text(
                                          'Login',
                                          style: CustomTextStyle.GraphikRegular(
                                              14, AppColors.colorPrimary),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              Get.to(MyCartScreen());
                            }
                          },
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: AppColors.colorPrimary,
                              // Background color for the count badge
                              borderRadius: BorderRadius.circular(
                                  10), // Round corners for the badge
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Text(
                              cart_count > 99
                                  ? '99+'
                                  : cart_count.toString().padLeft(1, '0'),
                              // Show '99+' if count exceeds 99, else display count with 2 digits
                              style: CustomTextStyle.GraphikRegular(
                                  12, AppColors.white),

                              textAlign: TextAlign.center,
                            ),
                            /*child: Text(
                              cart_count.toString(), // Replace this with your dynamic count value
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),*/
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                height: 1.0,
                color: AppTheme().lineColor,
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
            : bannerImagesList.isEmpty
                ? Center(
                    child: Text(
                    "No banners available",
                    style: CustomTextStyle.GraphikRegular(20, AppColors.black),
                  ))
                : Column(
                    children: [
                      Expanded(
                        child: isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.colorPrimary,
                                ),
                              )
                            : SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Container(
                                      color: AppTheme().whiteColor,
                                      padding: const EdgeInsets.only(
                                        left: 10.0,
                                        right: 10.0,
                                        top: 10.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    Get.to(CategoryPage(
                                                        catID: ''));
                                                  },
                                                  child: Visibility(
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 5,
                                                          vertical: 9),
                                                      // Add padding
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: AppColors
                                                              .textFieldBorderColor, // Border color
                                                          width:
                                                              1.0, // Border width
                                                        ),
                                                        color: AppColors.white,
                                                        // Background color
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                5), // Corner radius
                                                      ),
                                                      child: Column(
                                                        //mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between text and icon
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Shop by',
                                                            style: CustomTextStyle
                                                                .GraphikRegular(
                                                                    8,
                                                                    AppColors
                                                                        .greyColor),
                                                          ),
                                                          Text(
                                                            'Category',
                                                            style: CustomTextStyle
                                                                .GraphikMedium(
                                                                    9,
                                                                    AppColors
                                                                        .black),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 15.0,
                                                ),
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Get.to(SearchScreen());
                                                    },
                                                    child: Visibility(
                                                      visible:
                                                          true, // You can toggle this to control visibility
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8,
                                                                vertical: 13),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            color: AppColors
                                                                .textFieldBorderColor, // Border color
                                                            width:
                                                                1.0, // Border width
                                                          ),
                                                          color: AppTheme()
                                                              .whiteColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  'assets/icons/search_icon.svg',
                                                                  width: 20,
                                                                  height: 20,
                                                                  color: AppColors
                                                                      .greyColor,
                                                                ),
                                                                const SizedBox(
                                                                    width: 8),
                                                                Text(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  'Find 20,000+ Products',
                                                                  style: CustomTextStyle
                                                                      .GraphikMedium(
                                                                          13,
                                                                          AppColors
                                                                              .greyColor),
                                                                ),
                                                              ],
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
                                        ],
                                      ),
                                    ),
                                    Stack(
                                      children: [
                                        CarouselSlider.builder(
                                          itemCount: bannerImagesList.length,
                                          itemBuilder:
                                              (context, index, realIndex) {
                                            final imageUrl =
                                                bannerImagesList[index];

                                            return GestureDetector(
                                              onTap: () {
                                                //TODO
                                              },
                                              child: Container(
                                                color: AppColors.white,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  child: CachedNetworkImage(
                                                    imageUrl: imageUrl['image'],
                                                    height: 150,
                                                    width: double.infinity,
                                                    fit: BoxFit.contain,
                                                    placeholder: (context,
                                                            url) =>
                                                        const Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                      color: AppColors
                                                          .colorPrimary,
                                                    )),
                                                    errorWidget: (context,
                                                        error, stackTrace) {
                                                      // In case of error, show a default image
                                                      return Image.asset(
                                                        'assets/decont_splash_screen_images/decont_logo.png',
                                                        fit: BoxFit.contain,
                                                        height: 100,
                                                        width: double.infinity,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          options: CarouselOptions(
                                            height: 190,
                                            viewportFraction: 1.0,
                                            autoPlay: true,
                                            autoPlayInterval:
                                                const Duration(seconds: 3),
                                            enlargeCenterPage: false,
                                            scrollPhysics:
                                                BouncingScrollPhysics(),
                                            autoPlayAnimationDuration:
                                                const Duration(
                                                    milliseconds: 600),
                                            onPageChanged: (index, reason) {
                                              setState(() {
                                                _currentIndex = index;
                                              });
                                            },
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 10,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: bannerImagesList
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              return GestureDetector(
                                                child: Container(
                                                  width: 8.0,
                                                  height: 8.0,
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 4.0),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: _currentIndex ==
                                                            entry.key
                                                        ? AppColors.colorPrimary
                                                        : AppColors
                                                            .textFieldBorderColor,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                    GridView.builder(
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.all(10.0),
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount:
                                            MediaQuery.of(context).size.width >
                                                    600
                                                ? 3
                                                : 4,
                                        crossAxisSpacing: 5.0,
                                        mainAxisSpacing: 5.0,
                                      ),
                                      itemCount: homeCategoryList.length,
                                      itemBuilder: (context, index) {
                                        final item = homeCategoryList[index];
                                        return GestureDetector(
                                          onTap: () {
                                            print(
                                                "Category ID: ${item['catID']}");
                                            Navigator.of(context)
                                                .push(PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  CategoryPage(
                                                      catID:
                                                          '${item['catID']}'),
                                              transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                const begin = Offset(1.0, 0.0);
                                                const end = Offset.zero;
                                                const curve = Curves.easeInOut;

                                                var tween = Tween(
                                                        begin: begin, end: end)
                                                    .chain(CurveTween(
                                                        curve: curve));
                                                var offsetAnimation =
                                                    animation.drive(tween);

                                                return SlideTransition(
                                                  position: offsetAnimation,
                                                  child: child,
                                                );
                                              },
                                            ));
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                  width: 1,
                                                )),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: iconSize,
                                                  height: iconSize,
                                                  child: ClipOval(
                                                    child: CachedNetworkImage(
                                                      imageUrl: item['icon']!,
                                                      height: 150,
                                                      width: double.infinity,
                                                      fit: BoxFit.contain,
                                                      placeholder:
                                                          (context, url) =>
                                                              Center(
                                                        child: Image.asset(
                                                          'assets/decont_splash_screen_images/decont_logo.png',
                                                          fit: BoxFit.contain,
                                                          height: 100,
                                                          width:
                                                              double.infinity,
                                                        ),
                                                      ),
                                                      errorWidget: (context,
                                                          error, stackTrace) {
                                                        // In case of error, show a default image
                                                        return Image.asset(
                                                          'assets/decont_splash_screen_images/decont_logo.png',
                                                          fit: BoxFit.contain,
                                                          height: 100,
                                                          width:
                                                              double.infinity,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  item['name']!,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: CustomTextStyle
                                                      .GraphikMedium(
                                                          11,
                                                          AppColors
                                                              .secondTextColor),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    if (cart_product_list.isNotEmpty) ...[
                                      // const SizedBox(height: 10),
                                      SingleChildScrollView(
                                        child: Container(
                                          padding: const EdgeInsets.all(10.0),
                                          color: AppColors.white,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Items in your cart',
                                                style: CustomTextStyle
                                                    .GraphikRegular(
                                                        16, AppColors.black),
                                              ),
                                              const SizedBox(height: 10),
                                              SizedBox(
                                                height: 190,
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount:
                                                      cart_product_list.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    var item =
                                                        cart_product_list[
                                                            index];

                                                    return GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .push(
                                                                PageRouteBuilder(
                                                          pageBuilder: (context,
                                                                  animation,
                                                                  secondaryAnimation) =>
                                                              ProductDetailScreen(
                                                                  product_id: item[
                                                                      'productID']),
                                                          transitionsBuilder:
                                                              (context,
                                                                  animation,
                                                                  secondaryAnimation,
                                                                  child) {
                                                            const begin =
                                                                Offset(
                                                                    1.0, 0.0);
                                                            const end =
                                                                Offset.zero;
                                                            const curve = Curves
                                                                .easeInOut;

                                                            var tween = Tween(
                                                                    begin:
                                                                        begin,
                                                                    end: end)
                                                                .chain(CurveTween(
                                                                    curve:
                                                                        curve));
                                                            var offsetAnimation =
                                                                animation.drive(
                                                                    tween);

                                                            return SlideTransition(
                                                              position:
                                                                  offsetAnimation,
                                                              child: child,
                                                            );
                                                          },
                                                        ));
                                                        //_navigateToDetails(context);
                                                      },
                                                      child: Container(
                                                        color: AppTheme()
                                                            .whiteColor,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10.0),

                                                        //height: 250.0,
                                                        margin: const EdgeInsets
                                                            .only(bottom: 10.0),
                                                        child: Column(
                                                          // mainAxisAlignment:
                                                          //     MainAxisAlignment
                                                          //         .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              // mainAxisAlignment:
                                                              //     MainAxisAlignment
                                                              //         .spaceBetween,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Stack(
                                                                  children: [
                                                                    Container(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          1.0),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              AppColors.textFieldBorderColor, // Border color
                                                                          width:
                                                                              1.0, // Border width
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0), // Rounded corners
                                                                      ),
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.0), // Match container's radius
                                                                        child: Image
                                                                            .network(
                                                                          item[
                                                                              'image'],
                                                                          height:
                                                                              100,
                                                                          width:
                                                                              100,
                                                                          fit: BoxFit
                                                                              .contain,
                                                                          loadingBuilder: (context,
                                                                              child,
                                                                              loadingProgress) {
                                                                            if (loadingProgress ==
                                                                                null) {
                                                                              return child; // Image loaded
                                                                            }
                                                                            return const Center(
                                                                                child: CircularProgressIndicator(
                                                                              color: AppColors.colorPrimary,
                                                                            )); // Loading indicator
                                                                          },
                                                                          errorBuilder: (context,
                                                                              error,
                                                                              stackTrace) {
                                                                            return Image.asset(
                                                                              'assets/decont_splash_screen_images/decont_logo.png',
                                                                              fit: BoxFit.contain,
                                                                              height: 100,
                                                                              width: 100,
                                                                            ); // Fallback image
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),

                                                                const SizedBox(
                                                                    width:
                                                                        10.0), // Spacing between image and text

                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        item[
                                                                            'name'],
                                                                        // Example text from car object
                                                                        style: CustomTextStyle.GraphikMedium(
                                                                            13,
                                                                            AppColors.black),

                                                                        maxLines:
                                                                            2, // Limit to 1 line for name
                                                                        overflow:
                                                                            TextOverflow.ellipsis, // Ellipsis for overflow
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            2.0,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Row(
                                                                                  children: [
                                                                                    Visibility(
                                                                                      visible: item['price'] != null && item['price'].isNotEmpty,
                                                                                      child: Text(
                                                                                        '₹ ${'${item['price']}'}',
                                                                                        style: CustomTextStyle.GraphikRegular(13, AppColors.black),
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      width: 5.0,
                                                                                    ),
                                                                                    Visibility(
                                                                                      visible: item['mrp'] != null && item['mrp'].isNotEmpty,
                                                                                      child: Text(
                                                                                        '₹ ${'${item['mrp']}'}',
                                                                                        style: CustomTextStyle.GraphikMedium(13, AppColors.black)!.copyWith(color: AppColors.secondTextColor, fontSize: 12, decoration: TextDecoration.lineThrough, decorationThickness: 1, decorationColor: AppColors.textSub),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 5.0,
                                                                                ),
                                                                                Container(
                                                                                  margin: const EdgeInsets.only(top: 3.0),
                                                                                  child: Visibility(
                                                                                    visible: item['quantity'] != null && item['quantity'].isNotEmpty,
                                                                                    child: Text(
                                                                                      'QTY: ${'${item['quantity']}'}',
                                                                                      style: CustomTextStyle.GraphikRegular(14, AppColors.secondTextColor),
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
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Container(
                                                              color: AppColors
                                                                  .white,
                                                              // padding:
                                                              //     const EdgeInsets.all(10.0),
                                                              child: SizedBox(
                                                                width: double
                                                                    .infinity, // Button takes up full width
                                                                child:
                                                                    ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          Get.to(
                                                                              MyCartScreen());
                                                                        },
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          backgroundColor:
                                                                              AppColors.colorPrimary,
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(5),
                                                                          ),
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              vertical: 15),
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                          'PROCEED TO CHECKOUT ${'($cart_count)'}',
                                                                          style: CustomTextStyle.GraphikMedium(
                                                                              14,
                                                                              AppColors.white),
                                                                        )),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: products.length,
                                      itemBuilder: (context, index) {
                                        var category = products[index];
                                        var catID = category['catID'];
                                        var categoryName =
                                            category['category_name'];
                                        var categoryBanner =
                                            category['category_banner'];
                                        var categoryProducts =
                                            category['category_products'];

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (categoryBanner.isNotEmpty)
                                              Container(
                                                width: double.infinity,
                                                //padding: EdgeInsets.all(10.0),
                                                padding: const EdgeInsets.only(
                                                    right: 10.0,
                                                    left: 10.0,
                                                    top: 10),
                                                // color: AppTheme().whiteColor,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  child: Image.network(
                                                    categoryBanner,
                                                    width: double.infinity,
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Image.asset(
                                                      'assets/decont_splash_screen_images/decont_logo.png',
                                                      fit: BoxFit
                                                          .cover, // Full coverage for fallback
                                                      width: double.infinity,
                                                    ),
                                                    loadingBuilder: (context,
                                                        child,
                                                        loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) {
                                                        return child;
                                                      }
                                                      return const Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                        color: AppColors
                                                            .colorPrimary,
                                                      ));
                                                    },
                                                  ),
                                                ),
                                              ),

                                            // Category Name
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              color: AppColors.white,
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      categoryName,
                                                      style: CustomTextStyle
                                                          .GraphikRegular(16,
                                                              AppColors.black),
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      Get.to(CategoryPage(
                                                        catID: '$catID',
                                                      ));
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 5,
                                                          vertical: 5),
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .colorPrimary,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        // Space between text and icon
                                                        children: [
                                                          Text(
                                                            'VIEW ALL',
                                                            style: CustomTextStyle
                                                                .GraphikMedium(
                                                                    12,
                                                                    AppColors
                                                                        .white),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // SizedBox(
                                            //   height: 10,
                                            // ),

                                            // Product List
                                            categoryProducts.isNotEmpty
                                                ? Container(
                                                    color: AppColors.white,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5.0),
                                                    child: SizedBox(
                                                      height: 280.0,
                                                      child: ListView.builder(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemCount:
                                                            categoryProducts
                                                                .length,
                                                        itemBuilder: (context,
                                                            productIndex) {
                                                          var product =
                                                              categoryProducts[
                                                                  productIndex];
                                                          var productID =
                                                              product[
                                                                  'productID'];
                                                          var productName =
                                                              product['name'];
                                                          var productImage =
                                                              product['image'];
                                                          var without_gst_mrp =
                                                              product[
                                                                  'without_gst_mrp'];
                                                          var without_gst_price =
                                                              product[
                                                                  'without_gst_price'];
                                                          var without_gst_disc =
                                                              product[
                                                                  'without_gst_disc'];
                                                          var review_count =
                                                              product[
                                                                  'review_count'];
                                                          var review_msg =
                                                              product[
                                                                  'review_msg'];

                                                          var discount =
                                                              product[
                                                                  'discount'];

                                                          return GestureDetector(
                                                            onTap: () {
                                                              Get.to(
                                                                ProductDetailScreen(
                                                                    product_id:
                                                                        productID),
                                                              );
                                                            },
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(1.0),
                                                              height: 290.0,
                                                              width: 150.0,
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right:
                                                                          10.0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: AppColors
                                                                    .white,
                                                                border:
                                                                    Border.all(
                                                                  color: AppColors
                                                                      .textFieldBorderColor,
                                                                  width: 0.5,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.0),
                                                              ),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Stack(
                                                                    children: [
                                                                      ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.0),
                                                                        child:
                                                                            CachedNetworkImage(
                                                                          imageUrl:
                                                                              productImage,
                                                                          height:
                                                                              150,
                                                                          width:
                                                                              double.infinity,
                                                                          fit: BoxFit
                                                                              .contain,
                                                                          placeholder: (context, url) => Center(
                                                                              child: Image.asset(
                                                                            'assets/decont_splash_screen_images/decont_logo.png',
                                                                            fit:
                                                                                BoxFit.contain,
                                                                            height:
                                                                                100,
                                                                            width:
                                                                                double.infinity,
                                                                          )),
                                                                          errorWidget: (context,
                                                                              error,
                                                                              stackTrace) {
                                                                            // In case of error, show a default image
                                                                            return Image.asset(
                                                                              'assets/decont_splash_screen_images/decont_logo.png',
                                                                              fit: BoxFit.contain,
                                                                              height: 100,
                                                                              width: double.infinity,
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                      // discount ==
                                                                      //         ''
                                                                      //     ? SizedBox
                                                                      //         .shrink()
                                                                      //     : Positioned(
                                                                      //         top: 2,
                                                                      //         left: 0,
                                                                      //         child: Container(
                                                                      //           decoration: const BoxDecoration(
                                                                      //             color: AppColors.green,
                                                                      //             borderRadius: BorderRadius.only(
                                                                      //               bottomRight: Radius.circular(5),
                                                                      //             ),
                                                                      //           ),
                                                                      //           padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
                                                                      //           child: Column(
                                                                      //             children: [
                                                                      //               Text(
                                                                      //                 discount,
                                                                      //                 style: CustomTextStyle.GraphikMedium(8, AppTheme().whiteColor),
                                                                      //               ),
                                                                      //             ],
                                                                      //           ),
                                                                      //         ),
                                                                      //       ),
                                                                      Positioned(
                                                                        top: 1,
                                                                        right:
                                                                            0,
                                                                        child:
                                                                            IconButton(
                                                                          icon:
                                                                              Icon(
                                                                            _isFavorite
                                                                                ? Icons.favorite
                                                                                : Icons.favorite_border,
                                                                            color: _isFavorite
                                                                                ? Colors.red
                                                                                : Colors.grey, // Change color based on state
                                                                          ),
                                                                          onPressed:
                                                                              () {
//TOFo
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height:
                                                                        10.0,
                                                                  ),
                                                                  // Container(
                                                                  //   padding: const EdgeInsets
                                                                  //       .only(
                                                                  //       left:
                                                                  //           10.0,
                                                                  //       right:
                                                                  //           10.0),
                                                                  //   child: Row(
                                                                  //     children: [
                                                                  //       Expanded(
                                                                  //         child:
                                                                  //             Row(
                                                                  //           children: [
                                                                  //             Visibility(
                                                                  //               visible: review_count != null && review_count.isNotEmpty && review_count != '0',
                                                                  //               child: Container(
                                                                  //                 padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3), // Add padding
                                                                  //                 decoration: BoxDecoration(
                                                                  //                   color: AppColors.green,
                                                                  //                   borderRadius: BorderRadius.circular(5),
                                                                  //                 ),
                                                                  //                 child: const Row(
                                                                  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  //                   children: [
                                                                  //                     Text(
                                                                  //                       // review_count,
                                                                  //                       '10',
                                                                  //                       style: TextStyle(
                                                                  //                         fontSize: 11,
                                                                  //                         color: AppColors.white,
                                                                  //                       ),
                                                                  //                     ),
                                                                  //                     SizedBox(width: 4), // Add spacing between text and icon
                                                                  //                     Icon(
                                                                  //                       Icons.star,
                                                                  //                       color: AppColors.white, // Star color
                                                                  //                       size: 12, // Small icon size
                                                                  //                     ),
                                                                  //                   ],
                                                                  //                 ),
                                                                  //               ),
                                                                  //             ),
                                                                  //             const SizedBox(
                                                                  //               width: 5.0,
                                                                  //             ),
                                                                  //             Visibility(
                                                                  //               visible: review_msg != null && review_msg.isNotEmpty,
                                                                  //               child: Text(
                                                                  //                 '10 review',
                                                                  //                 // '($review_msg)',
                                                                  //                 style: CustomTextStyle.GraphikRegular(14, AppColors.black),
                                                                  //               ),
                                                                  //             ),
                                                                  //           ],
                                                                  //         ),
                                                                  //       ),
                                                                  //     ],
                                                                  //   ),
                                                                  // ),
                                                                  const SizedBox(
                                                                    height:
                                                                        10.0,
                                                                  ),
                                                                  Container(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10.0,
                                                                        right:
                                                                            10.0),
                                                                    child: Text(
                                                                      productName,
                                                                      style: CustomTextStyle.GraphikMedium(
                                                                          13.5,
                                                                          AppColors
                                                                              .black),
                                                                      maxLines:
                                                                          2, // Limit to 1 line for name
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis, // Ellipsis for overflow
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 3.0,
                                                                  ),
                                                                  Container(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            10),
                                                                    child: Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  Flexible(
                                                                                    flex: 1, // First flex item, takes 2 parts of the available space
                                                                                    child: Visibility(
                                                                                      visible: without_gst_mrp != null && without_gst_mrp.isNotEmpty,
                                                                                      child: Text(
                                                                                        '₹${'$without_gst_mrp'}',
                                                                                        style: CustomTextStyle.GraphikRegular(10.5, AppColors.secondTextColor)?.copyWith(decorationThickness: 1, decorationColor: AppColors.black, decoration: TextDecoration.lineThrough), overflow: TextOverflow.ellipsis, // Ensure text doesn't overflow
                                                                                        maxLines: 1, // Limit to one line
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width: 5.0,
                                                                                  ),
                                                                                  Visibility(
                                                                                    visible: without_gst_disc != null && without_gst_disc.isNotEmpty,
                                                                                    child: Text(
                                                                                      without_gst_disc,
                                                                                      style: TextStyle(fontSize: 12, color: AppTheme().DarkgreenColor, fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              Container(
                                                                                margin: const EdgeInsets.only(top: 3.0),
                                                                                child: Visibility(
                                                                                  visible: without_gst_price != null && without_gst_price.isNotEmpty,
                                                                                  child: Text(
                                                                                    '₹${'$without_gst_price'}',
                                                                                    style: CustomTextStyle.GraphikMedium(13.5, AppColors.black),
                                                                                  ),
                                                                                ),
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
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  )
                                                : Text('No products available',
                                                    style: CustomTextStyle
                                                        .GraphikMedium(20,
                                                            AppColors.black)),
                                          ],
                                        );
                                      },
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    if (img_refer.isNotEmpty) ...[
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(ReferScreen());
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(10.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            child: CachedNetworkImage(
                                              imageUrl: img_refer,
                                              height: 150,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                color: AppColors.colorPrimary,
                                              )),
                                              errorWidget:
                                                  (context, error, stackTrace) {
                                                // In case of error, show a default image
                                                return Image.asset(
                                                  'assets/decont_splash_screen_images/decont_logo.png',
                                                  fit: BoxFit.cover,
                                                  height: 100,
                                                  width: double.infinity,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedLabelStyle:
                CustomTextStyle.GraphikMedium(11, AppColors.black),
            unselectedLabelStyle:
                CustomTextStyle.GraphikRegular(10, AppColors.secondTextColor),
            selectedItemColor: AppColors.secondTextColor,
            unselectedItemColor: AppColors.secondTextColor,
            currentIndex: _selectedIndex,
            // onTap: _onItemTapped, // Uncomment and define this function if needed
            items: [
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {
                    Get.to(() => Home());
                  },
                  child: SvgPicture.asset(
                    'assets/icons/home.svg',
                    color: _selectedIndex == 0
                        ? AppColors.colorPrimary
                        : AppColors.secondTextColor,
                    width: 24,
                    height: 24,
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {
                    Get.to(() => ReferScreen());
                  },
                  child: SvgPicture.asset(
                    'assets/decont_drawer/referEarn.svg',
                    color: _selectedIndex == 1
                        ? AppColors.colorPrimary
                        : AppColors.secondTextColor,
                    width: 24,
                    height: 24,
                  ),
                ),
                label: 'Refer a Friend',
              ),
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Coming Soon",
                              style: CustomTextStyle.GraphikMedium(
                                  16, AppColors.white))),
                    );
                    // Get.to(() => WishListScreen());
                  },
                  child: SvgPicture.asset(
                    'assets/icons/wishlist_bottom.svg',
                    color: _selectedIndex == 2
                        ? AppColors.colorPrimary
                        : AppColors.secondTextColor,
                    width: 24,
                    height: 24,
                  ),
                ),
                label: 'Wishlist',
              ),
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {
                    Get.to(() => NotificationsPage(onBack: () {}));
                  },
                  child: SvgPicture.asset(
                    'assets/icons/notification_icon.svg',
                    color: _selectedIndex == 3
                        ? AppColors.colorPrimary
                        : AppColors.secondTextColor,
                    width: 24,
                    height: 24,
                  ),
                ),
                label: 'Notification',
              ),
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {
                    Get.to(() => MyAccountPage(onBack: () {}));
                  },
                  child: SvgPicture.asset(
                    'assets/icons/account.svg',
                    color: _selectedIndex == 4
                        ? AppColors.colorPrimary
                        : AppColors.secondTextColor,
                    width: 24,
                    height: 24,
                  ),
                ),
                label: 'My Account',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
