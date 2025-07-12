// import 'dart:convert';
// import 'dart:developer';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../BaseUrl.dart';
// import '../CustomeTextStyle/custometextstyle.dart';
// import '../ResponseModel/ProductResponse.dart';
// import '../productDetails/product_details_screen.dart';
// import '../productshimmer/productshimmer.dart';
// import '../theme/AppTheme.dart';
//
// String? first_name = '';
// String? last_name = '';
// String? email = '';
// String? mobile = '';
// String? user_token = '';
// String? image = '';
//
// class ProductListScreen extends StatefulWidget {
//   final VoidCallback onBack;
//   final String category;
//   final String category_name;
//
//   const ProductListScreen(
//       {super.key,
//       required this.onBack,
//       required this.category,
//       required this.category_name});
//
//   @override
//   _ProductListScreenState createState() => _ProductListScreenState();
// }
//
// class _ProductListScreenState extends State<ProductListScreen> {
//   final Map<String, int> productt = {};
//   Map<String, String> localizedStrings = {};
//   String currentLangCode = 'en';
//   String Category = '';
//   String CategoryName = '';
//   String product_count = '';
//   List<Map<String, dynamic>> productsList = [];
//   String pageCode = '0';
//   bool isLoading = false;
//   bool hasMoreData = true;
//   bool isPaginationLoading = false; // For pagination loading
//   bool isGridView = false; // Toggle state
//   int cart_count = 0;
//   bool? isCodAvailable;
//   int? selectedRating;
//
//   String selectedSortOption = ''; // To store the selected value
//
//   final ScrollController _scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCurrentLanguagePreference();
//     _initializeData();
//
//     Category = widget.category;
//     CategoryName = widget.category_name;
//
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels ==
//           _scrollController.position.maxScrollExtent) {
//         if (hasMoreData && !isPaginationLoading && !isLoading) {
//           _productListData(); // Load more data
//         }
//       }
//     });
//   }
//
//   Future<void> _initializeData() async {
//     // Load user preferences and initialize data
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       first_name = prefs.getString('first_name') ?? '';
//       last_name = prefs.getString('last_name') ?? '';
//       email = prefs.getString('email') ?? '';
//       mobile = prefs.getString('mobile') ?? '';
//       user_token = prefs.getString('user_token') ?? '';
//       image = prefs.getString('image') ?? '';
//       cart_count = prefs.getInt('cart_count')!;
//     });
//     await _productListData();
//   }
//
//   Future<void> _productListData() async {
//     if (isLoading || isPaginationLoading) return;
//
//     isPaginationLoading = true;
//     isLoading = true;
//
//     final url = Uri.parse(baseUrl);
//
//     final Map<String, String> headers = {
//       'Content-Type': 'application/x-www-form-urlencoded',
//       'Authorization': 'Bearer $user_token',
//     };
//
//     final Map<String, String> body = {
//       'view': 'product',
//       'pagecode': pageCode,
//       'catID': Category,
//       'type': selectedSortOption,
//       'type_code': '',
//       'type_rate': '',
//     };
//
//     try {
//       final response = await http.post(url, headers: headers, body: body);
//       final data = jsonDecode(response.body);
//
//       if (data['result'] == 1) {
//         log('Response data: $data');
//
//         // Extract products and update productsList
//         productsList.clear();
//         product_count = data['data']['product_count'].toString();
//
//         productsList.addAll((data['data']['product_list'] as List)
//             .map((item) => {
//                   'productID': item['productID'],
//                   'name': item['name'],
//                   'image': item['image'],
//                   'mrp': item['mrp'],
//                   'price': item['price'],
//                   'discount': item['discount'],
//                   'emi_option': item['emi_option'],
//                   'cashback_text': item['cashback_text'],
//                   'product_delivery_msg': item['product_delivery_msg'],
//                   'review_msg': item['review_msg'],
//                   'star': item['star'],
//                   'price_list': item['price_list'] ?? [],
//                 })
//             .toList());
//
//         // Handle pagination
//         if (data['data'].containsKey('pagination')) {
//           final pagination = data['data']['pagination'];
//           if (pagination['next_page'] != null &&
//               pagination['next_page'].toString().isNotEmpty) {
//             pageCode = pagination['next_page'].toString();
//           } else {
//             hasMoreData = false;
//           }
//         } else {
//           log('Pagination data not found');
//         }
//
//         setState(() {});
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               data['message'],
//               style: CustomTextStyle.GraphikMedium(16, AppColors.white),
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       log('Error: $e');
//     } finally {
//       isLoading = false;
//       isPaginationLoading = false;
//     }
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadLanguage(String langCode) async {
//     final String jsonString =
//         await rootBundle.loadString('assets/lang/$langCode.json');
//     setState(() {
//       localizedStrings = Map<String, String>.from(json.decode(jsonString));
//     });
//   }
//
//   Future<void> _loadCurrentLanguagePreference() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? langCode = prefs.getString('selected_language_code');
//
//     if (langCode != null && langCode.isNotEmpty) {
//       setState(() {
//         currentLangCode = langCode;
//       });
//       await _loadLanguage(currentLangCode);
//     }
//   }
//
//   String translate(String key) {
//     return localizedStrings[key] ?? key;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     _buildRadioButton(String value, String filtertype) {
//       return RadioListTile<String>(
//         contentPadding: EdgeInsets.zero, // Remove internal padding
//         dense: true, // Reduce visual height of the tile
//
//         title: Text(
//           value,
//           style: CustomTextStyle.GraphikRegular(16, AppColors.black),
//           // Customize font size if needed
//         ),
//         value: filtertype,
//         groupValue: selectedSortOption,
//         onChanged: (String? newValue) {
//           setState(() {
//             selectedSortOption = newValue!;
//             _loadCurrentLanguagePreference();
//             _initializeData();
//
//             Category = widget.category;
//             CategoryName = widget.category_name;
//             pageCode = '0';
//           });
//
//           Navigator.pop(context); // Close the bottom sheet on selection
//         },
//         activeColor:
//             AppColors.colorPrimary, // Change the selected radio button color
//       );
//     }
//
//     return Scaffold(
//         appBar: PreferredSize(
//           preferredSize: const Size.fromHeight(
//             kToolbarHeight + 1.0,
//           ),
//           child: Column(
//             children: [
//               AppBar(
//                 surfaceTintColor: Colors.transparent,
//                 elevation: 0.0,
//                 title: Text(
//                   CategoryName,
//                   textAlign: TextAlign.left,
//                   style: CustomTextStyle.GraphikMedium(16, AppColors.black),
//                 ),
//                 actions: [
//                   const Column(
//                     children: [
//                       SizedBox(height: 10.0),
//
//                       // Adjust the height as needed for spacing
//                     ],
//                   ),
//                   GestureDetector(
//                       onTap: () {
//                         Navigator.pushNamed(context, '/search');
//                       },
//                       child: const Icon(Icons.search)),
//                   const SizedBox(width: 5.0),
//                   Container(
//                     margin: const EdgeInsets.only(right: 15),
//                     // Adds 10px margin to the right
//                     child: Stack(
//                       children: <Widget>[
//                         IconButton(
//                           color: Colors.black,
//                           icon: SvgPicture.asset(
//                             'assets/icons/shopping_cart.svg',
//                             // Path to your SVG file
//                             width: 24, // Set the width of the SVG icon
//                             height: 24, // Set the height of the SVG icon
//                             color: Colors
//                                 .black, // Optional: change the color if needed
//                           ),
//                           onPressed: () {
//                             if (userID != null || userID!.isNotEmpty) {
//                               Navigator.of(context).pushNamed('/my_cart');
//                             } else {
//                               showDialog(
//                                 context: context,
//                                 builder: (context) {
//                                   return AlertDialog(
//                                     backgroundColor: AppTheme().whiteColor,
//                                     surfaceTintColor: AppTheme().whiteColor,
//                                     title: Text(
//                                       'Login Required',
//                                       style: CustomTextStyle.GraphikMedium(
//                                           16, AppColors.black),
//                                     ),
//                                     content: Text(
//                                       'Please log in to access my cart.',
//                                       style: CustomTextStyle.GraphikMedium(
//                                           16, AppColors.black),
//                                     ),
//                                     actions: [
//                                       TextButton(
//                                         onPressed: () {
//                                           Navigator.pop(
//                                               context); // Close the dialog
//                                         },
//                                         child: Text(
//                                           'Cancel',
//                                           style: CustomTextStyle.GraphikRegular(
//                                               14, AppColors.colorPrimary),
//                                         ),
//                                       ),
//                                       TextButton(
//                                         onPressed: () {
//                                           Navigator.pushNamed(context,
//                                               "/login"); // Navigate to login screen
//                                         },
//                                         child: Text(
//                                           'Login',
//                                           style: CustomTextStyle.GraphikRegular(
//                                               14, AppColors.colorPrimary),
//                                         ),
//                                       ),
//                                     ],
//                                   );
//                                 },
//                               );
//                             }
//                           },
//                         ),
//                         Positioned(
//                           right: 0,
//                           top: 0,
//                           child: Container(
//                             padding: const EdgeInsets.all(1),
//                             decoration: BoxDecoration(
//                               color: AppColors.colorPrimary,
//                               // Background color for the count badge
//                               borderRadius: BorderRadius.circular(
//                                   10), // Round corners for the badge
//                             ),
//                             constraints: const BoxConstraints(
//                               minWidth: 20,
//                               minHeight: 20,
//                             ),
//                             child: Text(
//                               cart_count > 99
//                                   ? '99+'
//                                   : cart_count.toString().padLeft(1, '0'),
//                               // Show '99+' if count exceeds 99, else display count with 2 digits
//                               style: CustomTextStyle.GraphikRegular(
//                                   12, AppColors.white),
//
//                               textAlign: TextAlign.center,
//                             ),
//                             /*child: Text(
//                               cart_count.toString(), // Replace this with your dynamic count value
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),*/
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               Container(
//                 height: 1.0,
//                 color: AppTheme().lineColor,
//               ),
//             ],
//           ),
//         ),
//         backgroundColor: AppTheme().mainBackgroundColor,
//         body: Stack(children: [
//           Container(
//             child: Column(
//               children: [
//                 Container(
//                   color: AppColors.white,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       // Left Side: Category Name and Product Count
//
//                       // Right Side: Sort & View Options
//                       Row(
//                         children: [
//                           IconButton(
//                             icon: Icon(
//                                 isGridView ? Icons.list : Icons.grid_view,
//                                 color: AppColors.black),
//                             onPressed: () {
//                               setState(() {
//                                 isGridView = !isGridView;
//                               });
//                             },
//                           ),
//                           Container(
//                             width: 100.0,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 13.0, vertical: 5.0),
//                             child: InkWell(
//                               onTap: () {
//                                 isCodAvailable =
//                                     null; // Ensure this is declared in parent State class
//
//                                 showModalBottomSheet(
//                                   context: context,
//                                   isDismissible: true,
//                                   useSafeArea: true,
//                                   isScrollControlled:
//                                       true, // <-- This is the key
//                                   backgroundColor: AppColors.white,
//                                   shape: const RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.vertical(
//                                         top: Radius.circular(20.0)),
//                                   ),
//                                   builder: (BuildContext context) {
//                                     return DraggableScrollableSheet(
//                                       expand: false,
//                                       initialChildSize:
//                                           0.6, // Adjust based on how much you want visible initially
//                                       minChildSize: 0.4,
//                                       maxChildSize:
//                                           0.95, // Maximum scrollable height
//                                       builder: (context, scrollController) {
//                                         return StatefulBuilder(
//                                             builder: (context, setModalState) {
//                                           return SingleChildScrollView(
//                                               child: Padding(
//                                                   padding: const EdgeInsets
//                                                       .only(
//                                                       bottom:
//                                                           20), // give some space at the bottom
//                                                   child: Column(
//                                                     mainAxisSize:
//                                                         MainAxisSize.min,
//                                                     children: [
//                                                       Row(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .spaceBetween,
//                                                         children: [
//                                                           Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .symmetric(
//                                                                     horizontal:
//                                                                         20,
//                                                                     vertical:
//                                                                         10),
//                                                             child: Text(
//                                                               'COD',
//                                                               style: CustomTextStyle
//                                                                   .GraphikMedium(
//                                                                       14,
//                                                                       AppColors
//                                                                           .black),
//                                                             ),
//                                                           ),
//                                                           InkWell(
//                                                             onTap: () =>
//                                                                 Navigator.pop(
//                                                                     context),
//                                                             child: Padding(
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .only(
//                                                                       right:
//                                                                           10),
//                                                               child: const Icon(
//                                                                   Icons.close,
//                                                                   color: AppColors
//                                                                       .black),
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                       const Divider(
//                                                           thickness: 1,
//                                                           color: AppColors
//                                                               .textFieldBorderColor),
//
//                                                       // COD Buttons
//                                                       Row(
//                                                         children: [
//                                                           // COD Available
//                                                           Expanded(
//                                                             child: Padding(
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .symmetric(
//                                                                       horizontal:
//                                                                           20),
//                                                               child:
//                                                                   OutlinedButton(
//                                                                 style: ElevatedButton
//                                                                     .styleFrom(
//                                                                   backgroundColor: isCodAvailable ==
//                                                                           true
//                                                                       ? AppColors
//                                                                           .colorPrimary
//                                                                       : Colors
//                                                                           .white,
//                                                                   foregroundColor: isCodAvailable ==
//                                                                           true
//                                                                       ? AppColors
//                                                                           .white
//                                                                       : AppColors
//                                                                           .colorPrimary,
//                                                                   padding: const EdgeInsets
//                                                                       .symmetric(
//                                                                       vertical:
//                                                                           14),
//                                                                   shape:
//                                                                       RoundedRectangleBorder(
//                                                                     borderRadius:
//                                                                         BorderRadius.circular(
//                                                                             10),
//                                                                     side:
//                                                                         BorderSide(
//                                                                       color: AppColors
//                                                                           .black,
//                                                                       width: 1,
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                                 onPressed: () {
//                                                                   setModalState(
//                                                                       () {
//                                                                     isCodAvailable = isCodAvailable ==
//                                                                             true
//                                                                         ? null
//                                                                         : true;
//                                                                   });
//                                                                 },
//                                                                 child: Text(
//                                                                   'COD Available',
//                                                                   style: isCodAvailable ==
//                                                                           true
//                                                                       ? CustomTextStyle.GraphikMedium(
//                                                                           16,
//                                                                           AppColors
//                                                                               .white)
//                                                                       : CustomTextStyle.GraphikRegular(
//                                                                           16,
//                                                                           AppColors
//                                                                               .secondTextColor),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           // COD Not Available
//                                                           Expanded(
//                                                             child: Padding(
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .symmetric(
//                                                                       horizontal:
//                                                                           20),
//                                                               child:
//                                                                   OutlinedButton(
//                                                                 style: OutlinedButton
//                                                                     .styleFrom(
//                                                                   backgroundColor: isCodAvailable == false
//                                                                       ? AppColors
//                                                                           .colorPrimary
//                                                                       : Colors
//                                                                           .white,
//                                                                   foregroundColor: isCodAvailable == false
//                                                                       ? AppColors
//                                                                           .colorPrimary
//                                                                       : AppColors
//                                                                           .secondTextColor,
//                                                                   padding: const EdgeInsets
//                                                                       .symmetric(
//                                                                       vertical:
//                                                                           14),
//                                                                   shape:
//                                                                       RoundedRectangleBorder(
//                                                                     borderRadius:
//                                                                         BorderRadius.circular(
//                                                                             10),
//                                                                     side:
//                                                                         const BorderSide(
//                                                                       color: AppColors
//                                                                           .black,
//                                                                       width: 1,
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                                 onPressed: () {
//                                                                   setModalState(
//                                                                       () {
//                                                                     isCodAvailable = isCodAvailable ==
//                                                                             false
//                                                                         ? null
//                                                                         : false;
//                                                                   });
//                                                                 },
//                                                                 child: Text(
//                                                                   'COD Not Available',
//                                                                   style: isCodAvailable ==
//                                                                           false
//                                                                       ? CustomTextStyle.GraphikMedium(
//                                                                           16,
//                                                                           AppColors
//                                                                               .white)
//                                                                       : CustomTextStyle.GraphikRegular(
//                                                                           16,
//                                                                           AppColors
//                                                                               .secondTextColor),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                       const SizedBox(
//                                                         height: 10,
//                                                       ),
//                                                       Column(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .start,
//                                                         children: [
//                                                           Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .symmetric(
//                                                                     horizontal:
//                                                                         20),
//                                                             child: Text(
//                                                               'Rating',
//                                                               style: CustomTextStyle
//                                                                   .GraphikMedium(
//                                                                       14,
//                                                                       AppColors
//                                                                           .black),
//                                                             ),
//                                                           ),
//                                                           const SizedBox(
//                                                             height: 10,
//                                                           ),
//                                                           Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .symmetric(
//                                                                     horizontal:
//                                                                         20),
//                                                             child: Row(
//                                                               children:
//                                                                   List.generate(
//                                                                       5,
//                                                                       (index) {
//                                                                 int starValue =
//                                                                     index + 1;
//                                                                 bool
//                                                                     isSelected =
//                                                                     selectedRating ==
//                                                                         starValue;
//
//                                                                 return Padding(
//                                                                   padding: const EdgeInsets
//                                                                       .symmetric(
//                                                                       horizontal:
//                                                                           4),
//                                                                   child:
//                                                                       OutlinedButton(
//                                                                     onPressed:
//                                                                         () {
//                                                                       setModalState(
//                                                                           () {
//                                                                         if (isSelected) {
//                                                                           selectedRating =
//                                                                               null; // Unselect if already selected
//                                                                         } else {
//                                                                           selectedRating =
//                                                                               starValue; // Select new star
//                                                                         }
//                                                                       });
//                                                                     },
//                                                                     style: OutlinedButton
//                                                                         .styleFrom(
//                                                                       backgroundColor: isSelected
//                                                                           ? AppColors
//                                                                               .colorPrimary
//                                                                           : Colors
//                                                                               .white,
//                                                                       foregroundColor: isSelected
//                                                                           ? AppColors
//                                                                               .white
//                                                                           : AppColors
//                                                                               .black,
//                                                                       padding: const EdgeInsets
//                                                                           .symmetric(
//                                                                           vertical:
//                                                                               10,
//                                                                           horizontal:
//                                                                               12),
//                                                                       shape:
//                                                                           RoundedRectangleBorder(
//                                                                         borderRadius:
//                                                                             BorderRadius.circular(8),
//                                                                         side:
//                                                                             BorderSide(
//                                                                           color:
//                                                                               AppColors.black,
//                                                                           width:
//                                                                               1,
//                                                                         ),
//                                                                       ),
//                                                                     ),
//                                                                     child: Text(
//                                                                       '$starValue ⭐',
//                                                                       style: isSelected
//                                                                           ? CustomTextStyle.GraphikMedium(
//                                                                               16,
//                                                                               AppColors
//                                                                                   .white)
//                                                                           : CustomTextStyle.GraphikRegular(
//                                                                               15,
//                                                                               AppColors.secondTextColor),
//                                                                     ),
//                                                                   ),
//                                                                 );
//                                                               }),
//                                                             ),
//                                                           ),
//                                                           SizedBox(
//                                                             height: 10,
//                                                           ),
//                                                           Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .symmetric(
//                                                                     horizontal:
//                                                                         20),
//                                                             child: Text(
//                                                               'Filters',
//                                                               style: CustomTextStyle
//                                                                   .GraphikMedium(
//                                                                       14,
//                                                                       AppColors
//                                                                           .black),
//                                                             ),
//                                                           ),
//                                                           const Divider(
//                                                               thickness: 1,
//                                                               color: AppColors
//                                                                   .textFieldBorderColor),
//                                                           Column(
//                                                             children: [
//                                                               Padding(
//                                                                 padding: const EdgeInsets
//                                                                     .symmetric(
//                                                                     horizontal:
//                                                                         20),
//                                                                 child: _buildRadioButton(
//                                                                     'Low Price',
//                                                                     'Price Low'),
//                                                               ),
//                                                               const Divider(
//                                                                   thickness: 1,
//                                                                   color: AppColors
//                                                                       .textFieldBorderColor),
//                                                               Padding(
//                                                                 padding: const EdgeInsets
//                                                                     .symmetric(
//                                                                     horizontal:
//                                                                         20),
//                                                                 child: _buildRadioButton(
//                                                                     'High Price',
//                                                                     'High Price'),
//                                                               ),
//                                                               const Divider(
//                                                                   thickness: 1,
//                                                                   color: AppColors
//                                                                       .textFieldBorderColor),
//                                                               Padding(
//                                                                 padding: const EdgeInsets
//                                                                     .symmetric(
//                                                                     horizontal:
//                                                                         20),
//                                                                 child: _buildRadioButton(
//                                                                     'A-Z Name',
//                                                                     'A-Z Name'),
//                                                               ),
//                                                               const Divider(
//                                                                   thickness: 1,
//                                                                   color: AppColors
//                                                                       .textFieldBorderColor),
//                                                               Padding(
//                                                                 padding: const EdgeInsets
//                                                                     .symmetric(
//                                                                     horizontal:
//                                                                         20),
//                                                                 child: _buildRadioButton(
//                                                                     'Z-A Name',
//                                                                     'Z-A Name'),
//                                                               ),
//                                                               const Divider(
//                                                                   thickness: 1,
//                                                                   color: AppColors
//                                                                       .textFieldBorderColor),
//                                                               Padding(
//                                                                 padding: const EdgeInsets
//                                                                     .symmetric(
//                                                                     horizontal:
//                                                                         20),
//                                                                 child: _buildRadioButton(
//                                                                     'New Arrival',
//                                                                     'New Arrival'),
//                                                               ),
//                                                             ],
//                                                           )
//                                                         ],
//                                                       ),
//                                                     ],
//                                                   )));
//                                         });
//                                       },
//                                     );
//                                   },
//                                 );
//                               },
//                               child: Row(
//                                 children: [
//                                   Expanded(
//                                     child: Text(
//                                       'Sort By',
//                                       style: CustomTextStyle.GraphikMedium(
//                                           12, AppColors.black),
//                                     ),
//                                   ),
//                                   SvgPicture.asset(
//                                     'assets/icons/arrow_down.svg',
//                                     color: Colors.grey,
//                                     width: 20,
//                                     height: 20,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 10.0),
//                           GestureDetector(
//                             onTap: () {
//                               _productListData();
//                             },
//                             child: Text('REFINE',
//                                 style: CustomTextStyle.GraphikMedium(
//                                     12, AppColors.black)),
//                           )
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Expanded(
//                   child: isGridView
//                       ? Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 10),
//                           child: GridView.builder(
//                             controller: _scrollController,
//                             gridDelegate:
//                                 const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2, // Number of items per row
//                               crossAxisSpacing: 8.0, // Horizontal spacing
//                               mainAxisSpacing: 8.0, // Vertical spacing
//                               childAspectRatio:
//                                   1 / 1.9, // Width-to-height ratio
//                             ),
//                             itemCount: productsList.length +
//                                 (isPaginationLoading ? 1 : 0),
//                             itemBuilder: (context, index) {
//                               var item = productsList[index];
//                               return GridViewMyListTile(
//                                 product: Product(
//                                   id: item['productID'],
//                                   name: item['name'],
//                                   url: item['image'],
//                                   mrp: item['mrp'],
//                                   price: item['price'],
//                                   discount: item['discount'],
//                                   emi_option: item['emi_option'],
//                                   product_delivery_msg:
//                                       item['product_delivery_msg'],
//                                   cashback_text: item['cashback_text'],
//                                   review_msg: item['review_msg'],
//                                   star: item['star'],
//                                   priceList: (item['price_list'] ?? [])
//                                       .map<Map<String, String>>((priceItem) => {
//                                             'label': priceItem['label']
//                                                     ?.toString() ??
//                                                 '',
//                                             'value': priceItem['value']
//                                                     ?.toString() ??
//                                                 '',
//                                           })
//                                       .toList(),
//                                 ),
//                               );
//                             },
//                           ),
//                         )
//                       : ListView.builder(
//                           controller: _scrollController,
//                           itemCount: productsList.length +
//                               (isPaginationLoading ? 1 : 0),
//                           itemBuilder: (context, index) {
//                             if (index >= productsList.length) {
//                               return const Center(
//                                   child: CircularProgressIndicator(
//                                 color: AppColors.colorPrimary,
//                               ));
//                             }
//                             var item = productsList[index];
//                             return VerticalMyListTile(
//                               isLoading: isLoading,
//                               product: Product(
//                                 id: item['productID'],
//                                 name: item['name'],
//                                 url: item['image'],
//                                 mrp: item['mrp'],
//                                 price: item['price'],
//                                 discount: item['discount'],
//                                 emi_option: item['emi_option'],
//                                 cashback_text: item['cashback_text'],
//                                 product_delivery_msg:
//                                     item['product_delivery_msg'],
//                                 review_msg: item['review_msg'],
//                                 star: item['star'],
//                                 priceList: (item['price_list'] ?? [])
//                                     .map<Map<String, String>>((priceItem) => {
//                                           'label':
//                                               priceItem['label']?.toString() ??
//                                                   '',
//                                           'value':
//                                               priceItem['value']?.toString() ??
//                                                   '',
//                                         })
//                                     .toList(),
//                               ),
//                             );
//                           },
//                         ),
//                 ),
//               ],
//             ),
//           ),
//           selectedSortOption.isEmpty
//               ? const SizedBox.shrink()
//               : Align(
//                   alignment: Alignment.bottomCenter,
//                   child: Container(
//                     width: double.infinity,
//                     color: AppColors.colorPrimary,
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     child: Row(children: [
//                       Expanded(
//                         child: Text(
//                           selectedSortOption,
//                           style: CustomTextStyle.GraphikRegular(
//                               14, AppColors.white),
//                         ),
//                       ),
//                       GestureDetector(
//                           onTap: () {
//                             selectedSortOption = '';
//                             _productListData();
//                           },
//                           child: Text(
//                             'Reset',
//                             style: CustomTextStyle.GraphikMedium(
//                                 16, AppColors.white),
//                           ))
//                     ]),
//                   ))
//         ]));
//   }
// }
//
// class VerticalMyListTile extends StatefulWidget {
//   VerticalMyListTile({required this.product, required this.isLoading});
//
//   final Product product;
//   bool isLoading;
//
//   @override
//   _VerticalMyListTileState createState() => _VerticalMyListTileState();
// }
//
// class _VerticalMyListTileState extends State<VerticalMyListTile> {
//   final bool _isFavorite = false;
//
//   @override
//   void initState() {
//     super.initState();
//     //_isFavorite = widget.product.inWishlist; // Set initial state from API response
//   }
//
//   Future<void> _toggleFavorite() async {
//     // Prepare the API call
//     final url =
//         Uri.parse(add_remove_wishlist); // Replace with your API endpoint
//     final Map<String, String> headers = {
//       'Content-Type': 'application/x-www-form-urlencoded',
//       'Authorization': 'Bearer $user_token',
//       // Include the user token if necessary
//     };
//
//     final Map<String, String> body = {
//       'product_id':
//           widget.product.id.toString(), // Pass the product ID to the API
//       'flag': _isFavorite.toString(), // Pass the new favorite state
//     };
//
//     try {
//       // Make the API call
//       final response = await http.post(url, headers: headers, body: body);
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['status'] == 'success') {
//           // Successfully updated favorite status
//           log('Favorite status updated: ${data['message']}');
//
//           /*setState(() {
//             _isFavorite = !_isFavorite; // Toggle the favorite state
//             widget.product.inWishlist = _isFavorite; // Update the product's wishlist state locally
//           });*/
//         } else {
//           // Handle error returned by the API
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(data['message'],
//                     style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
//           );
//         }
//       } else {
//         // Handle HTTP error responses
//         // Handle HTTP error responses
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: ${response.reasonPhrase}',
//                 style: CustomTextStyle.GraphikMedium(16, AppColors.white)),
//           ),
//         );
//       }
//     } catch (e) {
//       // Handle exceptions
//       log('Error updating favorite status: $e');
//       // Handle exceptions
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('An unexpected error occurred.',
//               style: CustomTextStyle.GraphikMedium(16, AppColors.white)),
//         ),
//       );
//     }
//   }
//
//   void _navigateToDetails(BuildContext context) {
//     log('id ${widget.product.id.toString()}');
//     Navigator.of(context)
//         .push(PageRouteBuilder(
//       pageBuilder: (context, animation, secondaryAnimation) =>
//           ProductDetailScreen(product_id: widget.product.id.toString()),
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         const begin = Offset(1.0, 0.0);
//         const end = Offset.zero;
//         const curve = Curves.easeInOut;
//
//         var tween =
//             Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//         var offsetAnimation = animation.drive(tween);
//
//         return SlideTransition(
//           position: offsetAnimation,
//           child: child,
//         );
//       },
//     ))
//         .then((_) {
//       // When returning from the Product Detail screen, call onResume
//       onResume();
//     });
//   }
//
//   void onResume() {
//     // Logic to handle after coming back to the product list screen
//     print("Product list resumed");
//
//     // For example, you might want to reload the product list or refresh data
//   }
//
//   String insertLineBreaks(String text, int interval) {
//     final buffer = StringBuffer();
//     for (int i = 0; i < text.length; i++) {
//       buffer.write(text[i]);
//       if ((i + 1) % interval == 0 && i != text.length - 1) {
//         buffer.write('\n');
//       }
//     }
//     return buffer.toString();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         _navigateToDetails(context);
//       },
//       child: widget.isLoading
//           ? const ProductCardShimmerForListTile()
//           : Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(5),
//                   color: AppColors.white,
//                   border: Border.all(
//                     color: AppTheme().lineColor,
//                     width: 0.3,
//                   ),
//                 ),
//                 //height: 250.0,
//                 margin: const EdgeInsets.only(bottom: 10.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Stack(
//                           children: [
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(5.0),
//                               child: SizedBox(
//                                 width: 120,
//                                 height: 150,
//                                 child: CachedNetworkImage(
//                                   imageUrl: widget.product.url,
//                                   height: 150,
//                                   width: double.infinity,
//                                   fit: BoxFit.contain,
//                                   placeholder: (context, url) => const Center(
//                                       child: CircularProgressIndicator(
//                                     color: AppColors.colorPrimary,
//                                   )),
//                                   errorWidget: (context, error, stackTrace) {
//                                     // In case of error, show a default image
//                                     return Image.asset(
//                                       'assets/decont_splash_screen_images/decont_logo.png',
//                                       fit: BoxFit.contain,
//                                       height: 100,
//                                       width: double.infinity,
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ),
//                             // Positioned(
//                             //   top: 0,
//                             //   left: 0,
//                             //   child: Container(
//                             //     decoration: const BoxDecoration(
//                             //       color: AppColors.green,
//                             //       borderRadius: BorderRadius.only(
//                             //         bottomRight: Radius.circular(5),
//                             //       ),
//                             //     ),
//                             //     padding: const EdgeInsets.symmetric(
//                             //         horizontal: 3, vertical: 5),
//                             //     child: Column(
//                             //       children: [
//                             //         Text(
//                             //           widget.product.discount,
//                             //           style: CustomTextStyle.GraphikMedium(
//                             //               8, AppTheme().whiteColor),
//                             //         ),
//                             //       ],
//                             //     ),
//                             //   ),
//                             // ),
//                             Positioned(
//                               top: 10,
//                               right: 5,
//                               child: GestureDetector(
//                                 onTap: () {
//                                   //TODO
//                                 },
//                                 child: Container(
//                                   height: 40,
//                                   width: 50,
//                                   decoration: const BoxDecoration(
//                                     borderRadius: BorderRadius.only(
//                                       bottomLeft: Radius.circular(5),
//                                     ),
//                                   ),
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 3,
//                                   ),
//                                   child: const Column(
//                                     children: [
//                                       Icon(
//                                         Icons.favorite_border_outlined,
//                                         color: AppColors.secondTextColor,
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(width: 10.0),
//                         Expanded(
//                           child: Container(
//                             margin: const EdgeInsets.only(top: 9),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: Row(
//                                         children: [
//                                           Visibility(
//                                             visible: widget
//                                                     .product.star.isNotEmpty &&
//                                                 widget.product.star != '0',
//                                             child: Container(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                       horizontal: 5,
//                                                       vertical: 2),
//                                               decoration: BoxDecoration(
//                                                 color: AppColors.darkgreenColor,
//                                                 borderRadius:
//                                                     BorderRadius.circular(5),
//                                               ),
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   Text(
//                                                     widget.product.star,
//                                                     style: CustomTextStyle
//                                                         .GraphikRegular(12,
//                                                             AppColors.white),
//                                                   ),
//                                                   const SizedBox(
//                                                       width:
//                                                           4), // Add spacing between text and icon
//                                                   const Icon(
//                                                     Icons.star,
//                                                     color: Colors
//                                                         .white, // Star color
//                                                     size: 12, // Small icon size
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                           const SizedBox(
//                                             width: 5.0,
//                                           ),
//                                           Visibility(
//                                             visible: widget
//                                                 .product.review_msg.isNotEmpty,
//                                             child: Text(
//                                               '(${widget.product.review_msg})',
//                                               style: CustomTextStyle
//                                                   .GraphikRegular(
//                                                       12,
//                                                       AppColors
//                                                           .secondTextColor),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 5.0,
//                                 ),
//                                 Text(
//                                   insertLineBreaks(widget.product.name, 30),
//                                   style: CustomTextStyle.GraphikMedium(
//                                       13, AppColors.black),
//                                   maxLines: 3,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 const SizedBox(
//                                   height: 2.0,
//                                 ),
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.start,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Row(
//                                             children: [
//                                               Visibility(
//                                                 visible: widget
//                                                     .product.mrp.isNotEmpty,
//                                                 child: Text(
//                                                   '₹${widget.product.mrp}',
//                                                   style: Theme.of(context)
//                                                       .textTheme
//                                                       .displayMedium!
//                                                       .copyWith(
//                                                           color: AppColors.tex,
//                                                           fontSize: 12,
//                                                           decoration:
//                                                               TextDecoration
//                                                                   .lineThrough,
//                                                           decorationThickness:
//                                                               1,
//                                                           decorationColor:
//                                                               AppColors
//                                                                   .textSub),
//                                                 ),
//                                               ),
//                                               const SizedBox(
//                                                 width: 5.0,
//                                               ),
//                                               Visibility(
//                                                 visible: widget.product.discount
//                                                     .isNotEmpty,
//                                                 child: Text(
//                                                   widget.product.discount,
//                                                   style: Theme.of(context)
//                                                       .textTheme
//                                                       .labelMedium!
//                                                       .copyWith(
//                                                           color: AppColors
//                                                               .darkgreenColor,
//                                                           fontSize: 13),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           const SizedBox(
//                                             width: 5.0,
//                                           ),
//                                           Container(
//                                             margin:
//                                                 const EdgeInsets.only(top: 3.0),
//                                             child: Visibility(
//                                               visible: widget
//                                                   .product.price.isNotEmpty,
//                                               child: Text(
//                                                 '₹${widget.product.price}',
//                                                 style: Theme.of(context)
//                                                     .textTheme
//                                                     .labelMedium!
//                                                     .copyWith(
//                                                         color: AppColors.black,
//                                                         fontSize: 15),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 2.0,
//                                 ),
//                                 Visibility(
//                                   visible: widget.product.emi_option.isNotEmpty,
//                                   child: SizedBox(
//                                     width: double.infinity,
//                                     child: Row(
//                                       children: [
//                                         Icon(
//                                           Icons.check_circle_sharp,
//                                           color: AppTheme().thirdTextColor,
//                                           size: 16,
//                                         ),
//                                         const SizedBox(width: 4),
//                                         Expanded(
//                                           child: Text(
//                                             widget.product.emi_option,
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .displayMedium!
//                                                 .copyWith(
//                                                     color: AppColors.textSub,
//                                                     fontSize: 14),
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   height: 2.0,
//                                 ),
//                                 Visibility(
//                                   visible:
//                                       widget.product.cashback_text.isNotEmpty,
//                                   child: SizedBox(
//                                     width: double.infinity,
//                                     child: Row(
//                                       children: [
//                                         Icon(
//                                           Icons.local_offer_outlined,
//                                           color: AppColors.darkgreenColor,
//                                           size: 16,
//                                         ),
//                                         const SizedBox(width: 4),
//                                         Expanded(
//                                           child: Text(
//                                             widget.product.cashback_text,
//                                             style: TextStyle(
//                                               fontSize: 13,
//                                               color: AppColors.darkgreenColor,
//                                             ),
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   height: 2.0,
//                                 ),
//                                 Visibility(
//                                   visible: widget
//                                       .product.product_delivery_msg.isNotEmpty,
//                                   child: SizedBox(
//                                     width: double.infinity,
//                                     child: Row(
//                                       children: [
//                                         const Icon(
//                                           Icons.offline_bolt_rounded,
//                                           color: AppColors.colorButton,
//                                           size: 16,
//                                         ),
//                                         const SizedBox(width: 4),
//                                         Expanded(
//                                           child: Text(
//                                             widget.product.product_delivery_msg,
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .labelMedium!
//                                                 .copyWith(
//                                                     color:
//                                                         AppColors.colorButton,
//                                                     fontSize: 11),
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     if (widget.product.priceList.isNotEmpty)
//                       const SizedBox(
//                         height: 10.0,
//                       ),
//                     // Visibility(
//                     //   visible: widget.product.priceList.isNotEmpty,
//                     //   child: SizedBox(
//                     //     height: 30.0,
//                     //     child: ListView.builder(
//                     //       scrollDirection: Axis.horizontal,
//                     //       itemCount: widget.product.priceList.length,
//                     //       itemBuilder: (context, index) {
//                     //         final priceItem = widget.product.priceList[index];
//                     //
//                     //         return Container(
//                     //           margin: const EdgeInsets.only(
//                     //               right: 8.0, bottom: 5, left: 4),
//                     //           padding: const EdgeInsets.symmetric(
//                     //               horizontal: 8.0, vertical: 2.0),
//                     //           decoration: BoxDecoration(
//                     //             color: AppTheme().whiteColor,
//                     //             borderRadius: BorderRadius.circular(5.0),
//                     //             border: Border.all(color: AppTheme().lineColor),
//                     //           ),
//                     //           child: Center(
//                     //             child: Text(
//                     //               "${priceItem['label'] ?? ''}: ${priceItem['value'] ?? ''}",
//                     //               style: const TextStyle(fontSize: 14.0),
//                     //             ),
//                     //           ),
//                     //         );
//                     //       },
//                     //     ),
//                     //   ),
//                     // ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }
//
// class GridViewMyListTile extends StatefulWidget {
//   const GridViewMyListTile({required this.product});
//
//   final Product product;
//
//   @override
//   _GridViewMyListTileState createState() => _GridViewMyListTileState();
// }
//
// class _GridViewMyListTileState extends State<GridViewMyListTile> {
// // Track favorite status
//
//   @override
//   void initState() {
//     super.initState();
//     //_isFavorite = widget.product.inWishlist; // Set initial state from API response
//   }
//
//   Future<void> _toggleFavorite() async {
//     // Prepare the API call
//     final url =
//         Uri.parse(add_remove_wishlist); // Replace with your API endpoint
//     final Map<String, String> headers = {
//       'Content-Type': 'application/x-www-form-urlencoded',
//       'Authorization': 'Bearer $user_token',
//       // Include the user token if necessary
//     };
//
//     final Map<String, String> body = {
//       'product_id':
//           widget.product.id.toString(), // Pass the product ID to the API
//       //'flag': _isFavorite.toString(), // Pass the new favorite state
//     };
//
//     try {
//       // Make the API call
//       final response = await http.post(url, headers: headers, body: body);
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['status'] == 'success') {
//           // Successfully updated favorite status
//           log('Favorite status updated: ${data['message']}');
//
//           /*setState(() {
//             _isFavorite = !_isFavorite; // Toggle the favorite state
//             widget.product.inWishlist = _isFavorite; // Update the product's wishlist state locally
//           });*/
//         } else {
//           // Handle error returned by the API
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(data['message'],
//                     style: Theme.of(context)
//                         .textTheme
//                         .displayMedium!
//                         .copyWith(color: AppColors.white))),
//           );
//         }
//       } else {
//         // Handle HTTP error responses
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text('Error: ${response.reasonPhrase}',
//                   style: Theme.of(context)
//                       .textTheme
//                       .displayMedium!
//                       .copyWith(color: AppColors.white))),
//         );
//       }
//     } catch (e) {
//       // Handle exceptions
//       log('Error updating favorite status: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text('An unexpected error occurred.',
//                 style: Theme.of(context)
//                     .textTheme
//                     .displayMedium!
//                     .copyWith(color: AppColors.white))),
//       );
//     }
//   }
//
//   void _navigateToDetails(BuildContext context) {
//     log('id ${widget.product.id.toString()}');
//     Navigator.of(context)
//         .push(PageRouteBuilder(
//       pageBuilder: (context, animation, secondaryAnimation) =>
//           ProductDetailScreen(product_id: widget.product.id.toString()),
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         const begin = Offset(1.0, 0.0);
//         const end = Offset.zero;
//         const curve = Curves.easeInOut;
//
//         var tween =
//             Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//         var offsetAnimation = animation.drive(tween);
//
//         return SlideTransition(
//           position: offsetAnimation,
//           child: child,
//         );
//       },
//     ))
//         .then((_) {
//       // When returning from the Product Detail screen, call onResume
//       onResume();
//     });
//   }
//
//   void onResume() {}
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         _navigateToDetails(context);
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: AppColors.white,
//           border: Border.all(
//             color: AppTheme().lineColor,
//             width: 0.3,
//           ),
//           borderRadius: BorderRadius.circular(5.0),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(5.0),
//                   child: CachedNetworkImage(
//                     imageUrl: widget.product.url,
//                     height: 150,
//                     width: double.infinity,
//                     fit: BoxFit.contain,
//                     placeholder: (context, url) => Center(
//                         child: CircularProgressIndicator(
//                       color: AppColors.colorPrimary,
//                     )),
//                     errorWidget: (context, error, stackTrace) {
//                       // In case of error, show a default image
//                       return Image.asset(
//                         'assets/decont_splash_screen_images/decont_logo.png',
//                         fit: BoxFit.contain,
//                         height: 100,
//                         width: double.infinity,
//                       );
//                     },
//                   ),
//                 ),
//                 Positioned(
//                   top: 10,
//                   right: 15,
//                   child: Container(
//                     height: 40,
//                     width: 40,
//                     decoration: const BoxDecoration(
//                       borderRadius: BorderRadius.only(
//                         bottomLeft: Radius.circular(5),
//                       ),
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 3,
//                     ),
//                     child: const Column(
//                       children: [
//                         Icon(
//                           Icons.favorite_border_outlined,
//                           color: AppColors.secondTextColor,
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 5.0,
//             ),
//
//             // PRODUCT RATINGS
//             SizedBox(
//               height: 30,
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 10),
//                       child: Row(
//                         children: [
//                           Visibility(
//                             visible: widget.product.star.isNotEmpty &&
//                                 widget.product.star != '0',
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 5, vertical: 5), // Add padding
//                               decoration: BoxDecoration(
//                                 color: AppColors.darkgreenColor,
//                                 // Background color
//                                 borderRadius:
//                                     BorderRadius.circular(5), // Corner radius
//                               ),
//                               child: Row(
//                                 // Space between text and icon
//                                 children: [
//                                   Text(widget.product.star,
//                                       style: CustomTextStyle.GraphikMedium(
//                                           11, AppColors.white)),
//                                   const SizedBox(width: 4),
//                                   // Add spacing between text and icon
//                                   const Icon(
//                                     Icons.star,
//                                     color: Colors.white, // Star color
//                                     size: 12, // Small icon size
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(
//                             width: 5.0,
//                           ),
//                           Visibility(
//                             visible: widget.product.review_msg.isNotEmpty,
//                             child: Text(
//                               '(${widget.product.review_msg})',
//                               style: CustomTextStyle.GraphikRegular(
//                                   11, AppColors.secondTextColor),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(
//               height: 5.0,
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Text(
//                 widget.product.name,
//                 style: Theme.of(context)
//                     .textTheme
//                     .labelMedium!
//                     .copyWith(color: AppColors.black, fontSize: 14),
//                 maxLines: 2, // Limit to 1 line for name
//                 overflow: TextOverflow.ellipsis, // Ellipsis for overflow
//               ),
//             ),
//             const SizedBox(
//               height: 2.0,
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Visibility(
//                               visible: widget.product.mrp.isNotEmpty,
//                               child: Text(
//                                 '₹${widget.product.mrp}',
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   color: AppTheme().thirdTextColor,
//                                   decoration: TextDecoration.lineThrough,
//                                   decorationColor: AppTheme().thirdTextColor,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(
//                               width: 5.0,
//                             ),
//                             widget.product.discount == ''
//                                 ? const SizedBox.shrink()
//                                 : Visibility(
//                                     visible: widget.product.discount.isNotEmpty,
//                                     child: Text(
//                                       widget.product.discount,
//                                       style: TextStyle(
//                                           fontSize: 13,
//                                           color: AppColors.darkgreenColor,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   ),
//                           ],
//                         ),
//                         const SizedBox(
//                           width: 5.0,
//                         ),
//                         Container(
//                           margin: const EdgeInsets.only(top: 3.0),
//                           child: Visibility(
//                             visible: widget.product.price.isNotEmpty,
//                             child: Text(
//                               '₹${widget.product.price}',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: AppTheme().firstTextColor,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(
//               height: 2.0,
//             ),
//             Visibility(
//               visible: widget.product.emi_option.isNotEmpty,
//               child: SizedBox(
//                 width: double.infinity,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.check_circle_sharp,
//                         color: AppTheme().thirdTextColor,
//                         size: 16,
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: Text(
//                           widget.product.emi_option,
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: AppTheme().thirdTextColor,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             const SizedBox(
//               height: 2.0,
//             ),
//             Visibility(
//               visible: widget.product.cashback_text.isNotEmpty,
//               child: SizedBox(
//                 width: double.infinity,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.local_offer_outlined,
//                         color: AppColors.darkgreenColor,
//                         size: 16,
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: Text(
//                           widget.product.cashback_text,
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: AppColors.darkgreenColor,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             const SizedBox(
//               height: 2.0,
//             ),
//             Visibility(
//               visible: widget.product.product_delivery_msg.isNotEmpty,
//               child: SizedBox(
//                 width: double.infinity,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.offline_bolt_rounded,
//                         color: AppTheme().orangeColor,
//                         size: 16,
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: Text(
//                           widget.product.product_delivery_msg,
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: AppTheme().orangeColor,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             if (widget.product.priceList.isNotEmpty)
//               const SizedBox(
//                 height: 10.0,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class Product {
//   final String id;
//   final String name;
//   final String url; // Image URL
//   final String mrp;
//   final String price;
//   final String discount;
//   final String emi_option;
//   final String cashback_text;
//   final String product_delivery_msg;
//   final String review_msg;
//   final String star;
//   final List<Map<String, String>> priceList;
//
//   Product({
//     required this.id,
//     required this.name,
//     required this.url,
//     required this.mrp,
//     required this.price,
//     required this.discount,
//     required this.emi_option,
//     required this.cashback_text,
//     required this.product_delivery_msg,
//     required this.review_msg,
//     required this.star,
//     required this.priceList,
//   });
// }
//
// class PriceList {
//   final String label;
//   final String value;
//
//   PriceList({required this.label, required this.value});
//
//   factory PriceList.fromJson(Map<String, dynamic> json) {
//     return PriceList(
//       label: json['label'],
//       value: json['value'],
//     );
//   }
// }
//
// class Pagination {
//   final String count;
//   final String nextPage;
//
//   Pagination({required this.count, required this.nextPage});
//
//   factory Pagination.fromJson(Map<String, dynamic> json) {
//     return Pagination(
//       count: json['count'],
//       nextPage: json['next_page'],
//     );
//   }
// }
//
// class ProductResponse {
//   final String status;
//   final int result;
//   final String message;
//   final ProductData data;
//
//   ProductResponse({
//     required this.status,
//     required this.result,
//     required this.message,
//     required this.data,
//   });
//
//   factory ProductResponse.fromJson(Map<String, dynamic> json) {
//     return ProductResponse(
//       status: json['status'],
//       result: json['result'],
//       message: json['message'],
//       data: ProductData.fromJson(json['data']),
//     );
//   }
// }
//
// class ProductData {
//   final int productCount;
//   final List<Product> productList;
//   final Pagination pagination;
//
//   ProductData({
//     required this.productCount,
//     required this.productList,
//     required this.pagination,
//   });
//
//   factory ProductData.fromJson(Map<String, dynamic> json) {
//     return ProductData(
//       productCount: json['product_count'],
//       productList: (json['product_list'] as List)
//           .map((item) => Product.fromJson(item))
//           .toList(),
//       pagination: Pagination.fromJson(json['pagination']),
//     );
//   }
// }

import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../BaseUrl.dart';
import '../CustomeTextStyle/custometextstyle.dart';
import '../productDetails/product_details_screen.dart';
import '../productshimmer/productshimmer.dart';
import '../theme/AppTheme.dart';

String? first_name = '';
String? last_name = '';
String? email = '';
String? mobile = '';
String? user_token = '';
String? userID = '';
String? image = '';

class ProductListScreen extends StatefulWidget {
  final VoidCallback onBack;
  final String category;
  final String category_name;

  const ProductListScreen({
    super.key,
    required this.onBack,
    required this.category,
    required this.category_name,
  });

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final Map<String, int> productt = {};
  Map<String, String> localizedStrings = {};
  String currentLangCode = 'en';
  String Category = '';
  String CategoryName = '';
  String product_count = '';
  List<Map<String, dynamic>> productsList = [];
  List<Map<String, dynamic>> filteredProductsList = []; // For filtered results
  String pageCode = '0';
  bool isLoading = false;
  bool hasMoreData = true;
  bool isPaginationLoading = false;
  bool isGridView = false;
  int cart_count = 0;
  bool? isCodAvailable;
  int? selectedRating;
  String? selectedSortOption;
  String? selectedMaterial;
  String? selectedColor;
  String? selectedUsage;
  String? selectedType;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguagePreference();
    _initializeData();

    Category = widget.category;
    CategoryName = widget.category_name;

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (hasMoreData && !isPaginationLoading && !isLoading) {
          _productListData();
        }
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
      userID = prefs.getString('user_id') ?? '';
      image = prefs.getString('image') ?? '';
      cart_count = prefs.getInt('cart_count') ?? 0;
    });
    await _productListData();
  }

  // Future<void> _productListData() async {
  //   if (isLoading || isPaginationLoading) return;
  //
  //   setState(() {
  //     isPaginationLoading = true;
  //     isLoading = true;
  //   });
  //
  //   final url = Uri.parse(baseUrl);
  //
  //   final Map<String, String> headers = {
  //     'Content-Type': 'application/x-www-form-urlencoded',
  //     'Authorization': 'Bearer $user_token',
  //   };
  //
  //   final Map<String, String> body = {
  //     'view': 'product',
  //     'pagecode': pageCode,
  //     'catID': Category,
  //     'type': selectedSortOption ?? '',
  //     'type_code': '',
  //     'type_rate': selectedRating?.toString() ?? '',
  //   };
  //
  //   try {
  //     final response = await http.post(url, headers: headers, body: body);
  //     final data = jsonDecode(response.body);
  //
  //     if (data['result'] == 1) {
  //       log('Response data: $pageCode');
  //
  //       setState(() {
  //         product_count = data['data']['product_count'].toString();
  //         if (pageCode == '0') {
  //           productsList.clear();
  //         }
  //         productsList.addAll((data['data']['product_list'] as List)
  //             .map((item) => {
  //                   'productID': item['productID'],
  //                   'name': item['name'],
  //                   'image': item['image'],
  //                   'mrp': item['mrp'],
  //                   'price': item['price'],
  //                   'discount': item['discount'],
  //                   'emi_option': item['emi_option'],
  //                   'cashback_text': item['cashback_text'],
  //                   'product_delivery_msg': item['product_delivery_msg'],
  //                   'review_msg': item['review_msg'],
  //                   'star': item['star'],
  //                   'price_list': item['price_list'] ?? [],
  //                 })
  //             .toList());
  //
  //         // Initialize filteredProductsList
  //         filteredProductsList = List.from(productsList);
  //
  //         // Handle pagination
  //         if (data['data'].containsKey('pagination')) {
  //           final pagination = data['data']['pagination'];
  //           if (pagination['next_page'] != null &&
  //               pagination['next_page'].toString().isNotEmpty) {
  //             pageCode = pagination['next_page'].toString();
  //           } else {
  //             hasMoreData = false;
  //           }
  //         } else {
  //           log('Pagination data not found');
  //           hasMoreData = false;
  //         }
  //       });
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             data['message'],
  //             style: CustomTextStyle.GraphikMedium(16, AppColors.white),
  //           ),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     log('Error: $e');
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //       isPaginationLoading = false;
  //     });
  //   }
  // }

  Future<void> _productListData() async {
    // Prevent multiple simultaneous requests
    if (isLoading || isPaginationLoading) return;

    // Only show full loading for initial load (pageCode == '0')
    // For pagination, only show pagination loading
    setState(() {
      if (pageCode == '0') {
        isLoading = true;
        isPaginationLoading = false;
      } else {
        isPaginationLoading = true;
        isLoading = false;
      }
    });

    final url = Uri.parse(baseUrl);

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token',
    };

    final Map<String, String> body = {
      'view': 'product',
      'pagecode': pageCode,
      'catID': Category,
      'type': selectedSortOption ?? '',
      'type_code': '',
      'type_rate': selectedRating?.toString() ?? '',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);
      final data = jsonDecode(response.body);

      if (data['result'] == 1) {
        log('Response data: $pageCode');

        setState(() {
          product_count = data['data']['product_count'].toString();

          if (pageCode == '0') {
            productsList.clear();
          }

          final newProducts = (data['data']['product_list'] as List)
              .map((item) => {
                    'productID': item['productID'],
                    'name': item['name'],
                    'image': item['image'],
                    'mrp': item['mrp'],
                    'price': item['price'],
                    'discount': item['discount'],
                    'emi_option': item['emi_option'],
                    'cashback_text': item['cashback_text'],
                    'product_delivery_msg': item['product_delivery_msg'],
                    'review_msg': item['review_msg'],
                    'star': item['star'],
                    'price_list': item['price_list'] ?? [],
                  })
              .toList();

          productsList.addAll(newProducts);

          if (pageCode == '0') {
            filteredProductsList = List.from(productsList);
          } else {
            filteredProductsList.addAll(newProducts);
          }

          if (data['data'].containsKey('pagination')) {
            final pagination = data['data']['pagination'];
            if (pagination['next_page'] != null &&
                pagination['next_page'].toString().isNotEmpty) {
              pageCode = pagination['next_page'].toString();
            } else {
              hasMoreData = false;
            }
          } else {
            log('Pagination data not found');
            hasMoreData = false;
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'],
              style: CustomTextStyle.GraphikMedium(16, AppColors.white),
            ),
          ),
        );
      }
    } catch (e) {
      log('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
        isPaginationLoading = false;
      });
    }
  }

  // Extract filter options
  Map<String, List<String>> _getFilterOptions() {
    Set<String> materials = {};
    Set<String> colors = {};
    Set<String> usages = {};
    Set<String> types = {};

    for (var product in productsList) {
      for (var priceItem in (product['price_list'] as List)) {
        if (priceItem['label'] == 'Material') {
          materials.add(priceItem['value']);
        } else if (priceItem['label'] == 'Color') {
          colors.add(priceItem['value']);
        } else if (priceItem['label'] == 'Usage') {
          usages.add(priceItem['value']);
        } else if (priceItem['label'] == 'Type') {
          types.add(priceItem['value']);
        }
      }
    }

    return {
      'materials': materials.toList()..sort(),
      'colors': colors.toList()..sort(),
      'usages': usages.toList()..sort(),
      'types': types.toList()..sort(),
    };
  }

  // Apply filters
  List<Map<String, dynamic>> _applyFilters(
      List<Map<String, dynamic>> products) {
    List<Map<String, dynamic>> filtered = List.from(products);

    // COD filter (placeholder, as JSON lacks COD info)
    if (isCodAvailable != null) {
      // Add logic if COD data is available
    }

    // Rating filter
    if (selectedRating != null) {
      filtered = filtered.where((product) {
        double starRating = double.tryParse(product['star']) ?? 0.0;
        return starRating >= selectedRating!;
      }).toList();
    }

    // Material filter
    if (selectedMaterial != null && selectedMaterial!.isNotEmpty) {
      filtered = filtered.where((product) {
        return (product['price_list'] as List).any((priceItem) =>
            priceItem['label'] == 'Material' &&
            priceItem['value'].toLowerCase() ==
                selectedMaterial!.toLowerCase());
      }).toList();
    }

    // Color filter
    if (selectedColor != null && selectedColor!.isNotEmpty) {
      filtered = filtered.where((product) {
        return (product['price_list'] as List).any((priceItem) =>
            priceItem['label'] == 'Color' &&
            priceItem['value'].toLowerCase() == selectedColor!.toLowerCase());
      }).toList();
    }

    // Usage filter
    if (selectedUsage != null && selectedUsage!.isNotEmpty) {
      filtered = filtered.where((product) {
        return (product['price_list'] as List).any((priceItem) =>
            priceItem['label'] == 'Usage' &&
            priceItem['value']
                .toLowerCase()
                .contains(selectedUsage!.toLowerCase()));
      }).toList();
    }

    // Type filter
    if (selectedType != null && selectedType!.isNotEmpty) {
      filtered = filtered.where((product) {
        return (product['price_list'] as List).any((priceItem) =>
            priceItem['label'] == 'Type' &&
            priceItem['value'].toLowerCase() == selectedType!.toLowerCase());
      }).toList();
    }

    // Sorting
    if (selectedSortOption != null && selectedSortOption!.isNotEmpty) {
      switch (selectedSortOption) {
        case 'Price Low':
          filtered.sort((a, b) =>
              double.parse(a['price']).compareTo(double.parse(b['price'])));
          break;
        case 'High Price':
          filtered.sort((a, b) =>
              double.parse(b['price']).compareTo(double.parse(a['price'])));
          break;
        case 'A-Z Name':
          filtered.sort((a, b) => a['name'].compareTo(b['name']));
          break;
        case 'Z-A Name':
          filtered.sort((a, b) => b['name'].compareTo(a['name']));
          break;
        case 'New Arrival':
          filtered.sort((a, b) => b['productID'].compareTo(a['productID']));
          break;
      }
    }

    return filtered;
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

  void _showFilterBottomSheet() {
    final filterOptions = _getFilterOptions();
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                Widget _buildRadioButton(String title, String value,
                    String groupValue, Function(String?) onChanged) {
                  return RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      title,
                      style:
                          CustomTextStyle.GraphikRegular(16, AppColors.black),
                    ),
                    value: value,
                    groupValue: groupValue,
                    onChanged: (newValue) {
                      setModalState(() {
                        onChanged(newValue);
                      });
                    },
                    activeColor: AppColors.colorPrimary,
                  );
                }

                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Text(
                                'Filters',
                                style: CustomTextStyle.GraphikMedium(
                                    14, AppColors.black),
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: const Padding(
                                padding: EdgeInsets.only(right: 10),
                                child:
                                    Icon(Icons.close, color: AppColors.black),
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                            thickness: 1,
                            color: AppColors.textFieldBorderColor),

                        // COD Filter
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'COD',
                            style: CustomTextStyle.GraphikMedium(
                                14, AppColors.black),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: isCodAvailable == true
                                        ? AppColors.colorPrimary
                                        : Colors.white,
                                    foregroundColor: isCodAvailable == true
                                        ? AppColors.white
                                        : AppColors.colorPrimary,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                          color: AppColors.black, width: 1),
                                    ),
                                  ),
                                  onPressed: () {
                                    setModalState(() {
                                      isCodAvailable =
                                          isCodAvailable == true ? null : true;
                                    });
                                  },
                                  child: Text(
                                    'COD Available',
                                    style: isCodAvailable == true
                                        ? CustomTextStyle.GraphikMedium(
                                            16, AppColors.white)
                                        : CustomTextStyle.GraphikRegular(
                                            16, AppColors.secondTextColor),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: isCodAvailable == false
                                        ? AppColors.colorPrimary
                                        : Colors.white,
                                    foregroundColor: isCodAvailable == false
                                        ? AppColors.white
                                        : AppColors.colorPrimary,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                          color: AppColors.black, width: 1),
                                    ),
                                  ),
                                  onPressed: () {
                                    setModalState(() {
                                      isCodAvailable = isCodAvailable == false
                                          ? null
                                          : false;
                                    });
                                  },
                                  child: Text(
                                    'COD Not Available',
                                    style: isCodAvailable == false
                                        ? CustomTextStyle.GraphikMedium(
                                            16, AppColors.white)
                                        : CustomTextStyle.GraphikRegular(
                                            16, AppColors.secondTextColor),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Rating',
                            style: CustomTextStyle.GraphikMedium(
                                14, AppColors.black),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: List.generate(5, (index) {
                              int starValue = index + 1;
                              bool isSelected = selectedRating == starValue;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: OutlinedButton(
                                  onPressed: () {
                                    setModalState(() {
                                      if (isSelected) {
                                        selectedRating = null;
                                      } else {
                                        selectedRating = starValue;
                                      }
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: isSelected
                                        ? AppColors.colorPrimary
                                        : Colors.white,
                                    foregroundColor: isSelected
                                        ? AppColors.white
                                        : AppColors.black,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: const BorderSide(
                                          color: AppColors.black, width: 1),
                                    ),
                                  ),
                                  child: Text(
                                    '$starValue ⭐',
                                    style: isSelected
                                        ? CustomTextStyle.GraphikMedium(
                                            16, AppColors.white)
                                        : CustomTextStyle.GraphikRegular(
                                            15, AppColors.secondTextColor),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Sort By',
                            style: CustomTextStyle.GraphikMedium(
                                14, AppColors.black),
                          ),
                        ),
                        const Divider(
                            thickness: 1,
                            color: AppColors.textFieldBorderColor),
                        Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: _buildRadioButton(
                                'Low Price',
                                'Price Low',
                                selectedSortOption ?? '',
                                (value) => selectedSortOption = value,
                              ),
                            ),
                            const Divider(
                                thickness: 1,
                                color: AppColors.textFieldBorderColor),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: _buildRadioButton(
                                'High Price',
                                'High Price',
                                selectedSortOption ?? '',
                                (value) => selectedSortOption = value,
                              ),
                            ),
                            const Divider(
                                thickness: 1,
                                color: AppColors.textFieldBorderColor),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: _buildRadioButton(
                                'A-Z Name',
                                'A-Z Name',
                                selectedSortOption ?? '',
                                (value) => selectedSortOption = value,
                              ),
                            ),
                            const Divider(
                                thickness: 1,
                                color: AppColors.textFieldBorderColor),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: _buildRadioButton(
                                'Z-A Name',
                                'Z-A Name',
                                selectedSortOption ?? '',
                                (value) => selectedSortOption = value,
                              ),
                            ),
                            const Divider(
                                thickness: 1,
                                color: AppColors.textFieldBorderColor),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: _buildRadioButton(
                                'New Arrival',
                                'New Arrival',
                                selectedSortOption ?? '',
                                (value) => selectedSortOption = value,
                              ),
                            ),
                          ],
                        ),

                        // Material Filter
                        if (filterOptions['materials']!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Material',
                              style: CustomTextStyle.GraphikMedium(
                                  14, AppColors.black),
                            ),
                          ),
                          const Divider(
                              thickness: 1,
                              color: AppColors.textFieldBorderColor),
                          Column(
                            children:
                                filterOptions['materials']!.map((material) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: _buildRadioButton(
                                  material,
                                  material,
                                  selectedMaterial ?? '',
                                  (value) => selectedMaterial = value,
                                ),
                              );
                            }).toList(),
                          ),
                        ],

                        // Color Filter
                        if (filterOptions['colors']!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Color',
                              style: CustomTextStyle.GraphikMedium(
                                  14, AppColors.black),
                            ),
                          ),
                          const Divider(
                              thickness: 1,
                              color: AppColors.textFieldBorderColor),
                          Column(
                            children: filterOptions['colors']!.map((color) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: _buildRadioButton(
                                  color,
                                  color,
                                  selectedColor ?? '',
                                  (value) => selectedColor = value,
                                ),
                              );
                            }).toList(),
                          ),
                        ],

                        // Usage Filter
                        if (filterOptions['usages']!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Usage',
                              style: CustomTextStyle.GraphikMedium(
                                  14, AppColors.black),
                            ),
                          ),
                          const Divider(
                              thickness: 1,
                              color: AppColors.textFieldBorderColor),
                          Column(
                            children: filterOptions['usages']!.map((usage) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: _buildRadioButton(
                                  usage,
                                  usage,
                                  selectedUsage ?? '',
                                  (value) => selectedUsage = value,
                                ),
                              );
                            }).toList(),
                          ),
                        ],

                        // Type Filter
                        if (filterOptions['types']!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Type',
                              style: CustomTextStyle.GraphikMedium(
                                  14, AppColors.black),
                            ),
                          ),
                          const Divider(
                              thickness: 1,
                              color: AppColors.textFieldBorderColor),
                          Column(
                            children: filterOptions['types']!.map((type) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: _buildRadioButton(
                                  type,
                                  type,
                                  selectedType ?? '',
                                  (value) => selectedType = value,
                                ),
                              );
                            }).toList(),
                          ),
                        ],

                        // Apply Button
                        const Divider(
                            thickness: 1,
                            color: AppColors.textFieldBorderColor),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.colorPrimary,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 30),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    filteredProductsList =
                                        _applyFilters(productsList);
                                  });
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Apply Filters',
                                  style: CustomTextStyle.GraphikMedium(
                                      15, AppColors.white),
                                ),
                              ),
                            ),

                            // Reset Button
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 30),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(
                                        color: AppColors.black, width: 1),
                                  ),
                                ),
                                onPressed: () {
                                  setModalState(() {
                                    isCodAvailable = null;
                                    selectedRating = null;
                                    selectedSortOption = null;
                                    selectedMaterial = null;
                                    selectedColor = null;
                                    selectedUsage = null;
                                    selectedType = null;
                                  });
                                  setState(() {
                                    filteredProductsList =
                                        List.from(productsList);
                                  });
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Reset Filters',
                                  style: CustomTextStyle.GraphikRegular(
                                      16, AppColors.secondTextColor),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 1.0),
        child: Column(
          children: [
            AppBar(
              surfaceTintColor: Colors.transparent,
              elevation: 0.0,
              title: Text(
                CategoryName,
                textAlign: TextAlign.left,
                style: CustomTextStyle.GraphikMedium(16, AppColors.black),
              ),
              actions: [
                const Column(
                  children: [
                    SizedBox(height: 10.0),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/search');
                  },
                  child: const Icon(Icons.search),
                ),
                const SizedBox(width: 5.0),
                Container(
                  margin: const EdgeInsets.only(right: 15),
                  child: Stack(
                    children: <Widget>[
                      IconButton(
                        color: Colors.black,
                        icon: SvgPicture.asset(
                          'assets/icons/shopping_cart.svg',
                          width: 24,
                          height: 24,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          if (userID != null && userID!.isNotEmpty) {
                            Navigator.of(context).pushNamed('/my_cart');
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: AppTheme().whiteColor,
                                  surfaceTintColor: AppTheme().whiteColor,
                                  title: Text(
                                    'Login Required',
                                    style: CustomTextStyle.GraphikMedium(
                                        16, AppColors.black),
                                  ),
                                  content: Text(
                                    'Please log in to access my cart.',
                                    style: CustomTextStyle.GraphikMedium(
                                        16, AppColors.black),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Cancel',
                                        style: CustomTextStyle.GraphikRegular(
                                            14, AppColors.colorPrimary),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, "/login");
                                      },
                                      child: Text(
                                        'Login',
                                        style: CustomTextStyle.GraphikRegular(
                                            14, AppColors.colorPrimary),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
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
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            cart_count > 99
                                ? '99+'
                                : cart_count.toString().padLeft(1, '0'),
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
              ),
            )
          : Stack(
              children: [
                Column(
                  children: [
                    Container(
                      color: AppColors.white,
                      child: Row(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  isGridView ? Icons.list : Icons.grid_view,
                                  color: AppColors.black,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isGridView = !isGridView;
                                  });
                                },
                              ),
                              SizedBox(
                                width: 80,
                              ),
                              Container(
                                width: 100.0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 13.0, vertical: 5.0),
                                child: InkWell(
                                  onTap: _showFilterBottomSheet,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Sort By',
                                          style: CustomTextStyle.GraphikMedium(
                                              12, AppColors.black),
                                        ),
                                      ),
                                      SvgPicture.asset(
                                        'assets/icons/arrow_down.svg',
                                        color: Colors.grey,
                                        width: 20,
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 90.0),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isCodAvailable = null;
                                    selectedRating = null;
                                    selectedSortOption = null;
                                    selectedMaterial = null;
                                    selectedColor = null;
                                    selectedUsage = null;
                                    selectedType = null;
                                    filteredProductsList =
                                        List.from(productsList);
                                    pageCode = '0';
                                    hasMoreData = true;
                                  });
                                  _productListData();
                                },
                                child: Text(
                                  'REFINE',
                                  style: CustomTextStyle.GraphikMedium(
                                      12, AppColors.black),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: isGridView
                          ? Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: GridView.builder(
                                controller: _scrollController,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                  childAspectRatio: 1 / 1.9,
                                ),
                                itemCount: filteredProductsList.length +
                                    (isPaginationLoading ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= filteredProductsList.length) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.colorPrimary,
                                      ),
                                    );
                                  }
                                  var item = filteredProductsList[index];
                                  return GridViewMyListTile(
                                    product: Product(
                                      id: item['productID'],
                                      name: item['name'],
                                      url: item['image'],
                                      mrp: item['mrp'],
                                      price: item['price'],
                                      discount: item['discount'],
                                      emi_option: item['emi_option'],
                                      product_delivery_msg:
                                          item['product_delivery_msg'],
                                      cashback_text: item['cashback_text'],
                                      review_msg: item['review_msg'],
                                      star: item['star'],
                                      priceList: (item['price_list'] ?? [])
                                          .map<Map<String, String>>(
                                              (priceItem) => {
                                                    'label': priceItem['label']
                                                            ?.toString() ??
                                                        '',
                                                    'value': priceItem['value']
                                                            ?.toString() ??
                                                        '',
                                                  })
                                          .toList(),
                                    ),
                                  );
                                },
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              itemCount: filteredProductsList.length +
                                  (isPaginationLoading ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index >= filteredProductsList.length) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.colorPrimary,
                                    ),
                                  );
                                }
                                var item = filteredProductsList[index];
                                return VerticalMyListTile(
                                  isLoading: isLoading,
                                  product: Product(
                                    id: item['productID'],
                                    name: item['name'],
                                    url: item['image'],
                                    mrp: item['mrp'],
                                    price: item['price'],
                                    discount: item['discount'],
                                    emi_option: item['emi_option'],
                                    cashback_text: item['cashback_text'],
                                    product_delivery_msg:
                                        item['product_delivery_msg'],
                                    review_msg: item['review_msg'],
                                    star: item['star'],
                                    priceList: (item['price_list'] ?? [])
                                        .map<Map<String, String>>(
                                            (priceItem) => {
                                                  'label': priceItem['label']
                                                          ?.toString() ??
                                                      '',
                                                  'value': priceItem['value']
                                                          ?.toString() ??
                                                      '',
                                                })
                                        .toList(),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
                if (selectedSortOption != null ||
                    selectedRating != null ||
                    selectedMaterial != null ||
                    selectedColor != null ||
                    selectedUsage != null ||
                    selectedType != null ||
                    isCodAvailable != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      color: AppColors.colorPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedSortOption ?? 'Filters Applied',
                              style: CustomTextStyle.GraphikRegular(
                                  14, AppColors.white),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedSortOption = null;
                                isCodAvailable = null;
                                selectedRating = null;
                                selectedMaterial = null;
                                selectedColor = null;
                                selectedUsage = null;
                                selectedType = null;
                                filteredProductsList = List.from(productsList);
                                pageCode = '0';
                                hasMoreData = true;
                              });
                              _productListData();
                            },
                            child: Text(
                              'Reset',
                              style: CustomTextStyle.GraphikMedium(
                                  16, AppColors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class VerticalMyListTile extends StatefulWidget {
  VerticalMyListTile({required this.product, required this.isLoading});

  final Product product;
  bool isLoading;

  @override
  _VerticalMyListTileState createState() => _VerticalMyListTileState();
}

class _VerticalMyListTileState extends State<VerticalMyListTile> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _toggleFavorite() async {
    final url = Uri.parse(add_remove_wishlist);
    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token',
    };

    final Map<String, String> body = {
      'product_id': widget.product.id.toString(),
      'flag': _isFavorite.toString(),
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          log('Favorite status updated: ${data['message']}');
          setState(() {
            _isFavorite = !_isFavorite;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['message'],
                style: CustomTextStyle.GraphikMedium(16, AppColors.white),
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${response.reasonPhrase}',
              style: CustomTextStyle.GraphikMedium(16, AppColors.white),
            ),
          ),
        );
      }
    } catch (e) {
      log('Error updating favorite status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An unexpected error occurred.',
            style: CustomTextStyle.GraphikMedium(16, AppColors.white),
          ),
        ),
      );
    }
  }

  void _navigateToDetails(BuildContext context) {
    log('id ${widget.product.id.toString()}');
    Navigator.of(context)
        .push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ProductDetailScreen(product_id: widget.product.id.toString()),
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
    ))
        .then((_) {
      onResume();
    });
  }

  void onResume() {
    print("Product list resumed");
  }

  String insertLineBreaks(String text, int interval) {
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % interval == 0 && i != text.length - 1) {
        buffer.write('\n');
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _navigateToDetails(context);
      },
      child: widget.isLoading
          ? const ProductCardShimmerForListTile()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: AppColors.white,
                  border: Border.all(
                    color: AppTheme().lineColor,
                    width: 0.3,
                  ),
                ),
                margin: const EdgeInsets.only(bottom: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: SizedBox(
                                width: 120,
                                height: 150,
                                child: CachedNetworkImage(
                                  imageUrl: widget.product.url,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.colorPrimary,
                                    ),
                                  ),
                                  errorWidget: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/decont_splash_screen_images/decont_logo.png',
                                      fit: BoxFit.contain,
                                      height: 100,
                                      width: double.infinity,
                                    );
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 5,
                              child: GestureDetector(
                                onTap: _toggleFavorite,
                                child: Container(
                                  height: 40,
                                  width: 50,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(5),
                                    ),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  child: Column(
                                    children: [
                                      Icon(
                                        _isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border_outlined,
                                        color: AppColors.secondTextColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(top: 9),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Visibility(
                                            visible: widget
                                                    .product.star.isNotEmpty &&
                                                widget.product.star != '0',
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.darkgreenColor,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    widget.product.star,
                                                    style: CustomTextStyle
                                                        .GraphikRegular(12,
                                                            AppColors.white),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Icon(
                                                    Icons.star,
                                                    color: Colors.white,
                                                    size: 12,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5.0),
                                          Visibility(
                                            visible: widget
                                                .product.review_msg.isNotEmpty,
                                            child: Text(
                                              '(${widget.product.review_msg})',
                                              style: CustomTextStyle
                                                  .GraphikRegular(
                                                      12,
                                                      AppColors
                                                          .secondTextColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5.0),
                                Text(
                                  insertLineBreaks(widget.product.name, 30),
                                  style: CustomTextStyle.GraphikMedium(
                                      13, AppColors.black),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2.0),
                                Row(
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
                                                visible: widget
                                                    .product.mrp.isNotEmpty,
                                                child: Text(
                                                  '₹${widget.product.mrp}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displayMedium!
                                                      .copyWith(
                                                        color: AppColors.tex,
                                                        fontSize: 12,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        decorationThickness: 1,
                                                        decorationColor:
                                                            AppColors.textSub,
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(width: 5.0),
                                              Visibility(
                                                visible: widget.product.discount
                                                    .isNotEmpty,
                                                child: Text(
                                                  widget.product.discount,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium!
                                                      .copyWith(
                                                        color: AppColors
                                                            .darkgreenColor,
                                                        fontSize: 13,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 5.0),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 3.0),
                                            child: Visibility(
                                              visible: widget
                                                  .product.price.isNotEmpty,
                                              child: Text(
                                                '₹${widget.product.price}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium!
                                                    .copyWith(
                                                      color: AppColors.black,
                                                      fontSize: 15,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2.0),
                                Visibility(
                                  visible: widget.product.emi_option.isNotEmpty,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_sharp,
                                          color: AppTheme().thirdTextColor,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            widget.product.emi_option,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium!
                                                .copyWith(
                                                  color: AppColors.textSub,
                                                  fontSize: 14,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2.0),
                                Visibility(
                                  visible:
                                      widget.product.cashback_text.isNotEmpty,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.local_offer_outlined,
                                          color: AppColors.darkgreenColor,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            widget.product.cashback_text,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.darkgreenColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2.0),
                                Visibility(
                                  visible: widget
                                      .product.product_delivery_msg.isNotEmpty,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.offline_bolt_rounded,
                                          color: AppColors.colorButton,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            widget.product.product_delivery_msg,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium!
                                                .copyWith(
                                                  color: AppColors.colorButton,
                                                  fontSize: 11,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (widget.product.priceList.isNotEmpty)
                      const SizedBox(height: 10.0),
                  ],
                ),
              ),
            ),
    );
  }
}

class GridViewMyListTile extends StatefulWidget {
  const GridViewMyListTile({required this.product});

  final Product product;

  @override
  _GridViewMyListTileState createState() => _GridViewMyListTileState();
}

class _GridViewMyListTileState extends State<GridViewMyListTile> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _toggleFavorite() async {
    final url = Uri.parse(add_remove_wishlist);
    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token',
    };

    final Map<String, String> body = {
      'product_id': widget.product.id.toString(),
      'flag': _isFavorite.toString(),
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          log('Favorite status updated: ${data['message']}');
          setState(() {
            _isFavorite = !_isFavorite;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['message'],
                style: CustomTextStyle.GraphikMedium(16, AppColors.white),
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${response.reasonPhrase}',
              style: CustomTextStyle.GraphikMedium(16, AppColors.white),
            ),
          ),
        );
      }
    } catch (e) {
      log('Error updating favorite status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An unexpected error occurred.',
            style: CustomTextStyle.GraphikMedium(16, AppColors.white),
          ),
        ),
      );
    }
  }

  void _navigateToDetails(BuildContext context) {
    log('id ${widget.product.id.toString()}');
    Navigator.of(context)
        .push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ProductDetailScreen(product_id: widget.product.id.toString()),
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
    ))
        .then((_) {
      onResume();
    });
  }

  void onResume() {}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _navigateToDetails(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            color: AppTheme().lineColor,
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
                  borderRadius: BorderRadius.circular(5.0),
                  child: CachedNetworkImage(
                    imageUrl: widget.product.url,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.colorPrimary,
                      ),
                    ),
                    errorWidget: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/decont_splash_screen_images/decont_logo.png',
                        fit: BoxFit.contain,
                        height: 100,
                        width: double.infinity,
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 15,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        children: [
                          Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border_outlined,
                            color: AppColors.secondTextColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5.0),
            SizedBox(
              height: 30,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Visibility(
                            visible: widget.product.star.isNotEmpty &&
                                widget.product.star != '0',
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.darkgreenColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    widget.product.star,
                                    style: CustomTextStyle.GraphikMedium(
                                        11, AppColors.white),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          Visibility(
                            visible: widget.product.review_msg.isNotEmpty,
                            child: Text(
                              '(${widget.product.review_msg})',
                              style: CustomTextStyle.GraphikRegular(
                                  11, AppColors.secondTextColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                widget.product.name,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: AppColors.black, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Visibility(
                              visible: widget.product.mrp.isNotEmpty,
                              child: Text(
                                '₹${widget.product.mrp}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme().thirdTextColor,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: AppTheme().thirdTextColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5.0),
                            widget.product.discount == ''
                                ? const SizedBox.shrink()
                                : Visibility(
                                    visible: widget.product.discount.isNotEmpty,
                                    child: Text(
                                      widget.product.discount,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.darkgreenColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                        const SizedBox(width: 5.0),
                        Container(
                          margin: const EdgeInsets.only(top: 3.0),
                          child: Visibility(
                            visible: widget.product.price.isNotEmpty,
                            child: Text(
                              '₹${widget.product.price}',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme().firstTextColor,
                                fontWeight: FontWeight.bold,
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
            const SizedBox(height: 2.0),
            Visibility(
              visible: widget.product.emi_option.isNotEmpty,
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_sharp,
                        color: AppTheme().thirdTextColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.product.emi_option,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme().thirdTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2.0),
            Visibility(
              visible: widget.product.cashback_text.isNotEmpty,
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_offer_outlined,
                        color: AppColors.darkgreenColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.product.cashback_text,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.darkgreenColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2.0),
            Visibility(
              visible: widget.product.product_delivery_msg.isNotEmpty,
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.offline_bolt_rounded,
                        color: AppTheme().orangeColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.product.product_delivery_msg,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme().orangeColor,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.product.priceList.isNotEmpty)
              const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }
}

class Product {
  final String id;
  final String name;
  final String url;
  final String mrp;
  final String price;
  final String discount;
  final String emi_option;
  final String cashback_text;
  final String product_delivery_msg;
  final String review_msg;
  final String star;
  final List<Map<String, String>> priceList;

  Product({
    required this.id,
    required this.name,
    required this.url,
    required this.mrp,
    required this.price,
    required this.discount,
    required this.emi_option,
    required this.cashback_text,
    required this.product_delivery_msg,
    required this.review_msg,
    required this.star,
    required this.priceList,
  });
}
