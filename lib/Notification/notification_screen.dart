import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../BaseUrl.dart';
import '../CustomeTextStyle/custometextstyle.dart';
import '../theme/AppTheme.dart';
import 'notificationdetails.dart';

String? first_name = '';
String? last_name = '';
String? email = '';
String? mobile = '';
String? user_token = '';
String? image = '';

class NotificationsPage extends StatefulWidget {
  final VoidCallback onBack;

  const NotificationsPage({required this.onBack});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  Map<String, String> localizedStrings = {};
  String currentLangCode = 'en';
  bool isLoading = false;
  bool hasMoreData = true;
  List<Map<String, dynamic>> notificationsList =
      []; // Store notifications as a list of maps
  String pageCode = '0';
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

  Future<void> _dashboardData({bool isPagination = false}) async {
    if (isLoading || isPaginationLoading) return;

    setState(() {
      if (isPagination) {
        isPaginationLoading = true;
      } else {
        isLoading = true;
      }
    });

    final url = Uri.parse(baseUrl);

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token',
    };

    final Map<String, String> body = {
      'pagecode': pageCode,
      'view': 'notification_list',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());
        log('Response data: $data');

        if (data['result'] == 1 && data['data'] != null) {
          final List<dynamic> fetchedData = data['data'];

          setState(() {
            notificationsList.addAll(
                fetchedData.map((item) => Map<String, dynamic>.from(item)));
          });

          if (data.containsKey('pagination')) {
            final pagination = data['pagination'];
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
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(data['message'],
                    style: CustomTextStyle.GraphikMedium(16, AppColors.white))),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response.reasonPhrase}',
                style: CustomTextStyle.GraphikMedium(16, AppColors.white)),
          ),
        );
      }
    } catch (e) {
      log('Error: $e');
      // Handle exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred.',
              style: CustomTextStyle.GraphikMedium(16, AppColors.white)),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
        isPaginationLoading = false;
      });
    }
  }

  // Future<void> _dashboardData() async {
  //   if (isLoading || isPaginationLoading) return; // Prevent multiple requests
  //   setState(() {
  //     if (!isLoading) isPaginationLoading = true;
  //     if (!isPaginationLoading) isLoading = true;
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
  //     //'pagecode': pageCode, // Use the current page code for pagination
  //     'pagecode': '', // Use the current page code for pagination
  //     'view': 'notification_list',
  //   };
  //
  //   try {
  //     final response = await http.post(url, headers: headers, body: body);
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body.trim());
  //       log('Response data: $data');
  //
  //       if (data['result'] == 1 && data['data'] != null) {
  //         final List<dynamic> fetchedData = data['data'];
  //
  //         // Update the notifications list
  //         setState(() {
  //           notificationsList.addAll(
  //               fetchedData.map((item) => Map<String, dynamic>.from(item)));
  //         });
  //
  //         // Handle pagination (if provided)
  //         if (data.containsKey('pagination')) {
  //           final pagination = data['pagination'];
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
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //               content: Text(data['message'] ?? 'No data found',
  //                   style: Theme.of(context)
  //                       .textTheme
  //                       .displayMedium!
  //                       .copyWith(color: AppColors.white))),
  //         );
  //       }
  //     } else {
  //       // Handle HTTP error responses
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error: ${response.reasonPhrase}')),
  //       );
  //     }
  //   } catch (e) {
  //     log('Error: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('An unexpected error occurred.')),
  //     );
  //   } finally {
  //     // Reset loading states
  //     setState(() {
  //       isLoading = false;
  //       isPaginationLoading = false;
  //     });
  //   }
  // }

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
    print('selectedLangCode: $langCode');

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
    return WillPopScope(
      onWillPop: () async {
        widget.onBack();

        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
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
                  translate('Notification'),
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
        backgroundColor: Colors.white,
        body: isLoading // Show CircularProgressIndicator while loading data
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.colorPrimary,
                ),
              )
            : notificationsList.isEmpty // Check if productsList is empty
                ? Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 22),
                        Text(
                          'No Data Available',
                          style: CustomTextStyle.GraphikMedium(
                              20, AppColors.black),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    controller: _scrollController,
                    itemCount: notificationsList.length +
                        (isPaginationLoading ? 1 : 0),
                    // Add 1 for loading indicator if needed

                    itemBuilder: (context, index) {
                      var notification = notificationsList[index];

                      return NotificationCard(
                        product_id: notification['offer_ID'].toString(),
                        image: notification['image'],
                        title: notification['title'],
                        description: notification['message'],
                        date: notification[
                            'added_on'], // Replace with actual date if available
                      );
                    },
                  ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String product_id;
  final String image;
  final String title;
  final String description;
  final String date;

  const NotificationCard({
    required this.product_id,
    required this.image,
    required this.title,
    required this.description,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: AppColors.textFieldBorderColor,
            width: 1,
          )),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image == '') ...[
              Image.network(
                image,
                height: 150,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
            ],
            Text(title,
                style: CustomTextStyle.GraphikMedium(15, AppColors.black)),
            const SizedBox(height: 4),
            Text(description,
                style: CustomTextStyle.GraphikRegular(
                    12, AppColors.secondTextColor)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date,
                    style: CustomTextStyle.GraphikMedium(
                        10, AppColors.secondTextColor)),

                //if(product_id.isNotEmpty)
                Visibility(
                  visible: product_id
                      .isNotEmpty,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(NotificationsDetailsPage(
                        onBack: () {},
                        title: title,
                        description: description,
                        image: image,
                        date: date,
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.colorPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                    ),
                    child: Text('View More',
                        style:
                            CustomTextStyle.GraphikMedium(12, AppColors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
