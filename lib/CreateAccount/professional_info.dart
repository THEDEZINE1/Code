import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/AppTheme.dart';

class ProfessionalScreen extends StatefulWidget {
  const ProfessionalScreen({super.key});

  @override
  State<ProfessionalScreen> createState() => _ProfessionalScreenState();
}

class _ProfessionalScreenState extends State<ProfessionalScreen> {

  final TextEditingController _emailController = TextEditingController();
  final List<String> _emailOptions = [
    'example1@example.com',
    'example2@example.com',
    'example3@example.com',
  ]; // Example list of email options

  Map<String, String> localizedStrings = {};
  String? langCode;

  @override
  void initState() {
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
    langCode = prefs.getString('selected_language_code');
    if (langCode != null) {
      _loadLanguage(langCode!);
    }
  }

  String translate(String key) {
    return localizedStrings[key] ?? key;
  }

  void _showEmailOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Select Email', style: TextStyle(fontSize: 20)),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _emailOptions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_emailOptions[index], style: const TextStyle(fontSize: 16)),
                  onTap: () {
                    setState(() {
                      _emailController.text = _emailOptions[index];
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  //api calling
  /*final TextEditingController _emailController = TextEditingController();
  List<String> _emailOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchEmailOptions(); // Fetch email options when the widget is initialized
  }

  Future<void> _fetchEmailOptions() async {
    try {
      final response = await http.get(Uri.parse('https://api.example.com/emails'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _emailOptions = List<String>.from(data.map((item) => item['email'])); // Adjust based on API response structure
        });
      } else {
        // Handle the error
        print('Failed to load email options');
      }
    } catch (e) {
      // Handle the exception
      print('Exception occurred: $e');
    }
  }

  void _showEmailOptionsDialog() {
    // Hide the keyboard before showing the dialog
    FocusScope.of(context).unfocus();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select Email', style: TextStyle(fontSize: 20)),
              IconButton(
                icon: Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _emailOptions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_emailOptions[index], style: TextStyle(fontSize: 16)),
                  onTap: () {
                    setState(() {
                      _emailController.text = _emailOptions[index];
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }*/


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppTheme().primaryColor,
    ));

    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme().whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 60.0), // Padding below the image
                        child: GestureDetector(
                          onTap: () {
                            //Navigator.of(context).pushNamed("/home"); // Replace with your desired route
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              "/home",
                                  (Route<dynamic> route) => false, // This will clear all previous routes
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Skip',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme().secondTextColor),
                              ),
                              const SizedBox(width: 8), // Add some space between the text and the icon
                              SvgPicture.asset(
                                'assets/icons/right_icon.svg', // Replace with your SVG asset path
                                width: 12, // Set the width of the SVG icon
                                height: 12, // Set the height of the SVG icon
                                color: AppTheme().secondTextColor, // Optional: set the color of the SVG icon
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.width * 0.2,
                    ),
                    Text(
                      translate('Proffession info'),
                      style: TextStyle(
                          fontSize: 24,
                          color: AppTheme().firstTextColor),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
                      style: TextStyle(
                          fontSize: 14,
                          color: AppTheme().secondTextColor),
                    ),
                    const SizedBox(height: 30),
                    const SizedBox(height: 20),
                    TextField(
                      readOnly: true,
                      autofocus: false,
                      showCursor: false,
                      controller: _emailController,
                      onTap: _showEmailOptionsDialog, // Show dialog on tap
                      enableInteractiveSelection: false, // Disable text selection and cursor
                      decoration: InputDecoration(
                        labelText: translate('Proffession info'),
                        labelStyle: TextStyle(
                          color: AppTheme().secondTextColor,
                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme().placeHolderColor)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppTheme().placeHolderColor,
                            width: 1.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppTheme().placeHolderColor,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 20),
                    TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: translate('Lisence number'),
                        labelStyle: TextStyle(
                          color: AppTheme().secondTextColor,
                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme().placeHolderColor)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppTheme().placeHolderColor,
                            width: 1.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppTheme().placeHolderColor,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed("/login");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Set text color
                        surfaceTintColor: AppTheme().whiteColor,
                        side: BorderSide(color: AppTheme().secondaryColor, width: 1), // Border color and width
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5), // Rounded corners with radius
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15), // Vertical padding for button content
                      ),
                      child: Text(
                        translate('Prev'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black, // Set text color directly
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15), // Spacing between buttons
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Action for the second button
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          "/home",
                              (Route<dynamic> route) => false, // This will clear all previous routes
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme().secondaryColor, // Background color of the button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5), // Rounded corners with radius
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15), // Vertical padding for button content
                      ),
                      child: Text(
    translate('Save'),
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
          ],
        ),
      ),
    );
  }
}