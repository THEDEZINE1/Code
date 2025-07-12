
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../CustomeTextStyle/custometextstyle.dart';

import '../theme/AppTheme.dart';
import 'imgfullscreen.dart';

class NotificationsPage extends StatefulWidget {
  final VoidCallback onBack;

  NotificationsPage({required this.onBack});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool isLoading = false;
  bool hasMoreData = true;
  List<Map<String, dynamic>> notificationsList =
      []; // Store notifications as a list of maps
  String? userID;
  @override
  void initState() {
    super.initState();
  }

//   Future<void> _shareNotificationdataByIndex(
//       BuildContext context, int index) async {
//     if (notificationsList.isEmpty ||
//         index < 0 ||
//         index >= notificationsList.length) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Invalid notification index')),
//       );
//       return;
//     }
//
//     io.File? tempFile;
//
//     try {
//       final notification = notificationsList[index];
//
//       final String title = notification['title'] ?? 'No Title';
//       final String message = notification['message'] ?? 'No message available';
//       final String? imageUrl = notification['image'];
//
//       final String shareText = '''
// 🔔 $title
// 📢 $message
// '''
//           .trim();
//
//       if (imageUrl != null && Uri.tryParse(imageUrl)?.isAbsolute == true) {
//         final response = await http.get(Uri.parse(imageUrl));
//         if (response.statusCode == 200) {
//           final tempDir = await getTemporaryDirectory();
//           tempFile = io.File('${tempDir.path}/notif_$index.jpg');
//           await tempFile.writeAsBytes(response.bodyBytes);
//
//           await Share.shareXFiles(
//             [XFile(tempFile.path)],
//             text: shareText,
//             subject: 'Family Farmer',
//           );
//         } else {
//           await Share.share(shareText);
//         }
//       } else {
//         await Share.share(shareText);
//       }
//     } catch (e) {
//       debugPrint('Share error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to share notification')),
//       );
//     } finally {
//       if (tempFile != null && await tempFile.exists()) {
//         await tempFile.delete();
//       }
//     }
//   }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Call the onBack callback to set the index to 0
        widget.onBack();
        // Pop the current screen from the navigation stack
        Navigator.pop(context);
        return false; // Prevents the default back button behavior (returning to previous screen)
      },
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
                    return IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: AppTheme().whiteColor,
                      ),
                      onPressed: () => Navigator.pop(context),
                    );
                  },
                ),
                backgroundColor: AppTheme().primaryColor,
                elevation: 0.0,
                title: Text(
                  'Notifications',
                  style:
                      CustomTextStyle.GraphikMedium(16, AppTheme().whiteColor),
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
            ? Center(
                child: CircularProgressIndicator(
                  color: AppTheme().primaryColor,
                ),
              )
            : notificationsList.isEmpty // Check if productsList is empty
                ? Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        SvgPicture.asset(
                          'assets/icons/no_cart.svg',
                          width: 250, // Set the width of the SVG icon
                          height: 250, // Set the height of the SVG icon
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No Data Available',
                          style: CustomTextStyle.GraphikMedium(
                              18, AppTheme().blackColor),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: notificationsList.length,
                    // Add 1 for loading indicator if needed

                    itemBuilder: (context, index) {
                      var notification = notificationsList[index];

                      return NotificationCard(
                        product_id: notification['product'].toString(),
                        offer: notification['offer'].toString(),
                        image: notification['image'],
                        title: notification['title'],
                        description: notification['message'],
                        date: notification['added_on'],
                      );
                      //   onShareNotification: (context) =>
                      //        _shareNotificationdataByIndex(context, index),
                      // );
                    },
                  ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String product_id;
  final String offer;
  final String image;
  final String title;
  final String description;
  final String date;
  // final Future<void> Function(BuildContext) onShareNotification;

  NotificationCard({
    required this.product_id,
    required this.offer,
    required this.image,
    required this.title,
    required this.description,
    required this.date,
    // required this.onShareNotification
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Progress Indicator
          Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(ImageViewScreenNotification(
                    productAppbarTitle: 'Notification',
                    initialIndex: 0,
                    galleryItems: [image],
                  ));
                },
                child: CachedNetworkImage(
                  imageUrl: image,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 7, 4, 2),
            child: Text(
              title,
              style: CustomTextStyle.GraphikMedium(18, AppTheme().blackColor),
            ),
          ),
          // Description
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
            child: Text(
              description,
              style: CustomTextStyle.GraphikRegular(
                  13, AppTheme().secondTextColor),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Dates
          // Buy Now and Share Row
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
            child: Row(
              children: [
                SizedBox(
                  width: 75,
                  height: 25,
                  child: ElevatedButton(
                    onPressed: () {
                      //  onShareNotification(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme().primaryColor,
                      padding: EdgeInsets.zero,
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                    child: Text(
                      'Share',
                      style: CustomTextStyle.GraphikMedium(
                          14, AppTheme().whiteColor),
                    ),
                  ),
                ),

                /*Spacer(),
                Text(
                  'SHARE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700], // Replace with droverbackground color
                  ),
                ),*/
                Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 6, 2),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      date, // Replace with date text
                      style: CustomTextStyle.GraphikRegular(
                          14, AppTheme().thirdTextColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
