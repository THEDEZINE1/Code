import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
//import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../BaseUrl.dart';
import '../CustomeTextStyle/custometextstyle.dart';
import '../theme/AppTheme.dart';

String? userID = '';
String? last_name = '';
String? email = '';
String? mobile = '';
String? user_token = '';
String? image = '';

class ReferScreen extends StatefulWidget {
  @override
  _ReferScreenState createState() => _ReferScreenState();
}

class _ReferScreenState extends State<ReferScreen> {
  Map<String, String> localizedStrings = {};
  String currentLangCode = 'en';
  bool isLoading = false;
  bool hasMoreData = true;

  Map<String, String> _socialLinks = {};
  List _pages = [];
  String _image = '';
  String _message = '';
  String _displayMessage = '';
  String _shareImage = '';
  String _referralKey = '';
  String _youGet = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguagePreference();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Load user preferences and initialize data
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('userID') ?? '';
      last_name = prefs.getString('last_name') ?? '';
      email = prefs.getString('email') ?? '';
      mobile = prefs.getString('mobile') ?? '';
      user_token = prefs.getString('user_token') ?? '';
      image = prefs.getString('image') ?? '';
    });
    await _dashboardData();
  }

  Future<void> _dashboardData() async {
    if (isLoading) return; // Prevent multiple requests

    isLoading = true; // Set loading to true for the initial request

    final url = Uri.parse(baseUrl);

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token',
    };

    final Map<String, String> body = {
      'view': 'share_msg',
      'custID': '$userID',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());
        log('Response data: $data');

        if (data['result'] == 1) {
          // Extract data and handle null safety
          final dashboardData = data['data'];

          final String image = dashboardData['image'] ?? '';
          final String message = dashboardData['message'] ?? '';
          final String displayMessage = dashboardData['display_message'] ?? '';
          final String shareImage = dashboardData['share_image'] ?? '';
          final String referralKey = dashboardData['ref_key'] ?? '';
          final String youGet = dashboardData['you_get'] ?? '';
          final String friendGets = dashboardData['you_friend_get'] ?? '';

          // Update the state with the fetched data
          setState(() {
            _image = image;
            _message = message;
            _displayMessage = displayMessage;
            _shareImage = shareImage;
            _referralKey = referralKey;
            _youGet = youGet;
          });

          log('Image URL: $_image');
        } else {
          // Handle API result other than success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(data['message'] ?? 'Something went wrong',
                    style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
          );
        }
      } else {
        // Handle HTTP errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${response.reasonPhrase}',
                  style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
        );
      }
    } catch (e) {
      // Handle exceptions
      log('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An unexpected error occurred.',
                style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
      );
    } finally {
      isLoading = false; // Reset loading state
    }
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
                      Navigator.pop(context);
                    },
                  );
                },
              ),
              backgroundColor: Colors.white,
              elevation: 0.0,
              title: Text(
                'Refer a friend',
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.colorPrimary,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.maxFinite,
                    height: 250.0,
                    decoration: BoxDecoration(
                      // Make it circular if needed
                      image: DecorationImage(
                        image: (_image.isNotEmpty)
                            ? NetworkImage(_image)
                            : const AssetImage('assets/images/profile.png')
                                as ImageProvider,
                        fit: BoxFit.fill, // Adjust fit as necessary
                      ),
                    ),
                  ),

                  /*Image.network(
              _image,
              height: 250,
              width: double.infinity,
              fit: BoxFit.contain,
                            ),*/

                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        // Refer Amount Text (Hidden)
                        Visibility(
                          visible: false,
                          child: Text(
                            '₹100',
                            textAlign: TextAlign.center,
                            style: CustomTextStyle.GraphikRegular(
                                14, AppColors.black),
                          ),
                        ),
                        // Refer Lines
                        const SizedBox(
                          height: 10.0,
                        ),

                        Text(
                          _displayMessage,
                          textAlign: TextAlign.center,
                          style: CustomTextStyle.GraphikMedium(
                              16, AppColors.black),
                        ),
                        // Refer Link
                        GestureDetector(
                          onTap: () {
                            _copyReferralLink(context, _referralKey);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 75.0),
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_referralKey,
                                    style: CustomTextStyle.GraphikRegular(
                                        14, AppColors.black)),
                                const SizedBox(
                                  width: 10.0,
                                ),
                                const Icon(Icons.copy, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 10.0,
                        ),

                        // Divider with text
                        Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Divider(
                                thickness: 0.5,
                                color: Colors.grey,
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: Text('SHARE WITH YOUR FRIENDS',
                                  textAlign: TextAlign.center,
                                  style: CustomTextStyle.GraphikRegular(
                                      16, AppColors.black)),
                            ),
                            const Expanded(
                              flex: 1,
                              child: Divider(
                                thickness: 0.5,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15.0),

                        // Social Media Share Icons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialShareIcon(
                              'assets/icons/whatsapp_icon.svg',
                              'WhatsApp',
                              onTap: () {
                                _shareOnWhatsApp(
                                  'Check this out: $_shareImage',
                                );
                              },
                            ),
                            const SizedBox(width: 10.0),
                            _socialShareIcon(
                              'assets/icons/share.svg',
                              'More',
                              onTap: () {
                                _shareMore(
                                  'Check this out: $_shareImage',
                                );
                              },
                            ),
                          ],
                        ),

                        /*Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialShareIcon('assets/icons/whatsapp_icon.svg', 'WhatsApp'),
                      SizedBox(width: 10.0,),
                      _socialShareIcon('assets/icons/share.svg', 'More'),
                    ],
                  ),*/
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Copy Referral Link to Clipboard
  void _copyReferralLink(BuildContext context, String referralLink) {
    //String referralLink = 'http://www.example.com/referral'; // Replace with actual referral link
    Clipboard.setData(ClipboardData(text: referralLink)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Referral link copied to clipboard',
                style: CustomTextStyle.GraphikMedium(16, AppColors.white)!
                    .copyWith(color: AppColors.white))),
      );
    });
  }

  Widget _socialShareIcon(String iconPath, String label,
      {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          SvgPicture.asset(
            iconPath,
            width: 40,
            height: 40,
          ),
          const SizedBox(height: 10.0),
          Text(label,
              style:
                  CustomTextStyle.GraphikMedium(12, AppColors.secondTextColor)),
        ],
      ),
    );
  }

  void _shareOnWhatsApp(String message) async {
    /*final Uri whatsappUri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('WhatsApp is not installed on your device.')),
      );
    }*/
    var whatsappUri = Uri.parse("whatsapp://send?phone=$mobile");

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("WhatsApp is not installed on the device",
              style: CustomTextStyle.GraphikMedium(16, AppColors.white)),
        ),
      );
    }
  }

  void _shareMore(String content) {
    try {
      // Share.share(content);
    } catch (e) {
      log('Error sharing content: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to share content.',
                style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
      );
    }
  }

  // Social Media Icon Widget
  /*Widget _socialShareIcon(String iconPath, String label, {bool hidden = false}) {
    return Visibility(
      visible: !hidden,
      child: Column(
        children: [
          SvgPicture.asset(
            iconPath,
            width: 40,
            height: 40,
            // You can also use 'color' property to apply color if needed
          ),

          SizedBox(height: 10.0,),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Color(0xFF9da0a7)),
          ),
        ],
      ),
    );
  }*/
}
