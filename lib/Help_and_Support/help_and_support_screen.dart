import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../BaseUrl.dart';
import '../CustomeTextStyle/custometextstyle.dart';
import '../theme/AppTheme.dart';

String? first_name = '';
String? name = '';
String? last_name = '';
String? mobile = '';
String? user_token = '';
String? image = '';
String? userID = '';

class HelpAndSupportScreen extends StatefulWidget {
  @override
  _HelpAndSupportScreenState createState() => _HelpAndSupportScreenState();
}

class _HelpAndSupportScreenState extends State<HelpAndSupportScreen> {
  final Map<String, int> cart = {};
  Map<String, String> localizedStrings = {};
  String currentLangCode = 'en';
  List<Map<String, dynamic>> productsList = [];
  String pageCode = '1';
  bool isLoading = false;
  bool hasMoreData = true;
  String mobile = ''; // Declare title variable
  String whattsapp = ''; // Declare title variable
  String email = ''; // Declare title variable
  String image = ''; // Declare title variable

  final _firstNameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguagePreference();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
      email = prefs.getString('email') ?? '';
      mobile = prefs.getString('mobile') ?? '';
      user_token = prefs.getString('user_token') ?? '';
      image = prefs.getString('image') ?? '';
      userID = prefs.getString('userID') ?? '';
    });
    _firstNameController.text = '$name';
    _mobileNumberController.text = '$mobile';
    _emailController.text = '$email';
  }

  Future<void> _dashboardData() async {
    if (isLoading) return; // Prevent multiple requests

    if (!isLoading) isLoading = true; // Set loading for initial data

    final url = Uri.parse(baseUrl);

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token',
    };

    final Map<String, String> body = {
      'view': 'help',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());
        log('Response data: $data');

        if (data['result'] == 1) {
          // Extract and set the title from API response
          image = data['data']
              ['image']; // Fallback to 'Default Title' if title is null
          mobile = data['data']
              ['mobile']; // Fallback to 'Default Title' if title is null
          whattsapp = data['data']
              ['whatsapp']; // Fallback to 'Default Title' if title is null
          email = data['data']
              ['email']; // Fallback to 'Default Title' if title is null
          // Optionally, extract other fields from the response as needed
          // e.g., email, mobile, description, etc.

          // Call setState to refresh the UI
          setState(() {});
        } else {
          // Show error message if result is not 1
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
      // Log any exceptions
      log('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred.')),
      );
    } finally {
      // Reset loading states
      isLoading = false;
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

  final List<Map<String, String>> faqData = [
    {
      'question': 'What is Lorem Ipsum?',
      'answer':
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
    },
    {
      'question': 'Why do we use it?',
      'answer':
          'It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout.',
    },
    {
      'question': 'Where can I get some?',
      'answer':
          'There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form.',
    },
    {
      'question': 'What is Lorem Ipsum?',
      'answer':
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
    },
    {
      'question': 'Why do we use it?',
      'answer':
          'It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout.',
    },
    {
      'question': 'Where can I get some?',
      'answer':
          'There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form.',
    },
  ];

  void _launchDialer(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        print('Could not launch dialer for $phoneNumber');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _launchWhatsapp() async {
    var whatsappUri = Uri.parse("whatsapp://send?phone=$mobile");

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("WhatsApp is not installed on the device"),
        ),
      );
    }
  }

  /*_launchWhatsapp() async {
    var whatsapp = mobile;
    var whatsappAndroid =Uri.parse("whatsapp://send?phone=$whatsapp");
    if (await canLaunchUrl(whatsappAndroid)) {
      await launchUrl(whatsappAndroid);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("WhatsApp is not installed on the device"),
        ),
      );
    }
  }*/

  /*Future sendEmail({
    required String toEmail
  }) async {
    final url =
        'mailto:$toEmail}';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }*/

  Future sendEmail({
    required String toEmail,
  }) async {
    // Correct the URL by removing the unnecessary '}'
    final String url = 'mailto:$toEmail';

    // Check if the device can handle the mailto link
    if (await canLaunch(url)) {
      // Launch the mailto URL
      await launch(url);
    } else {
      // Show an error message if mailto cannot be launched
      print('Could not open email client');
    }
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
                  translate('Help / Feedback'),
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
        backgroundColor: AppTheme().whiteColor,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 200.0,
                  height: 200.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/decont_splash_screen_images/decont_logo.png'),

                      fit: BoxFit.contain, // Adjust fit as necessary
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _firstNameController,
                  cursorColor: AppColors.colorPrimary,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle:
                        CustomTextStyle.GraphikMedium(14, AppColors.greyColor),
                    border: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColors.textFieldBorderColor)),
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
                  style: CustomTextStyle.GraphikRegular(14, AppColors.black),
                ),
                const SizedBox(height: 20),
                TextField(
                  cursorColor: AppColors.colorPrimary,
                  controller: _mobileNumberController,
                  keyboardType: TextInputType.number,
                  readOnly: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    labelText: translate('Mobile Number'),
                    labelStyle:
                        CustomTextStyle.GraphikMedium(14, AppColors.greyColor),
                    border: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColors.textFieldBorderColor)),
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
                    )),
                  ),
                  style: CustomTextStyle.GraphikRegular(14, AppColors.black),
                ),
                const SizedBox(height: 20),
                TextField(
                  cursorColor: AppColors.colorPrimary,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: translate('Email ID'),
                    labelStyle:
                        CustomTextStyle.GraphikMedium(14, AppColors.greyColor),
                    border: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColors.textFieldBorderColor)),
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
                  style: CustomTextStyle.GraphikRegular(14, AppColors.black),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _messageController,
                  cursorColor: AppColors.colorPrimary,
                  decoration: InputDecoration(
                    labelText: 'Message',
                    labelStyle:
                        CustomTextStyle.GraphikMedium(14, AppColors.greyColor),
                    border: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColors.textFieldBorderColor)),
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
                  style: CustomTextStyle.GraphikRegular(14, AppColors.black),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () async {
                        //TODO
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.colorPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(
                        translate('Send'),
                        style:
                            CustomTextStyle.GraphikMedium(16, AppColors.white),
                      )),
                ),
              ],
            ),
          ),
        ));
  }
}
