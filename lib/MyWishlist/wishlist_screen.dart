import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../BaseUrl.dart';
import '../CustomeTextStyle/custometextstyle.dart';
import '../productDetails/product_details_screen.dart';
import '../theme/AppTheme.dart';

class WishListScreen extends StatefulWidget {
  @override
  _WishListScreenState createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  final Map<String, int> cart = {};
  Map<String, String> localizedStrings = {};
  String currentLangCode = 'en';
  List<Map<String, dynamic>> productsList = [];
  String pageCode = '1';
  bool isLoading = false;
  bool hasMoreData = true;
  bool isPaginationLoading = false; // For pagination loading

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguagePreference();
    _initializeData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (hasMoreData && !isPaginationLoading && !isLoading) {
          _dashboardData(); // Load more data
        }
      }
    });
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
    if (isLoading || isPaginationLoading) return; // Prevent multiple requests
    isPaginationLoading = true; // Set loading for pagination
    if (!isLoading) isLoading = true; // Set loading for initial data

    final url = Uri.parse(wishlist);
    final Map<String, String> body = {
      'page': pageCode,
    };
    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());
        log('Response data: $data');

        if (data['result'] == 1) {
          // Extract products and update productsList
          productsList.addAll((data['data']['wishlist'] as List)
              .map((item) => {
                    'id': item['id'],
                    'partner_name': item['partner_name'],
                    'product_name': item['product_name'],
                    'product_image': item['product_image'],
                    'mrp': item['mrp'],
                    'product_id': item['product_id'],
                    'price': item['price'],
                    'in_cart': item['in_cart'],
                    'unit': item['unit'],
                    'base_weight': item['base_weight'],
                  })
              .toList());

          // Handle pagination
          if (data['data'].containsKey('pagination')) {
            final pagination = data['data']['pagination'];
            if (pagination['next_page'] != null &&
                pagination['next_page'].toString().isNotEmpty) {
              pageCode = pagination['next_page']
                  .toString(); // Update to the next page number
            } else {
              hasMoreData = false; // No more pages available
            }
          } else {
            log('Pagination data not found');
          }

          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(data['message'],
                style: Theme.of(context)
                    .textTheme
                    .displayMedium!
                    .copyWith(color: AppColors.white)),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${response.reasonPhrase}',
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium!
                      .copyWith(color: AppColors.white))),
        );
      }
    } catch (e) {
      log('Error: $e');
    } finally {
      isLoading = false;
      isPaginationLoading = false; // Reset pagination loading state
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
                      //onPressed: () => Navigator.pop(context,true),
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
                'My Wishlist',
                style: CustomTextStyle.GraphikMedium(16, AppColors.black),
              ),
              /*actions: [
                IconButton(
                  color: Colors.black,
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.pushNamed(context, '/my_cart');
                  },
                ),
              ],*/
            ),
            Container(
              height: 1.0,
              color: Colors.grey[300],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      /*body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0), // Add padding here

        child: Column(
          children: [

            const SizedBox(height: 10.0,),

            SizedBox(
              child: ListView.builder(
                shrinkWrap: true,
                // Ensures the ListView only takes as much space as needed
                physics: const NeverScrollableScrollPhysics(),
                // Prevents scrolling inside the ListView
                itemCount: CarModel.carItems.length,
                itemBuilder: (context, index) {
                  return VerticalMyListTile(
                    car: CarModel.carItems[index],
                    onRemove: () => _removeItemById(items[index].id),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),*/
      body: isLoading // Show CircularProgressIndicator while loading data
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.colorPrimary,
              ),
            )
          : productsList.isEmpty // Check if productsList is empty
              ? Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text('Your wishlist is empty!',
                          style: CustomTextStyle.GraphikMedium(
                              20, AppColors.black)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10.0),
                  controller: _scrollController,
                  itemCount:
                      productsList.length + (isPaginationLoading ? 1 : 0),
                  // Add 1 for loading indicator if needed

                  itemBuilder: (context, index) {
                    var item = productsList[index];

                    return VerticalMyListTile(
                      car: Car(
                        id: item['id'],
                        partnerName: item['partner_name'],
                        product_name: item['product_name'],
                        product_image: item['product_image'],
                        product_id: item['product_id'],
                        // Assuming this is the image URL
                        mrp: item['mrp'],
                        price: item['price'],
                        inCart: item['in_cart'],

                        unit: item['unit'],
                        base_weight: item['base_weight'],
                      ),
                      onRemove: () => _removeItemById(item['product_id']),
                    );
                  },
                ),
    );
  }

  _removeItemById(id) async {
    // Prepare the API call
    final url =
        Uri.parse(add_remove_wishlist); // Replace with your API endpoint
    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization':
          'Bearer $user_token', // Include the user token if necessary
    };

    final Map<String, String> body = {
      'product_id': id.toString(),
      'flag': 'true',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Successfully updated favorite status
          log('Favorite status updated: ${data['message']}');

          setState(() {
            productsList.removeWhere((item) => item['product_id'] == id);
          });
        } else {
          // Handle error returned by the API
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(data['message'],
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium!
                        .copyWith(color: AppColors.white))),
          );
        }
      } else {
        // Handle HTTP error responses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${response.reasonPhrase}',
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium!
                      .copyWith(color: AppColors.white))),
        );
      }
    } catch (e) {
      // Handle exceptions
      log('Error updating favorite status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An unexpected error occurred.',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium!
                    .copyWith(color: AppColors.white))),
      );
    }
  }
}

