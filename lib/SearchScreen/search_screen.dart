import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../BaseUrl.dart';
import '../CustomeTextStyle/custometextstyle.dart';
import '../productDetails/product_details_screen.dart';
import '../theme/AppTheme.dart';

String? user_token = '';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _results = [];
  Map<String, String> localizedStrings = {};
  String currentLangCode = 'en';
  bool hasMoreData = true;
  bool isLoading = false;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
    requestMicPermission();
    _loadCurrentLanguagePreference();
    _initializeData();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
      if (_searchController.text.isNotEmpty) {
        _dashboardData();
      } else {
        setState(() {
          _results.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onError: (val) {
          print('Speech Error: $val');
          setState(() => _isListening = false);
        },
        onStatus: (val) {
          print('Speech Status: $val');
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        debugLogging: true,
      );
      if (!_speechAvailable) {
        print("Speech recognition not available");
      } else {
        print("Speech recognition initialized successfully");
      }
    } catch (e) {
      print("Error initializing speech: $e");
      setState(() => _speechAvailable = false);
    }
    setState(() {});
  }

  Future<void> _listen() async {
    // Check microphone permission status
    var status = await Permission.microphone.status;

    if (!status.isGranted) {
      // If permission is not granted, show a dialog to prompt user to enable it
      _showPermissionDialog();
      return;
    }

    if (!_isListening) {
      // Check if speech is available first
      if (!_speechAvailable) {
        await _initSpeech();
      }

      if (_speechAvailable) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _searchController.text = val.recognizedWords;
              _searchQuery = val.recognizedWords;
            });

            if (val.recognizedWords.isNotEmpty) {
              _dashboardData();
            }
          },
          listenFor: Duration(seconds: 30),
          pauseFor: Duration(seconds: 5),
          partialResults: true,
          localeId: "en_US",
          onSoundLevelChange: (level) => print("Sound level: $level"),
        );
      } else {
        print("Speech recognition not available");
        _showErrorSnackBar("Speech recognition not available");
      }
    } else {
      // Stop listening
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Microphone Permission Required',
            style: CustomTextStyle.GraphikMedium(16, AppColors.black),
          ),
          content: Text(
            'Please enable microphone permission in settings to use voice search.',
            style: CustomTextStyle.GraphikRegular(14, AppColors.black),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style:
                    CustomTextStyle.GraphikMedium(14, AppColors.colorPrimary),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                // Open app settings
                await openAppSettings();
              },
              child: Text(
                'Open Settings',
                style:
                    CustomTextStyle.GraphikMedium(14, AppColors.colorPrimary),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> requestMicPermission() async {
    var status = await Permission.microphone.status;
    print("Current mic permission status: $status");

    if (!status.isGranted) {
      var result = await Permission.microphone.request();
      print("Permission request result: $result");

      if (result != PermissionStatus.granted) {
        _showErrorSnackBar(
            "Microphone permission is required for voice search");
        return;
      }
    }

    // Initialize speech after permission is granted
    await _initSpeech();
  }

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      user_token = prefs.getString('user_token') ?? '';
    });
  }

  Future<void> _dashboardData() async {
    if (_searchController.text.isEmpty) {
      setState(() {
        _results.clear();
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(baseUrl);

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token',
    };

    final Map<String, String> body = {
      'view': 'search_new',
      //  'pagecode': '0',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());

        if (data['status'] == 'success') {
          _results.clear();

          if (data['data'] is List) {
            final List<dynamic> allData = data['data'];

            setState(() {
              _results = allData
                  .where((item) => item['name']
                      .toString()
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase()))
                  .map<Map<String, dynamic>>((item) {
                return {
                  'productID': item['productID'].toString(),
                  'name': item['name'],
                };
              }).toList();
            });
          }
        } else {
          _showErrorSnackBar('Error: ${data['message']}');
        }
      } else {
        _showErrorSnackBar('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: CustomTextStyle.GraphikMedium(14, AppColors.white),
        ),
      ),
    );
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

  Widget _buildSearchTextField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        if (value.isNotEmpty) {
          _dashboardData();
        } else {
          setState(() {
            _results.clear();
          });
        }
      },
      decoration: InputDecoration(
        labelText: 'Find 20000+ Products',
        labelStyle: CustomTextStyle.GraphikMedium(14, AppColors.greyColor),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Clear button
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _results.clear();
                  });
                },
              ),
            // Voice search button
            GestureDetector(
              onTap: _listen,
              child: Container(
                padding: EdgeInsets.all(8),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? Colors.red : Colors.grey,
                ),
              ),
            ),
          ],
        ),
        border: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.textFieldBorderColor)),
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
    );
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
                  return RotatedBox(
                    quarterTurns: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
              backgroundColor: Colors.white,
              elevation: 0.0,
              title: Text(
                'Search',
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
      backgroundColor: AppColors.mainBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                _buildSearchTextField(),
                // Status indicator for speech recognition
                if (_isListening)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.colorPrimary,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppColors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.mic, color: AppColors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Listening...',
                          style: CustomTextStyle.GraphikMedium(
                              12, AppColors.white),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                color: AppColors.colorPrimary,
              ),
            ),
          Expanded(
            child: _results.isEmpty &&
                    !isLoading &&
                    _searchController.text.isNotEmpty
                ? Center(
                    child: Text(
                      'No results found',
                      style: CustomTextStyle.GraphikMedium(16, AppColors.black),
                    ),
                  )
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      ProductDetailScreen(
                                    product_id: _results[index]['productID'],
                                  ),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;

                                    var tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));
                                    var offsetAnimation =
                                        animation.drive(tween);

                                    return SlideTransition(
                                      position: offsetAnimation,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                            child: ListTile(
                              title: Text(
                                _results[index]['name'],
                                style: CustomTextStyle.GraphikRegular(
                                    16, AppColors.black),
                              ),
                            ),
                          ),
                          const Divider(
                            thickness: 1,
                            color: AppColors.greyColor,
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
