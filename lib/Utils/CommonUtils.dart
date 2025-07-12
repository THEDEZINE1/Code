import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommonUtils {
  // Language Map to store loaded translations
  static Map<String, String> localizedStrings = {};
  static String? currentLangCode;

  // Method to load language file based on langCode
  static Future<void> loadLanguage(String langCode) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/lang/$langCode.json');
      localizedStrings = Map<String, String>.from(json.decode(jsonString));
    } catch (e) {
      print("Error loading language file: $e");
    }
  }

  // Method to load and set current language preference from SharedPreferences
  static Future<void> loadCurrentLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final String? langCode = prefs.getString('selected_language_code');
    print('selectedLangCode: $langCode');

    if (langCode != null && langCode.isNotEmpty) {
      currentLangCode = langCode;
      await loadLanguage(currentLangCode!);
    }
  }

  // Method to translate a given key
  static String translate(String key) {
    return localizedStrings[key] ?? key;
  }

  // User data variables
  static String firstName = '';
  static String lastName = '';
  static String email = '';
  static String mobile = '';
  static String userToken = '';
  static String image = '';

  // Method to load user data from SharedPreferences
  static Future<void> initializeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    firstName = prefs.getString('first_name') ?? '';
    lastName = prefs.getString('last_name') ?? '';
    email = prefs.getString('email') ?? '';
    mobile = prefs.getString('mobile') ?? '';
    userToken = prefs.getString('user_token') ?? '';
    image = prefs.getString('image') ?? '';
  }

  // Method to clear user data (optional, for logout)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    firstName = '';
    lastName = '';
    email = '';
    mobile = '';
    userToken = '';
    image = '';
  }
}