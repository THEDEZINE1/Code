import 'dart:convert';
import 'dart:io';
import 'package:Decont/MyCartList/cart_list_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../AskQuestions/ask_question_screen.dart';
import '../CustomeTextStyle/custometextstyle.dart';
import '../Dashboard/home_screen.dart';
import '../getquote/getquote.dart';
import '../theme/AppTheme.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../BaseUrl.dart';
import '../RatingAndReview/rating_review_list_screen.dart';
import '../RatingAndReview/write_review_screen.dart';
import '../imageview_screen.dart';
import 'other_screen.dart';

String? first_name = '';
String? last_name = '';
String? email = '';
String? mobile = '';
String? user_token = '';
String? image = '';
int? cart_count;
String? type = '';
String? userID = '';

class ProductDetailScreen extends StatefulWidget {
  final String product_id;

  // Constructor
  ProductDetailScreen({Key? key, required this.product_id}) : super(key: key);

  @override
  _ProductDetailScreen createState() => _ProductDetailScreen();
}

class _ProductDetailScreen extends State<ProductDetailScreen> {
  Map<String, String> localizedStrings = {};
  String currentLangCode = 'en';
  bool isLoading = false;
  bool hasMoreData = true;
  int _quantity = 1;
  String productSoldoutOrNOt = '';
  int _currentIndex = 0;
  final TextEditingController _pinController = TextEditingController();
  bool isCheckVisible = false;
  String Name = '';
  String price = '';
  String totalPriceString = '';
  String priceID = '';
  String totalMrpString = '';
  String totalGstPriceString = '';
  String mrp = '';
  String discount = '';
  String rating_msg = '';
  String qty_message = '';
  String deliverySelectionHeading = '';
  String description = '';
  String min_buy_qty = '';
  String max_buy_qty = '';
  String model = '';
  String product_delivery_msg = '';
  String returnPolicy = '';
  String gst_included = '';
  String decornt_delivery = '';
  String _product_id = '';
  String rating = '';
  String gst_price_text = '';
  String with_gst_price = '';
  String _message = '';
  String recent_show_label = '';
  String recent_show_product = '';
  String firstImageUrl = '';
  String tvdownload_pdf = '';
  String? productReviwCount;
  Color _messageColor = Colors.black; // Default message color
  List<Map<String, dynamic>> deliverySelection = [];
  String selectedDeliveryType = ''; // To store selected delivery type
  List<Map<String, dynamic>> product_label_info = [];
  List<Map<String, dynamic>> priceList = [];
  List<Map<String, dynamic>> productsList = [];
  List<Map<String, dynamic>> recent_show_product_list = [];

  List<String> _imageUrls = [];

  String _selectedSize = ''; // Default selected size
  String _selectedDelivery = ''; // Default selected size
  String _selectedMinQty = ''; // Default selected size
  String _selectDeliveryChargeLabel = ''; // Default selected size
  bool _isFavorite = false;

  double rating_1 = 0; // Example dynamic rating value
  final GlobalKey _reviewsKey =
      GlobalKey(); // Key for the Reviews & Ratings section

  final ScrollController _scrollController =
      ScrollController(); // Scroll controller

  final GlobalKey _buttonReviewKey = GlobalKey();

  void _scrollToButton() {
    final RenderBox renderBox =
        _buttonReviewKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero).dy;
    final offset = position - MediaQuery.of(context).padding.top;

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedMinQty = '1';
    _selectedSize = '';
    _loadCurrentLanguagePreference();
    _initializeData();

    _product_id = widget.product_id;

