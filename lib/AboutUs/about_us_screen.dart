import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Decont/CustomeTextStyle/custometextstyle.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';

import '../BaseUrl.dart';
import '../theme/AppTheme.dart';

String? first_name = '';
String? last_name = '';
String? email = '';
String? mobile = '';
String? user_token = '';
String? image = '';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  Map<String, String> localizedStrings = {};
  String currentLangCode = 'en';
  bool isLoading = false;
  bool hasMoreData = true;
  String _logo = '';
  String _title = '';
  String _description = '';
  List _pages = [];

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
      first_name = prefs.getString('first_name') ?? '';
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

    if (!isLoading) isLoading = true; // Set loading for initial data

    final url = Uri.parse(baseUrl);

    final Map<String, String> body = {
      'view': 'about',
    };

    try {
      final response = await http.post(url, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());
        log('Response data: $data');

        if (data['result'] == 1) {
          // Extract data from the response and provide default values to prevent null errors
          final dashboardData = data['data'];

          final String logo =
              dashboardData['image'] ?? ''; // Default to empty string if null
          final String title = dashboardData['title'] ?? '';
          final String description = dashboardData['text'] ??
              ''; // Assuming 'text' is the description field

          final List<Map<String, String>> links =
              List<Map<String, String>>.from(
            dashboardData['links']?.map((link) {
                  // Safely cast the values to String using 'as String' or provide a default value
                  return {
                    'title': link['title']?.toString() ??
                        '', // Ensure title is a String
                    'link': link['link']?.toString() ??
                        '', // Ensure link is a String
                  };
                }) ??
                [],
          );

          // Call setState to update UI with the fetched data
          setState(() {
            _logo = logo;
            _title = title;
            _description = description;
            _pages = links; // Assuming links represent pages or similar content
          });

          log('Logo URL: $_logo');
        } else {
          // Show error message if result is not 1
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(data['message'] ?? 'Something went wrong',
                    style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
          );
        }
      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${response.reasonPhrase}',
                  style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
        );
      }
    } catch (e) {
      // Log any exceptions
      log('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An unexpected error occurred.',
                style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
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
                'About Us',
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: AppColors.colorPrimary,
            )) // Show loading indicator while fetching data
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo Section
                    const SizedBox(height: 10),

                    /*Image(
                width: 150.0,
                height: 150.0,
                image: NetworkImage(_logo),
              ),*/

                    Container(
                      width: 210.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        // Make it circular if needed
                        image: DecorationImage(
                          image: (_logo.isNotEmpty)
                              ? NetworkImage(_logo)
                              // : const AssetImage('assets/images/logo.png')
                              : const AssetImage(
                                      'assets/decont_splash_screen_images/decont_logo.png')
                                  as ImageProvider,
                          fit: BoxFit.fill, // Adjust fit as necessary
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Title Section
                    Text(
                      _title,
                      style: const TextStyle(fontSize: 18),
                    ),

                    // Description Section
                    Html(
                      data: _description, // Your HTML content
                    ),
                    //Text(_description),
                    const SizedBox(height: 16),

                    // Social Media Links Section
                    /*Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [


                        GestureDetector(
                          onTap: () {
                            if (_socialLinks['facebook'] != null && _socialLinks['facebook']!.isNotEmpty) {
                              log(_socialLinks['facebook']!);
                              _launchInAppWithBrowserOptions(Uri.parse(_socialLinks['facebook']!)); // Replace with your link
                            }
                          },
                          child: SvgPicture.asset(
                            'assets/icons/facebook.svg',
                            // Replace with your SVG file path
                            height: 40, // Adjust size if needed
                            width: 40,
                          ),
                        ),
                        SizedBox(width: 15),

                  GestureDetector(
                    onTap: () {
                      if (_socialLinks['instagram'] != null &&
                          _socialLinks['instagram']!.isNotEmpty) {
                        log(_socialLinks['instagram']!);
                        _launchInAppWithBrowserOptions(Uri.parse(_socialLinks['instagram']!)); // Replace with your link
                      }
                    },
                    child: SvgPicture.asset(
                      'assets/icons/instagram.svg',
                      // Replace with your SVG file path
                      height: 40, // Adjust size if needed
                      width: 40,
                    ),
                  ),

                  SizedBox(width: 15),
                  GestureDetector(
                    onTap: () {
                      if (_socialLinks['twitter'] != null &&
                          _socialLinks['twitter']!.isNotEmpty) {
                        log(_socialLinks['twitter']!);
                        _launchInAppWithBrowserOptions(Uri.parse(_socialLinks['twitter']!)); // Replace with your link
                      }
                    },
                    child: SvgPicture.asset(
                      'assets/icons/twitter.svg',
                      // Replace with your SVG file path
                      height: 40, // Adjust size if needed
                      width: 40,
                    ),
                  ),

                  SizedBox(width: 15),
                  GestureDetector(
                    onTap: () {
                      if (_socialLinks['linkdln'] != null &&
                          _socialLinks['linkdln']!.isNotEmpty) {
                        log(_socialLinks['linkdln']!);
                        _launchInAppWithBrowserOptions(Uri.parse(_socialLinks['linkdln']!)); // Replace with your link
                      }
                    },
                    child: SvgPicture.asset(
                      'assets/icons/linkdln.svg',
                      // Replace with your SVG file path
                      height: 40, // Adjust size if needed
                      width: 40,
                    ),
                  ),

                  SizedBox(width: 15),
                  GestureDetector(
                    onTap: () {
                      if (_socialLinks['youtube'] != null &&
                          _socialLinks['youtube']!.isNotEmpty) {
                        log(_socialLinks['youtube']!);
                        _launchInAppWithBrowserOptions(Uri.parse(_socialLinks['youtube']!)); // Replace with your link
                      }
                    },
                    child: SvgPicture.asset(
                      'assets/icons/youtube.svg',
                      // Replace with your SVG file path
                      height: 40, // Adjust size if needed
                      width: 40,
                    ),
                  ),
                  // Add more icons as needed
                ],
              ),

              SizedBox(height: 20),*/

                    // Pages ListView Section
                    if (_pages.isNotEmpty)
                      ListView.builder(
                        shrinkWrap:
                            true, // Prevent ListView from taking full scroll
                        physics:
                            const NeverScrollableScrollPhysics(), // Disable scrolling in ListView itself
                        itemCount: _pages.length,
                        itemBuilder: (context, index) {
                          final page = _pages[index];
                          return Column(
                            children: [
                              ListTile(
                                title: Text(page['title']),
                                onTap: () => _launchInBrowserView(Uri.parse(
                                    page['link'])), // Open link on tap
                              ),
                              const Divider(), // Add Divider below each ListTile
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  void openFacebook(String facebookLink) async {
    final Uri uri = Uri.parse(facebookLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Handle the error gracefully, maybe show a message to the user
    }
  }

  /*void openFacebook(String facebookLink) async {
    final Uri uri = Uri.parse(facebookLink);
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      // Handle the error if the URL can't be launched
      throw 'Could not launch $facebookLink';
    }
  }*/

// Method to open the link in a browser
  Future<void> _launchInBrowserView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchInAppWithBrowserOptions(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $url');
    }
  }

  void _openLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Show an error message if the link cannot be opened
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Could not launch: $url',
                style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
      );
    }
  }
}
