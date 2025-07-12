import 'dart:convert';
import 'dart:developer';
import 'package:Decont/CreateAccount/create_account.dart';
import 'package:Decont/login/Otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../BaseUrl.dart';
import '../CustomeTextStyle/custometextstyle.dart';
import '../theme/AppTheme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String currentLangCode = 'en'; // Default language code (English)

  bool _isDialogShowing = false;

  Map<String, String> localizedStrings = {};
  final TextEditingController _customerMobileNumber =
      TextEditingController(); // Controller to track text input
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadLanguage(currentLangCode);
    _loadCurrentLanguagePreference();
    Future.delayed(const Duration(milliseconds: 200), () {
      FocusScope.of(context).requestFocus(_focusNode);
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

  Future<void> _login(BuildContext context) async {
    final url = Uri.parse(baseUrl);

    final Map<String, String> body = {
      'mobile': _customerMobileNumber.text,
      'app_type': 'Android',
      'action': 'login',
      'view': 'login',
    };

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    _showLoadingDialog(context);

    try {
      final response = await http.post(url, headers: headers, body: body);

      _hideLoadingDialog(context); // Always hide loader safely

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());

        if (data['result'] == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.green,
              content: Text(
                data['message'],
                style: CustomTextStyle.GraphikMedium(16, AppColors.white),
              ),
            ),
          );
          Get.to(Otp_screen(mobilNumber: _customerMobileNumber.text.toString(),));

        } else {
          if (data['message'] == "Please Enter Mobile.") {
            _showSnackBar(context, "Please enter your mobile number.");
          } else {
            _showErrorDialog(context); // Generic error dialog
          }
        }
      } else {
        _showSnackBar(context, 'Login failed: ${response.reasonPhrase}');
      }
    } catch (e) {
      _hideLoadingDialog(context);
      _showSnackBar(context, 'An error occurred: $e');
      log('data: $e');
    }
  }

  void _showLoadingDialog(BuildContext context) {
    _isDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.colorPrimary),
      ),
    );
  }

  void _hideLoadingDialog(BuildContext context) {
    if (_isDialogShowing) {
      Navigator.of(context, rootNavigator: true).pop();
      _isDialogShowing = false;
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: CustomTextStyle.GraphikMedium(16, AppColors.white),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: Theme.of(context)
              .copyWith(dialogBackgroundColor: AppColors.white),
          child: AlertDialog(
            backgroundColor: AppColors.white,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'Number Not Registered',
              style: CustomTextStyle.GraphikMedium(16, AppColors.black),
            ),
            content: Text(
              'The number you entered is not registered. Please try again or sign up.',
              style:
                  CustomTextStyle.GraphikRegular(16, AppColors.secondTextColor),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                },
                child: Text(
                  'Change Number',
                  style:
                      CustomTextStyle.GraphikMedium(14, AppColors.colorPrimary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigator.of(context).pushNamed(
                  //   '/create_account',
                  //   arguments: _customerMobileNumber.text,
                  // );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateAccountScreen(
                          mobileNumberUser:
                              _customerMobileNumber.text.toString()),
                    ),
                  );
                },
                child: Text(
                  'Sign Up',
                  style:
                      CustomTextStyle.GraphikMedium(14, AppColors.colorPrimary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  // Future<void> _login(BuildContext context) async {
  //   final url = Uri.parse(baseUrl);
  //
  //   final Map<String, String> body = {
  //     'mobile': _customerMobileNumber.text,
  //     'app_type': 'Android',
  //     'action': 'login',
  //     'view': 'login',
  //   };
  //
  //   final Map<String, String> headers = {
  //     'Content-Type': 'application/x-www-form-urlencoded',
  //   };
  //
  //   try {
  //     final response = await http.post(url, headers: headers, body: body);
  //
  //     // Close loading dialog
  //   //  Navigator.of(context, rootNavigator: true).pop();
  //
  //     print('Response status: ${response.statusCode}');
  //     print('Response body: ${response.body}');
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body.trim());
  //       if (data['result'] == 1) {
  //         Navigator.of(context)
  //             .pushNamed("/otp", arguments: _customerMobileNumber.text);
  //       } else {
  //         if(_customerMobileNumber.text.isEmpty){
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text(
  //                 data,
  //                 style:  CustomTextStyle.GraphikMedium(
  //                     16, AppColors.white),
  //               ),
  //             ),
  //           );
  //         }
  //         else{
  //           _showErrorDialog(context);
  //
  //         }
  //       }
  //     } else {
  //       _showSnackBar(context, 'Login failed: ${response.reasonPhrase}');
  //     }
  //   } catch (e) {
  //     Navigator.of(context, rootNavigator: true).pop(); // Close loading
  //     _showSnackBar(context, 'An error occurred: $e');
  //     log('data: $e');
  //   }
  // }
  //
  // void _showSnackBar(BuildContext context, String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         message,
  //           style:  CustomTextStyle.GraphikMedium(
  //               16, AppColors.white),
  //       ),
  //     ),
  //   );
  // }
  //
  // // Function to show error dialog
  // void _showErrorDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         backgroundColor: AppColors.white,
  //         surfaceTintColor: Colors.transparent,
  //         title: Text(
  //           'Number Not Registered',
  //           style:  CustomTextStyle.GraphikMedium(
  //               18, AppColors.black),
  //         ),
  //         content: Text(
  //           'The number you entered is not registered. Please try again or sign up.',
  //         style:  CustomTextStyle.GraphikRegular(
  //               16, AppColors.black),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               // Action for changing number
  //               Navigator.pop(context);
  //
  //             },
  //             child: Text(
  //               'Change Number',
  //               style:  CustomTextStyle.GraphikMedium(
  //                   16, AppColors.colorPrimary),
  //             ),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               // Action for signing up
  //               Navigator.pop(context); // Close the dialog
  //               Navigator.of(context).pushNamed('/create_account',
  //                   arguments:
  //                       _customerMobileNumber.text); // Navigate to sign-up page
  //             },
  //             child: Text(
  //               'Sign Up',
  //               style:  CustomTextStyle.GraphikMedium(
  //                   16, AppColors.colorPrimary),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.colorPrimary,
    ));

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Expanded(
              //       child: InkWell(
              //         onTap: ()  {
              //          Get.to(const Home());
              //         },
              //         child: Text(
              //           'Skip',
              //           textAlign: TextAlign.end,
              //           style:
              //               CustomTextStyle.GraphikMedium(16, AppColors.black),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),

              SizedBox(
                height: 90.0,
                child: Image.asset(
                  "assets/decont_splash_screen_images/decont_logo.png",
                  fit: BoxFit.cover,
                  width: 120,
                  height: 120,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                translate('login_or_signup'),
                style:
                    CustomTextStyle.GraphikMedium(18, AppColors.colorPrimary),
              ),
              const SizedBox(height: 10),
              Text(
                translate('enter_phone_number'),
                style: CustomTextStyle.GraphikRegular(14, AppColors.greyColor),
              ),
              const SizedBox(height: 30),
              Container(
                decoration: const BoxDecoration(color: AppColors.white),
                child: Stack(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: TextFormField(
                        cursorColor: AppColors.colorPrimary,
                        controller: _customerMobileNumber,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          labelText: translate('mobile_number'),
                          labelStyle: CustomTextStyle.GraphikMedium(
                              14, AppColors.greyColor),
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.textFieldBorderColor)),
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
                        style:
                            CustomTextStyle.GraphikRegular(14, AppColors.black),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        color: AppColors.white,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  //onPressed: () => _login(context), // Wrap in an anonymous function
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _login(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colorPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(translate('Continue'),
                      style:
                          CustomTextStyle.GraphikMedium(14, AppColors.white)),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                translate('privacy_policy'),
                textAlign: TextAlign.center,
                style: CustomTextStyle.GraphikRegular(14, AppColors.greyColor),
              ),
              const SizedBox(
                  height: 20), // Ensure there's some space at the bottom
            ],
          ),
        ),
      ),
    );
  }
}
