import 'package:Decont/MyWallet/add_money_screen.dart';
import 'package:Decont/razorpay_payment_screen/razorpay_screen.dart';
import 'package:Decont/splashScreen/SplashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:Decont/productDetails/product_details_screen.dart';
import 'package:Decont/produtList/product_list_screen.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'AboutUs/about_us_screen.dart';
import 'AddressScreen/add_edit_address_screen.dart';
import 'AskQuestions/que_ans_list_screen.dart';
import 'CategoryList/category_screen.dart';
import 'ContactUs/contact_us_screen.dart';
import 'CreateAccount/create_account.dart';
import 'CreateAccount/professional_info.dart';
import 'Dashboard/home_screen.dart';
import 'Help_and_Support/help_and_support_screen.dart';
import 'MyCartList/cart_list_screen.dart';
import 'MyCartList/delivery_address_screen.dart';
import 'MyWallet/wallet_history_Screen.dart';
import 'MyWallet/wallet_success.dart';
import 'MyWishlist/wishlist_screen.dart';
import 'Notification/notification_screen.dart';
import 'OrderDetailsScreen/order_details_screen.dart';
import 'OrderList/order_list_screen.dart';
import 'OrderSuccess/WebviewAddWalletScreen.dart';
import 'OrderSuccess/online_payment_screen_webview.dart';
import 'OrderSuccess/order_success.dart';
import 'PaymentMethod/payment_screen.dart';
import 'ProfileScreen/profile_screen.dart';
import 'RatingAndReview/rating_review_list_screen.dart';
import 'RatingAndReview/write_review_screen.dart';
import 'ReferScreen/refer_screen.dart';
import 'SearchScreen/search_screen.dart';
import 'SelectLanguage/select_language.dart';
import 'WebviewPage/WebviewScreen.dart';
import 'feedbackandreview/feedback_and_review_screen.dart';
import 'firebase_options.dart';
import 'login/Otp_screen.dart';
import 'login/login_screen.dart';
import 'myaccount/my_account_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  try {
    // Initialize Firebase with the generated options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions
          .currentPlatform, // Automatically generated for your platform
    );
    print("Firebase initialized successfully!");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
  FirebaseMessaging fcmMessage = FirebaseMessaging.instance;
   //await fcmMessage.subscribeToTopic('indianherbsonlineUsers');

  runApp(
    const GetMaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        "/language": (context) => const SelectLanguage(),
        "/home": (context) => const Home(),
        "/login": (context) => const LoginScreen(),
        "/create_account": (context) =>
            const CreateAccountScreen(mobileNumberUser: ''),
        "/professional_info": (context) => const ProfessionalScreen(),
        "/product_list": (context) => ProductListScreen(
              onBack: () {},
              category: '',
              category_name: '',
            ),
        //"/product_list": (context) => ProductListScreenTestScreen(onBack: () {  }, category: '',),
        "/my_account": (context) => MyAccountPage(
              onBack: () {},
            ),
        "/profile": (context) => ProfileScreenPage(),
        "/addMoney": (context) => AddMoneyScreen(),
        "/CategoryPage": (context) => CategoryPage(catID: ''),
        "/add_edit_address": (context) => const AddressScreen(),
        "/help_and_support": (context) => HelpAndSupportScreen(),
        "/notification": (context) => NotificationsPage(
              onBack: () {},
            ),
        "/wish_list": (context) => WishListScreen(),
        "/my_cart": (context) => MyCartScreen(),
        "/referScreen": (context) => ReferScreen(),

        "/order_success": (context) => OrderSuccessScreen(),
        "/wallet_success": (context) => const WalletSuccessScreen(),
        "/add_money_webview_payment": (context) =>
            WebviewAddWalletScreenExample(),
        "/order_webview_PaymentPaytm": (context) => PaymentPaytmPage(),
        "/order_list": (context) => OrderListScreen(
              onBack: () {},
            ),
        "/order_detail": (context) => OrderDetailScreen(
              product_id: '',
              home: '',
            ),
        "/product_detail": (context) => ProductDetailScreen(
              product_id: '',
            ),
        "/contact_us": (context) => const ContactUsScreen(),
        "/about_us": (context) => const AboutUsScreen(),
        "/search": (context) => SearchScreen(),
        "/selectLanguage": (context) => const SelectLanguage(),
        //"/home": (context) => Home(),
        "/home": (context) => const Home(),
        "/rating": (context) => RatingBarExample(),
        "/wallet_history": (context) => WalletHistoryScreen(),
        "/webView": (context) => WebViewExample(
              title: '',
              link: '',
            ),
        "/rating_review": (context) => RatingAndReviewScreen(),
        "/write_review": (context) => WriteReviewScreen(),
        "/que_ans_list_review": (context) => QuestionAndAnswerListScreen(),
      },
    );
  }
}
