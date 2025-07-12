import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Decont/theme/AppTheme.dart';

import '../CustomeTextStyle/custometextstyle.dart';

/*class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool? onborad;

  Future<void> handleRedirect() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get saved language code and user id from SharedPreferences
    String? selectedLangCode = prefs.getString('selected_language_code');
    String? user_token = prefs.getString('user_token');
    print('Stored Employee ID: $user_token');
    print('selectedLangCode: $selectedLangCode');

    Timer(const Duration(seconds: 3), () {
      if (selectedLangCode == null) {
        // If no language selected, navigate to the Language Selection screen
        Navigator.of(context).pushNamedAndRemoveUntil("/language", (route) => false);
      } else if (user_token == null || user_token.isEmpty) {
        // If user is not logged in, navigate to the Login screen
        Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
      } else {
        // If user is logged in, navigate to the Home screen
        Navigator.of(context).pushNamedAndRemoveUntil("/home", (route) => false);
      }
    });
  }


  @override
  void initState() {
    //setupInteractedMessage();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    //Implement animation here
    _animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
    Future.delayed(Duration(seconds: 1), () {
      handleRedirect();
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();
    return SafeArea(
      child: Scaffold(
        body: FadeTransition(
          opacity: _animation,
          child: Center( // Center widget to align image
            child: SizedBox.expand(
              child: Image.asset(
                'assets/splash/splash_new.png',
              ),
            ),
          ),
        ),
      ),
    );
  }
}*/

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool? onborad;
  bool _hasRedirected = false; // Prevent multiple redirects

  Future<void> handleRedirect() async {
    if (_hasRedirected) return; // Exit if redirect has already happened

    _hasRedirected = true; // Set to true to prevent future calls

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedLangCode = prefs.getString('selected_language_code');
    String? user_token = prefs.getString('user_token');

    Timer(const Duration(seconds: 3), () {
      /*if (selectedLangCode == null) {
        Navigator.of(context).pushNamedAndRemoveUntil("/language", (route) => false);
      } else*/

      if (user_token == null || user_token.isEmpty) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil("/login", (route) => false);
      } else {
        Navigator.of(context)
            .pushNamedAndRemoveUntil("/home", (route) => false);
        //Navigator.of(context).pushNamedAndRemoveUntil("/test_screen", (route) => false);
      }
    });
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    // Call handleRedirect with delay and ensure it only runs once
    Future.delayed(const Duration(seconds: 1), handleRedirect);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.repeat(reverse: true); // makes the logo blink

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/decont_splash_screen_images/decont_splash_screen.png',
                fit: BoxFit.cover,
              ),
            ),

            // Foreground content (centered tagline and logo)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 50.0), // Adjust top padding
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        "India's Largest Online Store for Hospitality & Event Wedding Decoration Catering Products.",
                        textAlign: TextAlign.center,
                        style: CustomTextStyle.GraphikMedium(
                            20, AppColors.colorPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _animation.value,
                        child: Image.asset(
                          'assets/decont_splash_screen_images/decont_logo.png',
                          width: 160,
                          height: 160,
                        ),
                      );
                    },
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
