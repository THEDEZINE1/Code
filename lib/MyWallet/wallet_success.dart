import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Decont/MyWallet/wallet_history_Screen.dart';

import '../CustomeTextStyle/custometextstyle.dart';
import '../theme/AppTheme.dart';

class WalletSuccessScreen extends StatefulWidget {
  const WalletSuccessScreen({super.key});

  @override
  _WalletSuccessScreenState createState() => _WalletSuccessScreenState();
}

class _WalletSuccessScreenState extends State<WalletSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final message1 = args['message_1'];
    final message2 = args['message_2'];
    final orderId = args['orderId'];
    final status = args['status'];

    return WillPopScope(
      onWillPop: () async {
        // Call the onBack callback to set the index to 0

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                WalletHistoryScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
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
          ),
        );
        // Pop the current screen from the navigation stack
        return false; // Prevents the default back button behavior (returning to previous screen)
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
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Center vertically
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // Center horizontally
                      children: <Widget>[
                        // Conditional icon based on status
                        Icon(
                          status == 'captured'
                              ? Icons.check_circle_outline
                              : Icons
                                  .close, // Show check_circle_outline for captured and close for failed
                          size: 100,
                          color: status == 'captured'
                              ? AppColors.darkgreenColor
                              : AppColors
                                  .red, // Green for captured, Red for failed
                        ),
                        const SizedBox(height: 20),
                        Text(
                          message1,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: AppColors.black),
                          textAlign: TextAlign.center, // Center text
                        ),
                        const SizedBox(height: 10),
                        Text(
                          message2,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: AppColors.black),
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
                            Navigator.of(context).pushReplacement(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        WalletHistoryScreen(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;

                                  var tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);

                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.colorPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: Text(
                            'Back to Wallet',
                            style: CustomTextStyle.GraphikMedium(
                                16, AppColors.white),
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
