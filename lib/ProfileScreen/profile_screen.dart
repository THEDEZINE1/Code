import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../CustomeTextStyle/custometextstyle.dart';
import '../theme/AppTheme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../BaseUrl.dart';

String? name = '';
String? last_name = '';
String? email = '';
String? mobile = '';
String? user_token = '';
String? image = '';
String? userID = '';

class ProfileScreenPage extends StatefulWidget {
  @override
  _ProfileScreenPageState createState() => _ProfileScreenPageState();
}

class _ProfileScreenPageState extends State<ProfileScreenPage> {
  final _firstNameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _emailController = TextEditingController();
  Map<String, String> localizedStrings = {};
  String currentLangCode = 'en'; // Default language code (English)

  @override
  void initState() {
    _loadCurrentLanguagePreference();
    _initializeData(); // Call the async method

    super.initState();
  }

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
      last_name = prefs.getString('last_name') ?? '';
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
  void dispose() {
    _firstNameController.dispose();
    _mobileNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> updateprofile(
      String firstName, String mobileNumber, String email) async {
    if (_firstNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please enter username first',
                style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
      );
      return;
    }

    final url = Uri.parse(baseUrl);

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token',
    };

    final Map<String, String> body = {
      'view': 'profile',
      'custID': '$userID',
      'name': firstName,
      'email': email,
      'mobile': mobileNumber,
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Successfully created account
        if (data['result'] == 1) {
          final prefs = await SharedPreferences.getInstance();

          final userData = data['data'];
          await prefs.setString('userID', userData['ID']);
          await prefs.setString('name', userData['name']);
          await prefs.setString('email', userData['email']);
          await prefs.setString('mobile', userData['phone']);

          /*await prefs.setString('name', firstName);
          await prefs.setString('email', email);
          await prefs.setString('mobile', mobileNumber);*/

          Navigator.of(context).pushNamed("/my_account");
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
                translate('My Profile'),
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
      body: Padding(
        padding: const EdgeInsets.only(right: 15.0, left: 15.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /*Stack(
                children: [
                  // CircleAvatar with border
                  Container(
                    width: 130.0,
                    height: 130.0,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme().primaryColor, // Border color
                        width: 2.0, // Border width
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50.0,
                      backgroundImage: AssetImage(
                          'assets/images/dummy_image.png'), // Replace with your image
                      backgroundColor: Colors.grey[200], // Background color
                    ),
                  ),
                  // Camera icon at bottom right
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                        AppTheme().primaryColor, // Background color of the camera icon circle
                        border: Border.all(
                          color: Colors.white, // Border color for the small circle
                          width: 1.0, // Border width for the small circle
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white, // Camera icon color
                        size: 20.0, // Camera icon size
                      ),
                    ),
                  ),
                ],
              ),*/
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
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    //onPressed: updateprofile,
                    onPressed: () async {
                      /*print('First Name: ${_firstNameController.text}');
                    print('Last Name: ${_lastNameController.text}');
                    print('Mobile Number: ${_mobileNumberController.text}');
                    print('Email: ${_emailController.text}');
                    Navigator.of(context).pop("/my_account");*/
                      await updateprofile(_firstNameController.text,
                          _mobileNumberController.text, _emailController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.colorPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      translate('Update'),
                      style: CustomTextStyle.GraphikMedium(16, AppColors.white),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
