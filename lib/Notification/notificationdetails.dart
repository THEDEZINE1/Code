import 'package:share_plus/share_plus.dart';
import 'dart:io' as io;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../CustomeTextStyle/custometextstyle.dart';
import '../theme/AppTheme.dart';
import 'imgfullscreen.dart';

class NotificationsDetailsPage extends StatefulWidget {
  final VoidCallback onBack;
  final String title;
  final String description;
  final String date;
  final String image;

  const NotificationsDetailsPage({
    Key? key,
    required this.onBack,
    required this.title,
    required this.description,
    required this.date,
    required this.image,
  }) : super(key: key);

  @override
  _NotificationsDetailsPageState createState() =>
      _NotificationsDetailsPageState();
}

class _NotificationsDetailsPageState extends State<NotificationsDetailsPage> {
  bool isLoading = false;
  bool hasMoreData = true;
  List<Map<String, dynamic>> notificationsList = [];
  String? userID;
  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('userID') ?? '';
    });
  }

  // Future<void> _shareNotificationdataByIndex(
  //     BuildContext context, int index) async {
  //   if (notificationsList.isEmpty ||
  //       index < 0 ||
  //       index >= notificationsList.length) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Invalid notification index')),
  //     );
  //     return;
  //   }
  //
  //   io.File? tempFile;
  //
  //   try {
  //     final notification = notificationsList[index];
  //
  //     final String title = notification['title'] ?? 'No Title';
  //     final String message = notification['message'] ?? 'No message available';
  //     final String? imageUrl = notification['image'];
  //
  //     final String shareText = '''
  //   🔔 $title
  //   📢 $message
  //    '''
  //         .trim();
  //
  //     if (imageUrl != null && Uri.tryParse(imageUrl)?.isAbsolute == true) {
  //       final response = await http.get(Uri.parse(imageUrl));
  //       if (response.statusCode == 200) {
  //         final tempDir = await getTemporaryDirectory();
  //         tempFile = io.File('${tempDir.path}/notif_$index.jpg');
  //         await tempFile.writeAsBytes(response.bodyBytes);
  //
  //         await Share.shareXFiles(
  //           [XFile(tempFile.path)],
  //           text: shareText,
  //           subject: 'Decont',
  //         );
  //       } else {
  //         await Share.share(shareText);
  //       }
  //     } else {
  //       await Share.share(shareText);
  //     }
  //   } catch (e) {
  //     debugPrint('Share error: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Failed to share notification')),
  //     );
  //   } finally {
  //     if (tempFile != null && await tempFile.exists()) {
  //       await tempFile.delete();
  //     }
  //   }
  // }

  Future<void> _shareNotification({
    required BuildContext context,
    required String title,
    required String message,
    required String? imageUrl,
  }) async {
    io.File? tempFile;

    try {
      final String shareText = '''
🔔 $title
📢 $message
    '''
          .trim();

      if (imageUrl != null && Uri.tryParse(imageUrl)?.isAbsolute == true) {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          tempFile = io.File('${tempDir.path}/notif.jpg');
          await tempFile.writeAsBytes(response.bodyBytes);

          await Share.shareXFiles(
            [XFile(tempFile.path)],
            text: shareText,
            subject: 'Decont',
          );
        } else {
          debugPrint(
              'Image download failed with status: ${response.statusCode}');
          await Share.share(shareText);
        }
      } else {
        debugPrint('Image URL is null or invalid');
        await Share.share(shareText);
      }
    } catch (e) {
      debugPrint('Share error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to share notification')),
      );
    } finally {
      if (tempFile != null && await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

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
                backgroundColor: AppColors.colorPrimary,
                elevation: 0.0,
                title: Text(
                  'Notification details',
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
            : widget.title.isEmpty
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
                : Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: NotificationCard(
                      title: widget.title,
                      description: widget.description,
                      date: widget.date,
                      image: widget.image,
                      onShareNotification: (context) => _shareNotification(
                        context: context,
                        title: widget.title,
                        message: widget.description,
                        imageUrl: widget.image,
                      ),
                    ),
                  ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final String date;
  final Future<void> Function(BuildContext) onShareNotification;

  const NotificationCard({
    required this.image,
    required this.title,
    required this.description,
    required this.date,
    required this.onShareNotification,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,

      decoration: BoxDecoration(
        color: AppTheme().mainBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(10),

      //  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image.isNotEmpty)
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
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => Center(
                  child: SizedBox(
                    height: 150,
                    child: Image.asset(
                      'assets/decont_splash_screen_images/decont_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 7, 4, 2),
            child: Text(
              title,
              style: CustomTextStyle.GraphikMedium(18, AppTheme().blackColor),
            ),
          ),
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
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
            child: Row(
              children: [
                SizedBox(
                  width: 75,
                  height: 25,
                  child: ElevatedButton(
                    onPressed: () => onShareNotification(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.colorPrimary,
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
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 6, 2),
                  child: Text(
                    date,
                    style: CustomTextStyle.GraphikRegular(
                        14, AppTheme().thirdTextColor),
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
