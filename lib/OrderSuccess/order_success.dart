import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../OrderDetailsScreen/order_details_screen.dart';
import '../theme/AppTheme.dart';

class OrderSuccessScreen extends StatefulWidget {
  @override
  _OrderSuccessScreenState createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {

  @override
  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final message1 = args['message_1'];
    final message2 = args['message_2'];
    final orderId = args['orderId'];
    final status = args['status'];


    return WillPopScope(
        onWillPop: () async {
      // Call the onBack callback to set the index to 0
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('cart_count', 0);
          Navigator.of(context).pushReplacementNamed('/home');


      return false;
    },
    child: Scaffold(
      backgroundColor: AppTheme().whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(15.0),
                margin: const EdgeInsets.only(top: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                    crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
                    children: <Widget>[

                      Lottie.asset(
                        status == 'captured'
                            ? 'assets/animations/success.json'
                            : 'assets/animations/fail_new.json',
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        message1,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center, // Center text
                      ),
                      const SizedBox(height: 10),
                      Text(
                        message2,
                        textAlign: TextAlign.center, // Center text
                      ),
                      const SizedBox(height: 16.0),
                      // ListView needs a height constraint
                    ],
                  )
                /*child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                  crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
                  children: <Widget>[
                    Icon(
                      Icons.check_circle_outline,
                      size: 100,
                      color: Colors.green,
                    ),
                    SizedBox(height: 20),
                    Text(
                      message1,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center, // Center text
                    ),

                    SizedBox(height: 10),
                    Text(
                      message2,
                      textAlign: TextAlign.center, // Center text
                    ),
                    SizedBox(height: 16.0),
                    // ListView needs a height constraint
                  ],
                ),*/
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[

                  Container(
                    color: AppTheme().whiteColor,
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      width: double.infinity, // Button takes up full width
                      child: ElevatedButton(
                        onPressed: () {
                          // Add your button action here
                          Navigator.of(context).push(PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                OrderDetailScreen(product_id: orderId.toString(), home: 'Home'),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;

                              var tween =
                              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);

                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme().secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(
                          'View Order',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme().whiteColor,
                          ),
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
      ),
    );
  }
}