class VerticalMyListTile extends StatefulWidget {
  final Car car;
  final VoidCallback onRemove;

  const VerticalMyListTile({
    Key? key,
    required this.car,
    required this.onRemove,
  }) : super(key: key);

  @override
  _VerticalMyListTileState createState() => _VerticalMyListTileState();
}

class _VerticalMyListTileState extends State<VerticalMyListTile> {
  int _count = 0; // Initialize count

  @override
  void initState() {
    super.initState();
    _count = widget.car.inCart; // Set initial state from API response
  }

  /*void _increment() {
    setState(() {
      _count++;
    });
  }

  void _decrement() {
    setState(() {
      if (_count > 0) {
        _count--;
      }
    });
  }*/

  void _increment() {
    setState(() {
      _count++;
    });

    AddToCart(
        _count, widget.car.product_id.toString()); // Replace with actual values
  }

  void _decrement() {
    setState(() {
      if (_count > 0) {
        _count--;
      }
    });

    if (_count == 0) {
      _removeItemById1(widget.car.product_id);
    } else {
      AddToCart(_count,
          widget.car.product_id.toString()); // Replace with actual values
    }
  }

  AddToCart(int quantity, String product_id) async {
    // Prepare the API call
    final url = Uri.parse(addCart); // Replace with your API endpoint
    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization':
          'Bearer $user_token', // Include the user token if necessary
    };
    /*final body = jsonEncode({
      'product_id': product_id, // Pass the car ID to the API
      'qty': quantity, // Pass the new favorite state
    });*/

    final Map<String, String> body = {
      'product_id': product_id.toString(), // Pass the car ID to the API
      'qty': quantity.toString(), // Pass the new favorite state
    };

