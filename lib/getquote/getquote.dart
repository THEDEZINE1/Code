import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert'; // For JSON encoding/decoding
import '../BaseUrl.dart';
import '../CustomeTextStyle/custometextstyle.dart';
import '../theme/AppTheme.dart';

String? name = '';
String? email = '';
String? mobile = '';
String? user_token = '';
String? image = '';

class GetQuote extends StatefulWidget {
  final String? productName;
  const GetQuote({super.key, required this.productName});

  @override
  State<GetQuote> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<GetQuote> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  Map<String, String> localizedStrings = {};
  String? langCode;

  @override
  void initState() {
    _loadCurrentLanguagePreference();
    _initializeData();

    super.initState();
  }

  _launchPhone(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not dial $phoneNumber';
    }
  }

  // Function to launch the email client
  _launchEmail(String email) async {
    final url = 'mailto:$email';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not send email to $email';
    }
  }

  Future<void> _initializeData() async {
    // Load user preferences and initialize data
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
      email = prefs.getString('email') ?? '';
      mobile = prefs.getString('mobile') ?? '';
      user_token = prefs.getString('user_token') ?? '';
      image = prefs.getString('image') ?? '';
    });

    _firstNameController.text = '$name';
    _emailController.text = '$email';
    _mobileNumberController.text = '$mobile';
    //_companyController.text = widget.address!.company;
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
    langCode = prefs.getString('selected_language_code');
    if (langCode != null) {
      _loadLanguage(langCode!);
    }
  }

  String translate(String key) {
    return localizedStrings[key] ?? key;
  }

  Future<void> ContactUs() async {
    final String firstName = _firstNameController.text;
    final String mobileNumber = _mobileNumberController.text;
    final String email = _emailController.text;
    final String address = _addressController.text;

    await ContactUsApi(firstName, mobileNumber, email, address);
  }

  Future<void> ContactUsApi(String firstName, String mobileNumber, String email,
      String Address) async {
    final url = Uri.parse(baseUrl);

    final Map<String, String> body = {
      'name': firstName,
      'email': email,
      'mobile': mobileNumber,
      'message': Address,
      'view': 'contact',
    };

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());

        // Successfully created account
        if (data['result'] == 1) {
          // Navigate to the OTP screen
          Navigator.of(context).pushNamed("/home");

          // Show a success message
        } else {
          // Handle failed login
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(data['message'],
                    style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
          );
        }
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle any errors
      print('Error: $e');
    }
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
                    onPressed: () => Navigator.pop(context),
                  );
                },
              ),
              backgroundColor: Colors.white,
              elevation: 0.0,
              title: Text(
                'Get Bulk Product Quote TODO',
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Text(
                widget.productName.toString(),
                style: CustomTextStyle.GraphikMedium(16, AppColors.black),
              )),
              SizedBox(
                height: 20,
              ),
              TextField(
                cursorColor: AppColors.colorPrimary,
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: translate('First Name'),
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
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  labelText: translate('Mobile number'),
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
                cursorColor: AppColors.colorPrimary,
                controller: _addressController,
                keyboardType: TextInputType.multiline,
                minLines: 3,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: translate('Message'),

                  labelStyle:
                      CustomTextStyle.GraphikMedium(14, AppColors.greyColor),

                  contentPadding: const EdgeInsets.fromLTRB(
                      12, 16, 12, 0), // Adjust padding
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: ContactUs,
                  /*onPressed: () {
                      Navigator.of(context).pushNamed("/login");
                    },*/
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colorPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(translate('Continue'),
                      style:
                          CustomTextStyle.GraphikMedium(16, AppColors.white)),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Our customer support contact number is',
                      style: CustomTextStyle.GraphikMedium(14, AppColors.black),
                    ),
                    GestureDetector(
                        onTap: () {
                          _launchPhone(
                            '+919284320472',
                          );
                        },
                        child: Text(
                          '+ 91 9284 320 472',
                          style: CustomTextStyle.GraphikRegular(
                              18, AppColors.black),
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    Text('Available from 10:00 am to 6:00 pm. Mon to Sun',
                        style:
                            CustomTextStyle.GraphikMedium(14, AppColors.black)),
                    SizedBox(
                      height: 10,
                    ),
                    Text('Or email us',
                        style:
                            CustomTextStyle.GraphikMedium(14, AppColors.black)),
                    GestureDetector(
                        onTap: () {
                          _launchEmail('support@decornt.com');
                        },
                        child: Text('support@decornt.com',
                            style: CustomTextStyle.GraphikRegular(
                                18, AppColors.black))),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
