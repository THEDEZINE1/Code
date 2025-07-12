import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../CustomeTextStyle/custometextstyle.dart';
import '../theme/AppTheme.dart';

class WebviewAddWalletScreenExample extends StatefulWidget {



  @override
  _WebviewAddWalletScreenExampleState createState() => _WebviewAddWalletScreenExampleState();

}

class _WebviewAddWalletScreenExampleState extends State<WebviewAddWalletScreenExample> {
  late WebViewController _webViewController;
  bool isLoading = true;
  String status = "";
  String message1 = "", message2 = "";
  String orderId = "";
  String webUrl = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    setState(() {
      message1 = args['message_1'] ?? "";
      message2 = args['message_2'] ?? "";
      orderId = args['orderId'] ?? "";
      webUrl = args['webUrl'] ?? "";
    });

    _initializeWebView();
  }

  void _initializeWebView() async {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          setState(() {
            isLoading = true;
          });
        },
        onPageFinished: (url) {
          setState(() {
            isLoading = false;
          });
          _handlePaymentStatus(url);
        },
        /*onWebResourceError: (error) {
          Fluttertoast.showToast(msg: "Error loading page");
        },*/
      ))
      ..loadRequest(Uri.parse(webUrl));
    log('url: ${Uri.parse(webUrl)}');
  }

  void _handlePaymentStatus(String url) {
    if (url.contains("payment_status=success")) {
      _processPayment(url, "captured");
    } else if (url.contains("payment_status=failed")) {
      _processPayment(url, "failed");
    }
  }

  void _processPayment(String url, String paymentStatus) {
    Uri uri = Uri.parse(url);
    setState(() {
      message1 = uri.queryParameters['msg1'] ?? "";
      message2 = uri.queryParameters['msg2'] ?? "";
      status = paymentStatus;
    });
    Navigator.pushReplacementNamed(context, '/wallet_success', arguments: {
      'message_1': message1,
      'message_2': message2,
      'orderId': orderId,
      'status': status,
    });
  }

  Future<bool> _onWillPop() async {
    if (await _webViewController.canGoBack() && status.isEmpty) {
      _webViewController.goBack();
      return false;
    } else {
      _showCancelDialog();
      return true;
    }
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme().whiteColor,
          surfaceTintColor: AppTheme().whiteColor,
          title: const Text("Cancel Transaction"),
          content: const Text("Pressing back would cancel your current transaction. Proceed to cancel?"),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/wallet_success', arguments: {
                  'message_1': message1,
                  'message_2': message2,
                  'orderId': orderId,
                  'status': 'failed',
                });
              },
            ),
            TextButton(
              child: const Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
                        onPressed: () => _showCancelDialog,
                      ),
                    );
                  },
                ),
                backgroundColor: Colors.white,
                elevation: 0.0,
                title: Text(
                  '',
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
        body: Stack(
          children: [
            WebViewWidget(controller: _webViewController),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