    _pinController.addListener(() {
      if (_pinController.text.length == 6) {
        setState(() {
          isCheckVisible = true;
          _message = ''; // Clear the message when the user types
        });
      } else {
        setState(() {
          isCheckVisible = false;
          _message = ''; // Clear the message when the user types
        });
      }
    });
  }

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      first_name = prefs.getString('first_name') ?? '';
      last_name = prefs.getString('last_name') ?? '';
      email = prefs.getString('email') ?? '';
      mobile = prefs.getString('mobile') ?? '';
      user_token = prefs.getString('user_token') ?? '';
      type = prefs.getString('type') ?? '';
      image = prefs.getString('image') ?? '';
      cart_count = prefs.getInt('cart_count')!;
      userID = prefs.getString('userID') ?? '';
    });

    await _dashboardData();
    await _related_productData();
  }

  Future<void> _dashboardData() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(baseUrl);

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token',
    };

    final Map<String, dynamic> body = {
      'view': 'product_detail',
      'custID': userID,
      'productID': _product_id,
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());

        if (data['result'] == 1) {
          setState(() {
            _quantity = 1; // Force quantity to remain 1
            _selectedSize = ''; // No option selected
            _selectedMinQty = '1'; // Show min qty as 1 initially
          });

          final product = data['data']['product'][0];

          priceList.clear();

          priceList = List<Map<String, dynamic>>.from(
            product['price_list']?.map((price) => {
                      'type': (price['type'] ?? '').toString(),
                      'price': (price['price'] ?? '0').toString(),
                      'mrp': (price['mrp'] ?? '0').toString(),
                      'priceID': (price['priceID'] ?? '').toString(),
                      'discount': (price['discount'] ?? '0').toString(),
                      'buy_min_qty': (price['buy_min_qty'] ?? '0').toString(),
                      'size_option': (price['size_option'] ?? '').toString(),
                    }) ??
                [],
          );

          // Set product details with type conversion
          Name = (product['name'] ?? '').toString();
          tvdownload_pdf = (product['download_pdf'] ?? '').toString();

          price = (product['price'] ?? '0').toString();
          mrp = (product['mrp'] ?? '0').toString();
          discount = (product['discount'] ?? '0').toString();
          description = (product['description'] ?? '').toString();
          min_buy_qty = (product['min_buy_qty'] ?? '0').toString();
          max_buy_qty = (product['max_buy_qty'] ?? '0').toString();
          rating = (product['rating'] ?? '0').toString();
          gst_price_text = (product['gst_price_text'] ?? '').toString();
          with_gst_price = (product['with_gst_price'] ?? '0').toString();
          rating_msg = (product['rating_msg'] ?? '').toString();
          deliverySelectionHeading =
              (product['deliverySelectionHeading'] ?? '').toString();

          model = (product['model'] ?? '').toString();

          productReviwCount = (product['count_review_msg'] ?? '0').toString();

          qty_message = (product['qty_message'] ?? '').toString();
          productSoldoutOrNOt = (product['sold_out'] ?? '').toString();
          product_delivery_msg =
              (product['product_delivery_msg'] ?? '').toString();
          //_quantity = product['in_cart'];
          //_isFavorite = product['in_wishlist']; // Set initial state from API response

          // Extract product images
          //_imageUrls = List<String>.from(product['image_list'].map((image) => image['image']));
          _imageUrls = List<String>.from(product['image_list']
                  ?.map((image) => image['image'].toString()) ??
              []);
          firstImageUrl = _imageUrls.isNotEmpty ? _imageUrls[0] : '';

          product_label_info = List<Map<String, dynamic>>.from(
              product['product_label_info']?.map((label) => {
                        'label_name': (label['label_name'] ?? '').toString(),
                        'label_value': (label['label_value'] ?? '').toString(),
                      }) ??
                  []);

          // Delivery details
          deliverySelection.clear();
          final deliveryTypes = product['deliverySelection'] ?? [];

          deliveryTypes.forEach((delivery) {
            deliverySelection.add({
              'type': (delivery['type'] ?? '').toString(),
              'label': (delivery['label'] ?? '').toString(),
              'notes': (delivery['notes'] ?? '').toString(),
              'shipChargeAdd': (delivery['shipChargeAdd'] ?? '0').toString(),
            });
          });

          // Return policy and GST information
          returnPolicy = product['return_policy'];
          gst_included = product['gst_included'];
          decornt_delivery = product['decornt_delivery'];

          // Extract price_list

          setState(() {
            //price = totalPriceString;
            totalPriceString = price;
            totalMrpString = mrp;
            totalGstPriceString = with_gst_price;
          });
        }
      } else {}
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _related_productData() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(baseUrl);

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token',
    };

    final Map<String, dynamic> body = {
      'view':
          'related_product', // Assuming the API requires the item ID to remove
      'custID': userID, // Assuming the API requires the item ID to remove
      'catID': _product_id, // Assuming the API requires the item ID to remove
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());

        if (data['result'] == 1) {
          productsList.clear();
          recent_show_product_list.clear();

          //product_count = data['data']['product_count'].toString();
          recent_show_label = data['data']['recent_show_label'].toString();
          recent_show_product = data['data']['recent_show_product'].toString();

          productsList.addAll((data['data']['product_list'] as List)
              .map((item) => {
                    'productID': item['productID'],
                    'name': item['name'],
                    'image': item['image'],
                    'mrp': item['mrp'],
                    'price': item['price'],
                    'discount': item['discount'],
                    'without_gst_price': item['without_gst_price'],
                    'buy_min_qty': item['buy_min_qty'],
                    'without_gst_mrp': item['without_gst_mrp'],
                    'without_gst_disc': item['without_gst_disc'],
                    'gst_price_text': item['gst_price_text'],
                    'review_count': item['review_count'],
                    'review_msg': item['review_msg'],
                  })
              .toList());

          recent_show_product_list
              .addAll((data['data']['recent_show_product_list'] as List)
                  .map((item) => {
                        'productID': item['productID'],
                        'name': item['name'],
                        'image': item['image'],
                        'mrp': item['mrp'],
                        'price': item['price'],
                        'discount': item['discount'],
                        'without_gst_price': item['without_gst_price'],
                        'without_gst_mrp': item['without_gst_mrp'],
                        'without_gst_disc': item['without_gst_disc'],
                        'gst_price_text': item['gst_price_text'],
                        'review_count': item['review_count'],
                        'review_msg': item['review_msg'],
                      })
                  .toList());

          setState(() {});
        }
      } else {}
    } catch (e) {
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  AddToCart(String quantity, String selectedTestIds, String product_id) async {
    // Prepare the API call
    final url = Uri.parse(baseUrl); // Replace with your API endpoint
    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization':
          'Bearer $user_token', // Include the user token if necessary
    };

    final Map<String, String> body = {
      'productID': product_id, // Pass the car ID to the API
      'productQty': quantity, // Pass the new favorite state
      'priceID': selectedTestIds, // Pass the new favorite state
      'view': 'cart', // Pass the new favorite state
      'custID': '$userID', // Pass the new favorite state
      'page': 'add', // Pass the new favorite state
      'app_type': 'Android', // Pass the new favorite state
      'productColor': '', // Pass the new favorite state
      'deliveryType': selectedDeliveryType, // Pass the new favorite state
    };

    try {
      // Make the API call
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          // Successfully updated favorite status
          final totalItem = int.tryParse(data['data']['cart_count']) ?? 0;

          //final totalItem = data['data']['cart_count'];
          final prefs = await SharedPreferences.getInstance();

          setState(() {
            // Ensure precision up to 2 decimal points
            cart_count = totalItem;
            prefs.setInt('cart_count', totalItem);
          });
        } else {
          // Handle error returned by the API
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(data['message'],
                    style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
          );
        }
      } else {
        // Handle HTTP error responses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response.reasonPhrase}',
                style: CustomTextStyle.GraphikMedium(16, AppColors.white)),
          ),
        );
      }
    } catch (e) {
      // Handle exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred.',
              style: CustomTextStyle.GraphikMedium(16, AppColors.white)),
        ),
      );
    }
  }

  BuyNow(String quantity, String selectedTestIds, String product_id) async {
    // Prepare the API call
    final url = Uri.parse(baseUrl); // Replace with your API endpoint
    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization':
          'Bearer $user_token', // Include the user token if necessary
    };

    final Map<String, String> body = {
      'productID': product_id, // Pass the car ID to the API
      'productQty': quantity, // Pass the new favorite state
      'priceID': selectedTestIds, // Pass the new favorite state
      'view': 'cart', // Pass the new favorite state
      'custID': '$userID', // Pass the new favorite state
      'page': 'add', // Pass the new favorite state
      'app_type': 'Android', // Pass the new favorite state
      'productColor': '', // Pass the new favorite state
      'deliveryType': selectedDeliveryType, // Pass the new favorite state
    };

    try {
      // Make the API call
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Successfully updated favorite status
          final totalItem = int.tryParse(data['data']['cart_count']) ?? 0;

          //final totalItem = data['data']['cart_count'];
          final prefs = await SharedPreferences.getInstance();

          setState(() {
            // Ensure precision up to 2 decimal points
            cart_count = totalItem;
            prefs.setInt('cart_count', totalItem);
          });

          Navigator.pushNamed(context, '/my_cart');
        } else {
          // Handle error returned by the API
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'],
                  style: CustomTextStyle.GraphikMedium(16, AppColors.white)),
            ),
          );
        }
      } else {
        // Handle HTTP error responses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${response.reasonPhrase}',
                  style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
        );
      }
    } catch (e) {
      // Handle exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred.',
              style: CustomTextStyle.GraphikMedium(16, AppColors.white)),
        ),
      );
    }
  }

  checkpincode(String product_id) async {
    // Prepare the API call
    final url = Uri.parse(baseUrl); // Replace with your API endpoint
    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization':
          'Bearer $user_token', // Include the user token if necessary
    };

    /*final body = jsonEncode({
      'product_id': product_id, // Pass the car ID to the API
      'pincode': _pinController.text, // Pass the new favorite state
    });*/

    final Map<String, String> body = {
      'view': 'check_pincode', // Pass the car ID to the API
      'custID': '$userID',
      'productID': product_id.toString(), // Pass the car ID to the API
      'pincode': _pinController.text.toString(), // Pass the new favorite state
    };

    try {
      // Make the API call
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] == 1) {
          setState(() {
            _message = '${data['message']}';
            _messageColor = Colors.green; // Set message color to green
          });
        } else {
          // Handle error returned by the API
          setState(() {
            _message = '${data['message']}';
            _messageColor = Colors.red; // Set message color to green
          });

          /*ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );*/
        }
      } else {
        // Handle HTTP error responses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${response.reasonPhrase}',
                  style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred.',
              style: CustomTextStyle.GraphikMedium(16, AppColors.white)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
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

  Future<void> _toggleFavorite() async {
    // Prepare the API call
    final url =
        Uri.parse(add_remove_wishlist); // Replace with your API endpoint
    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization':
          'Bearer $user_token', // Include the user token if necessary
    };

    final Map<String, String> body = {
      'product_id': _product_id.toString(), // Pass the car ID to the API
      'flag': _isFavorite.toString(), // Pass the new favorite state
    };

    try {
      // Make the API call
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(data['message'],
                    style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
          );
          setState(() {
            _isFavorite = !_isFavorite; // Toggle the favorite state
          });
        } else {
          // Handle error returned by the API
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(data['message'],
                    style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
          );
        }
      } else {
        // Handle HTTP error responses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${response.reasonPhrase}',
                  style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
        );
      }
    } catch (e) {
      // Handle exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An unexpected error occurred.',
                style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
      );
    }
  }

  void _scrollToReviews() {
    // Find the position of the Reviews & Ratings section
    final RenderBox renderBox =
        _reviewsKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero, ancestor: null).dy;

    // Scroll to the position
    _scrollController.animateTo(
      _scrollController.offset +
          position -
          80, // Adjust for some padding if needed
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  /*Future<void> _shareOnWhatsApp() async {
    final message = 'Hey, check this out: $Name';

    // WhatsApp URL format for sharing
    final url = 'https://wa.me/?text=${Uri.encodeComponent(message)}';

    // Check if the WhatsApp URL can be launched
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // If the URL cannot be launched, show a message
      throw 'Could not open WhatsApp';
    }
  }*/

  /*Future<void> shareOnWhatsApp() async {
    String name = Name;
    String imageUrl = firstImageUrl;

    // WhatsApp URL format for sharing
    String whatsappUrl = "https://wa.me/?text=Check%20this%20out!%0AName:%20$name%0AImage:%20$imageUrl";

    // Check if WhatsApp is installed
    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      print("WhatsApp not installed");
    }
  // }*/

  void shareOnWhatsApp1() async {
//    Share.share("$text\n$imageUrl");

    // try {
    //   await SocialSharing.shareToWhatsApp(
    //     text: text,
    //     imageUrl: imageUrl,
    //   );
    // } catch (e) {
    //   print("Error sharing on WhatsApp: $e");
    // }
  }

  void shareOnWhatsApp() async {
    String message =
        "Check out this amazing Product!"; // You can customize this
    String url = "https://wa.me/?text=${Uri.encodeComponent(message)}";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      // Optional: show error
    }
  }

  void downloadPDF(BuildContext context, String url_image) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    String message = "";

    try {
      // Download the file from the URL
      final http.Response response = await http.get(Uri.parse(url_image));

      if (response.statusCode == 200) {
        // Extract the filename from the URL manually (after the last '/')
        String filename = url_image.substring(
            url_image.lastIndexOf('/') + 1); // Extracts 'invoice_123.pdf'

        // Get the temporary directory where we want to save the file
        final dir = await getTemporaryDirectory();

        // Create the full file path using the extracted filename
        var filePath = '${dir.path}/$filename';

        // Save the file to the filesystem
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Ask the user to save it using SaveFileDialog
        final params = SaveFileDialogParams(sourceFilePath: file.path);
        final finalPath = await FlutterFileDialog.saveFile(params: params);

        if (finalPath != null) {
          message = 'File saved to $filename';
        } else {
          message = 'File not saved';
        }
      } else {
        message =
            'Failed to download file. HTTP Status: ${response.statusCode}';
      }
    } catch (e) {
      message = 'Error: $e';
      print('selectedLangCode: $e');
    }

    // Show the message in a Snackbar
    scaffoldMessenger.showSnackBar(SnackBar(
      content: Text(message,
          style: CustomTextStyle.GraphikMedium(16, AppColors.white)),
      backgroundColor: const Color(0xFF000000),
    ));
  }

  @override
  Widget build(BuildContext context) {
    int minQty =
        int.tryParse(min_buy_qty) ?? 0; // Use 0 if the conversion fails
    int maxQty =
        int.tryParse(max_buy_qty) ?? 0; // Use 0 if the conversion fails

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
                  return IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                    onPressed: () => Get.to( const Home()),
                  );
                },
              ),
              backgroundColor: Colors.white,
              elevation: 0.0,
              title: Text(
                translate('Product Details'),
                //widget.carName, // Use widget.carName here
                style: CustomTextStyle.GraphikMedium(16, AppColors.black),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(
                      right: 10), // Adds 10px margin to the right
                  child: Stack(
                    children: <Widget>[
                      IconButton(
                        color: Colors.black,
                        icon: SvgPicture.asset(
                          'assets/icons/shopping_cart.svg', // Path to your SVG file
                          width: 24,
                          height: 24, // Set the height of the SVG icon
                          color: Colors
                              .black, // Optional: change the color if needed
                        ),
                        onPressed: () {
                          if (userID == null || userID!.isEmpty) {
                            // If userID is null or empty, show a message or navigate to the login screen
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: AppTheme().whiteColor,
                                  surfaceTintColor: AppTheme().whiteColor,
                                  title: Text(
                                    'Login Required',
                                    style: CustomTextStyle.GraphikMedium(
                                        18, AppColors.black),
                                  ),
                                  content: Text(
                                    'Please log in to access my cart.',
                                    style: CustomTextStyle.GraphikRegular(
                                        14, AppColors.black),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context); // Close the dialog
                                      },
                                      child: Text(
                                        'Cancel',
                                        style: CustomTextStyle.GraphikMedium(
                                            14, AppColors.colorPrimary),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context,
                                            "/login"); // Navigate to login screen
                                      },
                                      child: Text(
                                        'Login',
                                        style: CustomTextStyle.GraphikMedium(
                                            14, AppColors.colorPrimary),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            Get.to(MyCartScreen());
                          }
                        },
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: AppColors.colorPrimary,
                            borderRadius: BorderRadius.circular(
                                10), // Round corners for the badge
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            cart_count
                                .toString(), // Replace this with your dynamic count value
                            style: CustomTextStyle.GraphikRegular(
                                12, AppColors.white),

                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              height: 1.0,
              color: AppTheme().lineColor,
            ),
          ],
        ),
      ),
      backgroundColor: AppTheme().mainBackgroundColor,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: AppColors.colorPrimary,
            ))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                color: AppTheme().whiteColor,
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        if (_imageUrls.isNotEmpty)
                                          CarouselSlider.builder(
                                            itemCount: _imageUrls.length,
                                            itemBuilder:
                                                (context, index, realIndex) {
                                              final imageUrl =
                                                  _imageUrls[index];
                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ImageViewScreen(
                                                        productName: Name,
                                                        initialIndex: index,
                                                        galleryItems:
                                                            _imageUrls,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  child: CachedNetworkImage(
                                                    imageUrl: imageUrl,
                                                    height: 150,
                                                    width: double.infinity,
                                                    fit: BoxFit.contain,
                                                    placeholder: (context,
                                                            url) =>
                                                        const Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                      color: AppColors
                                                          .colorPrimary,
                                                    )),
                                                    errorWidget: (context,
                                                        error, stackTrace) {
                                                      // In case of error, show a default image
                                                      return Image.asset(
                                                        'assets/decont_splash_screen_images/decont_logo.png',
                                                        fit: BoxFit.contain,
                                                        height: 100,
                                                        width: double.infinity,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                            options: CarouselOptions(
                                              height: 250,
                                              viewportFraction: 1.0,
                                              onPageChanged: (index, reason) {
                                                setState(() {
                                                  _currentIndex = index;
                                                });
                                              },
                                            ),
                                          )
                                        else
                                          Center(
                                            child: Opacity(
                                              opacity: 0.5,
                                              child: Image.asset(
                                                'assets/decont_splash_screen_images/decont_logo.png',
                                                fit: BoxFit.contain,
                                                height: 250,
                                                width: double.infinity,
                                              ),
                                            ),
                                          ),

                                        // Dots Indicator
                                        if (_imageUrls.isNotEmpty)
                                          Positioned(
                                            bottom: 10,
                                            left: 0,
                                            right: 0,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: _imageUrls
                                                  .asMap()
                                                  .entries
                                                  .map((entry) {
                                                return GestureDetector(
                                                  child: Container(
                                                    width: 8.0,
                                                    height: 8.0,
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 4.0),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: _currentIndex ==
                                                              entry.key
                                                          ? AppColors
                                                              .colorPrimary
                                                          : Colors.grey,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        Positioned(
                                          top: 5,
                                          left: 10,
                                          child: GestureDetector(
                                            onTap: () {
                                              //TODO
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                    color:
                                                        AppColors.colorPrimary,
                                                    width: 1.0),
                                              ),
                                              child: const Column(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .favorite_border_outlined,
                                                    color: AppColors
                                                        .secondTextColor,
                                                    size: 18.0,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Share Icon
                                        Positioned(
                                          top: 5,
                                          right: 10,
                                          child: GestureDetector(
                                            onTap: shareOnWhatsApp,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                    color:
                                                        AppColors.colorPrimary,
                                                    width: 1.0),
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                              child: const Icon(
                                                Icons.share,
                                                size: 18.0,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(Name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium!
                                            .copyWith(
                                                color: AppColors.black,
                                                fontSize: 15)),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Visibility(
                                          visible: price.isNotEmpty,
                                          child: Text(
                                            '₹ $totalPriceString',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: AppTheme().blackColor,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5.0,
                                        ),
                                        Visibility(
                                          visible: mrp.isNotEmpty,
                                          child: Text(
                                            //'₹ ${'${widget.car.price} / ${widget.car.base_weight}'}',
                                            '₹ $totalMrpString',
                                            textAlign: TextAlign
                                                .center, // Center-align the text

                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium!
                                                .copyWith(
                                                    color: AppColors.tex,
                                                    fontSize: 12,
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    decorationThickness: 1,
                                                    decorationColor:
                                                        AppColors.textSub),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5.0,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    GestureDetector(
                                      onTap:
                                          _scrollToReviews, // Add the click event
                                      child: Row(
                                        children: [
                                          Visibility(
                                            visible:
                                                rating.toString().isNotEmpty &&
                                                    rating.toString() != '0',
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical:
                                                          5), // Add padding
                                              decoration: BoxDecoration(
                                                color: AppColors.darkgreenColor,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        5), // Corner radius
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .spaceBetween, // Space between text and icon
                                                children: [
                                                  Text(
                                                    rating.toString(),
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color:
                                                          AppTheme().whiteColor,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      width:
                                                          4), // Add spacing between text and icon
                                                  const Icon(
                                                    Icons.star,
                                                    color: Colors
                                                        .white, // Star color
                                                    size: 12, // Small icon size
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5.0,
                                          ),
                                          Visibility(
                                            visible: rating_msg.isNotEmpty,
                                            child: Text(
                                              //'₹ ${'${widget.car.price} / ${widget.car.base_weight}'}',
                                              '${'(${rating_msg})'}',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: AppTheme()
                                                      .secondTextColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    /*Text('Select Size'),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: _sizes.map((size) {
                                return ChoiceChip(
                                  showCheckmark: false,

                                  label: Text(size),
                                  selected: _selectedSize == size,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedSize = selected
                                          ? size
                                          : ''; // Set to empty string if not selected

                                      //_selectedSize = size;

                                      log('$_selectedSize');

                                    });
                                  },
                                  selectedColor: AppTheme().primaryColor,
                                  // Background color when selected
                                  backgroundColor: AppTheme().whiteColor,
                                  // Background color when not selected
                                  labelStyle: TextStyle(
                                    color: _selectedSize == size
                                        ? Colors.white
                                        : Colors.black, // Text color change based on selection
                                  ),

                                  side: BorderSide(
                                    color: _selectedSize == size
                                        ? AppTheme().primaryColor
                                        : AppTheme().primaryColor,
                                    // Border color based on selection
                                    width: 1.0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                );
                              }).toList(),
                            ),*/

                                    /*Text('Select Size'),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: priceList.map((delivery) {
                                // Access label and other details from the current delivery
                                String label = delivery['type'];
                                String type = delivery['price'];
                                String priceID = delivery['priceID'].toString();

                                return ChoiceChip(
                                  showCheckmark: false,
                                  label: Text(label),  // Use the label from delivery
                                  selected: _selectedSize == label,  // Update selection based on label
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedSize = selected ? label : '';  // Update the selected size

                                      // Log the selected size and its corresponding 'type' from the delivery selection
                                      log('Delivery Type: $type');
                                      log('priceID: $priceID');

                                      // Optionally, you can display the selected delivery type on the UI
                                      //selectedDeliveryType = type;
                                    });
                                  },
                                  selectedColor: AppTheme().primaryColor,
                                  backgroundColor: AppTheme().whiteColor,
                                  labelStyle: TextStyle(
                                    color: _selectedSize == label ? Colors.white : Colors.black, // Text color change based on selection
                                  ),
                                  side: BorderSide(
                                    color: _selectedSize == label ? AppTheme().primaryColor : AppTheme().placeHolderColor,
                                    width: 1.0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                );
                              }).toList(),
                            ),*/

                                    if (rating.toString() != '0')
                                      const SizedBox(height: 10),
                                    Text(
                                      '$gst_price_text ₹ $totalGstPriceString',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium!
                                          .copyWith(
                                            color: AppColors.tex,
                                            fontSize: 12,
                                          ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    qty_message.toString() != ''
                                        ? Text(
                                            '$qty_message',
                                            style:
                                                CustomTextStyle.GraphikRegular(
                                                    11, AppColors.colorPrimary),
                                          )
                                        : SizedBox.shrink(),
                                    if (priceList.any((delivery) =>
                                        delivery['type']
                                            .toString()
                                            .trim()
                                            .isNotEmpty)) ...[
                                      const SizedBox(height: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Select Size',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Wrap(
                                            spacing: 8.0,
                                            runSpacing: 8.0,
                                            children: priceList
                                                .where((delivery) =>
                                                    delivery['type']
                                                        .toString()
                                                        .trim()
                                                        .isNotEmpty)
                                                .map((delivery) {
                                              // Extract relevant details
                                              String label = delivery['type'];
                                              String type = delivery['price'];
                                              String PriceID =
                                                  delivery['priceID']
                                                      .toString();
                                              String buyMinQty = delivery[
                                                      'buy_min_qty']
                                                  .toString(); // Get the specific min qty for this option

                                              return ChoiceChip(
                                                showCheckmark: false,
                                                label: Text(
                                                    label), // Use the label from delivery
                                                selected: _selectedSize ==
                                                    label, // Update selection based on label
                                                onSelected: (selected) {
                                                  setState(() {
                                                    if (selected) {
                                                      _selectedSize = label;
                                                      _selectedMinQty =
                                                          buyMinQty;
                                                      priceID = PriceID;

                                                      // CHANGED: Start with quantity 1 instead of minimum
                                                      _quantity =
                                                          1; // Always start with 1 when changing variants

                                                      // Calculate totals based on the selected option's prices and new quantity
                                                      double priceAsDouble =
                                                          double.tryParse(
                                                                  delivery[
                                                                      'price']) ??
                                                              0.0;
                                                      double mrpAsDouble =
                                                          double.tryParse(
                                                                  delivery[
                                                                      'mrp']) ??
                                                              0.0;

                                                      double totalPrice =
                                                          _quantity *
                                                              priceAsDouble;
                                                      double totalMrp =
                                                          _quantity *
                                                              mrpAsDouble;

                                                      totalPriceString =
                                                          totalPrice
                                                              .toStringAsFixed(
                                                                  2);
                                                      totalMrpString = totalMrp
                                                          .toStringAsFixed(2);
                                                      totalGstPriceString =
                                                          totalPrice
                                                              .toStringAsFixed(
                                                                  2);

                                                      // Update global variables for display
                                                      price = delivery['price'];
                                                      mrp = delivery['mrp'];
                                                      discount =
                                                          delivery['discount'];
                                                      with_gst_price = delivery[
                                                          'price']; // Assuming price includes GST
                                                    } else {
                                                      // Reset when deselected
                                                      _selectedSize = '';
                                                      _selectedMinQty = '';
                                                    }
                                                  });
                                                },
                                                selectedColor:
                                                    AppColors.colorPrimary,
                                                backgroundColor:
                                                    AppTheme().whiteColor,
                                                labelStyle: TextStyle(
                                                  color: _selectedSize == label
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                                side: BorderSide(
                                                  color: _selectedSize == label
                                                      ? AppTheme().primaryColor
                                                      : AppTheme()
                                                          .placeHolderColor,
                                                  width: 1.0,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                              );
                                            }).toList(),
                                          )
                                          // Wrap(
                                          //   spacing: 8.0,
                                          //   runSpacing: 8.0,
                                          //   children: priceList
                                          //       .where((delivery) =>
                                          //           delivery['type']
                                          //               .toString()
                                          //               .trim()
                                          //               .isNotEmpty)
                                          //       .map((delivery) {
                                          //     // Extract relevant details
                                          //     String label = delivery['type'];
                                          //     String type = delivery['price'];
                                          //     String PriceID =
                                          //         delivery['priceID']
                                          //             .toString();
                                          //     String buyMinQty = delivery[
                                          //             'buy_min_qty']
                                          //         .toString(); // Get the specific min qty for this option
                                          //
                                          //     return ChoiceChip(
                                          //       showCheckmark: false,
                                          //       label: Text(
                                          //           label), // Use the label from delivery
                                          //       selected: _selectedSize ==
                                          //           label, // Update selection based on label
                                          //       onSelected: (selected) {
                                          //         setState(() {
                                          //           if (selected) {
                                          //             _selectedSize = label;
                                          //             _selectedMinQty =
                                          //                 buyMinQty;
                                          //             priceID = PriceID;
                                          //
                                          //             // IMPORTANT: Update quantity to the minimum required for this option
                                          //             int newMinQty =
                                          //                 int.tryParse(
                                          //                         buyMinQty) ??
                                          //                     1;
                                          //             _quantity =
                                          //                 newMinQty; // Always set to minimum when changing variants
                                          //
                                          //             // Calculate totals based on the selected option's prices and new quantity
                                          //             double priceAsDouble =
                                          //                 double.tryParse(
                                          //                         delivery[
                                          //                             'price']) ??
                                          //                     0.0;
                                          //             double mrpAsDouble =
                                          //                 double.tryParse(
                                          //                         delivery[
                                          //                             'mrp']) ??
                                          //                     0.0;
                                          //
                                          //             double totalPrice =
                                          //                 _quantity *
                                          //                     priceAsDouble;
                                          //             double totalMrp =
                                          //                 _quantity *
                                          //                     mrpAsDouble;
                                          //
                                          //             totalPriceString =
                                          //                 totalPrice
                                          //                     .toStringAsFixed(
                                          //                         2);
                                          //             totalMrpString = totalMrp
                                          //                 .toStringAsFixed(2);
                                          //             totalGstPriceString =
                                          //                 totalPrice
                                          //                     .toStringAsFixed(
                                          //                         2);
                                          //
                                          //             // Update global variables for display
                                          //             price = delivery['price'];
                                          //             mrp = delivery['mrp'];
                                          //             discount =
                                          //                 delivery['discount'];
                                          //             with_gst_price = delivery[
                                          //                 'price']; // Assuming price includes GST
                                          //           } else {
                                          //             // Reset when deselected
                                          //             _selectedSize = '';
                                          //             _selectedMinQty = '';
                                          //           }
                                          //         });
                                          //       },
                                          //       selectedColor:
                                          //           AppColors.colorPrimary,
                                          //       backgroundColor:
                                          //           AppTheme().whiteColor,
                                          //       labelStyle: TextStyle(
                                          //         color: _selectedSize == label
                                          //             ? Colors.white
                                          //             : Colors.black,
                                          //       ),
                                          //       side: BorderSide(
                                          //         color: _selectedSize == label
                                          //             ? AppTheme().primaryColor
                                          //             : AppTheme()
                                          //                 .placeHolderColor,
                                          //         width: 1.0,
                                          //       ),
                                          //       shape: RoundedRectangleBorder(
                                          //         borderRadius:
                                          //             BorderRadius.circular(
                                          //                 5.0),
                                          //       ),
                                          //     );
                                          //   }).toList(),
                                          // )
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                    Text(
                                      deliverySelectionHeading,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .copyWith(
                                              color: AppColors.black,
                                              fontSize: 15),
                                    ),
                                    Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children:
                                          deliverySelection.map((delivery) {
                                        // Access label and other details from the current delivery
                                        String label = delivery['label'];
                                        String type = delivery['type'];
                                        String notes = delivery['notes'];

                                        return ChoiceChip(
                                          showCheckmark: false,
                                          label: Text(
                                              label), // Use the label from delivery
                                          selected: _selectedDelivery ==
                                              label, // Update selection based on label
                                          onSelected: (selected) {
                                            setState(() {
                                              _selectedDelivery =
                                                  selected ? label : '';
                                              _selectDeliveryChargeLabel =
                                                  selected ? notes : '';

                                              selectedDeliveryType = type;
                                            });
                                          },
                                          selectedColor: AppColors.colorPrimary,
                                          backgroundColor:
                                              AppTheme().whiteColor,
                                          labelStyle: TextStyle(
                                            color: _selectedDelivery == label
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                          side: BorderSide(
                                            color: _selectedDelivery == label
                                                ? AppTheme().primaryColor
                                                : AppColors.colorPrimary,
                                            width: 1.0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(_selectDeliveryChargeLabel),
                                    const SizedBox(height: 10),
                                    productSoldoutOrNOt == 'Yes'
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 25, vertical: 10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: AppTheme().redColor,
                                            ),
                                            child: Text(
                                              'Sold Out',
                                              style:
                                                  CustomTextStyle.GraphikMedium(
                                                      12,
                                                      AppTheme().whiteColor),
                                            ),
                                          )
                                        : Row(
                                            children: [
                                              Text(
                                                translate('Quantity'),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayMedium!
                                                    .copyWith(
                                                        color: AppColors.black,
                                                        fontSize: 18),
                                              ),
                                              const SizedBox(width: 10),
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 30.0,
                                                    height: 30.0,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        // Get the current selected option's minimum quantity
                                                        int currentMinQty =
                                                            int.tryParse(
                                                                    _selectedMinQty) ??
                                                                1;
                                                        print(
                                                            "Current Min Qty: $currentMinQty");

                                                        setState(() {
                                                          if (_quantity >
                                                              currentMinQty) {
                                                            _quantity--;

                                                            // Get the selected price option details for calculation
                                                            Map<String,
                                                                    dynamic>?
                                                                selectedOption =
                                                                priceList
                                                                    .firstWhere(
                                                              (option) =>
                                                                  option[
                                                                      'type'] ==
                                                                  _selectedSize,
                                                              orElse: () => priceList
                                                                      .isNotEmpty
                                                                  ? priceList[0]
                                                                  : {},
                                                            );

                                                            if (selectedOption
                                                                .isNotEmpty) {
                                                              // Use the selected option's prices for calculation
                                                              double
                                                                  priceAsDouble =
                                                                  double.tryParse(
                                                                          selectedOption[
                                                                              'price']) ??
                                                                      0.0;
                                                              double
                                                                  mrpAsDouble =
                                                                  double.tryParse(
                                                                          selectedOption[
                                                                              'mrp']) ??
                                                                      0.0;

                                                              // Calculate totals
                                                              double
                                                                  totalPrice =
                                                                  _quantity *
                                                                      priceAsDouble;
                                                              double totalMrp =
                                                                  _quantity *
                                                                      mrpAsDouble;

                                                              // Format as string
                                                              totalPriceString =
                                                                  totalPrice
                                                                      .toStringAsFixed(
                                                                          2);
                                                              totalMrpString =
                                                                  totalMrp
                                                                      .toStringAsFixed(
                                                                          2);
                                                              totalGstPriceString =
                                                                  totalPrice
                                                                      .toStringAsFixed(
                                                                          2); // Assuming GST is included in price
                                                            }
                                                          } else {
                                                            // Show message when trying to go below minimum quantity
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    SnackBar(
                                                              content: Text(
                                                                  "Minimum Purchase Qty is $currentMinQty",
                                                                  style: CustomTextStyle
                                                                      .GraphikMedium(
                                                                          16,
                                                                          AppColors
                                                                              .white)),
                                                              duration:
                                                                  Duration(
                                                                      seconds:
                                                                          2),
                                                            ));
                                                          }
                                                        });

                                                        print(
                                                            "Total Price: $totalPriceString");
                                                      },
                                                      // onPressed: () {
                                                      //   print(minQty);
                                                      //   setState(() {
                                                      //     if (_quantity >
                                                      //         minQty) {
                                                      //       _quantity--;
                                                      //     } else {
                                                      //       // _quantity = minQty;
                                                      //     }
                                                      //
                                                      //     // Parse price values safely
                                                      //     double priceAsDouble =
                                                      //         double.tryParse(
                                                      //                 price) ??
                                                      //             0.0;
                                                      //     double mrpAsDouble =
                                                      //         double.tryParse(
                                                      //                 mrp) ??
                                                      //             0.0;
                                                      //     double
                                                      //         gstPriceAsDouble =
                                                      //         double.tryParse(
                                                      //                 with_gst_price) ??
                                                      //             0.0;
                                                      //
                                                      //     // Calculate totals
                                                      //     double totalPrice =
                                                      //         _quantity *
                                                      //             priceAsDouble;
                                                      //     double totalMrp =
                                                      //         _quantity *
                                                      //             mrpAsDouble;
                                                      //     double totalGstPrice =
                                                      //         _quantity *
                                                      //             gstPriceAsDouble;
                                                      //
                                                      //     // Format as string
                                                      //     totalPriceString =
                                                      //         totalPrice
                                                      //             .toStringAsFixed(
                                                      //                 2);
                                                      //     totalMrpString = totalMrp
                                                      //         .toStringAsFixed(2);
                                                      //     totalGstPriceString =
                                                      //         totalGstPrice
                                                      //             .toStringAsFixed(
                                                      //                 2);
                                                      //   });
                                                      //   print(totalPriceString);
                                                      // },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        foregroundColor:
                                                            AppTheme()
                                                                .whiteColor,
                                                        backgroundColor:
                                                            AppColors
                                                                .colorPrimary,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.0),
                                                        ),
                                                        side: const BorderSide(
                                                          color:
                                                              AppColors.white,
                                                          width:
                                                              1.5, // Border width
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 1.0,
                                                                vertical: 1.0),
                                                      ),
                                                      child: const Icon(
                                                          Icons.remove,
                                                          color:
                                                              AppColors.white),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5.0),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: AppTheme()
                                                              .new_maintextcolor,
                                                          width: 1.0),
                                                      color:
                                                          AppTheme().whiteColor,
                                                      // Set the background color
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0), // Rounded corners with radius 5
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 2.0),
                                                    // Add padding around the text
                                                    child: Text(
                                                      '$_quantity', // Name
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .displayMedium!
                                                          .copyWith(
                                                              color: AppColors
                                                                  .black,
                                                              fontSize: 18),
                                                      textAlign: TextAlign
                                                          .center, // Center-align the text
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5.0),
                                                  SizedBox(
                                                    width: 30.0,
                                                    height: 30.0,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          // Get the current selected option's minimum quantity
                                                          int currentMinQty =
                                                              int.tryParse(
                                                                      _selectedMinQty) ??
                                                                  1;

                                                          // Check if the quantity is less than the maxQty
                                                          if (_quantity <
                                                              maxQty) {
                                                            // If current quantity is less than the minimum required for selected option,
                                                            // jump directly to that minimum quantity
                                                            if (_quantity <
                                                                currentMinQty) {
                                                              _quantity =
                                                                  currentMinQty;
                                                            } else {
                                                              // Otherwise, increment by 1
                                                              _quantity++;
                                                            }

                                                            // Double check to ensure we don't exceed maxQty
                                                            if (_quantity >
                                                                maxQty) {
                                                              _quantity =
                                                                  maxQty;
                                                            }

                                                            // Get the selected price option details for calculation
                                                            Map<String,
                                                                    dynamic>?
                                                                selectedOption =
                                                                priceList
                                                                    .firstWhere(
                                                              (option) =>
                                                                  option[
                                                                      'type'] ==
                                                                  _selectedSize,
                                                              orElse: () => priceList
                                                                      .isNotEmpty
                                                                  ? priceList[0]
                                                                  : {},
                                                            );

                                                            if (selectedOption
                                                                .isNotEmpty) {
                                                              // Use the selected option's prices for calculation
                                                              double
                                                                  priceAsDouble =
                                                                  double.tryParse(
                                                                          selectedOption[
                                                                              'price']) ??
                                                                      0.0;
                                                              double
                                                                  mrpAsDouble =
                                                                  double.tryParse(
                                                                          selectedOption[
                                                                              'mrp']) ??
                                                                      0.0;

                                                              // Calculate total price
                                                              double
                                                                  totalPrice =
                                                                  _quantity *
                                                                      priceAsDouble;
                                                              double totalMrp =
                                                                  _quantity *
                                                                      mrpAsDouble;

                                                              // Convert to string with two decimal places
                                                              totalPriceString =
                                                                  totalPrice
                                                                      .toStringAsFixed(
                                                                          2);
                                                              totalMrpString =
                                                                  totalMrp
                                                                      .toStringAsFixed(
                                                                          2);
                                                              totalGstPriceString =
                                                                  totalPrice
                                                                      .toStringAsFixed(
                                                                          2); // Assuming GST is included in price
                                                            }
                                                          } else {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(SnackBar(
                                                                    content: Text(
                                                                        "Max Purchase Qty $maxQty",
                                                                        style: CustomTextStyle.GraphikMedium(
                                                                            16,
                                                                            AppColors.white))));
                                                          }
                                                        });
                                                      },
                                                      // onPressed: () {
                                                      //   setState(() {
                                                      //     // Get the current selected option's minimum quantity
                                                      //     int currentMinQty =
                                                      //         int.tryParse(
                                                      //                 _selectedMinQty) ??
                                                      //             1;
                                                      //
                                                      //     // Check if the quantity is less than the maxQty
                                                      //     if (_quantity <
                                                      //         maxQty) {
                                                      //       // If current quantity is less than the minimum required for selected option,
                                                      //       // jump directly to that minimum quantity
                                                      //       if (_quantity <
                                                      //           currentMinQty) {
                                                      //         _quantity =
                                                      //             currentMinQty;
                                                      //       } else {
                                                      //         // Otherwise, increment by 1
                                                      //         _quantity++;
                                                      //       }
                                                      //
                                                      //       // Double check to ensure we don't exceed maxQty
                                                      //       if (_quantity >
                                                      //           maxQty) {
                                                      //         _quantity =
                                                      //             maxQty;
                                                      //       }
                                                      //
                                                      //       // Get the selected price option details for calculation
                                                      //       Map<String,
                                                      //               dynamic>?
                                                      //           selectedOption =
                                                      //           priceList
                                                      //               .firstWhere(
                                                      //         (option) =>
                                                      //             option[
                                                      //                 'type'] ==
                                                      //             _selectedSize,
                                                      //         orElse: () => priceList
                                                      //                 .isNotEmpty
                                                      //             ? priceList[0]
                                                      //             : {},
                                                      //       );
                                                      //
                                                      //       if (selectedOption
                                                      //           .isNotEmpty) {
                                                      //         // Use the selected option's prices for calculation
                                                      //         double
                                                      //             priceAsDouble =
                                                      //             double.tryParse(
                                                      //                     selectedOption[
                                                      //                         'price']) ??
                                                      //                 0.0;
                                                      //         double
                                                      //             mrpAsDouble =
                                                      //             double.tryParse(
                                                      //                     selectedOption[
                                                      //                         'mrp']) ??
                                                      //                 0.0;
                                                      //
                                                      //         // Calculate total price
                                                      //         double
                                                      //             totalPrice =
                                                      //             _quantity *
                                                      //                 priceAsDouble;
                                                      //         double totalMrp =
                                                      //             _quantity *
                                                      //                 mrpAsDouble;
                                                      //
                                                      //         // Convert to string with two decimal places
                                                      //         totalPriceString =
                                                      //             totalPrice
                                                      //                 .toStringAsFixed(
                                                      //                     2);
                                                      //         totalMrpString =
                                                      //             totalMrp
                                                      //                 .toStringAsFixed(
                                                      //                     2);
                                                      //         totalGstPriceString =
                                                      //             totalPrice
                                                      //                 .toStringAsFixed(
                                                      //                     2); // Assuming GST is included in price
                                                      //       }
                                                      //     } else {
                                                      //       ScaffoldMessenger
                                                      //               .of(context)
                                                      //           .showSnackBar(SnackBar(
                                                      //               content: Text(
                                                      //                   "Max Purchase Qty $maxQty",
                                                      //                   style: CustomTextStyle.GraphikMedium(
                                                      //                       16,
                                                      //                       AppColors.white))));
                                                      //     }
                                                      //   });
                                                      // },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        foregroundColor:
                                                            AppTheme()
                                                                .whiteColor,
                                                        backgroundColor:
                                                            AppColors
                                                                .colorPrimary,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.0),
                                                        ),
                                                        side: const BorderSide(
                                                          color:
                                                              AppColors.white,
                                                          width:
                                                              1.5, // Border width
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 1.0,
                                                                vertical: 1.0),
                                                      ),
                                                      child: const Icon(
                                                          Icons.add,
                                                          color:
                                                              AppColors.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                  'Min Buy Qty:- $_selectedMinQty',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displayMedium!
                                                      .copyWith(
                                                          color:
                                                              AppColors.black,
                                                          fontSize: 13)),
                                            ],
                                          ),
                                    const SizedBox(height: 15),
                                    GestureDetector(
                                      onTap: () {
                                        _scrollToButton();
                                      },
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star,
                                              color: Colors.yellow, size: 30),
                                          const Icon(Icons.star,
                                              color: Colors.yellow, size: 30),
                                          const Icon(Icons.star,
                                              color: Colors.yellow, size: 30),
                                          const Icon(Icons.star,
                                              color: Colors.yellow, size: 30),
                                          const Icon(Icons.star,
                                              color: Colors.yellow, size: 30),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          productReviwCount == ''
                                              ? const Text("0 Reviews")
                                              : Text(productReviwCount ?? '0'),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Item Code : $model',
                                            style:
                                                CustomTextStyle.GraphikRegular(
                                                    13,
                                                    AppColors.secondTextColor),
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons
                                                    .delivery_dining, // Starting icon
                                                color: AppColors
                                                    .textFieldBorderColor, // Adjust color as needed
                                                size: 20,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                product_delivery_msg,
                                                style: CustomTextStyle
                                                    .GraphikRegular(
                                                        12, AppColors.black),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          if (tvdownload_pdf.isNotEmpty) ...[
                                            const SizedBox(
                                              height: 10.0,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    downloadPDF(context,
                                                        tvdownload_pdf);
                                                  },
                                                  child: Text(
                                                    'Download Datasheet',
                                                    style: CustomTextStyle
                                                        .GraphikRegular(13,
                                                            AppColors.black),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    if (product_label_info.isNotEmpty)
                                      Container(
                                        color: AppTheme().whiteColor,
                                        child: Visibility(
                                          visible:
                                              product_label_info.isNotEmpty,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),

                                            itemCount: product_label_info
                                                .length, // Use the correct list length
                                            itemBuilder: (context, index) {
                                              final label =
                                                  product_label_info[index];
                                              return Container(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0, left: 8.0),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: AppTheme()
                                                        .placeHolderColor, // Border color
                                                    width:
                                                        0.5, // Border thickness
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    // First text with fixed width
                                                    SizedBox(
                                                      width: 120.0,
                                                      child: Text(
                                                        label['label_name'] ??
                                                            '',
                                                        style: CustomTextStyle
                                                            .GraphikMedium(
                                                                14,
                                                                AppColors
                                                                    .black),
                                                      ),
                                                    ),
                                                    // Divider line
                                                    Container(
                                                      width: 0.5,
                                                      height:
                                                          50, // Adjust the height of the divider as needed
                                                      color: AppColors
                                                          .textFieldBorderColor,
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10.0),
                                                    ),
                                                    // Second text
                                                    Expanded(
                                                      child: Text(
                                                        label['label_value'] ??
                                                            '',
                                                        style: CustomTextStyle
                                                            .GraphikRegular(13,
                                                                AppColors.tex),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),

                                    /*Container(
                              color: AppTheme().whiteColor,
                              child: ListView.builder(
                                shrinkWrap: true, // Allow ListView to take only the required height
                                physics: NeverScrollableScrollPhysics(), // Disable scrolling to prevent overflow

                                itemCount: _sizes.length,
                                itemBuilder: (context, index) {
                                  final label = _sizes[index];
                                  return Container(
                                    padding: EdgeInsets.all(8.0), // Padding inside the item
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppTheme().lineColor, // Border color
                                        width: 1.0, // Border thickness
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            // First text with fixed width
                                            SizedBox(
                                              width: 60.0,
                                              child: Text(
                                                'Model',
                                                style: TextStyle(

                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16.0,
                                                  color: AppTheme().new_maintextcolor,
                                                ),
                                              ),
                                            ),
                                            // Divider line
                                            Container(
                                              width: 1.0,
                                              height: 20, // Adjust the height of the divider as needed
                                              color: AppTheme().lineColor, // Divider color
                                              margin: const EdgeInsets.symmetric(horizontal: 10.0),
                                            ),
                                            // Second text
                                            Expanded(
                                              child: Text(
                                                'Printer',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: AppTheme().secondTextColor,
                                                  fontWeight: FontWeight.w300
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),*/

                                    /*Container(
                              color: AppTheme().whiteColor,
                              child: ListView.builder(
                                // Use shrinkWrap to allow the GridView to take only the required height
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(), // Disable scrolling to prevent overflow

                                itemCount: productLabels.length,
                                itemBuilder: (context, index) {
                                  final label = productLabels[index];
                                  return Container(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [

                                        SizedBox(
                                          width: 100.0,
                                          child: Text(
                                            label['label'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme().secondTextColor, // Adjust as needed
                                            ),
                                          ),
                                        ),

                                        Text(label['value']),
                                        //Divider(thickness: 1, color: AppTheme().lineColor), // Optional Divider
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),*/

                                    if (product_label_info.isNotEmpty)
                                      const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Column(
                              children: [
                                Container(
                                  color: AppTheme().whiteColor,
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      Text(
                                        translate('Product Details'),
                                        style: CustomTextStyle.GraphikMedium(
                                            14, AppColors.black),
                                      ),
                                      Html(
                                        data:
                                            description, // This will render the HTML content
                                        style: {
                                          // Optionally, you can add styling to the HTML content
                                          "body": Style(
                                              fontSize: FontSize(13.0),
                                              fontFamily: 'GraphikMedium',
                                              color: AppColors.black)
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /*Container(
                        color: AppTheme().whiteColor,
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            // Reusable Column for Icon and Text
                            Expanded(
                              flex: 1, // Set flex to equally distribute space
                              child: Column(
                                children: <Widget>[
                                  SvgPicture.asset(
                                    'assets/icons/affordable_price.svg',
                                    width: 50,
                                    height: 50,
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    translate('Affordable'),
                                    textAlign: TextAlign.center, // Center text for better alignment
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: AppTheme().secondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.0), // Optional spacing between columns
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: <Widget>[
                                  SvgPicture.asset(
                                    'assets/icons/easy_return.svg',
                                    width: 50,
                                    height: 50,
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    translate('Easy Return'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: AppTheme().secondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: <Widget>[
                                  SvgPicture.asset(
                                    'assets/icons/gst_invoice.svg',
                                    width: 50,
                                    height: 50,
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    translate('GST Invoice'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: AppTheme().secondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: <Widget>[
                                  SvgPicture.asset(
                                    'assets/icons/gst_invoice.svg',
                                    width: 50,
                                    height: 50,
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    translate('Fast Shipping'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: AppTheme().secondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),*/

                              Container(
                                color: AppTheme().whiteColor,
                                padding: const EdgeInsets.all(15.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    // Reusable Column for Icon and Text
                                    /*Expanded(
                              flex: 1, // Set flex to equally distribute space
                              child: GestureDetector(
                                onTap: () {
                                  // Add your click action here
                                  print('Affordable tapped');
                                  String title = translate('Affordable');
                                  String value = returnPolicy; // Replace with your actual value

                                  log('Title: $title, Value: $value');
                                  // Add navigation or other actions here
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OtherScreen(
                                          title: title, value: value),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: <Widget>[
                                    SvgPicture.asset(
                                      'assets/icons/affordable_price.svg',
                                      width: 50,
                                      height: 50,
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      translate('Affordable'),
                                      textAlign: TextAlign.center,
                                      // Center text for better alignment
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: AppTheme().secondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 8.0),*/
                                    // Optional spacing between columns
                                    Expanded(
                                      flex: 1,
                                      child: GestureDetector(
                                        onTap: () {
                                          // Add your click action here
                                          String title = 'Return Policy';
                                          String value =
                                              returnPolicy; // Default to empty string if returnPolicy is null

                                          // Add navigation or other actions here
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => OtherScreen(
                                                title: title,
                                                value: value,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Visibility(
                                          visible: returnPolicy.isNotEmpty,
                                          child: Column(
                                            children: <Widget>[
                                              SvgPicture.asset(
                                                'assets/icons/easy_return.svg',
                                                width: 50,
                                                height: 50,
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                translate('Return Policy'),
                                                textAlign: TextAlign.center,
                                                style: CustomTextStyle
                                                    .GraphikRegular(13,
                                                        AppColors.colorPrimary),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      flex: 1,
                                      child: GestureDetector(
                                        onTap: () {
                                          // Add your click action here
                                          String title = 'GST Included';
                                          String value = gst_included;

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => OtherScreen(
                                                title: title,
                                                value: value,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Visibility(
                                          visible: gst_included
                                              .isNotEmpty, // Check if returnPolicy is not null and not empty
                                          child: Column(
                                            children: <Widget>[
                                              SvgPicture.asset(
                                                'assets/icons/gst_invoice.svg',
                                                width: 50,
                                                height: 50,
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                translate('Decont Delivery'),
                                                textAlign: TextAlign.center,
                                                style: CustomTextStyle
                                                    .GraphikRegular(13,
                                                        AppColors.colorPrimary),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      flex: 1,
                                      child: GestureDetector(
                                        onTap: () {
                                          // Add your click action here
                                          String title =
                                              translate('Fast Shipping');
                                          String value =
                                              decornt_delivery; // Replace with your actual value
                                          // Add navigation or other actions here
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => OtherScreen(
                                                  title: title, value: value),
                                            ),
                                          );
                                        },
                                        child: Visibility(
                                          visible: decornt_delivery
                                              .isNotEmpty, // Check if returnPolicy is not null and not empty
                                          child: Column(
                                            children: <Widget>[
                                              SvgPicture.asset(
                                                'assets/icons/gst_invoice.svg',
                                                width: 50,
                                                height: 50,
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                translate('GST Included'),
                                                textAlign: TextAlign.center,
                                                style: CustomTextStyle
                                                    .GraphikRegular(13,
                                                        AppColors.colorPrimary),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                color:
                                    AppTheme().product_detail_offer_background,
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.discount, // Starting icon
                                          color: AppColors
                                              .darkgreenColor, // Adjust color as needed
                                          size: 20,
                                        ),
                                        const SizedBox(
                                            width:
                                                10), // Space between icon and text
                                        Expanded(
                                          child: Text(
                                            'Save Extra with Offers', // Name
                                            style:
                                                CustomTextStyle.GraphikMedium(
                                                    16,
                                                    AppColors.darkgreenColor),
                                            maxLines:
                                                2, // Set the maximum number of lines
                                            overflow: TextOverflow
                                                .ellipsis, // Add ellipsis for overflow
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                          'assets/images/gst_image.png',
                                          fit: BoxFit.fill,
                                          height: 30.0,
                                          width: 30.0,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                          height: 10.0,
                                        ),
                                        // Using Flexible instead of Expanded as it's more appropriate for controlling flex behavior
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Get Cashback',
                                                style: CustomTextStyle
                                                    .GraphikMedium(
                                                        15, AppColors.black),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Get 1% cashback on your super wallet amounting to 91',
                                                style: CustomTextStyle
                                                    .GraphikRegular(
                                                        14,
                                                        AppColors
                                                            .secondTextColor),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    GestureDetector(
                                      onTap: () => _showBottomSheet(context),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/images/gst_image.png',
                                            fit: BoxFit.fill,
                                            height: 30.0,
                                            width: 30.0,
                                          ),
                                          const SizedBox(width: 10),
                                          // Using Flexible instead of Expanded as it's more appropriate for controlling flex behavior
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Get GST invoice and save up to 28% on Business Purchases.',
                                                  style: CustomTextStyle
                                                      .GraphikMedium(
                                                          15, AppColors.black),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Registered users will receive business (GST) invoice with your company name and GST number.',
                                                  style: CustomTextStyle
                                                      .GraphikRegular(
                                                          14,
                                                          AppColors
                                                              .secondTextColor),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.black,
                                            size: 13,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                          'assets/images/gst_image.png',
                                          fit: BoxFit.fill,
                                          height: 30.0,
                                          width: 30.0,
                                        ),
                                        const SizedBox(width: 10),
                                        // Using Flexible instead of Expanded as it's more appropriate for controlling flex behavior
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'EMIs Available on all Leading Credit Cards & ZestMoney',
                                                style: CustomTextStyle
                                                    .GraphikMedium(
                                                        15, AppColors.black),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                'EMI is available from leading credit cards like ICICI, SBI, HDFC, YES Bank, etc., and a Buy Now, Pay Later facility is available from Lazy Pay Simpl and others. Check the payment page at the time of check-out to avail of these facilities.',
                                                style: CustomTextStyle
                                                    .GraphikRegular(
                                                        14,
                                                        AppColors
                                                            .secondTextColor),
                                                maxLines: 5,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    /*GestureDetector(
                              onTap: () => _showBottomSheet(context),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Image.asset(
                                    'assets/images/gst_image.png',
                                    fit: BoxFit.fill,
                                    height: 30.0,
                                    width: 30.0,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Get GST invoice and save up to 28% on Business Purchases.',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppTheme().blackColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Registered users will receive business (GST) invoice with your company name and GST number.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme().secondTextColor,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.black,
                                    size: 13,
                                  ),
                                ],
                              ),
                            ),*/

                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          /*SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: AppTheme().product_detail_offer_background,
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Text(
                                  translate('Offers and Coupons'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppTheme().new_maintextcolor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),


                            SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between start and end
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delivery_dining_sharp, // Starting icon
                                        color: AppTheme().product_detail_icon, // Adjust color as needed
                                        size: 24,
                                      ),
                                      SizedBox(width: 8), // Space between icon and text
                                      Expanded(
                                        child: Text(
                                          'Get Flat Rs. 300 OFF all Products on November Sale', // Name
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppTheme().secondTextColor,
                                          ),
                                          maxLines: 2, // Set the maximum number of lines
                                          overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios, // End icon
                                  color: AppTheme().blackColor,
                                  size: 13,
                                ),
                              ],
                            ),

                            SizedBox(height: 10),

                            Divider(height: 1.0, color: AppTheme().lineColor),

                            SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between start and end
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delivery_dining_sharp, // Starting icon
                                        color: AppTheme().product_detail_icon, // Adjust color as needed
                                        size: 24,
                                      ),
                                      SizedBox(width: 8), // Space between icon and text
                                      Expanded(
                                        child: Text(
                                          'Get GST invoice and save up to 18% on business purchases', // Name
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppTheme().secondTextColor,
                                          ),
                                          maxLines: 2, // Set the maximum number of lines
                                          overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios, // End icon
                                  color: AppTheme().blackColor,
                                  size: 13,
                                ),
                              ],
                            ),

                            SizedBox(height: 10),

                            Divider(height: 1.0, color: AppTheme().lineColor),

                            SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between start and end
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delivery_dining_sharp, // Starting icon
                                        color: AppTheme().product_detail_icon, // Adjust color as needed
                                        size: 24,
                                      ),
                                      SizedBox(width: 8), // Space between icon and text
                                      Expanded(
                                        child: Text(
                                          'EMIs Available On min. purchase of Rs. 3000 across banks', // Name
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppTheme().secondTextColor,
                                          ),
                                          maxLines: 2, // Set the maximum number of lines
                                          overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios, // End icon
                                  color: AppTheme().blackColor,
                                  size: 13,
                                ),
                              ],
                            ),



                            SizedBox(height: 10),

                          ],
                        ),
                      ),
                    ],
                  ),*/

                          //Delivery Option
                          const SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                color: AppTheme()
                                    .product_detail_delivery_background
                                    .withAlpha(50),
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Text(
                                          translate(
                                              'Specify pincode to find delivery at your location'),
                                          style: CustomTextStyle.GraphikMedium(
                                              13, AppColors.black),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors
                                            .white, // Set the background color to white
                                        border: Border.all(
                                            color:
                                                AppColors.textFieldBorderColor),
                                        borderRadius: BorderRadius.circular(
                                            5), // Rounded corners
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              8.0), // Add padding inside the container
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                                cursorColor:
                                                    AppColors.colorPrimary,
                                                controller: _pinController,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                ],
                                                maxLength: 6,
                                                decoration: InputDecoration(
                                                  hintText: translate(
                                                      'Enter PIN Code'),
                                                  labelStyle: CustomTextStyle
                                                      .GraphikMedium(14,
                                                          AppColors.greyColor),
                                                  hintStyle: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium!
                                                      .copyWith(
                                                          color: AppColors.tex,
                                                          fontSize: 13),
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  counterText:
                                                      "", // Removes the character counter below the field
                                                  border: InputBorder
                                                      .none, // No border for the text field
                                                ),
                                                style: CustomTextStyle
                                                    .GraphikRegular(
                                                        12,
                                                        AppColors
                                                            .secondTextColor)),
                                          ),
                                          if (isCheckVisible)
                                            InkWell(
                                              onTap: () {
                                                // Handle the click event here
                                                checkpincode(_product_id);
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: AppColors.colorPrimary
                                                      .withOpacity(
                                                          0.5), // Light red background color for the button
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0), // Rounded corners
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 10.0,
                                                  vertical: 6.0,
                                                ), // Add padding inside the button
                                                child: Text(
                                                  'CHECK', // Button text
                                                  style: CustomTextStyle
                                                      .GraphikMedium(
                                                          12, AppColors.black),
                                                  textAlign: TextAlign
                                                      .center, // Center-align the text
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    if (_message.isNotEmpty)
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.delivery_dining_sharp,
                                            color: AppTheme()
                                                .thirdTextColor, // Icon color
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8.0),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _message,
                                                  textAlign: TextAlign.start,
                                                  style: CustomTextStyle
                                                      .GraphikRegular(
                                                          14,
                                                          AppColors
                                                              .darkgreenColor),
                                                  maxLines:
                                                      2, // Limit the number of lines
                                                  overflow: TextOverflow
                                                      .ellipsis, // Handle overflow with ellipsis
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (_message.isNotEmpty)
                                      const SizedBox(height: 10),

                                    /*Container(

                              child: Column(
                                children: [

                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.delivery_dining_sharp,
                                        color: AppTheme().thirdTextColor, // Icon color
                                        size: 24,
                                      ),
                                      SizedBox(width: 8.0), // Space between icon and text
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Free Delivery',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF0A7205), // Use the full 8-character hex code
                                              ),
                                              maxLines: 2, // Limit the number of lines
                                              overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                                            ),

                                            Text(
                                              'No shipping charge on this order',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF6f6f6f), // Use the full 8-character hex code
                                              ),
                                              maxLines: 2, // Limit the number of lines
                                              overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                                            ),
                                          ],
                                        ),

                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),

                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.delivery_dining_sharp,
                                        color: AppTheme().thirdTextColor, // Icon color
                                        size: 24,
                                      ),
                                      SizedBox(width: 8.0), // Space between icon and text
                                      Expanded(
                                        child: Text(
                                          'Regular delivery also available at 110092 in 2 day(s) ',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme().new_maintextcolor, // Adjust as needed
                                          ),
                                          maxLines: 2, // Limit the number of lines
                                          overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 10),

                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.delivery_dining_sharp,
                                        color: AppTheme().thirdTextColor, // Icon color
                                        size: 24,
                                      ),
                                      SizedBox(width: 8.0), // Space between icon and text
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'COD Available',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF0A7205), // Use the full 8-character hex code
                                              ),
                                              maxLines: 2, // Limit the number of lines
                                              overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                                            ),

                                            Text(
                                              'You can pay at the time of delivery',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF6f6f6f), // Use the full 8-character hex code
                                              ),
                                              maxLines: 2, // Limit the number of lines
                                              overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                                            ),
                                          ],
                                        ),
                                      ),

                                    ],
                                  ),
                                  SizedBox(height: 5),

                                ],

                              ),
                            ),

                            SizedBox(height: 10),*/
                                  ],
                                ),
                              ),
                            ],
                          ),

                          //get bulk order
                          /*SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: AppTheme().whiteColor,
                        //padding: const EdgeInsets.all(10.0),
                        padding: EdgeInsets.only(right: 10.0, left: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between start and end
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.local_offer, // Starting icon
                                      color: AppTheme().thirdTextColor, // Adjust color as needed
                                      size: 20,
                                    ),
                                    SizedBox(width: 8), // Space between icon and text

                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Interested to buy in bulk?', // Name
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme().new_maintextcolor,
                                            ),
                                          ),

                                          SizedBox(height: 2),

                                          Text(
                                            'Get customized price', // Name
                                            //textAlign: Alignment.topLeft,
                                            textAlign: TextAlign.start, // Center-align the text

                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme().secondTextColor,
                                            ),
                                          ),
                                        ],
                                    ),

                                  ],
                                ),

                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFfae0e1), // Light red background color for the button
                                    borderRadius: BorderRadius.circular(5.0), // Rounded corners
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                    vertical: 6.0,
                                  ), // Add padding inside the button
                                  child: Text(
                                    'GET QUOTE', // Button text
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFd9232d), // Dark red text color
                                      fontWeight: FontWeight.w600, // Bold text
                                    ),
                                    textAlign: TextAlign.center, // Center-align the text
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 10),

                          ],
                        ),
                      ),
                    ],
                  ),*/

                          //Review
                          const SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                key: _reviewsKey,

                                color: AppTheme().whiteColor,
                                //padding: const EdgeInsets.all(10.0),
                                padding: const EdgeInsets.only(
                                    right: 10.0, left: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween, // Space between start and end
                                      children: [
                                        Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Reviews & Ratings',
                                                    style: CustomTextStyle
                                                        .GraphikMedium(14,
                                                            AppColors.black)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Get.to(WriteReviewScreen());
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                  0xFFfae0e1), // Light red background color for the button
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      5.0), // Rounded corners
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0,
                                              vertical: 6.0,
                                            ), // Add padding inside the button
                                            child: Text(
                                              'WRITE A REVIEW', // Button text
                                              style:
                                                  CustomTextStyle.GraphikMedium(
                                                      12,
                                                      AppColors.colorPrimary),
                                              textAlign: TextAlign
                                                  .center, // Center-align the text
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        const SizedBox(height: 10),
                                        Text(
                                          Name.toString(),
                                          style: CustomTextStyle.GraphikMedium(
                                              12, AppColors.black),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 1,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        '4.7',
                                                        style: TextStyle(
                                                            fontSize: 32,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.green),
                                                      ),
                                                      Icon(
                                                        Icons.star,
                                                        size: 32,
                                                        color: Colors.green,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Text(
                                                    'Average Rating based on 6 ratings and 6 reviews',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: AppTheme()
                                                            .new_maintextcolor),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                                width:
                                                    20), // Space between the two widgets
                                            Expanded(
                                              flex: 1,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  _buildRatingItem(
                                                      5, Colors.green, 0.8),
                                                  _buildRatingItem(
                                                      4, Colors.green, 0.4),
                                                  _buildRatingItem(
                                                      3, Colors.grey, 0),
                                                  _buildRatingItem(
                                                      2, Colors.grey, 0),
                                                  _buildRatingItem(
                                                      1, Colors.grey, 0),
                                                ],
                                              ),
                                              //child: _buildRatingBar(),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Divider(
                                      color: AppTheme().lineColor,
                                      thickness: 1.0,
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount:
                                          2, // Replace with actual number of reviews
                                      itemBuilder: (context, index) {
                                        return Column(
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10.0),
                                              child: Container(
                                                //padding: const EdgeInsets.all(10.0),

                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween, // Space between start and end
                                                      children: [
                                                        Row(
                                                          children: [
                                                            // Build dynamic stars based on rating
                                                            for (int i = 0;
                                                                i < 5;
                                                                i++)
                                                              Icon(
                                                                i <
                                                                        rating_1
                                                                            .floor() // Full stars for rating
                                                                    ? Icons.star
                                                                    : (i < rating_1 &&
                                                                            rating_1 - rating_1.floor() >=
                                                                                0.5
                                                                        ? Icons
                                                                            .star_half // Half star if needed
                                                                        : Icons
                                                                            .star_border), // Empty stars
                                                                size: 20,
                                                                color: const Color(
                                                                    0xfffdb92c),
                                                              ),
                                                            const SizedBox(
                                                                width: 8),
                                                          ],
                                                        ),
                                                        Text(
                                                          'Verified Purchase', // Button text
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: AppTheme()
                                                                .DarkgreenColor, // Dark red text color
                                                          ),
                                                          textAlign: TextAlign
                                                              .center, // Center-align the text
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      'User  ${index + 1}',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: AppTheme()
                                                              .new_maintextcolor),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    const Text(
                                                      'February 17, 2024 ',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Color(0xff6f6f6f),
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      'Solid choice ',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color: AppTheme()
                                                              .new_maintextcolor,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      'I received the printer precisely as promised and the shipping was quick I am overjoyed with my buy. ',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: AppTheme()
                                                            .new_maintextcolor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (index <
                                                1) // Add a divider only between items, not after the last one
                                              Divider(
                                                color: AppTheme().lineColor,
                                                thickness: 1.0,
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                    Divider(
                                      color: AppTheme().lineColor,
                                      thickness: 1.0,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(RatingAndReviewScreen());
                                      },
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceBetween, // Space between start and end
                                        children: [
                                          Row(
                                            children: [
                                              // Build dynamic stars based on rating
                                              Text(
                                                ' VIEW 4 MORE HELPFUL REVIEWS', // Button text
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(
                                                        0xff086ac9), // Dark red text color
                                                    fontWeight:
                                                        FontWeight.w600),
                                                textAlign: TextAlign
                                                    .center, // Center-align the text
                                              ),
                                            ],
                                          ),

                                          Icon(
                                            Icons.chevron_right,
                                            color: Color(0xff086ac9),
                                          ), // Empty stars
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          //ask questions
                          /*SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: AppTheme().whiteColor,
                        //padding: const EdgeInsets.all(10.0),
                        padding: EdgeInsets.only(right: 10.0, left: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between start and end
                              children: [
                                Row(
                                  children: [

                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Frequently Asked Questions',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppTheme().new_maintextcolor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),

                                      ],
                                    ),

                                  ],
                                ),


                                GestureDetector(
                                  onTap: () {
                                    // Action when the button is clicked
                                    Navigator.of(context).push(PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => AskQuestionScreen(),
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
                                    // You can perform any action here like navigating to another page or showing a dialog.
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFfae0e1), // Light red background color for the button
                                      borderRadius: BorderRadius.circular(5.0), // Rounded corners
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                      vertical: 6.0,
                                    ), // Add padding inside the button
                                    child: Text(
                                      'ASK NOW', // Button text
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFd9232d), // Dark red text color
                                        fontWeight: FontWeight.w600, // Bold text
                                      ),
                                      textAlign: TextAlign.center, // Center-align the text
                                    ),
                                  ),
                                ),

                              ],
                            ),


                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 10),
                                Text(
                                  ' Displaying Questions 2/3',
                                  style: TextStyle(fontSize: 12, color: AppTheme().new_maintextcolor),
                                ),
                              ],
                            ),

                            Divider(
                              color: AppTheme().lineColor,
                              thickness: 1.0,
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: 2, // Replace with actual number of reviews
                              itemBuilder: (context, index) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: 5.0),
                                      child: Container(

                                        //padding: const EdgeInsets.all(10.0),

                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [

                                            Text(
                                              'Q1: Does it support inverter?',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: AppTheme().new_maintextcolor,
                                                fontWeight: FontWeight.w600
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Container(
                                              margin: EdgeInsets.only(left: 25.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Ans: Yes, it does',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Color(0xff6f6f6f),
                                                        fontWeight: FontWeight.w400),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    if (index < 1) // Add a divider only between items, not after the last one
                                      Divider(
                                        color: AppTheme().lineColor,
                                        thickness: 1.0,
                                      ),

                                  ],
                                );
                              },
                            ),

                            Divider(
                              color: AppTheme().lineColor,
                              thickness: 1.0,
                            ),

                            GestureDetector(
                              onTap: () {
                                // Add the action for the tap event here
                                Navigator.of(context).push(PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => QuestionAndAnswerListScreen(),
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
                                // You can navigate to another screen or perform any other action
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between start and end
                                children: [
                                  Row(
                                    children: [
                                      // Build dynamic stars based on rating
                                      Text(
                                        ' VIEW 4 MORE FAQs', // Button text
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xff086ac9), // Dark red text color
                                            fontWeight: FontWeight.w600
                                        ),
                                        textAlign: TextAlign.center, // Center-align the text
                                      ),
                                    ],
                                  ),

                                  Icon(Icons.chevron_right, color: Color(0xff086ac9),), // Empty stars
                                ],
                              ),
                            ),
                            SizedBox(height: 10),

                          ],
                        ),
                      ),
                    ],
                  ),*/
                          InkWell(
                            key: _buttonReviewKey,
                            onTap: () {
                              //TODO
                            },
                            child: Container(
                              color: AppColors.white,
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DECONT BULK',
                                    style: CustomTextStyle.GraphikMedium(
                                        14, AppColors.black),
                                  ),
                                  const SizedBox(height: 5),
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(GetQuote(
                                        productName: Name,
                                      ));
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Want to request for bulk purchases?',
                                            style:
                                                CustomTextStyle.GraphikRegular(
                                                    13, AppColors.black),
                                          ),
                                        ),
                                        Text(
                                          'GET QUOTE',
                                          style: CustomTextStyle.GraphikMedium(
                                              14,
                                              AppColors
                                                  .colorPrimary), // or any highlight color
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Get quick quotes for bulk queries',
                                    style: CustomTextStyle.GraphikRegular(
                                        13, AppColors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 15,
                          ),
                          Container(
                            color: AppColors.white,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text('Review & Rating',
                                    style: CustomTextStyle.GraphikMedium(
                                        14, AppColors.black)),
                                const SizedBox(
                                  height: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      "/write_review",
                                      arguments: {
                                        'productName': Name,
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    height: 50,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.colorButton,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      "RATE AND WRITE REVIEW",
                                      style: CustomTextStyle.GraphikMedium(
                                          14, AppColors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                    'Share your experience with other customers.',
                                    style: CustomTextStyle.GraphikRegular(
                                        14, AppColors.black)),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Container(
                            color: AppColors.white,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text('Have doubts regarding this product ?',
                                    style: CustomTextStyle.GraphikMedium(
                                        14, AppColors.black)),
                                const SizedBox(
                                  height: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    Get.to(AskQuestionScreen(
                                      productName: Name.toString(),
                                    ));
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    height: 50,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.colorButton,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      "ASK QUESTION",
                                      style: CustomTextStyle.GraphikMedium(
                                          14, AppColors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),

                          //Related Product Section Layout
                          buildRelatedProducts(),
                          // if (productsList.isNotEmpty) ...[
                          //   const SizedBox(height: 10),
                          //   Container(
                          //     padding: const EdgeInsets.all(10.0),
                          //     color: AppTheme().whiteColor,
                          //     child: Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: [
                          //         Text('Related Porducts',
                          //             style: CustomTextStyle.GraphikMedium(
                          //                 14, AppColors.black)),
                          //         const SizedBox(height: 15),
                          //         SizedBox(
                          //           height: 245.0,
                          //           child: ListView.builder(
                          //             scrollDirection: Axis.horizontal,
                          //             itemCount: productsList.length,
                          //             itemBuilder: (context, index) {
                          //               var item = productsList[index];
                          //
                          //               return GestureDetector(
                          //                 onTap: () {
                          //                   Get.to(ProductDetailScreen(
                          //                       product_id: item['productID']));
                          //                 },
                          //                 child: Container(
                          //                   padding: const EdgeInsets.all(1.0),
                          //                   height: 200.0,
                          //                   width: 160,
                          //                   margin: const EdgeInsets.only(
                          //                       right: 10.0),
                          //                   decoration: BoxDecoration(
                          //                     color: AppColors.white,
                          //                     border: Border.all(
                          //                       color: AppColors
                          //                           .textFieldBorderColor,
                          //                       width: 0.3,
                          //                     ),
                          //                     borderRadius:
                          //                         BorderRadius.circular(5.0),
                          //                   ),
                          //                   child: Column(
                          //                     mainAxisAlignment:
                          //                         MainAxisAlignment.start,
                          //                     crossAxisAlignment:
                          //                         CrossAxisAlignment.start,
                          //                     children: [
                          //                       Stack(
                          //                         children: [
                          //                           ClipRRect(
                          //                             borderRadius:
                          //                                 BorderRadius.circular(
                          //                                     5.0),
                          //                             child: CachedNetworkImage(
                          //                               imageUrl: item['image'],
                          //                               height: 130,
                          //                               width: double.infinity,
                          //                               fit: BoxFit.contain,
                          //                               placeholder: (context,
                          //                                       url) =>
                          //                                   const Center(
                          //                                       child:
                          //                                           CircularProgressIndicator(
                          //                                 color: AppColors
                          //                                     .colorPrimary,
                          //                               )),
                          //                               errorWidget: (context,
                          //                                   error, stackTrace) {
                          //                                 // In case of error, show a default image
                          //                                 return Image.asset(
                          //                                   'assets/decont_splash_screen_images/decont_logo.png',
                          //                                   fit: BoxFit.contain,
                          //                                   height: 100,
                          //                                   width:
                          //                                       double.infinity,
                          //                                 );
                          //                               },
                          //                             ),
                          //                           ),
                          //                           Positioned(
                          //                             top: 2,
                          //                             left: 0,
                          //                             child: Container(
                          //                               decoration:
                          //                                   const BoxDecoration(
                          //                                 color: AppColors.green,
                          //                                 borderRadius:
                          //                                     BorderRadius.only(
                          //                                   bottomRight:
                          //                                       Radius.circular(
                          //                                           5),
                          //                                 ),
                          //                               ),
                          //                               padding: const EdgeInsets
                          //                                   .symmetric(
                          //                                   horizontal: 3,
                          //                                   vertical: 5),
                          //                               child: Column(
                          //                                 children: [
                          //                                   Text(
                          //                                     discount,
                          //                                     style: CustomTextStyle
                          //                                         .GraphikMedium(
                          //                                             8,
                          //                                             AppTheme()
                          //                                                 .whiteColor),
                          //                                   ),
                          //                                 ],
                          //                               ),
                          //                             ),
                          //                           ),
                          //                           Positioned(
                          //                             right: 5.0,
                          //                             child: IconButton(
                          //                               icon: Icon(
                          //                                 _isFavorite
                          //                                     ? Icons.favorite
                          //                                     : Icons
                          //                                         .favorite_border,
                          //                                 color: _isFavorite
                          //                                     ? Colors.red
                          //                                     : Colors.grey,
                          //                               ),
                          //                               onPressed:
                          //                                   _toggleFavorite,
                          //                             ),
                          //                           )
                          //                         ],
                          //                       ),
                          //                       const SizedBox(
                          //                         height: 10.0,
                          //                       ),
                          //                       // Container(
                          //                       //   padding: const EdgeInsets.only(
                          //                       //       left: 10.0, right: 10.0),
                          //                       //   child: Row(
                          //                       //     children: [
                          //                       //       Expanded(
                          //                       //         child: Row(
                          //                       //           children: [
                          //                       //             Visibility(
                          //                       //               visible: item[
                          //                       //                           'review_count'] !=
                          //                       //                       null &&
                          //                       //                   item['review_count']
                          //                       //                       .isNotEmpty &&
                          //                       //                   item['review_count'] !=
                          //                       //                       '0',
                          //                       //               child: Container(
                          //                       //                 padding:
                          //                       //                     const EdgeInsets
                          //                       //                         .symmetric(
                          //                       //                         horizontal:
                          //                       //                             5,
                          //                       //                         vertical:
                          //                       //                             3),
                          //                       //                 // Add padding
                          //                       //                 decoration:
                          //                       //                     BoxDecoration(
                          //                       //                   color: AppColors
                          //                       //                       .darkgreenColor,
                          //                       //
                          //                       //                   // Background color
                          //                       //                   borderRadius:
                          //                       //                       BorderRadius
                          //                       //                           .circular(
                          //                       //                               5), // Corner radius
                          //                       //                 ),
                          //                       //                 child: Row(
                          //                       //                   mainAxisAlignment:
                          //                       //                       MainAxisAlignment
                          //                       //                           .spaceBetween,
                          //                       //                   // Space between text and icon
                          //                       //                   children: [
                          //                       //                     Text(
                          //                       //                       item['review_count']
                          //                       //                           .toString(),
                          //                       //                       // Use dynamic star value
                          //                       //                       style:
                          //                       //                           TextStyle(
                          //                       //                         fontSize:
                          //                       //                             11,
                          //                       //                         color: AppTheme()
                          //                       //                             .whiteColor,
                          //                       //                       ),
                          //                       //                     ),
                          //                       //                     const SizedBox(
                          //                       //                         width: 4),
                          //                       //                     // Add spacing between text and icon
                          //                       //                     const Icon(
                          //                       //                       Icons.star,
                          //                       //                       color: Colors
                          //                       //                           .white,
                          //                       //                       // Star color
                          //                       //                       size:
                          //                       //                           12, // Small icon size
                          //                       //                     ),
                          //                       //                   ],
                          //                       //                 ),
                          //                       //               ),
                          //                       //             ),
                          //                       //             const SizedBox(
                          //                       //               width: 5.0,
                          //                       //             ),
                          //                       //             Visibility(
                          //                       //               visible: item[
                          //                       //                           'review_msg'] !=
                          //                       //                       null &&
                          //                       //                   item['review_msg']
                          //                       //                       .isNotEmpty,
                          //                       //               child: Text(
                          //                       //                   '(${item['review_msg']})',
                          //                       //                   style: Theme.of(
                          //                       //                           context)
                          //                       //                       .textTheme
                          //                       //                       .displayMedium!
                          //                       //                       .copyWith(
                          //                       //                           color: AppColors
                          //                       //                               .textSub,
                          //                       //                           fontSize:
                          //                       //                               12)),
                          //                       //             ),
                          //                       //           ],
                          //                       //         ),
                          //                       //       ),
                          //                       //     ],
                          //                       //   ),
                          //                       // ),
                          //                       const SizedBox(
                          //                         height: 10.0,
                          //                       ),
                          //                       Container(
                          //                         padding: const EdgeInsets.only(
                          //                             left: 10.0, right: 10.0),
                          //                         child: Text(
                          //                           item['name'],
                          //                           // Example text from car object
                          //                           style: CustomTextStyle
                          //                               .GraphikMedium(13.5,
                          //                                   AppColors.black),
                          //                           maxLines: 2,
                          //                           // Limit to 1 line for name
                          //                           overflow: TextOverflow
                          //                               .ellipsis, // Ellipsis for overflow
                          //                         ),
                          //                       ),
                          //                       const SizedBox(
                          //                         height: 2.0,
                          //                       ),
                          //                       Container(
                          //                         padding:
                          //                             const EdgeInsets.symmetric(
                          //                                 horizontal: 10),
                          //                         child: Row(
                          //                           children: [
                          //                             Expanded(
                          //                               child: Column(
                          //                                 mainAxisAlignment:
                          //                                     MainAxisAlignment
                          //                                         .start,
                          //                                 crossAxisAlignment:
                          //                                     CrossAxisAlignment
                          //                                         .start,
                          //                                 children: [
                          //                                   Row(
                          //                                     children: [
                          //                                       Flexible(
                          //                                         flex: 1,
                          //                                         // First flex item, takes 2 parts of the available space
                          //                                         child:
                          //                                             Visibility(
                          //                                           visible: item[
                          //                                                       'without_gst_mrp'] !=
                          //                                                   null &&
                          //                                               item['without_gst_mrp']
                          //                                                   .isNotEmpty,
                          //                                           child: Text(
                          //                                             '₹ ${'${item['without_gst_mrp']}'}',
                          //                                             style: CustomTextStyle.GraphikRegular(10.5, AppColors.secondTextColor)?.copyWith(
                          //                                                 decorationThickness:
                          //                                                     1,
                          //                                                 decorationColor:
                          //                                                     AppColors
                          //                                                         .black,
                          //                                                 decoration:
                          //                                                     TextDecoration.lineThrough),
                          //                                             overflow:
                          //                                                 TextOverflow
                          //                                                     .ellipsis, // Ensure text doesn't overflow
                          //
                          //                                             maxLines:
                          //                                                 1, // Limit to one line
                          //                                           ),
                          //                                         ),
                          //                                       ),
                          //                                       // const SizedBox(
                          //                                       //     width: 5.0),
                          //                                       // // Spacer between the two Flexible widgets
                          //                                       // Flexible(
                          //                                       //   flex: 1,
                          //                                       //   // Second flex item, takes 1 part of the available space
                          //                                       //   child:
                          //                                       //       Visibility(
                          //                                       //     visible: item[
                          //                                       //                 'without_gst_disc'] !=
                          //                                       //             null &&
                          //                                       //         item['without_gst_disc']
                          //                                       //             .isNotEmpty,
                          //                                       //     child: Text(
                          //                                       //       '${item['without_gst_disc']}',
                          //                                       //       style: Theme.of(
                          //                                       //               context)
                          //                                       //           .textTheme
                          //                                       //           .labelMedium!
                          //                                       //           .copyWith(
                          //                                       //               color:
                          //                                       //                   AppColors.darkgreenColor,
                          //                                       //               fontSize: 13),
                          //                                       //
                          //                                       //       overflow:
                          //                                       //           TextOverflow
                          //                                       //               .ellipsis,
                          //                                       //       // Ensure text doesn't overflow
                          //                                       //       maxLines:
                          //                                       //           1, // Limit to one line
                          //                                       //     ),
                          //                                       //   ),
                          //                                       // ),
                          //                                     ],
                          //                                   ),
                          //                                   const SizedBox(
                          //                                     width: 5.0,
                          //                                   ),
                          //                                   Container(
                          //                                     margin:
                          //                                         const EdgeInsets
                          //                                             .only(
                          //                                             top: 3.0),
                          //                                     child: Visibility(
                          //                                       visible: item[
                          //                                                   'without_gst_price'] !=
                          //                                               null &&
                          //                                           item['without_gst_price']
                          //                                               .isNotEmpty,
                          //                                       child: Text(
                          //                                         '₹ ${'${item['without_gst_price']}'}',
                          //                                         style: CustomTextStyle
                          //                                             .GraphikMedium(
                          //                                                 13.5,
                          //                                                 AppColors
                          //                                                     .black),
                          //                                       ),
                          //                                     ),
                          //                                   ),
                          //                                 ],
                          //                               ),
                          //                             ),
                          //                           ],
                          //                         ),
                          //                       ),
                          //
                          //                       /*Container(
                          //             padding: EdgeInsets.only(left: 10.0, right: 10.0),
                          //             child: Row(
                          //               children: [
                          //                 Expanded(
                          //                   child: Row(
                          //                     children: [
                          //                       Visibility(
                          //                         visible: true,
                          //                         //visible: widget.car.price != null && widget.car.price.isNotEmpty,
                          //                         child: Container(
                          //                           padding: EdgeInsets.symmetric(
                          //                               horizontal: 5, vertical: 5), // Add padding
                          //                           decoration: BoxDecoration(
                          //                             color: AppTheme().DarkgreenColor,
                          //                             // Background color
                          //                             borderRadius:
                          //                             BorderRadius.circular(5), // Corner radius
                          //                           ),
                          //                           child: Row(
                          //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //                             // Space between text and icon
                          //                             children: [
                          //                               Text(
                          //                                 '4.5',
                          //                                 style: TextStyle(
                          //                                   fontSize: 11,
                          //                                   color: AppTheme().whiteColor,
                          //                                 ),
                          //                               ),
                          //                               SizedBox(width: 4),
                          //                               // Add spacing between text and icon
                          //                               Icon(
                          //                                 Icons.star,
                          //                                 color: Colors.white, // Star color
                          //                                 size: 12, // Small icon size
                          //                               ),
                          //                             ],
                          //                           ),
                          //                         ),
                          //                       ),
                          //                       SizedBox(
                          //                         width: 5.0,
                          //                       ),
                          //                       Visibility(
                          //                         visible: true,
                          //                         //visible: widget.car.price != null && widget.car.price.isNotEmpty,
                          //                         child: Text(
                          //                           //'₹ ${'${widget.car.price} / ${widget.car.base_weight}'}',
                          //                           '(1 Review)',
                          //                           style: TextStyle(
                          //                               fontSize: 13,
                          //                               color: AppTheme().secondTextColor),
                          //                         ),
                          //                       ),
                          //                     ],
                          //                   ),
                          //                 ),
                          //               ],
                          //             ),
                          //           ),
                          //           SizedBox(
                          //             height: 10.0,
                          //           ),
                          //           Container(
                          //             padding: EdgeInsets.only(left: 10.0, right: 10.0),
                          //             child: Text(
                          //               item['name'],
                          //               // Example text from car object
                          //               style: const TextStyle(
                          //                 fontSize: 14.0,
                          //               ),
                          //               maxLines: 2, // Limit to 1 line for name
                          //               overflow: TextOverflow.ellipsis, // Ellipsis for overflow
                          //             ),
                          //           ),
                          //           SizedBox(
                          //             height: 10.0,
                          //           ),
                          //           Container(
                          //             padding: EdgeInsets.only(left: 10.0, right: 10.0),
                          //             child: Row(
                          //               children: [
                          //                 Expanded(
                          //                   child: Column(
                          //                     mainAxisAlignment: MainAxisAlignment.start,
                          //                     crossAxisAlignment: CrossAxisAlignment.start,
                          //                     children: [
                          //                       Row(
                          //                         children: [
                          //                           Visibility(
                          //                             //visible: widget.car.price != null && widget.car.price.isNotEmpty,
                          //                             visible: true,
                          //                             child: Text(
                          //                               //'₹ ${'${widget.car.price} / ${widget.car.base_weight}'}',
                          //                               '₹ 2000',
                          //                               style: TextStyle(
                          //                                 fontSize: 13,
                          //                                 color: AppTheme().thirdTextColor,
                          //                                 decoration: TextDecoration.lineThrough,
                          //                                 decorationColor: AppTheme().thirdTextColor,
                          //                               ),
                          //                             ),
                          //                           ),
                          //                           SizedBox(
                          //                             width: 5.0,
                          //                           ),
                          //                           Visibility(
                          //                             visible: true,
                          //                             //visible: widget.car.price != null && widget.car.price.isNotEmpty,
                          //                             child: Text(
                          //                               //'₹ ${'${widget.car.price} / ${widget.car.base_weight}'}',
                          //                               '7% OFF',
                          //                               style: TextStyle(
                          //                                   fontSize: 13,
                          //                                   color: AppTheme().DarkgreenColor,
                          //                                   fontWeight: FontWeight.bold),
                          //                             ),
                          //                           ),
                          //                         ],
                          //                       ),
                          //                       SizedBox(
                          //                         width: 5.0,
                          //                       ),
                          //                       Container(
                          //                         margin: EdgeInsets.only(top: 3.0),
                          //                         child: Visibility(
                          //                           */ /*visible: widget.car.mrp != null &&
                          //       widget.car.mrp.isNotEmpty,*/ /*
                          //                           child: Text(
                          //                             //'₹ ${'${widget.car.mrp}'}',
                          //                             '₹ 10000',
                          //                             style: TextStyle(
                          //                               fontSize: 16,
                          //                               color: AppTheme().firstTextColor,
                          //                               fontWeight: FontWeight.bold,
                          //                             ),
                          //                           ),
                          //                         ),
                          //                       ),
                          //                     ],
                          //                   ),
                          //                 ),
                          //               ],
                          //             ),
                          //           ),*/
                          //                     ],
                          //                   ),
                          //                 ),
                          //               );
                          //               /*return MyListTile(
                          //     car: Car(
                          //       id: item['id'],
                          //       partnerName: item['partner_id'],
                          //       name: item['product_name'],
                          //       url: item['image'],
                          //       // Assuming this is the image URL
                          //       mrp: item['mrp'],
                          //       price: item['price'],
                          //       inCart: item['in_cart'],
                          //       inWishlist: item['in_wishlist'],
                          //       unit: item['unit'],
                          //       base_weight: item['base_weight'],
                          //     ),
                          //   );*/
                          //             },
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ],

                          buildRecentViewedProducts(),
                        ]),
                  ),
                ),
                Container(
                  height: 1.0,
                  color: AppTheme().lineColor,
                ),
                productSoldoutOrNOt == 'Yes'
                    ? Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: AppTheme().redColor,
                        ),
                        child: Text(
                          'Sold Out',
                          style: CustomTextStyle.GraphikMedium(
                              12, AppTheme().whiteColor),
                        ),
                      )
                    : Container(
                        color: AppTheme().whiteColor,
                        padding: const EdgeInsets.all(3.0),
                        child: SizedBox(
                          width: double.infinity, // Button takes up full width
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // const Icon(
                              //   Icons.favorite_border_outlined,
                              //   size: 30,
                              // ),
                              // const SizedBox(
                              //   width: 5,
                              // ),
                              Expanded(
                                flex: 1, // Takes up 50% of the width
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // Step 1: Validate delivery type
                                    if (selectedDeliveryType.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Please select a delivery type',
                                            style:
                                                CustomTextStyle.GraphikMedium(
                                                    16, AppColors.white),
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return; // 🚫 Stop execution here
                                    }

                                    // Step 2: Validate size if required
                                    if (_selectedSize.isEmpty &&
                                        priceList.any((delivery) =>
                                            delivery['size_option'] == 'Yes')) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Please select a size',
                                            style:
                                                CustomTextStyle.GraphikMedium(
                                                    16, AppColors.white),
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return; // 🚫 Stop here as well
                                    }

                                    // Step 3: Check if product is already in cart
                                    Future<bool> checkIfProductInCart(
                                        String productId) async {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      List<String> cartItems =
                                          prefs.getStringList('cart_items') ??
                                              [];
                                      for (String item in cartItems) {
                                        Map<String, dynamic> cartItem =
                                            jsonDecode(item);
                                        if (cartItem['product_id'] ==
                                            productId) {
                                          return true;
                                        }
                                      }
                                      return false;
                                    }

                                    bool isProductInCart =
                                        await checkIfProductInCart(_product_id);
                                    if (isProductInCart) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'This product is already in your cart',
                                            style:
                                                CustomTextStyle.GraphikMedium(
                                                    16, AppColors.white),
                                          ),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }

                                    // Step 4: Check login
                                    if (userID == null || userID!.isEmpty) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor:
                                                AppTheme().whiteColor,
                                            surfaceTintColor:
                                                AppTheme().whiteColor,
                                            title: Text(
                                              'Login Required',
                                              style:
                                                  CustomTextStyle.GraphikMedium(
                                                      18, AppColors.black),
                                            ),
                                            content: Text(
                                              'Please log in to access add to cart.',
                                              style: CustomTextStyle
                                                  .GraphikRegular(
                                                      14, AppColors.black),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text(
                                                  'Cancel',
                                                  style: CustomTextStyle
                                                      .GraphikMedium(
                                                          14,
                                                          AppColors
                                                              .colorPrimary),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  Navigator.pushNamed(
                                                      context, "/login");
                                                },
                                                child: Text(
                                                  'Login',
                                                  style: CustomTextStyle
                                                      .GraphikMedium(
                                                          14,
                                                          AppColors
                                                              .colorPrimary),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      return;
                                    }

                                    if (priceList.any((delivery) =>
                                        delivery['size_option'] == 'No')) {
                                      priceID = priceList.isNotEmpty
                                          ? priceList[0]['priceID']
                                          : '';
                                    }

                                    AddToCart(_quantity.toString(), priceID,
                                        _product_id);
                                  },

                                  // onPressed: () async {
                                  //   Future<bool> checkIfProductInCart(
                                  //       String productId) async {
                                  //     // Replace with your cart checking logic
                                  //     SharedPreferences prefs =
                                  //         await SharedPreferences.getInstance();
                                  //     List<String> cartItems =
                                  //         prefs.getStringList('cart_items') ??
                                  //             [];
                                  //
                                  //     for (String item in cartItems) {
                                  //       Map<String, dynamic> cartItem =
                                  //           jsonDecode(item);
                                  //       if (cartItem['product_id'] ==
                                  //           productId) {
                                  //         return true;
                                  //       }
                                  //     }
                                  //     return false;
                                  //   }
                                  //
                                  //   bool isProductInCart =
                                  //       await checkIfProductInCart(_product_id);
                                  //
                                  //
                                  //   if (selectedDeliveryType.isEmpty) {
                                  //     ScaffoldMessenger.of(context)
                                  //         .showSnackBar(
                                  //       SnackBar(
                                  //         content: Text(
                                  //             'Please select a delivery type',
                                  //             style:
                                  //                 CustomTextStyle.GraphikMedium(
                                  //                     16, AppColors.white)),
                                  //         backgroundColor: Colors.red,
                                  //       ),
                                  //     );
                                  //   } else if (_selectedSize.isEmpty &&
                                  //       priceList.any((delivery) =>
                                  //           delivery['size_option'] == 'Yes')) {
                                  //     ScaffoldMessenger.of(context)
                                  //         .showSnackBar(
                                  //       SnackBar(
                                  //         content: Text('Please select a size',
                                  //             style:
                                  //                 CustomTextStyle.GraphikMedium(
                                  //                     16, AppColors.white)),
                                  //         backgroundColor: Colors.red,
                                  //       ),
                                  //     );
                                  //     if (isProductInCart) {
                                  //       ScaffoldMessenger.of(context)
                                  //           .showSnackBar(
                                  //         SnackBar(
                                  //           content: Text(
                                  //               'This product is already in your cart',
                                  //               style: CustomTextStyle
                                  //                   .GraphikMedium(
                                  //                       16, AppColors.white)),
                                  //           backgroundColor: Colors.orange,
                                  //         ),
                                  //       );
                                  //       return;
                                  //     }
                                  //   } else {
                                  //     if (priceList.any((delivery) =>
                                  //         delivery['size_option'] == 'No')) {
                                  //       priceID = priceList.isNotEmpty
                                  //           ? priceList[0]['priceID']
                                  //           : '';
                                  //
                                  //       if (userID == null || userID!.isEmpty) {
                                  //         showDialog(
                                  //           context: context,
                                  //           builder: (context) {
                                  //             return AlertDialog(
                                  //               backgroundColor:
                                  //                   AppTheme().whiteColor,
                                  //               surfaceTintColor:
                                  //                   AppTheme().whiteColor,
                                  //               title: Text(
                                  //                 'Login Required',
                                  //                 style: CustomTextStyle
                                  //                     .GraphikMedium(
                                  //                         18, AppColors.black),
                                  //               ),
                                  //               content: Text(
                                  //                 'Please log in to access add to cart.',
                                  //                 style: CustomTextStyle
                                  //                     .GraphikRegular(
                                  //                         14, AppColors.black),
                                  //               ),
                                  //               actions: [
                                  //                 TextButton(
                                  //                   onPressed: () {
                                  //                     Navigator.pop(
                                  //                         context); // Close the dialog
                                  //                   },
                                  //                   child: Text(
                                  //                     'Cancel',
                                  //                     style: CustomTextStyle
                                  //                         .GraphikMedium(
                                  //                             14,
                                  //                             AppColors
                                  //                                 .colorPrimary),
                                  //                   ),
                                  //                 ),
                                  //                 TextButton(
                                  //                   onPressed: () {
                                  //                     Navigator.pushNamed(
                                  //                         context,
                                  //                         "/login"); // Navigate to login screen
                                  //                   },
                                  //                   child: Text(
                                  //                     'Login',
                                  //                     style: CustomTextStyle
                                  //                         .GraphikMedium(
                                  //                             14,
                                  //                             AppColors
                                  //                                 .colorPrimary),
                                  //                   ),
                                  //                 ),
                                  //               ],
                                  //             );
                                  //           },
                                  //         );
                                  //       } else {
                                  //         AddToCart(_quantity.toString(),
                                  //             priceID, _product_id);
                                  //       }
                                  //     } else {
                                  //       //priceID = priceList.isNotEmpty ? priceList[0]['priceID'] : '';
                                  //
                                  //       //AddToCart(_quantity.toString(), priceID, _product_id);
                                  //       if (userID == null || userID!.isEmpty) {
                                  //         // If userID is null or empty, show a message or navigate to the login screen
                                  //         showDialog(
                                  //           context: context,
                                  //           builder: (context) {
                                  //             return AlertDialog(
                                  //               backgroundColor:
                                  //                   AppTheme().whiteColor,
                                  //               surfaceTintColor:
                                  //                   AppTheme().whiteColor,
                                  //               title: Text(
                                  //                 'Login Required',
                                  //                 style: CustomTextStyle
                                  //                     .GraphikMedium(
                                  //                         18, AppColors.black),
                                  //               ),
                                  //               content: Text(
                                  //                 'Please log in to access add to cart.',
                                  //                 style: CustomTextStyle
                                  //                     .GraphikRegular(
                                  //                         14, AppColors.black),
                                  //               ),
                                  //               actions: [
                                  //                 TextButton(
                                  //                   onPressed: () {
                                  //                     Navigator.pop(
                                  //                         context); // Close the dialog
                                  //                   },
                                  //                   child: Text(
                                  //                     'Cancel',
                                  //                     style: CustomTextStyle
                                  //                         .GraphikMedium(
                                  //                             14,
                                  //                             AppColors
                                  //                                 .colorPrimary),
                                  //                   ),
                                  //                 ),
                                  //                 TextButton(
                                  //                   onPressed: () {
                                  //                     Navigator.pushNamed(
                                  //                         context,
                                  //                         "/login"); // Navigate to login screen
                                  //                   },
                                  //                   child: Text(
                                  //                     'Login',
                                  //                     style: CustomTextStyle
                                  //                         .GraphikMedium(
                                  //                             14,
                                  //                             AppColors
                                  //                                 .colorPrimary),
                                  //                   ),
                                  //                 ),
                                  //               ],
                                  //             );
                                  //           },
                                  //         );
                                  //       } else {
                                  //         // If userID is not null and not empty, proceed to the WalletHistoryScreen
                                  //         AddToCart(_quantity.toString(),
                                  //             priceID, _product_id);
                                  //       }
                                  //     }
                                  //   }
                                  // },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.colorButton,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shopping_cart,
                                        color: AppTheme().whiteColor,
                                        size: 20.0, // Adjust the size as needed
                                      ),
                                      const SizedBox(
                                          width:
                                              8), // Add space between icon and text
                                      Text(
                                        translate('ADD TO CART'),
                                        style: CustomTextStyle.GraphikMedium(
                                            16, AppColors.white),
                                        textAlign: TextAlign
                                            .center, // Center text horizontally
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Spacer with 10px space between buttons
                              const SizedBox(width: 10),

                              // "Buy Now" Button
                              Expanded(
                                flex: 1, // Takes up the other 50% of the width
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Check if the delivery type is empty
                                    if (selectedDeliveryType.isEmpty) {
                                      // If delivery type is empty, fetch priceID from priceList
                                      print('PriceID is empty!');

                                      // Optionally, show a Snackbar to inform the user to select a delivery type
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Please select a delivery type',
                                            style:
                                                CustomTextStyle.GraphikMedium(
                                                    16, AppColors.white),
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                    // If size is required but not selected, prompt the user to select size
                                    else if (_selectedSize.isEmpty &&
                                        priceList.any((delivery) =>
                                            delivery['size_option'] == 'Yes')) {
                                      // If size is empty and the size option is available
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text('Please select a size',
                                              style:
                                                  CustomTextStyle.GraphikMedium(
                                                      16, AppColors.white)),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    } else {
                                      // If both delivery type and size (if required) are selected, proceed with the buy logic
                                      if (priceList.any((delivery) =>
                                          delivery['size_option'] == 'No')) {
                                        priceID = priceList.isNotEmpty
                                            ? priceList[0]['priceID']
                                            : '';
                                        //BuyNow(_quantity.toString(), priceID, _product_id);
                                        if (userID == null || userID!.isEmpty) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                backgroundColor:
                                                    AppTheme().whiteColor,
                                                surfaceTintColor:
                                                    AppTheme().whiteColor,
                                                title: Text(
                                                  'Login Required',
                                                  style: CustomTextStyle
                                                      .GraphikMedium(
                                                          18, AppColors.black),
                                                ),
                                                content: Text(
                                                  'Please log in to access buy now.',
                                                  style: CustomTextStyle
                                                      .GraphikRegular(
                                                          14, AppColors.black),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context); // Close the dialog
                                                    },
                                                    child: Text(
                                                      'Cancel',
                                                      style: CustomTextStyle
                                                          .GraphikMedium(
                                                              14,
                                                              AppColors
                                                                  .colorPrimary),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pushNamed(
                                                          context,
                                                          "/login"); // Navigate to login screen
                                                    },
                                                    child: Text(
                                                      'Login',
                                                      style: CustomTextStyle
                                                          .GraphikMedium(
                                                              14,
                                                              AppColors
                                                                  .colorPrimary),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        } else {
                                          // If userID is not null and not empty, proceed to the WalletHistoryScreen
                                          BuyNow(_quantity.toString(), priceID,
                                              _product_id);
                                        }
                                      } else {
                                        //priceID = priceList.isNotEmpty ? priceList[0]['priceID'] : '';

                                        //BuyNow(_quantity.toString(), priceID, _product_id);
                                        if (userID == null || userID!.isEmpty) {
                                          // If userID is null or empty, show a message or navigate to the login screen
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                backgroundColor:
                                                    AppTheme().whiteColor,
                                                surfaceTintColor:
                                                    AppTheme().whiteColor,
                                                title: Text(
                                                  'Login Required',
                                                  style: CustomTextStyle
                                                      .GraphikMedium(
                                                          18, AppColors.black),
                                                ),
                                                content: Text(
                                                  'Please log in to access buy now.',
                                                  style: CustomTextStyle
                                                      .GraphikRegular(
                                                          14, AppColors.black),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context); // Close the dialog
                                                    },
                                                    child: Text(
                                                      'Cancel',
                                                      style: CustomTextStyle
                                                          .GraphikMedium(
                                                              14,
                                                              AppColors
                                                                  .colorPrimary),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pushNamed(
                                                          context,
                                                          "/login"); // Navigate to login screen
                                                    },
                                                    child: Text(
                                                      'Login',
                                                      style: CustomTextStyle
                                                          .GraphikMedium(
                                                              14,
                                                              AppColors
                                                                  .colorPrimary),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        } else {
                                          // If userID is not null and not empty, proceed to the WalletHistoryScreen
                                          BuyNow(_quantity.toString(), priceID,
                                              _product_id);
                                        }
                                      }

                                      // Proceed with your BuyNow function or any other logic
                                      //BuyNow(_quantity.toString(), '0', _product_id);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.colorPrimary, // Button color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                  ),
                                  child: Text(
                                    translate('BUY NOW'),
                                    style: CustomTextStyle.GraphikMedium(
                                        16, AppColors.white),
                                    textAlign: TextAlign
                                        .center, // Center the text horizontally
                                  ),
                                ),
                              ),

                              /*Expanded(
                    flex: 1, // Takes up the other 50% of the width
                    child: ElevatedButton(
                      onPressed: () {
                        // Buy Now action

                        print('qty: $_quantity');
                        print('_product_id: $_product_id');
                        print('selectedDeliveryType: $selectedDeliveryType');
                        log('priceID: $priceID');

                        //BuyNow(_quantity.toString(), '0', _product_id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme().primaryColor, // Different color for Buy Now
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(
                        translate('BUY NOW'),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme().whiteColor,
                        ),
                        textAlign: TextAlign.center, // Center text horizontally
                      ),
                    ),
                  ),*/
                            ],
                          ),
                        ),
                      ),
              ],
            ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      backgroundColor: AppTheme().whiteColor,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stack to position the close icon at the top right
              Stack(
                children: [
                  // Title text
                  const Text(
                    'Get GST invoice and save up to 28% on Business Purchases.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis, // Handle overflow with ellipsis
                  ),
                  // Positioned close icon
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(
                            context); // Close the bottom sheet when pressed
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'How it works.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme().blackColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Create your free Decont user account with us \n• Add the products in your cart and proceed to checkout \n• During Checkout, select "Use GSTIN for Business Purchase" checkbox \n• Add your shipping and billing details in the address section \n• Complete the order and you shall receive business (GST) invoice along with your delivered orders \n• Your billing details will be saved with us for quicker checkout for your next purchase \n• You can edit the billing details any time later for your next purchase \n• Please note that currently GST is mandatory for getting business Invoices \n• Kindly provide correct billing details during checkout \n• Decont is not responsible if the customer has entered incorrect billing details resulting in customer not receiving the input tax credit while filing returns',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRelatedProducts() {
    return productsList.isNotEmpty
        ? Column(
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10.0),
                color: AppTheme().whiteColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Related Products',
                      style:
                          CustomTextStyle.GraphikRegular(16, AppColors.black),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 265.0,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: productsList.length,
                        itemBuilder: (context, index) {
                          var item = productsList[index];

                          // Calculate discount percentage
                          double mrp = double.tryParse(item['mrp'] ?? '0') ?? 0;
                          double price =
                              double.tryParse(item['price'] ?? '0') ?? 0;
                          String discountText = '';
                          if (mrp > 0 && price > 0 && mrp > price) {
                            double discountPercent =
                                ((mrp - price) / mrp * 100);
                            discountText =
                                '${discountPercent.toStringAsFixed(0)}% OFF';
                          }

                          return GestureDetector(
                            onTap: item['productID'] != null
                                ? () {
                                    Get.to(ProductDetailScreen(
                                        product_id: item['productID']));
                                  }
                                : null,
                            child: Container(
                              padding: const EdgeInsets.all(1.0),
                              height: 200.0,
                              width: 155,
                              margin: const EdgeInsets.only(right: 10.0),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                border: Border.all(
                                  color: AppColors.textFieldBorderColor,
                                  width: 0.3,
                                ),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        child: CachedNetworkImage(
                                          imageUrl: item['image'] ?? '',
                                          height: 130,
                                          width: double.infinity,
                                          fit: BoxFit.contain,
                                          placeholder: (context, url) =>
                                              const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                            color: AppColors.colorPrimary,
                                          )),
                                          errorWidget:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                              'assets/decont_splash_screen_images/decont_logo.png',
                                              fit: BoxFit.contain,
                                              height: 100,
                                              width: double.infinity,
                                            );
                                          },
                                        ),
                                      ),
                                      // if (discountText.isNotEmpty)
                                      //   Positioned(
                                      //     top: 2,
                                      //     left: 0,
                                      //     child: Container(
                                      //       decoration: const BoxDecoration(
                                      //         color: AppColors.green,
                                      //         borderRadius: BorderRadius.only(
                                      //           bottomRight: Radius.circular(5),
                                      //         ),
                                      //       ),
                                      //       padding: const EdgeInsets.symmetric(
                                      //           horizontal: 3, vertical: 5),
                                      //       child: Text(
                                      //         discountText,
                                      //         style:
                                      //             CustomTextStyle.GraphikMedium(
                                      //                 8, AppTheme().whiteColor),
                                      //       ),
                                      //     ),
                                      //   ),
                                      Positioned(
                                        top: 0.0,
                                        right: 0.0,
                                        child: IconButton(
                                          icon: Icon(
                                            _isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: _isFavorite
                                                ? Colors.red
                                                : Colors.grey,
                                          ),
                                          onPressed: _toggleFavorite,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10.0),
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                    child: Text(
                                      item['name'] ?? '',
                                      style: CustomTextStyle.GraphikMedium(
                                          13.5, AppColors.black),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Visibility(
                                                    visible:
                                                        item['without_gst_mrp']
                                                                ?.isNotEmpty ??
                                                            false,
                                                    child: Text(
                                                      '₹ ${item['without_gst_mrp'] ?? ''}',
                                                      style: CustomTextStyle
                                                              .GraphikRegular(
                                                                  10.5,
                                                                  AppColors
                                                                      .secondTextColor)
                                                          ?.copyWith(
                                                        decorationThickness: 1,
                                                        decorationColor:
                                                            AppColors.black,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5.0),
                                                  Visibility(
                                                    visible:
                                                        discountText.isNotEmpty,
                                                    child: Text(
                                                      discountText,
                                                      style: CustomTextStyle
                                                          .GraphikMedium(
                                                              11,
                                                              AppColors
                                                                  .darkgreenColor),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 3.0),
                                              Visibility(
                                                visible:
                                                    item['without_gst_price']
                                                            ?.isNotEmpty ??
                                                        false,
                                                child: Text(
                                                  '₹ ${item['without_gst_price'] ?? ''}',
                                                  style: CustomTextStyle
                                                      .GraphikMedium(13.5,
                                                          AppColors.black),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        : const SizedBox.shrink();
  }

  Widget buildRecentViewedProducts() {
    return recent_show_product == 'Yes' && recent_show_product_list.isNotEmpty
        ? Column(
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10.0),
                color: AppColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recent_show_label,
                      style:
                          CustomTextStyle.GraphikRegular(16, AppColors.black),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 285.0,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recent_show_product_list.length,
                        itemBuilder: (context, index) {
                          var item = recent_show_product_list[index];

                          // Calculate discount percentage
                          double mrp = double.tryParse(item['mrp'] ?? '0') ?? 0;
                          double price =
                              double.tryParse(item['price'] ?? '0') ?? 0;
                          String discountText = '';
                          if (mrp > 0 && price > 0 && mrp > price) {
                            double discountPercent =
                                ((mrp - price) / mrp * 100);
                            discountText =
                                '${discountPercent.toStringAsFixed(0)}% OFF';
                          }

                          return GestureDetector(
                            onTap: item['productID'] != null
                                ? () {
                                    Get.to(ProductDetailScreen(
                                        product_id: item['productID']));
                                  }
                                : null,
                            child: Container(
                              //  padding: const EdgeInsets.only(right: 10.0),
                              height: 280.0,
                              width: 150,
                              margin: const EdgeInsets.only(right: 10.0),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                border: Border.all(
                                  color: AppColors.textFieldBorderColor,
                                  width: 0.3,
                                ),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      SizedBox(
                                        height: 150,
                                        width: double.infinity,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          child: CachedNetworkImage(
                                            imageUrl: item['image'] ?? '',
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const Center(
                                              child: CircularProgressIndicator(
                                                color: AppColors.colorPrimary,
                                              ),
                                            ),
                                            errorWidget:
                                                (context, error, stackTrace) =>
                                                    Image.asset(
                                              'assets/decont_splash_screen_images/decont_logo.png',
                                              fit: BoxFit.cover,
                                              height: 150,
                                              width: double.infinity,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // if (discountText.isNotEmpty)
                                      //   Positioned(
                                      //     top: 2,
                                      //     left: 0,
                                      //     child: Container(
                                      //       decoration: const BoxDecoration(
                                      //         color: AppColors.green,
                                      //         borderRadius: BorderRadius.only(
                                      //           bottomRight: Radius.circular(5),
                                      //         ),
                                      //       ),
                                      //       padding: const EdgeInsets.symmetric(
                                      //           horizontal: 3, vertical: 5),
                                      //       child: Text(
                                      //         discountText,
                                      //         style:
                                      //             CustomTextStyle.GraphikMedium(
                                      //                 8, AppTheme().whiteColor),
                                      //       ),
                                      //     ),
                                      //   ),
                                      Positioned(
                                        top: 1,
                                        right: 0,
                                        child: IconButton(
                                          icon: Icon(
                                            _isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: _isFavorite
                                                ? Colors.red
                                                : Colors.grey,
                                            size: 24,
                                          ),
                                          onPressed: _toggleFavorite,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10.0),
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                    child: Text(
                                      item['name'] ?? '',
                                      style: CustomTextStyle.GraphikMedium(
                                          13.5, AppColors.black),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Visibility(
                                                    visible:
                                                        item['without_gst_mrp']
                                                                ?.isNotEmpty ??
                                                            false,
                                                    child: Text(
                                                      '₹ ${item['without_gst_mrp'] ?? ''}',
                                                      style: CustomTextStyle
                                                              .GraphikRegular(
                                                                  10.5,
                                                                  AppColors
                                                                      .secondTextColor)
                                                          ?.copyWith(
                                                        decorationThickness: 1,
                                                        decorationColor:
                                                            AppColors.black,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5.0),
                                                  Visibility(
                                                    visible:
                                                        discountText.isNotEmpty,
                                                    child: Text(
                                                      discountText,
                                                      style: CustomTextStyle
                                                          .GraphikMedium(
                                                              11,
                                                              AppColors
                                                                  .darkgreenColor),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 3.0),
                                              Visibility(
                                                visible:
                                                    item['without_gst_price']
                                                            ?.isNotEmpty ??
                                                        false,
                                                child: Text(
                                                  '₹ ${item['without_gst_price'] ?? ''}',
                                                  style: CustomTextStyle
                                                      .GraphikMedium(13.5,
                                                          AppColors.black),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        : const SizedBox.shrink();
  }

  Widget _buildRatingItem(int rating, Color color, double progress) {
    return Row(
      children: <Widget>[
        Text(
          '$rating',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10.0,
            backgroundColor: const Color(0xFFededed),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
