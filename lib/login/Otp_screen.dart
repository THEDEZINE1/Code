import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../BaseUrl.dart';
import '../CustomeTextStyle/custometextstyle.dart';
import '../Dashboard/home_screen.dart';
import '../theme/AppTheme.dart';

class Otp_screen extends StatefulWidget {
  final String? mobilNumber;

  const Otp_screen({super.key, required this.mobilNumber});

  @override
  State<Otp_screen> createState() => _OptPageState();
}

class _OptPageState extends State<Otp_screen> {
  bool isLoading = false;
  int start = 29;
  bool wait = false;
  List isSelecteds = [];
  List deviceToken = [];
  var duration = const Duration(seconds: 29);
  bool timeout = false;
  bool enableButton = false;
  bool isDisabled = true;

  bool isLoggedIn = false;

  final TextEditingController _pinPutController = TextEditingController();
  Map<String, String> localizedStrings = {};
  String? langCode;
  String mobileNumber = '';
  String currentLangCode = 'en'; // Default language code (English)

  @override
  void initState() {
    startTimer();
    _loadCurrentLanguagePreference();
    super.initState();
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

  void startTimer() {
    setState(() {
      wait = false; // Disable resend button
      start = 29; // Reset the timer to 29 seconds
    });

    // Start a periodic timer to decrease the time
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (start > 0) {
        setState(() {
          start--; // Decrement the timer every second
        });
      } else {
        setState(() {
          timer.cancel(); // Stop the timer when it reaches 0
          wait = true; // Enable the resend button
        });
      }
    });
  }

  Future<void> _verify_otp(BuildContext context, String mobileNumber) async {
    final url = Uri.parse(baseUrl); // Your API URL
    final Map<String, String> body = {
      'mobile': mobileNumber, // Use the mobile number from the arguments
      'otp': _pinPutController.text, // OTP entered by the user
      'app_type': 'Android',
      'view': 'login',
      'action': 'otpVerify',
    };

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());

        // Ensure the required keys exist and are not null
        if (data != null &&
            data['status'] == 'success' &&
            data['result'] == 1 &&
            data['data'] != null &&
            data['data']['customer_detail'] != null &&
            data['data']['customer_detail'].isNotEmpty) {
          // Access customer_detail safely
          final customer = data['data']['customer_detail'][0];

          final prefs = await SharedPreferences.getInstance();

          // Safely extract values with null checks
          await prefs.setString('userID',
              customer['ID'] ?? ''); // Default to empty string if null
          await prefs.setString('user_token',
              customer['user_token'] ?? ''); // Default to empty string if null
          await prefs.setString('name', customer['name'] ?? '');
          await prefs.setString('image', customer['image'] ?? '');
          await prefs.setString('email', customer['email'] ?? '');
          await prefs.setString('mobile', customer['phone'] ?? '');

          await prefs.setInt(
              'cart_count', int.tryParse(data['data']['cart_count']) ?? 0);

          log('Data: $data');

          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return const Home();
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0); // Start offscreen to the right
              const end = Offset.zero; // End at the screen's center
              const curve = Curves.easeInOut; // Animation curve

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
              data['message'] ?? 'Login failed',
              style: CustomTextStyle.GraphikMedium(16, AppColors.white),
            )),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            'Login failed: ${response.reasonPhrase}',
            style: CustomTextStyle.GraphikMedium(16, AppColors.white),
          )),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'An error occurred: $e',
          style: CustomTextStyle.GraphikMedium(16, AppColors.white),
        )),
      );
      log('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _resendOTP(String mobileNumber) async {
    // Define the URL
    final url = Uri.parse(baseUrl); // Your API URL
    final Map<String, String> body = {
      'mobile': mobileNumber, // Use the mobile number from the arguments
      'view': 'login',
      'action': 'resendOTP',
    };

    // Set headers
    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    try {
      // Perform the POST request
      final response = await http.post(url, headers: headers, body: body);

      // Print response body
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());

        // Check for successful login
        if (data['result'] == 1) {
          // Navigate to the OTP screen
          setState(() {
            wait == false;
          });
          startTimer();
        } else {
          // Handle failed login
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
              data['message'],
              style: CustomTextStyle.GraphikMedium(16, AppColors.white),
            )),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            'Login failed: ${response.reasonPhrase}',
            style: CustomTextStyle.GraphikMedium(16, AppColors.white),
          )),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'An error occurred: $e',
          style: CustomTextStyle.GraphikMedium(16, AppColors.white),
        )),
      );
      log('data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    mobileNumber = widget.mobilNumber.toString();
    String maskedNumber = mobileNumber.replaceRange(
        0, mobileNumber.length - 4, '*' * (mobileNumber.length - 4));

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                        child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.width * 0.2,
                          ),
                          Text(
                            'Please enter the verification\ncode sent to your $maskedNumber phone.',
                            style: CustomTextStyle.GraphikMedium(
                                16, AppColors.black),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: Column(children: [
                              Pinput(
                                autofocus: true,
                                length: 4,
                                controller: _pinPutController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                defaultPinTheme: PinTheme(
                                  height: 50.0,
                                  width: 50.0,
                                  // Set both height and width to the same value for square shape
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.colorPrimary,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        5), // Square corners
                                  ),
                                  textStyle: CustomTextStyle.GraphikMedium(
                                      16, AppColors.black),
                                ),
                                focusedPinTheme: PinTheme(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  height: 50.0,
                                  width: 50.0,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.textFieldBorderColor,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        5), // Square corners
                                  ),
                                ),
                                onChanged: (a) {
                                  if (_pinPutController.text.length == 4) {
                                    setState(() {
                                      isDisabled = false;
                                    });
                                  } else {
                                    setState(() {
                                      isDisabled = true;
                                    });
                                  }
                                },
                                enabled: true,
                                pinAnimationType: PinAnimationType.scale,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter OTP';
                                  }
                                  return null;
                                },
                              ),
                            ]),
                          ),
                          const SizedBox(height: 40),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: wait == false
                                  ? Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        // Adjust the radius here
                                        border: Border.all(
                                            color:
                                                AppColors.textFieldBorderColor),
                                      ),
                                      child: InkWell(
                                        onTap: null,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 12.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SvgPicture.asset(
                                                'assets/icons/resend_otp.svg', // Replace with your SVG file path
                                                color: AppColors
                                                    .greyColor, // Set color for SVG
                                                height:
                                                    20, // Adjust size if needed
                                                width: 20,
                                              ),
                                              // Add your icon here
                                              const SizedBox(width: 10),
                                              // Space between icon and text
                                              Text(
                                                translate('Resend in') +
                                                    ' $start s',
                                                style: CustomTextStyle
                                                    .GraphikRegular(14,
                                                        AppColors.greyColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        // Adjust the radius here
                                        border: Border.all(
                                            color:
                                                AppColors.textFieldBorderColor),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          if (wait == true) {
                                            setState(() {
                                              _resendOTP(widget.mobilNumber
                                                  .toString());
                                              _pinPutController.text = '';
                                            });
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 12.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SvgPicture.asset(
                                                'assets/icons/resend_otp.svg', // Replace with your SVG file path
                                                color: AppColors
                                                    .textFieldBorderColor, // Set color for SVG
                                                height:
                                                    20, // Adjust size if needed
                                                width: 20,
                                              ),
                                              // Add your icon here
                                              const SizedBox(width: 10),
                                              // Space between icon and text
                                              Text(
                                                'Resend OTP',
                                                style: CustomTextStyle
                                                    .GraphikMedium(
                                                        14, AppColors.black),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),

                          /*SizedBox(height: 20),
                          if (wait == true) ... [
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    // Adjust the radius here
                                    border: Border.all(
                                        color: AppTheme().lineColor),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      if (wait == true) {
                                        setState(() {
                                          //_verifyphone();
                                        });
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 12.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icons/whatsapp_icon.svg', // Replace with your SVG file path
                                            height: 20, // Adjust size if needed
                                            width: 20,
                                          ),
                                          // Add your icon here
                                          SizedBox(width: 10),
                                          // Space between icon and text
                                          Text(
                                            translate('Send via Whatsapp'),
                                            style: TextStyle(
                                                color: AppTheme().secondTextColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          ],*/
                        ],
                      ),
                    ))
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: InkWell(
                    //onTap: _verify_otp,
                    onTap: () => _verify_otp(
                        context,
                        widget.mobilNumber
                            .toString()), // Wrap in an anonymous function

                    /*onTap: () {
                      Navigator.of(context).pushNamed("/create_account");
                    },*/
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: isDisabled
                            ? AppColors.greyColor
                            : AppColors.colorPrimary,
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(255, 179, 179, 179),
                            blurRadius: 3,
                            blurStyle: BlurStyle.outer,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      width: double.infinity,
                      child: Center(
                        child: isDisabled
                            ? Text(
                                'Verify',
                                style: CustomTextStyle.GraphikMedium(
                                    16, AppColors.white),
                              )
                            : isLoading
                                ? Text(
                                    'Wait...',
                                    style: CustomTextStyle.GraphikMedium(
                                        16, AppColors.white),
                                  )
                                : Text(
                                    'Verify',
                                    style: CustomTextStyle.GraphikMedium(
                                        16, AppColors.white),
                                  ),
                      ),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