    try {
      // Make the API call
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Successfully updated favorite status
          log('response: ${data['message']}');
          final totalItem = data['data']['totalItem'];
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
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium!
                        .copyWith(color: AppColors.white))),
          );
        }
      } else {
        // Handle HTTP error responses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      // Handle exceptions
      log('Error updating favorite status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred.')),
      );
    }
  }

  _removeItemById1(int ID) async {
    log('id:- $ID');
    log('token:- $user_token');

    final url = Uri.parse(cart_item_delete);

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token', // Use your actual token here
    };

    // Body of the request
    final Map<String, dynamic> body = {
      'id': ID.toString(), // Assuming the API requires the item ID to remove
      'product_id':
          ID.toString(), // Assuming the API requires the item ID to remove
    };

    // Optimistically update the UI first

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());
        if (data['status'] == 'success') {
          // Successfully removed item from the server
          log('Item removed successfully: $data');
          final totalItem = data['data']['cartItemCount'];
          final prefs = await SharedPreferences.getInstance();

          setState(() {
            // Ensure precision up to 2 decimal points
            prefs.setInt('cart_count', totalItem);
          });
        } else {
          // Server responded with an error message
          //_showErrorSnackBar('Error: ${data['message']}');
          log('response: ${data['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${data['message']}')),
          );
        }
      } else {
        // HTTP response was not OK
        //_showErrorSnackBar('Error: ${response.reasonPhrase}');
        log('response.reasonPhrase: ${response.reasonPhrase}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      // An error occurred during the API call
      log('Error updating favorite status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred.')),
      );
    }
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ProductDetailScreen(product_id: widget.car.product_id.toString()),
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
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _navigateToDetails(context);
      },
      child: Container(
        height: 120.0,
        margin: const EdgeInsets.only(bottom: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100.0,
              width: 100.0, // Fixed width
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey, // Border color
                  width: 1.0, // Border width
                ),
                borderRadius: BorderRadius.circular(10.0),
                image: DecorationImage(
                  image: NetworkImage(widget.car.product_image),
                  fit: BoxFit.contain, // Adjust image fit
                ),
              ),
            ),
            const SizedBox(width: 10.0), // Spacing between image and text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.car.product_name,
                          // Example text from car object
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2, // Limit to 1 line for name
                          overflow:
                              TextOverflow.ellipsis, // Ellipsis for overflow
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: widget.onRemove,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5.0), // Space between text elements
                  Text(
                    widget
                        .car.partnerName, // Another text field from car object
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey,
                    ),
                    maxLines: 1, // Limit to 2 lines
                    overflow: TextOverflow.ellipsis, // Ellipsis for overflow
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '₹ ${'${widget.car.price} / ${widget.car.base_weight}'}', // Provide a default value if null
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        if (_count > 0) ...[
                          SizedBox(
                            width: 30.0,
                            height: 30.0,
                            child: ElevatedButton(
                              onPressed: _decrement,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: AppTheme().whiteColor,
                                backgroundColor: AppTheme().secondaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 1.0, vertical: 1.0),
                              ),
                              child: Icon(Icons.remove,
                                  color: AppTheme().whiteColor),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Text(
                            '$_count',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 10.0),
                          SizedBox(
                            width: 30.0,
                            height: 30.0,
                            child: ElevatedButton(
                              onPressed: _increment,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: AppTheme().whiteColor,
                                backgroundColor: AppTheme().secondaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 1.0, vertical: 1.0),
                              ),
                              child:
                                  Icon(Icons.add, color: AppTheme().whiteColor),
                            ),
                          ),
                        ] else ...[
                          // Show only the add button if count is 0
                          SizedBox(
                            width: 90.0,
                            height: 30.0,
                            child: ElevatedButton(
                              onPressed: () {
                                _navigateToDetails(context);
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: AppTheme().whiteColor,
                                backgroundColor: AppTheme().secondaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 1.0, vertical: 1.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add, color: AppTheme().whiteColor),
                                  const SizedBox(width: 5.0),
                                  Text(
                                    'ADD',
                                    style: TextStyle(
                                      color: AppTheme().whiteColor,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
  }
}

class Car {
  final int id;
  final int product_id;
  final String partnerName;
  final String product_name;
  final String product_image; // Image URL
  final String mrp;
  final String price;
  final int inCart;
  final String unit;
  final String? base_weight;

  Car({
    required this.id,
    required this.product_id,
    required this.partnerName,
    required this.product_name,
    required this.product_image,
    required this.mrp,
    required this.price,
    required this.inCart,
    required this.unit,
    required this.base_weight,
  });
}
