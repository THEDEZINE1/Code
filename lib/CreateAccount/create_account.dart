import 'dart:developer';

import 'package:Decont/login/Otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding/decoding
import '../BaseUrl.dart';
import '../CustomeTextStyle/custometextstyle.dart';
import '../theme/AppTheme.dart';

class CreateAccountScreen extends StatefulWidget {
  final String? mobileNumberUser;
  const CreateAccountScreen({super.key, required this.mobileNumberUser});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  Map<String, String> localizedStrings = {};
  String? langCode;
  String mobileNumber = '';

  @override
  void initState() {
    _loadCurrentLanguagePreference();
    _mobileNumberController.text = widget.mobileNumberUser!;
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
    langCode = prefs.getString('selected_language_code');
    if (langCode != null) {
      _loadLanguage(langCode!);
    }
  }

  String translate(String key) {
    return localizedStrings[key] ?? key;
  }

  Future<void> createAccount() async {
    final String firstName = _firstNameController.text;
    final String lastName = _lastNameController.text;
    final String mobileNumber = _mobileNumberController.text;
    final String email = _emailController.text;

    await createAccountApi(firstName, lastName, mobileNumber, email);
  }

  Future<void> createAccountApi(String firstName, String lastName,
      String mobileNumber, String email) async {
    final url = Uri.parse(baseUrl);

    final Map<String, String> body = {
      'sname': firstName,
      'email': email,
      'mobile': mobileNumber,
      'app_type': 'android',
      'action': 'signup',
      'view': 'login',
      's_refer_code': lastName,
    };

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    print(body);

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());
        log('Response data: $data');

        // Successfully created account
        if (data['result'] == 1) {
          Get.to(Otp_screen(
            mobilNumber: _mobileNumberController.text.toString(),
          ));
          // Navigator.pushNamed(context, '/otp',
          //     arguments: _mobileNumberController.text);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.green,
              content: Text(
                data['message'],
                style: CustomTextStyle.GraphikMedium(16, AppColors.white),
              ),
            ),
          );

          // Navigator.of()
          //     .pushNamed("/otp", arguments: _mobileNumberController.text);

          // Show a success message
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
        // Handle error
        print('Failed to create account. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // Handle any errors
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // mobileNumber = ModalRoute.of(context)!.settings.arguments as String;

    // _mobileNumberController.text = mobileNumber;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.colorPrimary,
    ));

    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme().whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.width * 0.2,
              ),
              Text(
                translate('Create account'),
                style:
                    CustomTextStyle.GraphikMedium(18, AppColors.colorPrimary),
              ),
              const SizedBox(height: 10),
              Text(
                translate(
                    'You’re almost there! Create your new account for +91 ${_mobileNumberController.text.toString()}'),
                style: CustomTextStyle.GraphikRegular(14, AppColors.greyColor),
              ),
              const SizedBox(height: 30),

              // Adding the gender selection

              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: translate('Name'),
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
                cursorColor: AppColors.colorPrimary,
                style: CustomTextStyle.GraphikRegular(14, AppColors.black),
              ),

              const SizedBox(height: 20),
              TextField(
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
                cursorColor: AppColors.colorPrimary,
                style: CustomTextStyle.GraphikRegular(14, AppColors.black),
              ),
              const SizedBox(height: 20),
              TextField(
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
                cursorColor: AppColors.colorPrimary,
                style: CustomTextStyle.GraphikRegular(14, AppColors.black),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Refer Code',
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
                cursorColor: AppColors.colorPrimary,
                style: CustomTextStyle.GraphikRegular(14, AppColors.black),
              ),

              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(
                      unselectedWidgetColor: AppTheme().primaryColor,
                    ),
                    child: Checkbox(
                      value: true,
                      onChanged: null,
                      fillColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        return AppColors.colorPrimary;
                      }),
                      checkColor: AppTheme().whiteColor,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'I agree to the privacy policy, Terms of Service & Terms of Business',
                      style: CustomTextStyle.GraphikRegular(
                          12, AppColors.greyColor),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    createAccount();
                  },
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
                  child: Text(
                    translate('Continue'),
                    style: CustomTextStyle.GraphikMedium(14, AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
