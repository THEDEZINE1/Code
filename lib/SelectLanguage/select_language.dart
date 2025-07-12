import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../CustomeTextStyle/custometextstyle.dart';
import '../theme/AppTheme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login/login_screen.dart';

class SelectLanguage extends StatefulWidget {
  const SelectLanguage({super.key});

  @override
  State<SelectLanguage> createState() => _SelectLanguage();
}

class _SelectLanguage extends State<SelectLanguage> {
  List<Map<String, String>> languages = [
    {
      'name': 'English',
      'icon': 'assets/icons/first_language.svg',
      'code': 'en'
    },
    {'name': 'हिंदी', 'icon': 'assets/icons/second_language.svg', 'code': 'hi'},
    {
      'name': 'ગુજરાતી',
      'icon': 'assets/icons/third_language.svg',
      'code': 'gu'
    },
    {'name': 'தமிழ்', 'icon': 'assets/icons/four_language.svg'},
    {'name': 'മലയാളം', 'icon': 'assets/icons/five_language.svg'},
    {'name': 'తెలుగు', 'icon': 'assets/icons/six_language.svg'},
    {'name': 'ಕನ್ನಡ', 'icon': 'assets/icons/six_language.svg'},
    {'name': 'मराठी', 'icon': 'assets/icons/second_language.svg'},
    {'name': 'বাংলা', 'icon': 'assets/icons/nine_language.svg'},
  ];

  String selectedLanguage = 'English';
  String currentLangCode = 'en'; // Default language code (English)
  Map<String, String> localizedStrings = {};
  final AppTheme appTheme = AppTheme();

  @override
  void initState() {
    super.initState();
    _loadLanguage('en'); // Load English by default
  }

  Future<void> _loadLanguage(String langCode) async {
    final String jsonString =
        await rootBundle.loadString('assets/lang/$langCode.json');
    setState(() {
      localizedStrings = Map<String, String>.from(json.decode(jsonString));
      currentLangCode = langCode;
    });
  }

  String translate(String key) {
    return localizedStrings[key] ?? key;
  }

  Future<void> _saveLanguageCode(String langCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language_code', langCode);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.colorPrimary,
    ));
    return Scaffold(
      backgroundColor: AppTheme().whiteColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(
          kToolbarHeight + 1.0, // AppBar default height + container height
        ),
        child: Column(
          children: [
            AppBar(
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              backgroundColor: Colors.white,
              elevation: 0.0,
              title: Text(
                'Select Language',
                style: CustomTextStyle.GraphikMedium(16, AppColors.black),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          // Global padding for the entire screen
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(
                height: 90.0, // Set the height
                child: Container(
                  child: Image.asset(
                    fit: BoxFit.cover,
                      "assets/decont_splash_screen_images/decont_logo.png"),
                ),
              ),

              const SizedBox(height: 15),
              Text(
                'Choose the language',
                style: CustomTextStyle.GraphikMedium(20, AppColors.black),
              ),
              Text(
                'Select the language to get started',
                style: CustomTextStyle.GraphikRegular(
                    16, AppColors.secondTextColor),
              ),
              const SizedBox(height: 20), // Adds space between text and grid
              Expanded(
                child: GridView.builder(
                  physics: const ClampingScrollPhysics(),
                  // Ensure scrolling is enabled
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Number of columns in the grid
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final language = languages[index];
                    final languageName = language['name']!;
                    final isSelected = languageName == selectedLanguage;
                    Expanded(
                      child: Column(children: [
                        const Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.only(top: 5.0),
                            child: Icon(
                              Icons.check_circle,
                              // Replace with the desired icon
                              color: AppColors.white,
                              size: 20, // Adjust the icon size as needed
                            ),
                          ),
                        ),
                      ]),
                    );

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedLanguage = languageName;
                          _loadLanguage(
                              language['code']!); // Load selected language
                          _saveLanguageCode(
                              language['code']!); // Save selected language
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.colorPrimary
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color:
                                isSelected ? AppColors.white : AppColors.black,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Expanded(
                              child: Column(children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: 10.0, right: 5.0),
                                    child: Icon(
                                      Icons.check_circle,
                                      // Replace with the desired icon
                                      color: Colors.white,
                                      size:
                                          20, // Adjust the icon size as needed
                                    ),
                                  ),
                                ),
                              ]),
                            ),

                            SvgPicture.asset(language['icon']!,
                                width: 20,
                                height: 20,
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.greyColor),
                            const SizedBox(height: 10), // Space between icon and text
                            Text(
                              language['name']!,
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected
                                     ? AppColors.white
                                    : AppColors.greyColor,
                              ),
                            ),
                            const SizedBox(height: 20), // Space between icon and text
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10), // Adds space between grid and button
              SizedBox(
                width: double.infinity, // Button takes up full width
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colorPrimary,
                    // Background color of the button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          5), // Rounded corners with radius
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15), // Vertical padding for button content
                  ),
                  child: Text(
                    'Start',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme().whiteColor,
                    ),
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
