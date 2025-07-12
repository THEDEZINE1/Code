import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import '../CustomeTextStyle/custometextstyle.dart';
import '../theme/AppTheme.dart';


class OtherScreen extends StatefulWidget {
  final String title;
  final String value; // This will hold the HTML content
  const OtherScreen({required this.title, required this.value});

  @override
  _OtherScreenPageState createState() => _OtherScreenPageState();
}

class _OtherScreenPageState extends State<OtherScreen> {
  String return_policy = '';
  String title = '';

  @override
  void initState() {
    return_policy = widget.value;
    title = widget.title;
    super.initState();
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
                      onPressed: () => Navigator.pop(context),
                    ),
                  );
                },
              ),
              backgroundColor: Colors.white,
              elevation: 0.0,
              title: Text(
                title,
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
              Html(
                data: return_policy,
                style: {
                  // Optionally, you can add styling to the HTML content
                  "body": Style(
                      fontSize: FontSize(13.0),
                      fontFamily: 'GraphikRegular',
                      color: AppColors.black)
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
